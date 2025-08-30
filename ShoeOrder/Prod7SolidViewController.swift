//
//  Prod7SolidViewController.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 6/3/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit
import SQLite3

class Prod7SolidViewController: UIViewController {
    
    @IBOutlet weak var lblProd: UILabel!
    @IBOutlet weak var lblColor: UILabel!
    @IBOutlet weak var lblSumQty: UILabel!
    @IBOutlet weak var lblSumFreeqty: UILabel! //จำนวนแถม
    
    @IBOutlet weak var myTable: UITableView!
    
    var db: OpaquePointer?
    let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("order.sqlite")
    
    var prod7 = [Pro7]()          //ประกาศตัวแปรของคลาส
    var intRownumber: Int = 0     //เก็บ Rows ที่กำลังแก้ไข
    var qty_solid : Int = 0       //เก็บจำนวนคู่เฉพาะ prod7 solid
    var qtyFree : Int = 0         //เก็บจำนวนคู่ที่แถม
    
    var strQtySolid = String()
    
    var blnFree : Bool = false //true  //event pass button free เริ่มต้นให้ซ่อนแถม
    var blnSave : Bool = false
    var blnAEfreeQty : Bool = false  //ดักการกดปุ่มอัพเดทรายการแถม
    var blnSaveCurrRec : Bool = false //เก็บการกดบันทึก textbox แถวปัจจุบัน
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showAlert(title: "บันทึก Solid: ", message: CustomerViewController.GlobalValiable.logiCode + " " + CustomerViewController.GlobalValiable.logiName)
        
        print(">>>>> logiCode: ", CustomerViewController.GlobalValiable.logiCode)
        print(">>>>> logiName: ", CustomerViewController.GlobalValiable.logiName)
        print(">>>>> logisCode: ", CustomerViewController.GlobalValiable.logisCode)

        UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self]).font = UIFont.boldSystemFont(ofSize: 25)
        
        if let font = UIFont(name: "PSL Display", size: 25)
        {
            UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self]).font = font
        }
        
        self.lblProd.text = CustomerViewController.GlobalValiable.prod
        self.lblColor.text = CustomerViewController.GlobalValiable.color
        self.myTable.delegate = self
        CustomerViewController.GlobalValiable.qty = 0
        
        //หามีการคีย์แถมก่อนหน้าให้แสดง textbox แถมไว้รอ
        if (CustomerViewController.GlobalValiable.free == "แถม")
        {
            blnFree = false
        }
        else
        {
            blnFree = true
        }
        
        Query()
        PrepairData()
    }
    
    
    @IBAction func btnFree(_ sender: Any)
    {
        if (blnFree)
        {
            blnFree = false
            CustomerViewController.GlobalValiable.free = "แถม"
        }
        else
        {
            blnFree = true
            if (chkFreeOd()! == false)   //หากกดปุ่มซ่อนรายการแถม ให้เช็คทุกครั้งว่ามีการแถมก่อนหน้าหรือไม่ ถ้าไม่มีแก้ไขสถานะการแถมได้
            {
                CustomerViewController.GlobalValiable.free = ""
            }
        }
        
        blnSaveCurrRec =  false
        qty_solid = 0  //Clear
        qtyFree = 0    //Clear
        
        Query()
        PrepairData()
        myTable.reloadData()
    }
    
    
    @IBAction func btnSave(_ sender: Any)
    {
        blnSave = true
//        var blnHaveDt: Int = 0
        
        //เช็คว่ามีสินค้าที่ไม่ใช่เป็นการคีย์ของเเถมอย่างเดียว
//        for dt in prod7
//        {
//            let  _qty = dt.qty!
//
//            if _qty > 0
//            {
//                blnHaveDt = 1
//            }
//        }

        //if (blnHaveDt == 1 && ChkQtyPerBox())  //หากเป็น solid ไม่ต้องเช็คครบกล่อง
//        if (blnHaveDt == 1)
//        {
            ConfirmData()
            moveToMainTable()  //สินค้าคิดเงิน
            moveToMainTable_free()  //เฉพาะสินค้าแถม
      
            CustomerViewController.GlobalValiable.qty = 0
            //CustomerViewController.GlobalValiable.free = ""  //Clear valible
            
            if let menu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Keyod") as? TakeOrderViewController
            {
                menu.modalPresentationStyle = .fullScreen
                self.present(menu, animated: true, completion: nil)
            }
//        }
    }
    
    @IBAction func btnCancel(_ sender: Any)
    {
        if let menu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Keyod") as? TakeOrderViewController
        {
            CustomerViewController.GlobalValiable.qty = 0
            menu.modalPresentationStyle = .fullScreen
            self.present(menu, animated: true, completion: nil)
        }
    }
    
    //เช็คครบกล่อง
    func ChkQtyPerBox() ->Bool
    {
        var _sumQty : Int = 0
        var _pairs : Int = 0
        var _bool = false

        for prod in prod7
        {
            _pairs = prod.pairs!
        }

        //Open db
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            let queryString = String(format:"SELECT qty FROM tmp_odmst WHERE prodcode = '%@' AND code ='%@' AND colorcode = '%@' AND store = ''", "GS-" + lblProd.text!, CustomerViewController.GlobalValiable.myCode, CustomerViewController.GlobalValiable.colorcode)
            //print("คิวรี่ : \(queryString)")

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
                _sumQty = _sumQty + Int(sqlite3_column_int(stmt, 0))
            }

            sqlite3_finalize(stmt)
            lblSumQty.text = String(_sumQty)
            
            _sumQty = 0
            //หาจำนวนแถมคู่
            let queryString2 = String(format:"SELECT qty FROM tmp_odmst WHERE prodcode = '%@' AND code ='%@' AND colorcode = '%@' AND store = 'แถม'", "GS-" + lblProd.text!, CustomerViewController.GlobalValiable.myCode, CustomerViewController.GlobalValiable.colorcode)

            var stmt2:OpaquePointer?
            if sqlite3_prepare(db, queryString2, -1, &stmt2, nil) != SQLITE_OK
            {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing : \(errmsg)")
            }
            
            while(sqlite3_step(stmt2) == SQLITE_ROW)
            {
                _sumQty = _sumQty + Int(sqlite3_column_int(stmt2, 0))
            }
            
            sqlite3_finalize(stmt2)
            sqlite3_close(db)
    
            lblSumFreeqty.text = String(_sumQty)
            
            if (_sumQty % _pairs == 0)   //กรณีครบกล่อง
            {
                _bool = true
            }
            else   //กรณีไม่ครบกล่อง
            {
                _bool =  false
            }
        }
        else
        {
            print("error opening database")
        }

        return _bool
    }
    
    func ConfirmData()
    {
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            var updateStatement: OpaquePointer?
            
            //Update จำนวนคู่
            let UpdateSql = String(format:"UPDATE tmp_odmst SET status = '' WHERE code ='%@'", CustomerViewController.GlobalValiable.myCode)
            //print("อัพเดท : \(UpdateSql)")
            
            if sqlite3_prepare(db, UpdateSql, -1, &updateStatement, nil) == SQLITE_OK
            {
                if sqlite3_step(updateStatement) != SQLITE_DONE
                {
                    print("Could not update row.")
                }
            }
            else{
                print("UPDATE statement could not be prepared")
            }
            
            sqlite3_finalize(updateStatement)
            sqlite3_close(db)
        }
    }
    
    func PrepairData()
    {
        var db1: OpaquePointer?
        //Open db
        if sqlite3_open(fileURL.path, &db1) == SQLITE_OK
        {
            //บันทึกข้อมูลชุดใหม่
            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            
            let numRec = getNumberOfRec()
            var i:Int = 0
            var j:Int = numRec! + 1
            var statement: OpaquePointer?  //รายการคิดเงิน
            var statement2: OpaquePointer?  //รายการแถม
            
            let deleteStatementString = String(format:"DELETE FROM tmp_odmst WHERE code = '%@'", CustomerViewController.GlobalValiable.myCode)
            
            var deleteStatement: OpaquePointer?
            
            if sqlite3_prepare(db1, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK
            {
                if sqlite3_step(deleteStatement) != SQLITE_DONE
                {
                    print("Could not delete row.")
                }
            }
            else
            {
                print("DELETE statement could not be prepared")
            }
            
            sqlite3_finalize(deleteStatement)
            
            for dt in prod7
            {
                
                let  _qty = dt.qty!
                
                //=============  บันทึกเฉพาะที่ระบุจำนวน  ===============
                let insertSql = "INSERT INTO tmp_odmst (status, date, delivery, code, orderno, no, prodcode, n_pack, packcode, sizedesc, colorcode, colordesc, qty, price, amt, packno, pairs, dozen, disc1, pono, tax_rate, vat_type, tax_amt, net_amt, cr_term, saleman, remark, recfirm, incvat, logis_code, logicode, ctrycode, store)" + " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);"
                
                //preparing the query
                if sqlite3_prepare(db1, insertSql, -1, &statement, nil) == SQLITE_OK
                {
                    // Create date formatter
                    let date = Date()
                    let dateFormatter: DateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd/MM/yyyy"
                    
                    //let numRec = getNumberOfRec()
                    let intQty:Int = prod7[intRownumber].qty!
                    let intDozen:Int = intQty / 12
//                    var send = CustomerViewController.GlobalValiable.logiCode
//                    send = String(send.prefix(2))
                    
                    sqlite3_bind_text(statement, 1, "N", -1, SQLITE_TRANSIENT)
                    sqlite3_bind_text(statement, 2, dateFormatter.string(from: date), -1, SQLITE_TRANSIENT)
                    sqlite3_bind_text(statement, 3, dateFormatter.string(from: date), -1, SQLITE_TRANSIENT)
                    sqlite3_bind_text(statement, 4, CustomerViewController.GlobalValiable.myCode, -1, SQLITE_TRANSIENT)
                    sqlite3_bind_text(statement, 5, "", -1, SQLITE_TRANSIENT)  //ยังไม่กำหนด เลขที่ od จนกว่าจะกดส่งข้อมูล
                    sqlite3_bind_int(statement, 6, Int32(j))      //Int32(numRec!))
                    sqlite3_bind_text(statement, 7, prod7[i].prodcode, -1, SQLITE_TRANSIENT)
                    sqlite3_bind_text(statement, 8, String(CustomerViewController.GlobalValiable.n_pack), -1, SQLITE_TRANSIENT)
                    sqlite3_bind_text(statement, 9, prod7[i].packcode, -1, SQLITE_TRANSIENT)
                    sqlite3_bind_text(statement, 10, prod7[i].sizedesc, -1, SQLITE_TRANSIENT)
                    sqlite3_bind_text(statement, 11, CustomerViewController.GlobalValiable.colorcode, -1, SQLITE_TRANSIENT)
                    sqlite3_bind_text(statement, 12, CustomerViewController.GlobalValiable.color, -1, SQLITE_TRANSIENT)
                    sqlite3_bind_int(statement, 13, Int32(_qty))
                    sqlite3_bind_double(statement, 14, 0)
                    sqlite3_bind_double(statement, 15, 0)
                    sqlite3_bind_text(statement, 16, prod7[i].packno, -1, SQLITE_TRANSIENT)
                    sqlite3_bind_int(statement, 17, Int32(CustomerViewController.GlobalValiable.pairs)) //เศษโหล
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
                    sqlite3_bind_text(statement, 33, "", -1, SQLITE_TRANSIENT)
                    
                    //executing the query to insert values
                    if sqlite3_step(statement) != SQLITE_DONE
                    {
                        let errmsg = String(cString: sqlite3_errmsg(db1)!)
                        print("failure Inserting tmp_odmst_ปกติ: \(errmsg)")
                        return
                    }
                    
                    sqlite3_finalize(statement)
                }
                else
                {
                    let errmsg = String(cString: sqlite3_errmsg(db1)!)
                    print("error preparing insert: \(errmsg)")
                    return
                }
                
                if (CustomerViewController.GlobalValiable.free == "แถม")
                {
                    //=========== Insert รายการแถมรอไว้ ===============
                    //บันทึกเฉพาะที่ระบุจำนวน
                    let insertSql2 = "INSERT INTO tmp_odmst (status, date, delivery, code, orderno, no, prodcode, n_pack, packcode, sizedesc, colorcode, colordesc, qty, price, amt, packno, pairs, dozen, disc1, pono, tax_rate, vat_type, tax_amt, net_amt, cr_term, saleman, remark, recfirm, incvat, logis_code, logicode, ctrycode, store)" + " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);"
                    
                    //preparing the query
                    if sqlite3_prepare(db1, insertSql2, -1, &statement2, nil) == SQLITE_OK
                    {
                        // Create date formatter
                        let date = Date()
                        let dateFormatter: DateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd/MM/yyyy"
                        
                        let intQty:Int = prod7[intRownumber].qty_free!
                        let intDozen:Int = intQty / 12
//                        var send = CustomerViewController.GlobalValiable.logiCode
//                        send = String(send.prefix(2))
                        
                        sqlite3_bind_text(statement2, 1, "N", -1, SQLITE_TRANSIENT)
                        sqlite3_bind_text(statement2, 2, dateFormatter.string(from: date), -1, SQLITE_TRANSIENT)
                        sqlite3_bind_text(statement2, 3, dateFormatter.string(from: date), -1, SQLITE_TRANSIENT)
                        sqlite3_bind_text(statement2, 4, CustomerViewController.GlobalValiable.myCode, -1, SQLITE_TRANSIENT)
                        sqlite3_bind_text(statement2, 5, "", -1, SQLITE_TRANSIENT)  //ยังไม่กำหนด เลขที่ od จนกว่าจะกดส่งข้อมูล
                        sqlite3_bind_int(statement2, 6, Int32(j))      //Int32(numRec!))
                        sqlite3_bind_text(statement2, 7, prod7[i].prodcode, -1, SQLITE_TRANSIENT)
                        sqlite3_bind_text(statement2, 8, String(CustomerViewController.GlobalValiable.n_pack), -1, SQLITE_TRANSIENT)
                        sqlite3_bind_text(statement2, 9, prod7[i].packcode, -1, SQLITE_TRANSIENT)
                        sqlite3_bind_text(statement2, 10, prod7[i].sizedesc, -1, SQLITE_TRANSIENT)
                        sqlite3_bind_text(statement2, 11, CustomerViewController.GlobalValiable.colorcode, -1, SQLITE_TRANSIENT)
                        sqlite3_bind_text(statement2, 12, CustomerViewController.GlobalValiable.color, -1, SQLITE_TRANSIENT)
                        sqlite3_bind_int(statement2, 13, Int32(dt.qty_free!))
                        sqlite3_bind_double(statement2, 14, 0)
                        sqlite3_bind_double(statement2, 15, 0)
                        sqlite3_bind_text(statement2, 16, prod7[i].packno, -1, SQLITE_TRANSIENT)
                        sqlite3_bind_int(statement2, 17, Int32(CustomerViewController.GlobalValiable.pairs)) //เศษโหล
                        sqlite3_bind_int(statement2, 18,  Int32(intDozen))  //จำนวนโหล
                        sqlite3_bind_int(statement2, 19,  Int32(CustomerViewController.GlobalValiable.disc))  //จำนวนโหล
                        sqlite3_bind_text(statement2, 20, "", -1, SQLITE_TRANSIENT)
                        sqlite3_bind_double(statement2, 21, 7.00)
                        sqlite3_bind_text(statement2, 22, "3", -1, SQLITE_TRANSIENT)
                        sqlite3_bind_double(statement2, 23, 0.00)
                        sqlite3_bind_double(statement2, 24, 0.00)
                        sqlite3_bind_int(statement2, 25,  Int32(CustomerViewController.GlobalValiable.cr_term))  //cr_term
                        sqlite3_bind_text(statement2, 26, CustomerViewController.GlobalValiable.saleid, -1, SQLITE_TRANSIENT)
                        sqlite3_bind_text(statement2, 27, "", -1, SQLITE_TRANSIENT)
                        sqlite3_bind_int(statement2, 28, Int32(CustomerViewController.GlobalValiable.recfirm))  //งานสั่งทำ
                        sqlite3_bind_int(statement2, 29, 1)  //incvat
                        sqlite3_bind_text(statement2, 30, CustomerViewController.GlobalValiable.logisCode, -1, SQLITE_TRANSIENT) //logis_code
                        sqlite3_bind_text(statement2, 31, CustomerViewController.GlobalValiable.logiCode, -1, SQLITE_TRANSIENT)
                        sqlite3_bind_text(statement2, 32, "TH", -1, SQLITE_TRANSIENT)
                        sqlite3_bind_text(statement2, 33, "แถม", -1, SQLITE_TRANSIENT)
                        
                        //executing the query to insert values
                        if sqlite3_step(statement2) != SQLITE_DONE
                        {
                            let errmsg = String(cString: sqlite3_errmsg(db1)!)
                            print("failure Inserting tmp_odmst_แถม: \(errmsg)")
                            return
                        }
                        
                        sqlite3_finalize(statement2)
                    }
                    else
                    {
                        let errmsg = String(cString: sqlite3_errmsg(db1)!)
                        print("error preparing insert: \(errmsg)")
                        return
                    }
                }
                
                i = i + 1
                j = j + 1
            } //Close for loops
            
            sqlite3_close(db1)
        }
    }
    
    //เช็คว่ามีการแถมก่อนหน้าหรือไม่
    func chkFreeOd() -> Bool?
    {
        var blnOdFree = false
        
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            let queryString = String(format:"SELECT * FROM odmst WHERE status = '' AND code = '%@' AND store = 'แถม'", CustomerViewController.GlobalValiable.myCode)
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
                blnOdFree = true
            }
            
            sqlite3_finalize(stmt)
            sqlite3_close(db)
        }
        
        return blnOdFree
    }
    
    
    func getNumberOfRec() -> Int?
    {
        var id: Int = 0
        
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
            
            sqlite3_finalize(stmt)
            sqlite3_close(db)
        }
        
        return id
    }
    
    func Query()
    {
        //Open db
        var db1: OpaquePointer?
        
        if sqlite3_open(fileURL.path, &db1) == SQLITE_OK
        {
            //first empty the list of ar
            prod7.removeAll()
            
            let strProd = CustomerViewController.GlobalValiable.prod
            let strNpack = CustomerViewController.GlobalValiable.n_pack
            let strColor = CustomerViewController.GlobalValiable.colorcode
            
            let queryString = String(format:"SELECT prodcode, style, n_pack, packcode, packno, sizedesc, pairs FROM prodlist WHERE prodcode = '%@' AND n_pack ='%@' AND colorcode = '%@' ORDER BY packcode", "GS-" + strProd, String(strNpack), strColor)
            //print(queryString)
            
            //statement pointer
            var stmt:OpaquePointer?
            
            //preparing the query
            if sqlite3_prepare(db1, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db1)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            
            //Clear dicictionary
            prod7.removeAll()
            
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                let Prod = String(cString: sqlite3_column_text(stmt, 0))
                let Style = String(cString: sqlite3_column_text(stmt, 1))
                let Npack = Int(sqlite3_column_int(stmt, 2))
                let Packcode = String(cString: sqlite3_column_text(stmt, 3))
                let Packno = String(cString: sqlite3_column_text(stmt, 4))
                let Size = String(cString: sqlite3_column_text(stmt, 5))
                let Pairs = Int(sqlite3_column_int(stmt, 6))
                var intQty = 0 //ออเดอร์จริง
                var intQtyfree = 0 //ออเดอร์แถม
                CustomerViewController.GlobalValiable.pairs = Pairs  //เก็บจำนวนแพ็ค
                
                //Get Qty per style
                let queryString2 = String(format:"SELECT prodcode, n_pack, colorcode, packcode, SUM(qty) as Qty FROM odmst WHERE prodcode = '%@' AND n_pack ='%@' AND colorcode = '%@' AND packcode = '%@' AND store = '' GROUP BY prodcode, n_pack, colorcode, packcode", Prod, String(Npack), strColor, Packcode)

                var stmt2:OpaquePointer?

                //preparing the query
                if sqlite3_prepare(db1, queryString2, -1, &stmt2, nil) != SQLITE_OK{
                    let errmsg = String(cString: sqlite3_errmsg(db1)!)
                    print("error preparing insert: \(errmsg)")
                    return
                }

                 while(sqlite3_step(stmt2) == SQLITE_ROW)
                 {
                    intQty = Int(sqlite3_column_int(stmt2, 4))
                 }

                sqlite3_finalize(stmt2)
                
                
                //เช็คว่าคลิกปุ่มแถมหรือไม่
                if (CustomerViewController.GlobalValiable.free == "แถม")
                {
                    //หาจำนวนคู่รายการแถมก่อนหน้า
                    let queryString3 = String(format:"SELECT prodcode, n_pack, colorcode, packcode, SUM(qty) as Qty FROM odmst WHERE prodcode = '%@' AND n_pack ='%@' AND colorcode = '%@' AND packcode = '%@' AND store = '%@' GROUP BY prodcode, n_pack, colorcode, packcode", Prod, String(Npack), strColor, Packcode, CustomerViewController.GlobalValiable.free)
                    //print("หารายการแถม :", queryString3)
                    
                    var stmt3:OpaquePointer?
                    
                    //preparing the query
                    if sqlite3_prepare(db1, queryString3, -1, &stmt3, nil) != SQLITE_OK{
                        let errmsg = String(cString: sqlite3_errmsg(db1)!)
                        print("error preparing insert: \(errmsg)")
                        return
                    }
                    
                    while(sqlite3_step(stmt3) == SQLITE_ROW)
                    {
                        intQtyfree = Int(sqlite3_column_int(stmt3, 4))
                    }
                    
                    sqlite3_finalize(stmt3)
                }
                else
                {
                    intQtyfree = 0
                }
                
                //Adding values to list
                prod7.append(Pro7(prodcode: Prod, style: Style, npack: Npack, packcode: Packcode, packno: Packno, sizedesc: Size, pairs: Pairs, qty: intQty, qty_free: intQtyfree))
            }
            
            myTable.reloadData()
            
            //แสดงจำนวนคู่ที่คีย์ก่อนหน้า
            var intQty: Int = 0
            var intFqty: Int = 0
            for value in prod7
            {
                intQty = intQty + value.qty!
                intFqty = intFqty + value.qty_free!
            }
         
            lblSumQty.text = String(intQty)
            lblSumFreeqty.text = String(intFqty)
            
            sqlite3_finalize(stmt)
            sqlite3_close(db1)
        }
        else
        {
            print("error opening database")
        }
    }
    
    func getODTransection()
    {
        //Open db
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            //first empty the list of ar
            prod7.removeAll()
            
            let strProd = CustomerViewController.GlobalValiable.prod
            let strNpack = CustomerViewController.GlobalValiable.n_pack
            
            let queryString = String(format:"SELECT prodcode, n_pack, packcode, packno, sizedesc, pairs, qty FROM tmp_odmst WHERE code = '%@' AND prodcode = '%@' AND n_pack ='%@' AND status = 'N' AND store = ''", CustomerViewController.GlobalValiable.myCode, "GS-" + strProd, String(strNpack))
            //print(queryString)
            
            //statement pointer
            var stmt:OpaquePointer?
            
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            
            //Clear dicictionary
            prod7.removeAll()
            
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                let Prod = String(cString: sqlite3_column_text(stmt, 0))
                
                //ตัด GS- ออก
                let indexStartOfText = Prod.index(Prod.startIndex, offsetBy: 3) //ตัวที่4 เป็นตันไป
                let Style = String(Prod[indexStartOfText...])
                
                let Npack = Int(sqlite3_column_int(stmt, 1))
                let Packcode = String(cString: sqlite3_column_text(stmt, 2))
                let Packno = String(cString: sqlite3_column_text(stmt, 3))
                let Size = String(cString: sqlite3_column_text(stmt, 4))
                let Pairs = Int(sqlite3_column_int(stmt, 5))
                let Qty = Int(sqlite3_column_int(stmt, 6))
                
                var QtyFree : Int = 0
                //========= หาจำนวนแถมก่อนหน้า ==========
                if (CustomerViewController.GlobalValiable.free == "แถม")
                {
                    //หาจำนวนคู่รายการแถมก่อนหน้า
                    let queryString3 = String(format:"SELECT prodcode, n_pack, colorcode, packcode, SUM(qty) as Qty FROM tmp_odmst WHERE prodcode = '%@' AND n_pack ='%@' AND packcode = '%@' AND store = 'แถม' GROUP BY prodcode, n_pack, colorcode, packcode", Prod, String(Npack), Packcode)
                    //print("หารายการแถม :", queryString3)
                    
                    var stmt3:OpaquePointer?
                    
                    //preparing the query
                    if sqlite3_prepare(db, queryString3, -1, &stmt3, nil) != SQLITE_OK{
                        let errmsg = String(cString: sqlite3_errmsg(db)!)
                        print("error preparing insert: \(errmsg)")
                        return
                    }
                    
                    while(sqlite3_step(stmt3) == SQLITE_ROW)
                    {
                        QtyFree = Int(sqlite3_column_int(stmt3, 4))
                    }
                    
                    sqlite3_finalize(stmt3)
                }
                else
                {
                    QtyFree = 0
                }
                
                
                //Adding values to list
                prod7.append(Pro7(prodcode: Prod, style: Style, npack: Npack, packcode: Packcode, packno: Packno, sizedesc: Size, pairs: Pairs, qty: Qty, qty_free: QtyFree))
            }
            
            myTable.reloadData()
            
            sqlite3_finalize(stmt)
            sqlite3_close(db)
        }
        else
        {
            print("error opening database")
        }
    }
    
    
    func AddDelQty(Type: String, prod: String, code: String, packcode: String, colorcode: String, pairs: Int)
    {
        //Open db
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            let queryString = String(format:"SELECT qty FROM tmp_odmst WHERE prodcode = '%@' AND code ='%@' AND packcode = '%@' AND colorcode = '%@' AND store = ''", prod, code, packcode, colorcode)
            //print("คิวรี่ : \(queryString)")
            
            //statement pointer
            var stmt:OpaquePointer?
            var updateStatement: OpaquePointer?
            
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                var qty = Int(sqlite3_column_int(stmt, 0))
                
                //print("Pairs : \(pairs)")
                if (Type == "ADD")
                {
                    //qty = qty + CustomerViewController.GlobalValiable.pairs
                    qty = qty + 1
                }
                else if (Type == "DEL")
                {
                    if (qty != 0)
                    {
                        //qty = qty - CustomerViewController.GlobalValiable.pairs
                        qty = qty - 1
                        
                        if (qty < 0)
                        {
                            qty = 0
                        }
                    }
                }
                else //Adjust ยอด
                {
                    if (blnAEfreeQty) //หากคีย์แถม
                    {
                        qty = qtyFree
                    }
                    else
                    {
                        qty = qty_solid
                    }
                   
                    
                    if (qty < 0)
                    {
                        qty = 0
                    }
                }
                
                //Update จำนวนคู่
                var UpdateSql = ""
                if (blnAEfreeQty)  //หากเป็นการบันทึกรายการแถม
                {
                    UpdateSql = String(format:"UPDATE tmp_odmst SET qty = \(qty) WHERE prodcode = '%@' AND code ='%@' AND packcode = '%@' AND colorcode = '%@' AND store = 'แถม'", prod, code, packcode, colorcode)
                    //print("อัพเดท : \(UpdateSql)")
                }
                else
                {
                    UpdateSql = String(format:"UPDATE tmp_odmst SET qty = \(qty) WHERE prodcode = '%@' AND code ='%@' AND packcode = '%@' AND colorcode = '%@' AND store = ''", prod, code, packcode, colorcode)
                    //print("อัพเดท : \(UpdateSql)")
                }
                
                
                if sqlite3_prepare(db, UpdateSql, -1, &updateStatement, nil) == SQLITE_OK
                {
                    if sqlite3_step(updateStatement) != SQLITE_DONE
                    {
                        print("Could not update row.")
                    }
                }
                else
                {
                    print("UPDATE statement could not be prepared")
                }
                
                sqlite3_finalize(updateStatement)
            }
            
            myTable.reloadData()
            
            sqlite3_finalize(stmt)
            sqlite3_close(db)
        }
        else
        {
            print("error opening database")
        }
    }
    
    //Copydata จาก tmp_odmst To odmst
    func moveToMainTable()
    {
        //Open db
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            let queryString = String(format:"SELECT code, prodcode, n_pack, packcode, colorcode, qty FROM tmp_odmst WHERE  code ='%@' AND status = '' AND store = ''", CustomerViewController.GlobalValiable.myCode)
            //print("คิวรี่ : \(queryString)")
            
            //statement pointer
            var stmt:OpaquePointer?
            
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                var blnExistData: Bool = false
                let prodcode = String(cString: sqlite3_column_text(stmt, 1))
                let npack = String(cString: sqlite3_column_text(stmt, 2))
                let packcode = String(cString: sqlite3_column_text(stmt, 3))
                let colorcode = String(cString: sqlite3_column_text(stmt, 4))
                let qty = Int(sqlite3_column_int(stmt, 5))
                
                let queryString2 = String(format:"SELECT code, prodcode, n_pack, packcode, colorcode, qty FROM odmst WHERE code ='%@' AND prodcode = '%@' AND n_pack = '%@' AND packcode = '%@' AND colorcode = '%@' AND store = ''", CustomerViewController.GlobalValiable.myCode, prodcode, npack, packcode, colorcode)
                
                var stmt2:OpaquePointer?
                if sqlite3_prepare(db, queryString2, -1, &stmt2, nil) != SQLITE_OK{
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("error preparing insert: \(errmsg)")
                    return
                }
                
                 while(sqlite3_step(stmt2) == SQLITE_ROW)
                 {
                    blnExistData = true
                 }
                
                sqlite3_finalize(stmt2)
                
                if (blnExistData)
                {
                    //หากมีรุ่นนี้อยู่แล้วให้อัพเดทยอด
                    let UpdateSql = String(format:"UPDATE odmst SET qty = \(qty) WHERE prodcode = '%@' AND code ='%@' AND packcode = '%@' AND colorcode = '%@' AND n_pack = '%@' AND store = ''", prodcode, CustomerViewController.GlobalValiable.myCode, packcode, colorcode, npack)
                    
                    //print("อัพเดท : \(UpdateSql)")
                    var updateStatement:OpaquePointer?
                    
                    if sqlite3_prepare(db, UpdateSql, -1, &updateStatement, nil) == SQLITE_OK
                    {
                        if sqlite3_step(updateStatement) != SQLITE_DONE
                        {
                            print("Could not update row.")
                        }
                    }
                    else
                    {
                        print("UPDATE statement could not be prepared")
                    }
                    
                    sqlite3_finalize(updateStatement)
                }
                else      //หาเป็นรายการใหม่ที่ยังไม่มีในระบบให้เพิ่ม
                {
                    var Statement: OpaquePointer? = nil
                    let insertStatementStirng = String(format:"INSERT INTO odmst SELECT * FROM tmp_odmst WHERE code = '%@' AND prodcode = '%@' AND n_pack = '%@' AND packcode = '%@' AND colorcode = '%@' AND store = '' AND qty > 0", CustomerViewController.GlobalValiable.myCode, prodcode, npack, packcode, colorcode)
                    //print("เพิ่มใหม่ : \(insertStatementStirng)")
                    
                    if sqlite3_prepare_v2(db, insertStatementStirng, -1, &Statement, nil) == SQLITE_OK
                    {
                        if sqlite3_step(Statement) != SQLITE_DONE
                        {
                            print("Could not insert row.")
                        }
                    } else {
                        print("Inset statement could not be prepared")
                    }
                    
                    sqlite3_finalize(Statement)
                }
            }
            
            sqlite3_close(db)
        }
        else
        {
            print("error opening database")
        }
    }
    
    //บันทึก รายการแถม
    func moveToMainTable_free()
    {
        //Open db
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            let queryString = String(format:"SELECT code, prodcode, n_pack, packcode, colorcode, qty FROM tmp_odmst WHERE  code ='%@' AND status = '' AND store = 'แถม'", CustomerViewController.GlobalValiable.myCode)
            //print("คิวรี่ : \(queryString)")
            
            //statement pointer
            var stmt:OpaquePointer?
            
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                var blnExistData: Bool = false
                let prodcode = String(cString: sqlite3_column_text(stmt, 1))
                let npack = String(cString: sqlite3_column_text(stmt, 2))
                let packcode = String(cString: sqlite3_column_text(stmt, 3))
                let colorcode = String(cString: sqlite3_column_text(stmt, 4))
                let qty = Int(sqlite3_column_int(stmt, 5))
                
                let queryString2 = String(format:"SELECT code, prodcode, n_pack, packcode, colorcode, qty FROM odmst WHERE code ='%@' AND prodcode = '%@' AND n_pack = '%@' AND packcode = '%@' AND colorcode = '%@' AND store = 'แถม'", CustomerViewController.GlobalValiable.myCode, prodcode, npack, packcode, colorcode)
                
                var stmt2:OpaquePointer?
                if sqlite3_prepare(db, queryString2, -1, &stmt2, nil) != SQLITE_OK{
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("error preparing insert: \(errmsg)")
                    return
                }
                
                while(sqlite3_step(stmt2) == SQLITE_ROW)
                {
                    blnExistData = true
                }
                
                sqlite3_finalize(stmt2)
                
                if (blnExistData)
                {
                    //หากมีรุ่นนี้อยู่แล้วให้อัพเดทยอด
                    let UpdateSql = String(format:"UPDATE odmst SET qty = \(qty) WHERE prodcode = '%@' AND code ='%@' AND packcode = '%@' AND colorcode = '%@' AND n_pack = '%@' AND store = 'แถม'", prodcode, CustomerViewController.GlobalValiable.myCode, packcode, colorcode, npack)
                    
                    //print("อัพเดท : \(UpdateSql)")
                    var updateStatement:OpaquePointer?
                    
                    if sqlite3_prepare(db, UpdateSql, -1, &updateStatement, nil) == SQLITE_OK
                    {
                        if sqlite3_step(updateStatement) != SQLITE_DONE
                        {
                            print("Could not update row.")
                        }
                    }
                    else
                    {
                        print("UPDATE statement could not be prepared")
                    }
                    
                    sqlite3_finalize(updateStatement)
                }
                else      //หาเป็นรายการใหม่ที่ยังไม่มีในระบบให้เพิ่ม
                {
                    var Statement: OpaquePointer? = nil
                    let insertStatementStirng = String(format:"INSERT INTO odmst SELECT * FROM tmp_odmst WHERE code = '%@' AND prodcode = '%@' AND n_pack = '%@' AND packcode = '%@' AND colorcode = '%@' AND store = 'แถม' AND qty > 0", CustomerViewController.GlobalValiable.myCode, prodcode, npack, packcode, colorcode)
                    //print("เพิ่มใหม่ : \(insertStatementStirng)")
                    
                    if sqlite3_prepare_v2(db, insertStatementStirng, -1, &Statement, nil) == SQLITE_OK
                    {
                        if sqlite3_step(Statement) != SQLITE_DONE
                        {
                            print("Could not insert row.")
                        }
                    } else {
                        print("Inset statement could not be prepared")
                    }
                    
                    sqlite3_finalize(Statement)
                }
            }
            
            
            ///==========  Clear tmp_odmst  =============
            let deltable = String(format:"DELETE FROM tmp_odmst")
            var Statement2: OpaquePointer? = nil
            
            if sqlite3_prepare_v2(db, deltable, -1, &Statement2, nil) == SQLITE_OK
            {
                if sqlite3_step(Statement2) != SQLITE_DONE
                {
                    print("Could not clear table.")
                }
            }
            else
            {
                print("statement could not be prepared")
            }
            
            sqlite3_finalize(Statement2)
            sqlite3_close(db)
        }
        else
        {
            print("error opening database")
        }
    }
    
}

