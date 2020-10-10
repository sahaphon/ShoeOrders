//
//  Prod7ViewController.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 3/5/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit
import SQLite3

class Prod7ViewController: UIViewController
{
    @IBOutlet weak var lblProd: UILabel!
    @IBOutlet weak var lblColor: UILabel!
    @IBOutlet weak var myTable: UITableView!
    @IBOutlet weak var lblSumQty: UILabel! //เก็บจำนวนคู่รวม
    
    var db: OpaquePointer?
    let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("order.sqlite")
    
    var prod7 = [Pro7]()          //ประกาศตัวแปรของคลาส
    var intRownumber: Int = 0     //เก็บ Rows ที่กำลังแก้ไข
    var qty_solid : Int = 0       //เก็บจำนวนคู่เฉพาะ prod7 solid
    var blnSave : Bool = false

    override func viewDidLoad()
    {
       super.viewDidLoad()
  
       UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self]).font = UIFont.boldSystemFont(ofSize: 25)
        
       if let font = UIFont(name: "PSL Display", size: 25)
       {
          UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self]).font = font
       }
        
        
        self.lblProd.text = CustomerViewController.GlobalValiable.prod
        self.lblColor.text = "สี : " + CustomerViewController.GlobalValiable.color
        self.myTable.delegate = self
        CustomerViewController.GlobalValiable.qty = 0
        
        Query()
        PrepairData()
    }
    
    @IBAction func btnCancel(_ sender: Any)
    {
        if let menu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Keyod") as? TakeOrderViewController
        {
            CustomerViewController.GlobalValiable.qty = 0
            self.present(menu, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnSave(_ sender: Any)
    {
        blnSave = true
        var blnHaveDt: Int = 0
        
        for dt in prod7
        {
            let  _qty = dt.qty!
            
            if _qty > 0
            {
                blnHaveDt = 1
            }
        }
        
        
        if (blnHaveDt == 1 && ChkQtyPerBox())
        {
            ConfirmData()
            //SaveData_P7()
            CustomerViewController.GlobalValiable.qty = 0
            
            if let menu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Keyod") as? TakeOrderViewController
            {
                self.present(menu, animated: true, completion: nil)
            }
        }
        else
        {
            //Alert
            let alert = UIAlertController(title: "Warnning!", message: "จำนวนคู่รวมไม่ถูกต้อง กรุณาลองใหม่อีกครั้ง..", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "ตกลง", style: .default, handler: nil))
            self.present(alert, animated: true)
            
            blnSave = false
        }
    }
    
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
            let queryString = String(format:"SELECT qty FROM odmst WHERE prodcode = '%@' AND code ='%@' AND colorcode = '%@'", "GS-" + lblProd.text!, CustomerViewController.GlobalValiable.myCode, CustomerViewController.GlobalValiable.colorcode)
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
               //print("sumQty ======> : ", _sumQty)
               _sumQty = _sumQty + Int(sqlite3_column_int(stmt, 0))
            }
            
            sqlite3_finalize(stmt)
            sqlite3_close(db)
            
            //print("sumQty : ", _sumQty)
            lblSumQty.text = "***" + String(_sumQty)
            
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
            let UpdateSql = String(format:"UPDATE odmst SET status = '' WHERE code ='%@'", CustomerViewController.GlobalValiable.myCode)
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
            var i:Int = 0
            var statement: OpaquePointer?
            
            let deleteStatementString = String(format:"DELETE FROM odmst WHERE code = '%@'", CustomerViewController.GlobalValiable.myCode)
          
            var deleteStatement: OpaquePointer?
            
            if sqlite3_prepare(db1, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK
            {
                if sqlite3_step(deleteStatement) == SQLITE_DONE
                {
                    print("Successfully deleted row.")
                }
                else{
                    print("Could not delete row.")
                }
            }
            else
            {
                print("DELETE statement could not be prepared")
            }
            
            sqlite3_finalize(deleteStatement)
            /*
            if sqlite3_close_v2(db) == SQLITE_OK{
                print("closed")
            }
            */
            
            for dt in prod7
            {

                let  _qty = dt.qty!
                
                //บันทึกเฉพาะที่ระบุจำนวน
                let insertSql = "INSERT INTO odmst (status, date, delivery, code, orderno, no, prodcode, n_pack, packcode, sizedesc, colorcode, colordesc, qty, price, amt, packno, pairs, dozen, disc1, pono, tax_rate, vat_type, tax_amt, net_amt, cr_term, saleman, remark, recfirm, incvat, logis_code, logicode, ctrycode, store)" + " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);"
                    
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
                        var send = CustomerViewController.GlobalValiable.logis
                        send = String(send.prefix(2))
                        
                        sqlite3_bind_text(statement, 1, "N", -1, SQLITE_TRANSIENT)
                        sqlite3_bind_text(statement, 2, dateFormatter.string(from: date), -1, SQLITE_TRANSIENT)
                        sqlite3_bind_text(statement, 3, dateFormatter.string(from: date), -1, SQLITE_TRANSIENT)
                        sqlite3_bind_text(statement, 4, CustomerViewController.GlobalValiable.myCode, -1, SQLITE_TRANSIENT)
                        sqlite3_bind_text(statement, 5, "", -1, SQLITE_TRANSIENT)  //ยังไม่กำหนด เลขที่ od จนกว่าจะกดส่งข้อมูล
                        sqlite3_bind_int(statement, 6, Int32(i))      //Int32(numRec!))
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
                        sqlite3_bind_text(statement, 30, "", -1, SQLITE_TRANSIENT) //logis_code
                        sqlite3_bind_text(statement, 31, send, -1, SQLITE_TRANSIENT)
                        sqlite3_bind_text(statement, 32, "TH", -1, SQLITE_TRANSIENT)
                        sqlite3_bind_text(statement, 33, CustomerViewController.GlobalValiable.free, -1, SQLITE_TRANSIENT)
                        
                        //executing the query to insert values
                        if sqlite3_step(statement) != SQLITE_DONE
                        {
                            let errmsg = String(cString: sqlite3_errmsg(db1)!)
                            print("failure Inserting armstr: \(errmsg)")
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
                
                i = i + 1
            } //Close for loops
            
            sqlite3_close(db1)
        }
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
            
            let queryString = String(format:"SELECT prodcode, style, n_pack, packcode, packno, sizedesc, pairs FROM prodlist WHERE prodcode = '%@' AND n_pack ='%@' AND colorcode = '%@'", "GS-" + strProd, String(strNpack), strColor)
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
                CustomerViewController.GlobalValiable.pairs = Pairs  //เก็บจำนวนแพ็ค
                
                //Adding values to list
                prod7.append(Pro7(prodcode: Prod, style: Style, npack: Npack, packcode: Packcode, packno: Packno, sizedesc: Size, pairs: Pairs, qty: 0))
            }
            
            myTable.reloadData()
            
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
            
            let queryString = String(format:"SELECT prodcode, n_pack, packcode, packno, sizedesc, pairs, qty FROM odmst WHERE code = '%@' AND prodcode = '%@' AND n_pack ='%@' AND status = 'N'", CustomerViewController.GlobalValiable.myCode, "GS-" + strProd, String(strNpack))
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
                                
                //Adding values to list
                prod7.append(Pro7(prodcode: Prod, style: Style, npack: Npack, packcode: Packcode, packno: Packno, sizedesc: Size, pairs: Pairs, qty: Qty))
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
            let queryString = String(format:"SELECT qty FROM odmst WHERE prodcode = '%@' AND code ='%@' AND packcode = '%@' AND colorcode = '%@'", prod, code, packcode, colorcode)
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
                     qty = qty + CustomerViewController.GlobalValiable.pairs
                }
                else if (Type == "DEL")
                {
                    if (qty != 0)
                    {
                        qty = qty - CustomerViewController.GlobalValiable.pairs
                        if (qty < 0)
                        {
                            qty = 0
                        }
                    }
                }
                else //Adjust ยอด
                {
                    qty = qty_solid
                    
                    if (qty < 0)
                    {
                        qty = 0
                    }
                }
               
               //Update จำนวนคู่
               let UpdateSql = String(format:"UPDATE odmst SET qty = \(qty) WHERE prodcode = '%@' AND code ='%@' AND packcode = '%@' AND colorcode = '%@'", prod, code, packcode, colorcode)
                //print("อัพเดท : \(UpdateSql)")
                
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
    
    /*
    func SaveData_P7()
    {
        var db1: OpaquePointer?
        //Open db
        if sqlite3_open(fileURL.path, &db1) == SQLITE_OK
        {
            //บันทึกข้อมูลชุดใหม่
            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            var i:Int = 0
            var statement: OpaquePointer?
            
            for dt in prod7
            {
                let  _qty = dt.qty!
                
                //บันทึกเฉพาะที่ระบุจำนวน
                if _qty > 0
                {
                    let insertSql = "INSERT INTO odmst (status, date, delivery, code, orderno, no, prodcode, n_pack, packcode, sizedesc, colorcode, colordesc, qty, price, amt, packno, pairs, dozen, disc1, pono, tax_rate, vat_type, tax_amt, net_amt, cr_term, saleman, remark, recfirm, incvat, logis_code, logicode, ctrycode, store)" + " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);"
                    
                    //preparing the query
                    if sqlite3_prepare(db1, insertSql, -1, &statement, nil) == SQLITE_OK
                    {
                        // Create date formatter
                        let date = Date()
                        let dateFormatter: DateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd/MM/yyyy"
                        
                        let numRec = getNumberOfRec()
                        let intQty:Int = prod7[intRownumber].qty!
                        let intDozen:Int = intQty / 12
                        var send = CustomerViewController.GlobalValiable.logis
                        send = String(send.prefix(2))
                        
                        sqlite3_bind_text(statement, 1, "", -1, SQLITE_TRANSIENT)
                        sqlite3_bind_text(statement, 2, dateFormatter.string(from: date), -1, SQLITE_TRANSIENT)
                        sqlite3_bind_text(statement, 3, dateFormatter.string(from: date), -1, SQLITE_TRANSIENT)
                        sqlite3_bind_text(statement, 4, CustomerViewController.GlobalValiable.myCode, -1, SQLITE_TRANSIENT)
                        sqlite3_bind_text(statement, 5, "", -1, SQLITE_TRANSIENT)  //ยังไม่กำหนด เลขที่ od จนกว่าจะกดส่งข้อมูล
                        sqlite3_bind_int(statement, 6, Int32(numRec!))
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
                        sqlite3_bind_text(statement, 30, "", -1, SQLITE_TRANSIENT) //logis_code
                        sqlite3_bind_text(statement, 31, send, -1, SQLITE_TRANSIENT)
                        sqlite3_bind_text(statement, 32, "TH", -1, SQLITE_TRANSIENT)
                        sqlite3_bind_text(statement, 33, CustomerViewController.GlobalValiable.free, -1, SQLITE_TRANSIENT)
                        
                        //executing the query to insert values
                        if sqlite3_step(statement) != SQLITE_DONE
                        {
                            let errmsg = String(cString: sqlite3_errmsg(db1)!)
                            print("failure Inserting armstr: \(errmsg)")
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
                }
                
                i = i + 1
            } //Close for loops
            
            sqlite3_close(db1)
        }
    }*/
}

    
extension Prod7ViewController: Prod7CellDelegate
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
}

