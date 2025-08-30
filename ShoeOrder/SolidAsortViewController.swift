//
//  SolidAsortViewController.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 6/27/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit
import Alamofire
import SQLite3

class SolidAsortViewController: UIViewController {

    @IBOutlet weak var lblProd: UILabel!
    @IBOutlet weak var lblColor: UILabel!
    @IBOutlet weak var lblSumQty: UILabel!
    @IBOutlet weak var myTable: UITableView!
    
    var blnInputQty = false
    
    var solidasorts = [SolidAsort]()          //ประกาศตัวแปรของคลาส
    var intRownumber: Int = 0                 //เก็บ Rows ที่กำลังแก้ไข
    
    @IBAction func btnSave(_ sender: Any)
    {
        //ไม่อนุญาตให้ save od แถมอย่างเดียว
        for (value) in solidasorts
        {
            if (value.qty! > 0)
            {
                SaveData(_packsale: value.packcode!, _qty: value.qty!)
            }
        }
        
        if let menu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Keyod") as? TakeOrderViewController
        {
            menu.modalPresentationStyle = .fullScreen
            self.present(menu, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnCancel(_ sender: Any)
    {
        if let menu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Keyod") as? TakeOrderViewController
        {
            menu.modalPresentationStyle = .fullScreen
            self.present(menu, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        showAlert(title: "บันทึก Solid: ", message: CustomerViewController.GlobalValiable.logiCode + " " + CustomerViewController.GlobalValiable.logiName)
//        
//        print(">>>>> logiCode: ", CustomerViewController.GlobalValiable.logiCode)
//        print(">>>>> logiName: ", CustomerViewController.GlobalValiable.logiName)
//        print(">>>>> logisCode: ", CustomerViewController.GlobalValiable.logisCode)
        
        lblProd.text = CustomerViewController.GlobalValiable.prod
        lblColor.text = CustomerViewController.GlobalValiable.color
        self.myTable.delegate = self
        
        PreloadData()
        QueryData()
    }
    
    //หาลำดับรายการใน OD
    func FindNumRec() -> Int?
    {
        var id: Int = 0
        var db: OpaquePointer?
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("order.sqlite")
        
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            let queryString = String(format:"SELECT no FROM odmst WHERE status = '' AND code = '%@' ORDER BY no DESC LIMIT 1", CustomerViewController.GlobalValiable.myCode)
            //print("Query : ", queryString)
            
            //statement pointer
            var stmt:OpaquePointer?
            
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK
            {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing : \(errmsg)")
            }
            
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                id = Int(sqlite3_column_int(stmt, 0))
            }
            
            if id == 0  //กรณีไม่มี od ให้เริ่มรหัสแรก
            {
                id = 1
            }
            else //กรณีมีการคีย์ od บ้างแล้ว
            {
                id = id + 1
            }
            
            sqlite3_finalize(stmt)
            sqlite3_close(db)
        }
        
        return id
    }
    
    
    func getPackno(_packcode: String) -> Int32?
    {
        var IntPackno: Int = 0
        
        var db: OpaquePointer?
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("order.sqlite")
        
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            let queryString = String(format:"SELECT prodcode, n_pack, packcode, packno FROM prodlist WHERE style = '%@' AND packcode = '%@' AND colorcode = '%@'", CustomerViewController.GlobalValiable.prod, _packcode, CustomerViewController.GlobalValiable.colorcode)
//            print("หา packno : ", queryString)
            
            //statement pointer
            var stmt:OpaquePointer?
            
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK
            {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing : \(errmsg)")
            }
            
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                IntPackno = Int(sqlite3_column_int(stmt, 3))
            }
        
            sqlite3_finalize(stmt)
            sqlite3_close(db)
        }
      
        return Int32(IntPackno)
        
    }
    
    func SaveData(_packsale: String, _qty: Int)
    {
        var db: OpaquePointer?
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("order.sqlite")
        
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            
            let queryString = String(format:"SELECT packcode, packdesc, pairs, packsale FROM solidasort WHERE prodcode = '%@' AND packsale = '%@'", "GS-" + CustomerViewController.GlobalValiable.prod, _packsale)
            //print("คิวรี่ : \(queryString)")

            var stmt:OpaquePointer?

            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK
            {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing : \(errmsg)")
            }

            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                let packcode = String(cString: sqlite3_column_text(stmt, 0))
                let packdesc = String(cString: sqlite3_column_text(stmt, 1))
                let pairs = Int(sqlite3_column_int(stmt, 2))
                
                
                //============ Inser data ===========
                let insertSql = "INSERT INTO odmst (status, date, delivery, code, orderno, no, prodcode, n_pack, packcode, sizedesc, colorcode, colordesc, qty, price, amt, packno, pairs, dozen, disc1, pono, tax_rate, vat_type, tax_amt, net_amt, cr_term, saleman, remark, recfirm, incvat, logis_code, logicode, ctrycode, store)" + " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);"
                
                var statement: OpaquePointer?
                if sqlite3_prepare_v2(db, insertSql, -1, &statement, nil) == SQLITE_OK
                {
                    // Create date formatter
                    let date = Date()
                    let dateFormatter: DateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd/MM/yyyy"
                    
                    let numRec = FindNumRec()
                    let intDozen:Int = Int((Int32(pairs) * (Int32(_qty) / 6)) / 12)
//                    var send = CustomerViewController.GlobalValiable.logiCode
//                    send = String(send.prefix(2))
                    
                    sqlite3_bind_text(statement, 1, "", -1, SQLITE_TRANSIENT)
                    sqlite3_bind_text(statement, 2, dateFormatter.string(from: date), -1, SQLITE_TRANSIENT)
                    sqlite3_bind_text(statement, 3, dateFormatter.string(from: date), -1, SQLITE_TRANSIENT)
                    sqlite3_bind_text(statement, 4, CustomerViewController.GlobalValiable.myCode, -1, SQLITE_TRANSIENT)
                    sqlite3_bind_text(statement, 5, "", -1, SQLITE_TRANSIENT)  //ยังไม่กำหนด เลขที่ od จนกว่าจะกดส่งข้อมูล
                    sqlite3_bind_int(statement, 6, Int32(numRec!))
                    sqlite3_bind_text(statement, 7, "GS-" + CustomerViewController.GlobalValiable.prod, -1, SQLITE_TRANSIENT)
                    sqlite3_bind_text(statement, 8, String(CustomerViewController.GlobalValiable.n_pack), -1, SQLITE_TRANSIENT)
                    sqlite3_bind_text(statement, 9, packcode, -1, SQLITE_TRANSIENT)
                    sqlite3_bind_text(statement, 10, packdesc, -1, SQLITE_TRANSIENT)
                    sqlite3_bind_text(statement, 11, CustomerViewController.GlobalValiable.colorcode, -1, SQLITE_TRANSIENT)
                    sqlite3_bind_text(statement, 12, CustomerViewController.GlobalValiable.color, -1, SQLITE_TRANSIENT)
                    sqlite3_bind_int(statement, 13, Int32(pairs) * Int32(_qty) / 6) //เอาจำนวนคู่ในแบบแพคนั้น คูณจำนวนใบแบบแพ็ค solid
                    sqlite3_bind_double(statement, 14, 0)
                    sqlite3_bind_double(statement, 15, 0)
                    sqlite3_bind_int(statement, 16, getPackno(_packcode: packcode)!)
                    sqlite3_bind_int(statement, 17, Int32(pairs))       //เศษโหล
                    sqlite3_bind_int(statement, 18,  Int32(intDozen))  //จำนวนโหล
                    sqlite3_bind_int(statement, 19,  Int32(CustomerViewController.GlobalValiable.disc))  //จำนวนโหล
                    sqlite3_bind_text(statement, 20, "", -1, SQLITE_TRANSIENT)
                    sqlite3_bind_double(statement, 21, 7.00)
                    sqlite3_bind_text(statement, 22, "3", -1, SQLITE_TRANSIENT)
                    sqlite3_bind_double(statement, 23, 0.00)
                    sqlite3_bind_double(statement, 24, 0.00)
                    sqlite3_bind_int(statement, 25,  Int32(CustomerViewController.GlobalValiable.cr_term))  //cr_term
                    sqlite3_bind_text(statement, 26, CustomerViewController.GlobalValiable.saleid, -1, SQLITE_TRANSIENT)
                    sqlite3_bind_text(statement, 27, "", -1, SQLITE_TRANSIENT)
                    sqlite3_bind_int(statement, 28, Int32(CustomerViewController.GlobalValiable.recfirm))  //งานสั่งทำ
                    sqlite3_bind_int(statement, 29, 1)  //incvat
                    sqlite3_bind_text(statement, 30, CustomerViewController.GlobalValiable.logisCode, -1, SQLITE_TRANSIENT) //logis_code
                    sqlite3_bind_text(statement, 31, CustomerViewController.GlobalValiable.logiCode, -1, SQLITE_TRANSIENT)
                    sqlite3_bind_text(statement, 32, "TH", -1, SQLITE_TRANSIENT)
                    sqlite3_bind_text(statement, 33, CustomerViewController.GlobalValiable.free, -1, SQLITE_TRANSIENT)
                 
                    //executing the query to insert values
                    if sqlite3_step(statement) != SQLITE_DONE
                    {
                        let errmsg = String(cString: sqlite3_errmsg(db)!)
                        print("failure Inserting armstr: \(errmsg)")
                        return
                    }
                    
                    sqlite3_finalize(statement)
                }//close if
                else
                {
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("error preparing insert: \(errmsg)")
                    return
                }
                
               
            }//close while loop
            sqlite3_finalize(stmt)
    
          sqlite3_close(db)
        } //close open db
    }
    
    func QueryData()
    {
        var db: OpaquePointer?
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("order.sqlite")
        
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            let queryString = String(format:"select prodcode, packsale, sizedesc FROM solidasort WHERE prodcode = '%@' GROUP BY prodcode, packsale, sizedesc", "GS-" + CustomerViewController.GlobalValiable.prod)
            print("คิวรี่ : \(queryString)")
            
            var stmt:OpaquePointer?
            
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK
            {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing : \(errmsg)")
            }
            
            self.solidasorts.removeAll()
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                let packsale = String(cString: sqlite3_column_text(stmt, 1))
                let sizedesc = String(cString: sqlite3_column_text(stmt, 2))
                
                self.solidasorts.append(SolidAsort(packcode: packsale, free: CustomerViewController.GlobalValiable.free, packdesc: sizedesc, qty: 0))
            }
            
            sqlite3_finalize(stmt)
            sqlite3_close(db)
        }
    }
    
    func PreloadData()
    {
        //ProgressBar
        let progressHUD = ProgressHUD(text: "Load Data...")
        self.view.addSubview(progressHUD)
        
        //URL
        let URL_USER_LOGIN = "http://consign-ios.adda.co.th/KeyOrders/findSolidAsort.php"
        
        //Set Parameter
        let parameters : Parameters=[
            "prod": CustomerViewController.GlobalValiable.prod
        ]
        
        //print("รุ่นที่ส่งไป :", CustomerViewController.GlobalValiable.prod)
//        Alamofire.request(URL_USER_LOGIN, method: .post, parameters: parameters).responseJSON
//        {
//                response in
//                print(response)
//                
//                if let array = response.result.value as? [[String: Any]] //หากมีข้อมูล
//                {
//                    //Check nil data
//                    var blnHaveData = false
//                    for _ in array  //วนลูปเช็คค่าที่ส่งมา
//                    {
//                        blnHaveData = true
//                        break
//                    }
//                    
//                    //เช็คสิทธิการเข้าใช้งาน
//                    if (blnHaveData)
//                    {
//                        var db: OpaquePointer?
//                        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//                            .appendingPathComponent("order.sqlite")
//                        
//                        if sqlite3_open(fileURL.path, &db) != SQLITE_OK
//                        {
//                            print("error opening database")
//                        }
//                        else
//                        {
//                            //ลบข้อมูลเก่าออกก่อน
//                            let delString = String(format:"DELETE FROM solidasort WHERE prodcode = '%@'", "GS-" + CustomerViewController.GlobalValiable.prod)
//                            //print(delString)
//                            
//                            var deleteStatement: OpaquePointer? = nil
//                            
//                            if sqlite3_prepare_v2(db, delString, -1, &deleteStatement, nil) == SQLITE_OK
//                            {
//                                if sqlite3_step(deleteStatement) != SQLITE_DONE
//                                {
//                                    print("Could not delete row.")
//                                }
//                            } else
//                            {
//                                print("DELETE statement could not be prepared")
//                            }
//                            
//                            sqlite3_finalize(deleteStatement)
//                            
//                            //บันทึกข้อมูลชุดใหม่
//                            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
//                            
//                            for personDict in array
//                            {
//                    
//                                let prodcode =  personDict["prod"] as! String
//                                let packcode =  personDict["packcode"] as! String
//                                let packdesc =  personDict["packdesc"] as! String
//                                let pairs =  personDict["pairs"] as! Int
//                                let packsale =  personDict["packsale"] as! String  //แบบแพ็ครวม solid
//                                let sizedesc =  personDict["sizedesc"] as! String
//                                
//                                
//                                //======== INSERT TO SQL ===========
//                                
//                                let insert = "INSERT INTO solidasort (prodcode, packcode, packdesc, pairs, packsale, sizedesc)" + "VALUES (?,?,?,?,?,?);"
//                                var statement: OpaquePointer?
//                                
//                                //preparing the query
//                                if sqlite3_prepare_v2(db, insert, -1, &statement, nil) == SQLITE_OK
//                                {
//                                    sqlite3_bind_text(statement, 1, prodcode, -1, SQLITE_TRANSIENT)
//                                    sqlite3_bind_text(statement, 2, packcode, -1, SQLITE_TRANSIENT)
//                                    sqlite3_bind_text(statement, 3, packdesc, -1, SQLITE_TRANSIENT)
//                                    sqlite3_bind_int(statement, 4, Int32(pairs))
//                                    sqlite3_bind_text(statement, 5, packsale, -1, SQLITE_TRANSIENT)
//                                    sqlite3_bind_text(statement, 6, sizedesc, -1, SQLITE_TRANSIENT)
//                                    
//                                    //executing the query to insert values
//                                    if sqlite3_step(statement) != SQLITE_DONE
//                                    {
//                                        let errmsg = String(cString: sqlite3_errmsg(db)!)
//                                        print("failure inserting armstr: \(errmsg)")
//                                        return
//                                    }
//                                    
//                                }
//                                else
//                                {
//                                    let errmsg = String(cString: sqlite3_errmsg(db)!)
//                                    print("error preparing insert: \(errmsg)")
//                                    return
//                                    
//                                }
//                                
//                                sqlite3_finalize(statement)
//                            }
//                            
//                        } // open DB
//                        
//                        sqlite3_close(db)
//                        progressHUD.hide()
//                        self.myTable.reloadData()
//                    }
//                    else
//                    {
//                        print("no data")
//                        progressHUD.hide()
//                        ProgressIndicator.hide()
//                        //Alert
//                        let alert = UIAlertController(title: "Not found data!", message: "ไม่พบข้อมูลในระบบ กรุณาลองใหม่อีกครั้ง..", preferredStyle: .alert)
//                        
//                        alert.addAction(UIAlertAction(title: "ตกลง", style: .default, handler: nil))
//                        self.present(alert, animated: true)
//                    }
//                }
//        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        if (blnInputQty)
        {
            solidasorts[intRownumber].qty = CustomerViewController.GlobalValiable.qty //ใส่จำนวนคู่ใน array
            myTable.reloadData()
            
            var sumQty: Int = 0
            
            for (value) in solidasorts
            {
                sumQty = sumQty + value.qty!
            }
            
            lblSumQty.text = String(format: "%ld", sumQty)
            blnInputQty = false
        }
        
    }
}