extension Prod7SolidViewController: Prod7CellDelegate
{
    func Add(prodcode : String, packcode : String, pairs : Int)
    {
        AddDelQty(Type: "ADD", prod: prodcode, code: CustomerViewController.GlobalValiable.myCode, packcode: packcode, colorcode: CustomerViewController.GlobalValiable.colorcode, pairs: pairs)
        //Query()
        ChkQtyPerBox()  //แสดงจำนวนคู่ขณะนั้น
        getODTransection()
    }
    
    func Delete(prodcode : String, packcode : String, pairs : Int)
    {
        AddDelQty(Type: "DEL", prod: prodcode, code: CustomerViewController.GlobalValiable.myCode, packcode: packcode, colorcode: CustomerViewController.GlobalValiable.colorcode, pairs: pairs)
        ChkQtyPerBox()  //แสดงจำนวนคู่ขณะนั้น
        getODTransection()
    }
    
    func SaveRecCurrent(prodcode : String, packcode : String, pairs : Int)
    {
        blnSaveCurrRec = true
        AddDelQty(Type: "ADJ", prod: prodcode, code: CustomerViewController.GlobalValiable.myCode, packcode: packcode, colorcode: CustomerViewController.GlobalValiable.colorcode, pairs: pairs)
        ChkQtyPerBox()  //แสดงจำนวนคู่ขณะนั้น
        getODTransection()
    }
    
