//
//  ProdFilterViewController2.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 1/9/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit
import SQLite3
import Alamofire

class ProdFilterViewController2: UIViewController {
    
    var db: OpaquePointer?
    var prod : [String] = [String]()
    
    @IBOutlet weak var lblTitle: UILabel!
    //Create SQLite
    let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("order.sqlite")
    
    @IBOutlet weak var pickProd: UIPickerView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        CustomerViewController.GlobalValiable.prod = ""  //Clear data
        
        if CustomerViewController.GlobalValiable.pro == 1
        {
            lblTitle.text = "เลือกรุ่น (PROMOTION)"
            lblTitle.backgroundColor = UIColor.yellow
        }
        
        pickProd.dataSource = self
        pickProd.delegate = self
        LoadData()
    }
    
    @IBAction func btnCancel(_ sender: Any)
    {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func btnAccept(_ sender: Any)
    {

        
        if (prod.count > 0)
        {
            //หากเป็นการคีย์ออเดอร์ โปรโมชั่นให้เช็ควันที่เริ่มต้นสิ้นสุดของรุ่นนั้นๆ ให้อยู่ใน length ก่อน
            // if
            
            if (CustomerViewController.GlobalValiable.prod == "")  //เป็นค่า defalse ไม่ต้องกดก็ได้
            {
                CustomerViewController.GlobalValiable.prod = String(prod[0].prefix(7))
            }
            
            //Fetch data find stock planc   edit_date: 01-02-2022
            //เช็คเฉพาะนอกแผนเท่านั้น
            
            let strplan : String = prod[0]
            let strplanArr : [String] = strplan.components(separatedBy: "/")

            // And then to access the individual words:
            let res_strplan : String = strplanArr[1]
            print("====> ", res_strplan);
            
            if (res_strplan == "นอกแผน")
            {
                let progressHUD = ProgressHUD(text: "Checking...")
                self.view.addSubview(progressHUD)
        
                let parameters : Parameters=[
                    "prodcode": String(prod[0].prefix(7)),
                    "npack": String(prod[0]).containsIgnoringCase(find: "Asort") ? "1" : "2"
                ]
            }

            
            print("=> ", String(prod[0].prefix(7)))
            print("=> ", prod[0])
            
            
            if String(prod[0]).containsIgnoringCase(find: "Asort")
            {
                CustomerViewController.GlobalValiable.n_pack = 1
                print("เลือก Asort")
                
                if let menu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "asort") as? AsortOnlyViewController
                {
                    menu.modalPresentationStyle = .fullScreen
                    self.present(menu, animated: true, completion: nil)
                }
            }
            else
            {
                CustomerViewController.GlobalValiable.n_pack = 2
                
                if let menu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "color") as? ColorsViewController
                {
                    menu.modalPresentationStyle = .fullScreen
                    self.present(menu, animated: true, completion: nil)
                }
            }
        }
    }
    
    func LoadData()
    {
        //Open db
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            //first empty array
            prod.removeAll()
            let queryString : String;
            
            //เช็คว่าเลือกจัดรายการหรือไม่ ถ้าจัดรายการจะค้นหาเฉพาะรายการที่อยู่ในช่วงเวลาเท่านั้น
            if CustomerViewController.GlobalValiable.pro == 1
            {
                queryString = String(format:"SELECT SUBSTR(prodcode,4,7) as prod, packtype, type FROM prodlist WHERE prodcode LIKE '%%%@%%' AND n_pack = '%@' AND p_novat <> 0 AND validdate <= '%@' AND (sfixdue <= '%@' AND efixdue >= '%@') GROUP BY prodcode, packtype, type ORDER BY prodcode", CustomerViewController.GlobalValiable.oldprod, String(CustomerViewController.GlobalValiable.n_pack), CustomerViewController.GlobalValiable.sevdate, CustomerViewController.GlobalValiable.sevdate, CustomerViewController.GlobalValiable.sevdate)
                //print("คิวรี่ prodFilter2 ", queryString)
            }
            else
            {
                 queryString = String(format:"SELECT SUBSTR(prodcode,4,7) as prod, packtype, type FROM prodlist WHERE prodcode LIKE '%%%@%%' AND n_pack = '%@' AND p_novat <> 0 AND validdate <= '%@' GROUP BY prodcode, packtype, type ORDER BY prodcode", CustomerViewController.GlobalValiable.oldprod, String(CustomerViewController.GlobalValiable.n_pack), CustomerViewController.GlobalValiable.sevdate)
                //print("คิวรี่ prodFilter2 ", queryString)
            }
                

            
            //statement pointer
            var stmt:OpaquePointer?
            
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing : \(errmsg)")
                return
            }
    
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
               let prod = String(cString: sqlite3_column_text(stmt, 0))
               let pack = String(cString: sqlite3_column_text(stmt, 1))
               let pln = String(cString: sqlite3_column_text(stmt, 2))
                
               self.prod.append(prod + "   " + pack + " / " + pln)
            }
            
            self.pickProd.reloadAllComponents()

            sqlite3_finalize(stmt)
            sqlite3_close(db)
        }
        else
        {
            print("error opening database")
        }
    }
}

extension ProdFilterViewController2: UIPickerViewDelegate, UIPickerViewDataSource
{
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return prod.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return prod[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "PSL Display", size:38)
            pickerLabel?.textAlignment = .center
        }
        
        pickerLabel?.text = prod[row]
        pickerLabel?.textColor = UIColor.blue
        
        return pickerLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        //ถ้าไม่มีการเลื่อน pickerView จะไม่ทำงานใน function นี้
        CustomerViewController.GlobalValiable.prod = String(prod[row].prefix(7))
        
        if String(prod[row]).containsIgnoringCase(find: "Asort")
        {
            CustomerViewController.GlobalValiable.n_pack = 1
        }
        else
        {
            CustomerViewController.GlobalValiable.n_pack = 2
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        //print("viewWillAppear")
        
        CustomerViewController.GlobalValiable.prod = ""
    }
}

//Contain sting
extension String {
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }
    
    //ไม่สนใจพิมพ์เล็กใหญ่
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
}