extension SolidAsortViewController: UITableViewDataSource, UITableViewDelegate
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return solidasorts.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return "               แบบแพ็ค:                                                                                             จำนวนคู่:"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let _solidasort = solidasorts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SolidAsortCell
        cell.setData(SolidAsort: _solidasort)
        cell.delegate = self
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor(red: 250/255, green: 250/255, blue:     250/255, alpha: 1.0)
        cell.selectedBackgroundView = selectedView
        //cell.selectionStyle = .none  //ปิดการ selected row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        //let _prod7 = prod7[indexPath.row]
        intRownumber = indexPath.row  //เก็บ row ปัจจุบันที่แก้ไข
        blnInputQty = true
        
        if let menu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "qty") as? PassQtyViewController
        {
            CustomerViewController.GlobalValiable.pairs = 6  //default 6 คู่/กล่อง
            menu.modalPresentationStyle = .fullScreen
            self.present(menu, animated: true, completion: nil)
        }
    }
}

extension SolidAsortViewController: SolidAsortCellDelegate
{
    func Add(packcode: String)
    {
        var i : Int = 0
        var sumQty: Int = 0
        var total : Int = 0
        
        for (value) in solidasorts
        {
            
            if (value.packcode! == packcode)
            {
                sumQty = value.qty! + 6
                total = total + sumQty
                solidasorts[i].qty! = sumQty
            }
            else
            {
                total = total + value.qty!
            }
            
            i = i + 1
        }
        
        myTable.reloadData()
        lblSumQty.text = String(format: "%ld", total)
    }
    
    func Delete(packcode: String)
    {

        var i : Int = 0
        var sumQty: Int = 0
        var total : Int = 0
        
        for (value) in solidasorts
        {
            
            if (value.packcode! == packcode)
            {
                if (value.qty! != 0)
                {
                    sumQty = value.qty! - 6
                    total = total + sumQty
                    solidasorts[i].qty! = sumQty
                }
            }
            else
            {
                total = total - value.qty!
            }
            
            i = i + 1
        }
        
        myTable.reloadData()
        lblSumQty.text = String(format: "%ld", total)
    }
}

