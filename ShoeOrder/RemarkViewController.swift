//
//  RemarkViewController.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 1/8/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit
import Alamofire
import SQLite3

class RemarkViewController: UIViewController, UISearchBarDelegate {
    
    var db: OpaquePointer?
    //var cr_term : [Int] = [Int]()
    var crterm = 0
    
    //Create SQLite
    let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("order.sqlite")

    var remarks : [String] = [String]()
    
    //ตัวแปรสำหรับกรองข้อมูล
    var searchActive : Bool = false
    @IBOutlet weak var txtSearch: UISearchBar!
    @IBOutlet var picRmk: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        picRmk.dataSource = self
        picRmk.delegate = self
        
        /* Setup delegates */
        txtSearch.delegate = self
        
        remarks.removeAll()    //Clear dictionary
        //getRemark()
        LoadRmkData()
    }
    
    @IBAction func btnCancel(_ sender: Any)
    {
        CustomerViewController.GlobalValiable.remark = ""
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func btnAdd(_ sender: Any)
    {
        let alertController = UIAlertController(title: "เพิ่มหมายเหตุ", message: "", preferredStyle: UIAlertController.Style.alert)
        
        let saveAction = UIAlertAction(title: "บันทึก", style: UIAlertAction.Style.default, handler: { alert -> Void in
            let firstTextField = alertController.textFields![0] as UITextField
            
            if (firstTextField.text!.count > 0)
            {
                //print("มีข้อมูล")
                self.addRemark(txtRmk: firstTextField.text!)
                self.filterRmk(searchTxt: "")  //แสดงข้อมูลใหม่
            }
        })
        
        let cancelAction = UIAlertAction(title: "ปิด", style: UIAlertAction.Style.default, handler: {
            (action : UIAlertAction!) -> Void in })
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "กรอกข้อมูล"
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func addRemark(txtRmk : String)
    {
        if sqlite3_open(self.fileURL.path, &self.db) != SQLITE_OK
        {
            print("error opening database")
        }
        else
        {
            //บันทึกข้อมูลชุดใหม่
            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        
            let update = "INSERT INTO remarks (remark, type)" + "VALUES (?,?);"
            var statement: OpaquePointer?
        
            //preparing the query
            if sqlite3_prepare_v2(self.db, update, -1, &statement, nil) == SQLITE_OK
            {
                sqlite3_bind_text(statement, 1, txtRmk, -1, SQLITE_TRANSIENT)
                sqlite3_bind_text(statement, 2, "1", -1, SQLITE_TRANSIENT)  //1 แทน พนักงานขาย Add เองเพื่อครั้งหน้าไม่ต้องพิมพ์อีก
                
                //executing the query to insert values
                if sqlite3_step(statement) != SQLITE_DONE
                {
                    let errmsg = String(cString: sqlite3_errmsg(self.db)!)
                    print("failure inserting armstr: \(errmsg)")
                    return
                }
            }
            else
            {
                let errmsg = String(cString: sqlite3_errmsg(self.db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
        
            sqlite3_finalize(statement)
            sqlite3_close(self.db)
        }
    }
    
    func LoadRmkData()
    {
        let progressHUD = ProgressHUD(text: "Please wait..")
        self.view.addSubview(progressHUD)
        
        let URLS = "http://consign-ios.adda.co.th/KeyOrders/getItem.php"
        
        Alamofire.request(URLS, method: .post, parameters: nil).responseJSON
            {
                response in
                
                if let array = response.result.value as? [[String: Any]]     //หากมีข้อมูล
                {
                    //Check nil data
                    var blnHaveData = false
                    for _ in array  //วนลูปเช็คค่าที่ส่งมา
                    {
                        blnHaveData = true
                        break
                    }
                    
                    //เช็คสิทธิการเข้าใช้งาน
                    if (blnHaveData)
                    {
                        if sqlite3_open(self.fileURL.path, &self.db) != SQLITE_OK
                        {
                            print("error opening database")
                        }
                        else
                        {
                            //ลบข้อมูลเก่าออกก่อน
                            let deleteStatementStirng = "DELETE FROM remarks WHERE type = '0'"
                            var deleteStatement: OpaquePointer? = nil
                            
                            if sqlite3_prepare_v2(self.db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK
                            {
                                if sqlite3_step(deleteStatement) != SQLITE_DONE
                                {
                                    print("Could not delete row.")
                                }
                            } else
                            {
                                print("DELETE statement could not be prepared")
                            }
                            
                            sqlite3_finalize(deleteStatement)
                            
                            //บันทึกข้อมูลชุดใหม่
                            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
                            
                            for personDict in array
                            {
                                let update = "INSERT INTO remarks (remark, type)" + "VALUES (?,?);"
                                var statement: OpaquePointer?
                                
                                //preparing the query
                                if sqlite3_prepare_v2(self.db, update, -1, &statement, nil) == SQLITE_OK
                                {
                                    let remark = (personDict["rmk"] as! String).trimmingCharacters(in: .whitespacesAndNewlines)
                                    sqlite3_bind_text(statement, 1, remark, -1, SQLITE_TRANSIENT)
                                    sqlite3_bind_text(statement, 2, "0", -1, SQLITE_TRANSIENT)  //0 แทนข้อมูลที่มาจาก server
                                    
                                    //executing the query to insert values
                                    if sqlite3_step(statement) != SQLITE_DONE
                                    {
                                        let errmsg = String(cString: sqlite3_errmsg(self.db)!)
                                        print("failure inserting armstr: \(errmsg)")
                                        return
                                    }
                                }
                                else
                                {
                                    let errmsg = String(cString: sqlite3_errmsg(self.db)!)
                                    print("error preparing insert: \(errmsg)")
                                    return
                                }
                                
                                sqlite3_finalize(statement)
                            }
                            
                            sqlite3_close(self.db)
                        }
                        
                        //self.getRemark()
                        self.filterRmk(searchTxt: "")  //โหดลข้อมูลจาก SQLite ใหม่
                    }
                }
                
            //ProgressIndicator.hide()
            progressHUD.hide()
        }
    }
    
    func filterRmk(searchTxt:String)
    {
        //Open db
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            var queryString = ""
            
            if (searchTxt == "")
            {
                queryString = String(format:"SELECT remark FROM remarks ORDER BY remark")
            }
            else
            {
                queryString = String(format:"SELECT remark FROM remarks WHERE remark LIKE '%%%@%%' ", searchTxt)
            }
            
            //print(queryString)
            //statement pointer
            var stmt:OpaquePointer?
            
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            
            //Clear all dictionary
            remarks.removeAll()
            
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                let _remark = String(cString: sqlite3_column_text(stmt, 0))
                
                //adding values to list
                self.remarks.append(String(_remark))
            }
            
            self.picRmk.reloadAllComponents()
            
            sqlite3_finalize(stmt)
            sqlite3_close(db)
        }
        else
        {
            print("error opening database")
        }
    }
    
    @IBAction func btnOk(_ sender: Any)
    {
        if((self.presentingViewController) != nil)
        {
            if (remarks.count > 0 && CustomerViewController.GlobalValiable.remark.count == 0)
            {
                CustomerViewController.GlobalValiable.remark = String(remarks[0])
            }
            
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    func getRemark()
    {
        let progressHUD = ProgressHUD(text: "Please wait..")
        self.view.addSubview(progressHUD)
        
        //URL
        let URL_USER_LOGIN = "http://consign-ios.adda.co.th/KeyOrders/getItem.php"
        
        //making a post request
        Alamofire.request(URL_USER_LOGIN, method: .post, parameters: nil).responseJSON
        {
            response in
                
                if let array = response.result.value as? [[String: Any]] //หากมีข้อมูล
                {
                    //Check nil data
                    var blnHaveData = false
                    for _ in array  //วนลูปเช็คค่าที่ส่งมา
                    {
                        blnHaveData = true
                        break
                    }
                    
                    if (blnHaveData)
                    {
                        var remark:String = ""
                        self.remarks.removeAll()    //Clear all data
                        
                        for personDict in array
                        {
                            remark = (personDict["rmk"] as! String).trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            //Add data to dictionary
                            self.remarks.append(String(remark))
                        }
                    }
                    
                    self.picRmk.reloadAllComponents()
                    //ProgressIndicator.hide()
                    progressHUD.hide()
                }
        }
    }
    
    //เหตุการณ์ ช่องค้นหาได้รับ focus
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        searchActive = true
        print("กำลังค้นหา")
    }
    
    //เหตุการณ์กดปุ่ม search
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchActive = false
        print("คลิก")
        self.txtSearch.endEditing(true)
    }
    
    //เหตุการณ์ กดซ่อนคีย์บอร์ด
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar)
    {
        searchActive = false
        print("สิ้นสุดการค้นหา")
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        searchActive = false
        print("cancel")
    }
    
    //เหตุการณ์ กรอกตัวอักษรใดๆ ในช่องค้นหา
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if (searchText != "")
        {
            filterRmk(searchTxt: searchText)
        }
        else
        {
            filterRmk(searchTxt: "")
        }
    }
}

extension RemarkViewController: UIPickerViewDelegate, UIPickerViewDataSource
{
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return remarks.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return String(remarks[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "PSL Display", size:30)
            pickerLabel?.textAlignment = .center
        }
        
        pickerLabel?.text = String(remarks[row])
        pickerLabel?.textColor = UIColor.black
        
        return pickerLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if (String(remarks[row]) != "")
        {
            CustomerViewController.GlobalValiable.remark = remarks[row]
        }
        else
        {
            print("เป็นค่่าว่าง")
        }
    }
}