    func SaveQtyFree(prodcode: String, packcode: String, pairs: Int)
    {
        blnSaveCurrRec = true
        blnAEfreeQty = true

        AddDelQty(Type: "ADJ", prod: prodcode, code: CustomerViewController.GlobalValiable.myCode, packcode: packcode, colorcode: CustomerViewController.GlobalValiable.colorcode, pairs: pairs)
        ChkQtyPerBox()  //แสดงจำนวนคู่ขณะนั้น
        getODTransection()
        
        qty_solid = 0  //Clear
        qtyFree = 0    //Clear
        blnAEfreeQty = false
    }
}

extension Prod7SolidViewController: UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return prod7.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return "แบบแพ็ค:                              แถม(คู่):                               จำนวนคู่:"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let _prod7 = prod7[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! Prod7Cell
        cell.setData(Pro7: _prod7, stat: blnFree)
        cell.txtQty.delegate = self
        cell.txtFree.delegate = self
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        //let _prod7 = prod7[indexPath.row]
        intRownumber = indexPath.row  //เก็บ row ปัจจุบันที่แก้ไข
    }
    
    // Called when the user click on the view (outside the UITextField).
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
    //ซ่อนคีย์บอร์ด
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        //print("End editing...")
        if (blnSaveCurrRec)  //เปลี่ยนสี background textfield
        {
            if (qty_solid == 0)
            {
                textField.backgroundColor = UIColor.white
            }
            else
            {
                textField.backgroundColor = UIColor.green
            }
            
        }
        else
        {
            textField.backgroundColor = UIColor.white
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //เฉพาะตัวเลข
        let allowCharactors = "0123456789"
        let allowCharactorSet = CharacterSet(charactersIn: allowCharactors)
        let typedCharactorSet = CharacterSet(charactersIn: string)
        
        if (string == "")
        {
            strQtySolid = ""
        }
        
        if (string.count > 0)
        {
            strQtySolid = "\(strQtySolid)\(string)"
            
            if (textField.tag == 0)
            {
                qtyFree = (strQtySolid as NSString).integerValue
            }
            else
            {
                qty_solid = (strQtySolid as NSString).integerValue
            }
            //print(strQtySolid)
        }
        
        return allowCharactorSet.isSuperset(of: typedCharactorSet)
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        //print("Begin")
        strQtySolid = ""  //เพิ่มมาใหม่
        blnSaveCurrRec = false
        textField.backgroundColor = UIColor.orange
        
        //หา แบบแพ็คจาก​ Row ปัจจุบัน
        let view = textField.superview!
        let cell = view.superview as! UITableViewCell
        let indexPath : NSIndexPath = myTable.indexPath(for: cell)! as NSIndexPath
        //let rowNumber : Int = indexPath.row
        intRownumber = indexPath.row
        
        if (textField.text == "0")
        {
            textField.text = ""
        }
        
        let _prod7 = prod7[intRownumber]
        CustomerViewController.GlobalValiable.packcode7 = _prod7.packcode!
        CustomerViewController.GlobalValiable.pairs = _prod7.pairs!
    }
    
    /*
     for prod in prod7
     {
     print("\(String(describing: prod.style!)): \(String(describing: prod.sizedesc!)): \(String(describing: prod.packcode!)): \(String(describing: prod.qty!))")
     }
     */
}
