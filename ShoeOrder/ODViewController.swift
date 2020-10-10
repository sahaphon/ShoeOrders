//
//  ODViewController.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 2/15/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit
import Alamofire
import SQLite3

class ODViewController: UIViewController, UISearchBarDelegate
{
    @IBOutlet weak var SerchBar: UISearchBar!
    @IBOutlet weak var myTable: UITableView!
    
    var od = [OdShoenw]()
    //ตัวแปรสำหรับกรองข้อมูล
    var searchActive : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Setup delegates */
        SerchBar.delegate = self
        
        self.title = CustomerViewController.GlobalValiable.desc
    
        //Set barbuttonItem font
        UIBarButtonItem.appearance().setTitleTextAttributes(
            [
                NSAttributedString.Key.font : UIFont(name: "PSL Display", size: 28)!,
                NSAttributedString.Key.foregroundColor : UIColor.red,
                ], for: .normal)

        //Set Title font
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "PSL Display", size: 30)!]
        
        LoadData()
    }
    
    func LoadData()
    {
        //ProgressBar
        let progressHUD = ProgressHUD(text: "LOADING...")
        self.view.addSubview(progressHUD)
        
        //URL
        let URL_USER_LOGIN = "http://consign-ios.adda.co.th/KeyOrders/getMainOD.php"
        
        //Set Parameter
        let parameters : Parameters=[
            "sale": CustomerViewController.GlobalValiable.saleid,
            "shop": CustomerViewController.GlobalValiable.myCode
        ]
        
        Alamofire.request(URL_USER_LOGIN, method: .post, parameters: parameters).responseJSON
        {
            response in
            //print(response)
            
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
                    //กำหนด พาร์ท db
                    let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                        .appendingPathComponent("order.sqlite")
                    
                    var db: OpaquePointer?
                    
                    if sqlite3_open(fileURL.path, &db) != SQLITE_OK
                    {
                        print("error opening database")
                    }
                    else
                    {
                        //ลบข้อมูลเก่าออกก่อน
                        let deleteStatementStirng = "DELETE FROM od"
                        var deleteStatement: OpaquePointer? = nil
                        
                        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK
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
                        
                        self.od.removeAll()
                        
                        for personDict in array
                        {
                            var od_sta = personDict["order_status"] as! String
                            if (od_sta == "green")
                            {
                                od_sta = "G.png"
                            }
                            else if (od_sta == "yellow")
                            {
                                od_sta = "Y.png"
                            }
                            else
                            {
                                od_sta = "R.png"
                            }
                            
                            let Date =  personDict["date"] as! String
                            let Orderno =  personDict["orderno"] as! String
                            let Confm =  personDict["stat"] as! String
                            let Crterm =  personDict["cr_term"] as! Int
                            let Prodcode =  personDict["prodcode"] as! String
                            let Pono =  personDict["pono"] as! String
                            let Remark =  personDict["remark"] as! String
                            
                            self.od.append(OdShoenw(od_status: od_sta, date: Date, orderno: Orderno, confirm: Confm, crterm: Crterm, prodcode: Prodcode, pono: Pono, remark: Remark))
                            
                            
                            //***************************
                            
                            let insert = "INSERT INTO od (od_status, date, orderno, confirm, crterm, prodcode, pono, remark)" + "VALUES (?,?,?,?,?,?,?,?);"
                            var statement: OpaquePointer?
                            
                            //preparing the query
                            if sqlite3_prepare_v2(db, insert, -1, &statement, nil) == SQLITE_OK
                            {
                                sqlite3_bind_text(statement, 1, od_sta, -1, SQLITE_TRANSIENT)
                                sqlite3_bind_text(statement, 2, Date, -1, SQLITE_TRANSIENT)
                                sqlite3_bind_text(statement, 3, Orderno, -1, SQLITE_TRANSIENT)
                                sqlite3_bind_text(statement, 4, Confm, -1, SQLITE_TRANSIENT)
                                sqlite3_bind_int(statement, 5, Int32(Crterm))
                                sqlite3_bind_text(statement, 6, Prodcode, -1, SQLITE_TRANSIENT)
                                sqlite3_bind_text(statement, 7, Pono, -1, SQLITE_TRANSIENT)
                                sqlite3_bind_text(statement, 8, Remark, -1, SQLITE_TRANSIENT)
                                
                                //executing the query to insert values
                                if sqlite3_step(statement) != SQLITE_DONE
                                {
                                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                                    print("failure inserting armstr: \(errmsg)")
                                    return
                                }
                                
                            }
                            else
                            {
                                let errmsg = String(cString: sqlite3_errmsg(db)!)
                                print("error preparing insert: \(errmsg)")
                                return
                                
                            }
                            
                            sqlite3_finalize(statement)
                        }
                        
                    } // open DB
                    
                    sqlite3_close(db)
                    
                    //ProgressIndicator.hide()
                    progressHUD.hide()
                    self.query()
                    //self.myTable.reloadData()
                }
                else
                {
                    progressHUD.hide()
                    ProgressIndicator.hide()
                    //Alert
                    let alert = UIAlertController(title: "Not found data!", message: "ไม่พบข้อมูลในระบบ กรุณาลองใหม่อีกครั้ง..", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "ตกลง", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
                
            }
        }
    }
    
    @IBAction func btnRefresh(_ sender: Any)
    {
        od.removeAll()
        self.myTable.reloadData()
        LoadData()
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
        self.SerchBar.endEditing(true)
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
            filter(searchTxt: searchText)
        }
        else
        {
            self.query()
        }
    }
    
    func query()
    {
        //กำหนด พาร์ท db
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("order.sqlite")
        
        var db: OpaquePointer?
        
        //Open db
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            //first empty the list of ar
            self.od.removeAll()
            
            let queryString = String(format:"SELECT * FROM od ORDER BY date DESC")
            //print(queryString)
            
            //statement pointer
            var stmt:OpaquePointer?
            
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            //od_status, date, orderno, confirm, crterm, prodcode, pono, remark
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                let Od_stat = String(cString: sqlite3_column_text(stmt, 0))
                let Date = String(cString: sqlite3_column_text(stmt, 1))
                let Orderno = String(cString: sqlite3_column_text(stmt, 2))
                let Conf = String(cString: sqlite3_column_text(stmt, 3))
                let Cr = Int(sqlite3_column_int(stmt, 4))
                let Prod = String(cString: sqlite3_column_text(stmt, 5))
                let Po = String(cString: sqlite3_column_text(stmt, 6))
                let Rem = String(cString: sqlite3_column_text(stmt, 7))
                
                
                //adding values to list
                self.od.append(OdShoenw(od_status: Od_stat, date: Date, orderno: Orderno, confirm: Conf, crterm: Cr, prodcode: Prod, pono: Po, remark: Rem))
            }
            
            self.myTable.reloadData()
            
            sqlite3_finalize(stmt)
            sqlite3_close(db)
        }
        else
        {
            print("error opening database")
        }
    }
    
    func filter(searchTxt:String)
    {
        //กำหนด พาร์ท db
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("order.sqlite")
        
        var db: OpaquePointer?
        
        //Open db
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            //first empty the list of ar
            self.od.removeAll()
            
            let queryString = String(format:"SELECT * FROM od WHERE orderno LIKE '%%%@%%' ORDER BY orderno", searchTxt)
            //print(queryString)
            
            //statement pointer
            var stmt:OpaquePointer?
            
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            //od_status, date, orderno, confirm, crterm, prodcode, pono, remark
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                let Od_stat = String(cString: sqlite3_column_text(stmt, 0))
                let Date = String(cString: sqlite3_column_text(stmt, 1))
                let Orderno = String(cString: sqlite3_column_text(stmt, 2))
                let Conf = String(cString: sqlite3_column_text(stmt, 3))
                let Cr = Int(sqlite3_column_int(stmt, 4))
                let Prod = String(cString: sqlite3_column_text(stmt, 5))
                let Po = String(cString: sqlite3_column_text(stmt, 6))
                let Rem = String(cString: sqlite3_column_text(stmt, 7))
                
                //adding values to list
               self.od.append(OdShoenw(od_status: Od_stat, date: Date, orderno: Orderno, confirm: Conf, crterm: Cr, prodcode: Prod, pono: Po, remark: Rem))
            }
            
            self.myTable.reloadData()
            
            sqlite3_finalize(stmt)
            sqlite3_close(db)
        }
        else
        {
            print("error opening database")
        }
    }
    
    @IBAction func btnBack(_ sender: Any)
    {
        if((self.presentingViewController) != nil)
        {
            self.dismiss(animated: false, completion: nil)
        }
    }
}

extension ODViewController: UITableViewDataSource, UITableViewDelegate
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return od.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let myOd = od[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! OdShoenwCell
        cell.viewData(OdShoenw: myOd)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let _prod = od[indexPath.row]
        CustomerViewController.GlobalValiable.od = _prod.orderno!
    }
}

