//
//  PackTypeViewController.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 1/10/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit
import SQLite3

class PackTypeViewController: UIViewController {
    
    @IBOutlet weak var lblProd: UILabel!
    @IBOutlet weak var lblColor: UILabel!
    @IBOutlet weak var myTable: UITableView!
    
    var db: OpaquePointer?
    let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("order.sqlite")
    
    var product = [prod]()  //ประกาศตัวแปรของคลาส
    var intRownumber: Int = 0  //เก็บ Rows ที่กำลังแก้ไข
    
    override func viewDidLoad() {
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
    }
    
    func Query()
    {
        //Open db
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            //first empty the list of ar
            product.removeAll()
            
            let strProd = CustomerViewController.GlobalValiable.prod
            let strNpack = CustomerViewController.GlobalValiable.n_pack
            let strColor = CustomerViewController.GlobalValiable.colorcode
            
            let queryString = String(format:"SELECT prodcode, style, n_pack, packcode, packno, sizedesc, pairs FROM prodlist WHERE prodcode = '%@' AND n_pack ='%@' AND colorcode = '%@'", "GS-" + strProd, String(strNpack), strColor)
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
            product.removeAll()
            
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                let Prod = String(cString: sqlite3_column_text(stmt, 0))
                let Style = String(cString: sqlite3_column_text(stmt, 1))
                let Npack = Int(sqlite3_column_int(stmt, 2))
                let Packcode = String(cString: sqlite3_column_text(stmt, 3))
                let Packno = String(cString: sqlite3_column_text(stmt, 4))
                let Size = String(cString: sqlite3_column_text(stmt, 5))
                let Pairs = Int(sqlite3_column_int(stmt, 6))
                
                //Adding values to list
                product.append(prod(prodcode: Prod, style: Style, npack: Npack, packcode: Packcode, packno: Packno, sizedesc: Size, pairs: Pairs, qty: 0))
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
        var blnHaveDt: Int = 0
        
        for dt in product
        {
            let  _qty = dt.qty!
            
            if _qty > 0
            {
                blnHaveDt = 1
            }
        }
        
        if blnHaveDt == 1
        {
            SaveData()
            CustomerViewController.GlobalValiable.qty = 0
            CustomerViewController.GlobalValiable.free = ""  //Clear valible
            
            if let menu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Keyod") as? TakeOrderViewController
            {
                self.present(menu, animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        product[intRownumber].qty = CustomerViewController.GlobalValiable.qty
        myTable.reloadData()
    }
    
    func SaveData()
    {
         var db1: OpaquePointer?
        //Open db
        if sqlite3_open(fileURL.path, &db1) == SQLITE_OK
        {
            //บันทึกข้อมูลชุดใหม่
            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            var i:Int = 0
            var statement: OpaquePointer?
            
            for dt in product
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
                        let intQty:Int = product[intRownumber].qty!
                        let intDozen:Int = intQty / 12
                        var send = CustomerViewController.GlobalValiable.logis
                        send = String(send.prefix(2))
                        
                        sqlite3_bind_text(statement, 1, "", -1, SQLITE_TRANSIENT)
                        sqlite3_bind_text(statement, 2, dateFormatter.string(from: date), -1, SQLITE_TRANSIENT)
                        sqlite3_bind_text(statement, 3, dateFormatter.string(from: date), -1, SQLITE_TRANSIENT)
                        sqlite3_bind_text(statement, 4, CustomerViewController.GlobalValiable.myCode, -1, SQLITE_TRANSIENT)
                        sqlite3_bind_text(statement, 5, "", -1, SQLITE_TRANSIENT)  //ยังไม่กำหนด เลขที่ od จนกว่าจะกดส่งข้อมูล
                        sqlite3_bind_int(statement, 6, Int32(numRec!))
                        sqlite3_bind_text(statement, 7, product[i].prodcode, -1, SQLITE_TRANSIENT)
                        sqlite3_bind_text(statement, 8, String(CustomerViewController.GlobalValiable.n_pack), -1, SQLITE_TRANSIENT)
                        sqlite3_bind_text(statement, 9, product[i].packcode, -1, SQLITE_TRANSIENT)
                        sqlite3_bind_text(statement, 10, product[i].sizedesc, -1, SQLITE_TRANSIENT)
                        sqlite3_bind_text(statement, 11, CustomerViewController.GlobalValiable.colorcode, -1, SQLITE_TRANSIENT)
                        sqlite3_bind_text(statement, 12, CustomerViewController.GlobalValiable.color, -1, SQLITE_TRANSIENT)
                        sqlite3_bind_int(statement, 13, Int32(_qty))
                        sqlite3_bind_double(statement, 14, 0)
                        sqlite3_bind_double(statement, 15, 0)
                        sqlite3_bind_text(statement, 16, product[i].packno, -1, SQLITE_TRANSIENT)
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

}

extension PackTypeViewController: UITableViewDataSource, UITableViewDelegate
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return product.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return "แบบแพ็ค:                                                        จำนวนคู่:"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let _prod = product[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ProductCell
        cell.setData(prod: _prod)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let _prod = product[indexPath.row]
        intRownumber = indexPath.row         //เก็บ row ปัจจุบันที่แก้ไข
        
        if let menu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "qty") as? PassQtyViewController
        {
            CustomerViewController.GlobalValiable.pairs = _prod.pairs!
            self.present(menu, animated: true, completion: nil)
        }
    }
}
