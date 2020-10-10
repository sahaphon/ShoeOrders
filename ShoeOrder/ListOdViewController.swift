//
//  ListOdViewController.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 8/1/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit
import Alamofire
import SQLite3

class ListOdViewController: UIViewController, UISearchBarDelegate
{
    @IBOutlet weak var SearchBar: UISearchBar!
    @IBOutlet weak var myTable: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblPullsta: UILabel!
    @IBOutlet weak var lblPullTime: UILabel!
    
    
    var od = [ListOd]()
    var searchActive : Bool = false
    
    var db: OpaquePointer?
    let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("order.sqlite")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /* Setup delegates */
        SearchBar.delegate = self
        
        lblTitle.text = CustomerViewController.GlobalValiable.desc
        
        lblPullsta.text = ""
        lblPullTime.text = ""
        LoadDataStatus()
        LoadOdShoenw()
    }
    
    func LoadOdShoenw()
    {
        //ตรวจสอบการเชื่อมต่อ Internet
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.isConnectedToNetwork()
        {
            //ProgressBar
            let progressHUD = ProgressHUD(text: "Please wait..")
            self.view.addSubview(progressHUD)
            
            //URL
            //let URL_USER_LOGIN = "http://consign-ios.adda.co.th/KeyOrders/getMainOD.php"
            //let URL_USER_LOGIN = "http://111.223.38.24:3000/cal_mainod"
            //let URL_USER_LOGIN = "http://111.223.38.24:3000/cal_test"     //ตัวทดสอบ v.1.0.13 store procedure TEST
            let URL_USER_LOGIN = "http://111.223.38.24:3000/cal_saleorder"  //ver 1.0.14  store procedure cal_sale_order_status
            
            //Set Parameter
            let parameters : Parameters=[
                "sale": CustomerViewController.GlobalValiable.saleid,
                "code": CustomerViewController.GlobalValiable.myCode
            ]
            
            Alamofire.request(URL_USER_LOGIN, method: .get, parameters: parameters).responseJSON
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
                                    //let Confm =  personDict["stat"] as! String
                                    let Crterm =  personDict["cr_term"] as! Int
                                    let Prodcode =  personDict["prodcode"] as! String
                                    let Pono =  personDict["pono"] as! String
                                    let Remark =  personDict["remark"] as! String
                                    
                                    
                                    self.od.append(ListOd(od_status: od_sta, date: Date, orderno: Orderno, confirm: "Y", crterm: Crterm, prodcode: Prodcode, pono: Pono, remark: Remark))
                                    
                                    let insert = "INSERT INTO od (od_status, date, orderno, confirm, crterm, prodcode, pono, remark)" + "VALUES (?,?,?,?,?,?,?,?);"
                                    var statement: OpaquePointer?
                                    
                                    //preparing the query
                                    if sqlite3_prepare_v2(db, insert, -1, &statement, nil) == SQLITE_OK
                                    {
                                        sqlite3_bind_text(statement, 1, od_sta, -1, SQLITE_TRANSIENT)
                                        sqlite3_bind_text(statement, 2, Date, -1, SQLITE_TRANSIENT)
                                        sqlite3_bind_text(statement, 3, Orderno, -1, SQLITE_TRANSIENT)
                                        sqlite3_bind_text(statement, 4, "Y", -1, SQLITE_TRANSIENT)
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
                            
                            self.od.removeAll()
                            self.myTable.reloadData()
                            
                            let alert = UIAlertController(title: "Not found data!", message: "ไม่พบข้อมูล กรุณาลองใหม่อีกครั้ง..", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "ตกลง", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        }
                        
                    }
            }
        }
        else    //หากไม่มีการต่อ Internet
        {
            if let delegate = UIApplication.shared.delegate as? AppDelegate
            {
                let storyboard : UIStoryboard? = UIStoryboard(name: "Main", bundle: nil)
                let rootController = storyboard!.instantiateViewController(withIdentifier: "internet")
                delegate.window?.rootViewController = rootController
            }
        }
    }
    
    func getFormattedDate(date: Date, format: String) -> String
    {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: date)
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
            
            let queryString = String(format:"SELECT * FROM od ORDER BY orderno DESC")
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
                self.od.append(ListOd(od_status: Od_stat, date: Date, orderno: Orderno, confirm: Conf, crterm: Cr, prodcode: Prod, pono: Po, remark: Rem))
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
    
    @IBAction func btnAdd(_ sender: Any)
    {
        if let delegate = UIApplication.shared.delegate as? AppDelegate
        {
            let storyboard : UIStoryboard? = UIStoryboard(name: "Main", bundle: nil)
            let rootController = storyboard!.instantiateViewController(withIdentifier: "Order")
            delegate.window?.rootViewController = rootController
        }
    }
    
    @IBAction func btnInvoice(_ sender: Any)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.isConnectedToNetwork()
        {
            let view_inv = self.storyboard!.instantiateViewController(withIdentifier: "inv30") as! Invoice30ViewController
            let navController = UINavigationController(rootViewController: view_inv)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated:true, completion: nil)
        }
        else
        {
            if let delegate = UIApplication.shared.delegate as? AppDelegate
            {
                let storyboard : UIStoryboard? = UIStoryboard(name: "Main", bundle: nil)
                let rootController = storyboard!.instantiateViewController(withIdentifier: "internet")
                delegate.window?.rootViewController = rootController
            }
        }
    }
    
    
    @IBAction func btnOd(_ sender: Any)
    {
        LoadDataStatus()
        LoadOdShoenw()
    }
    
    @IBAction func btnOd45(_ sender: Any)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.isConnectedToNetwork()
        {
            let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "ODNotSend") as! ODNotSendViewController
            let navController = UINavigationController(rootViewController: VC1)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated:true, completion: nil)
        }
        else
        {
            print("Internet Connection not Available!")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let chkView = storyboard.instantiateViewController(withIdentifier: "internet") as! CheckIntenetViewController
            let navController = UINavigationController(rootViewController: chkView)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated:true, completion: nil)
        }
    }
    
    @IBAction func btnBack(_ sender: Any)
    {
        CustomerViewController.GlobalValiable.myCode = ""
        CustomerViewController.GlobalValiable.desc = ""
        CustomerViewController.GlobalValiable.disc = 0
        CustomerViewController.GlobalValiable.cr_term = 0
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate
        {
            let storyboard : UIStoryboard? = UIStoryboard(name: "Main", bundle: nil)
            let rootController = storyboard!.instantiateViewController(withIdentifier: "Tab")
            delegate.window?.rootViewController = rootController
        }
    
    }
    
    func LoadDataStatus()
    {
        let URL_USER_LOGIN = "http://111.223.38.24:3000/getodstatus"
        
        //print("ค่าที่ส่งไป = ", CustomerViewController.GlobalValiable.myCode)
        //making a post request
        Alamofire.request(URL_USER_LOGIN, method: .get, parameters: nil).responseJSON
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
                        //var res:String = ""
                        var status:String = ""
                        
                        for personDict in array
                        {
                            status = (personDict["pull_sta"] as! String).trimmingCharacters(in: .whitespacesAndNewlines)
                            if (status == "1")
                            {
                                self.lblPullsta.text = "ดึงข้อมูลสำเร็จ"
                            }
                            else
                            {
                                self.lblPullsta.text = "อยู่ระหว่างดึงข้อมูล"
                            }
                            
                            self.lblPullTime.text = (personDict["time"] as! String).trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                    }
                    
                    ProgressIndicator.hide()
                }
        }
    }
    
    func ClearData()
    {
        if sqlite3_open(self.fileURL.path, &self.db) != SQLITE_OK
        {
            print("error opening database")
        }
        else
        {
            //ลบข้อมูลเก่าออกก่อน
            let deleteStatementStirng = String(format:"DELETE FROM odmst WHERE code = '%@'", CustomerViewController.GlobalValiable.myCode)
            
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
            sqlite3_close(self.db)
        }
    }
    
    //เหตุการณ์ ช่องค้นหาได้รับ focus
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        searchActive = true
    }
    
    //เหตุการณ์กดปุ่ม search
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchActive = false
        print("คลิก")
        self.SearchBar.endEditing(true)
    }
    
    //เหตุการณ์ กดซ่อนคีย์บอร์ด
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar)
    {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        searchActive = false
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
                self.od.append(ListOd(od_status: Od_stat, date: Date, orderno: Orderno, confirm: Conf, crterm: Cr, prodcode: Prod, pono: Po, remark: Rem))
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
    
    override func viewWillDisappear(_ animated: Bool) {
            //print("กำลังจะหายไป")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //print("เมื่อวิวถูกเรียกขึ้นมา")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        //print("หายไปแล้ว")
    }
}

extension ListOdViewController: UITableViewDataSource, UITableViewDelegate
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return od.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let myOd = od[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ListOdCell
        cell.viewData(ListOd: myOd)
        cell.backgroundColor = UIColor.white
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let _prod = od[indexPath.row]
        CustomerViewController.GlobalValiable.od = _prod.orderno!
        CustomerViewController.GlobalValiable.fromView = "ListOD"
        
        let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "OdTrans") as! OdTransViewController
        let navController = UINavigationController(rootViewController: VC1)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated:true, completion: nil)
        
        let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        selectedCell.contentView.backgroundColor = UIColor.lightText  //lightText
    }
}