extension Prod7ViewController: UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate
{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return prod7.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return "แบบแพ็ค:                                                        จำนวนคู่:"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let _prod7 = prod7[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! Prod7Cell
        cell.setData(Pro7: _prod7)
        cell.txtQty.delegate = self
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        //let _prod7 = prod7[indexPath.row]
        intRownumber = indexPath.row  //เก็บ row ปัจจุบันที่แก้ไข
        //print(_prod7.packcode!)
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
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //เฉพาะตัวเลข
        let allowCharactors = "0123456789"
        let allowCharactorSet = CharacterSet(charactersIn: allowCharactors)
        let typedCharactorSet = CharacterSet(charactersIn: string)
        //print("===>", string)
        
        if (string.count > 0)
        {
            let intVal = (string as NSString).integerValue
            //if (intVal > 0)  //กรอกเป็น 0 ได้
            //{
                qty_solid = intVal
                
                //ADJ == คีย์มือ
                AddDelQty(Type: "ADJ", prod: "GS-" + lblProd.text!, code: CustomerViewController.GlobalValiable.myCode, packcode: CustomerViewController.GlobalValiable.packcode7, colorcode: CustomerViewController.GlobalValiable.colorcode, pairs: CustomerViewController.GlobalValiable.pairs)
            
                ChkQtyPerBox()  //แสดงจำนวนคู่ขณะนั้น
                getODTransection()
                qty_solid = 0
            //}
        }
       
        return allowCharactorSet.isSuperset(of: typedCharactorSet)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        //print("Begin")
        //หา แบบแพ็คจาก​ Row ปัจจุบัน
        let view = textField.superview!
        let cell = view.superview as! UITableViewCell
        let indexPath : NSIndexPath = myTable.indexPath(for: cell)! as NSIndexPath
        //let rowNumber : Int = indexPath.row
        intRownumber = indexPath.row
        
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
