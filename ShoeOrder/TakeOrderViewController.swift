//
//  TakeOrderViewController.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 12/15/18.
//  Copyright © 2018 rich_noname. All rights reserved.
//

import UIKit
import SQLite3

class TakeOrderViewController: UIViewController{

    @IBOutlet var lblCode: UILabel!
    @IBOutlet var lblDesc: UILabel!
    @IBOutlet var lblCrterm: UILabel!
    @IBOutlet var myTable: UITableView!
    @IBOutlet weak var lblAmt: UILabel!
    @IBOutlet weak var lblFree: UILabel!
    
    @IBOutlet weak var lblTitles: UILabel!
    var Orders = [Order]()  //ประกาศตัวแปรของคลาส
    
    var db: OpaquePointer?
    let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("order.sqlite")
    
    @IBAction func btnCrterm(_ sender: Any)
    {
        CustomerViewController.GlobalValiable.blnEditCrterm =  true
        if let menu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "credit") as? CrViewController
        {
            menu.modalPresentationStyle = .fullScreen
            self.present(menu, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnAdd(_ sender: Any)
    {
        if let menu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProdFill") as? ProdFilterViewController
        {
            menu.modalPresentationStyle = .fullScreen
            CustomerViewController.GlobalValiable.blnEditLogistic = true
            self.present(menu, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnSave(_ sender: Any)
    {
        //Clear orderno  ----> ย้ายไปบันทึกหน้าหลัก
        CustomerViewController.GlobalValiable.odnumber = ""
    }
    
    @IBAction func btnClose(_ sender: Any)
    {
        if let menu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Order") as? OrderViewController
        {
            menu.modalPresentationStyle = .fullScreen
            self.present(menu, animated: true, completion: nil)
        }
    }
    
    @IBOutlet var lblQty: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CustomerViewController.GlobalValiable.pro == 1 //จัดรายการ
        {
            lblTitles.text = "รายการสั่งซื้อ (PROMOTION)"
            lblTitles.backgroundColor = UIColor.yellow
        }
            
        
        lblCode.text = CustomerViewController.GlobalValiable.myCode
        lblDesc.text = CustomerViewController.GlobalValiable.desc
        lblCrterm.text = String(CustomerViewController.GlobalValiable.cr_term)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        lblCrterm.text = String(CustomerViewController.GlobalValiable.cr_term)
        
        getData()
    }
    
    func getData()
    {
        //Open db
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            //first empty the list of ar
            Orders.removeAll()
            
            let queryString = String(format:"SELECT a.prodcode, a.packcode, a.packno, a.colorcode, a.colordesc, a.sizedesc, a.store, a.n_pack, b.p_novat, SUM(qty) as qty, SUM(qty) * b.p_novat AS amt FROM odmst AS a LEFT OUTER JOIN prodlist AS b ON a.prodcode = b.prodcode AND a.packcode = b.packcode AND a.packno = b.packno AND a.colorcode = b.colorcode AND a.n_pack = b.n_pack WHERE code = '%@' AND qty > 0 AND status = '' GROUP BY a.prodcode, a.packcode, a.packno, a.colorcode, a.colordesc, a.sizedesc, a.store, a.n_pack, b.p_novat ORDER BY a.prodcode, a.colorcode, a.packcode", CustomerViewController.GlobalValiable.myCode)
//            print(queryString)
            
            var stmt:OpaquePointer?
            
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            
            var sumQty = 0
            var sumQtyFree = 0
            var sumAmt = 0.00
            var _qtyFree = 0
            
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                let _prod = String(cString: sqlite3_column_text(stmt, 0))
                let _packcode = String(cString: sqlite3_column_text(stmt, 1))
                let _colordesc = String(cString: sqlite3_column_text(stmt, 4))
                let _sizedesc = String(cString: sqlite3_column_text(stmt, 5))
                let _store = String(cString: sqlite3_column_text(stmt, 6))
                let _npack = String(cString: sqlite3_column_text(stmt, 7))
                let _qty = Int(sqlite3_column_int(stmt, 9))
                var _amt = Double(sqlite3_column_double(stmt, 10))
                
                if (_store == "แถม")
                {
                    _amt = 0
                    _qtyFree = Int(sqlite3_column_int(stmt, 9))
                }
                else
                {
                    _qtyFree = 0
                }
                
                sumQtyFree = sumQtyFree + _qtyFree
                sumQty = (sumQty + _qty) - _qtyFree
                sumAmt = sumAmt + Double(_amt)
                
                //Adding values to list
                Orders.append(Order(packcode: _packcode, prodcode: _prod, colordesc: _colordesc, sizedesc: _sizedesc, qty: _qty, free: _store, npack: _npack))
            }
            
            //ใส่ commar คั้นจำนวนเงิน
            let formattedInt = String(format: "%d", locale: Locale.current, sumQty)
            lblQty.text = formattedInt
            
            let formattedInt2 = String(format: "%d", locale: Locale.current, sumQtyFree)
            lblFree.text = formattedInt2
            
            //======= Amount ยอดเงินหักส่วนลด======
            let balAmt = sumAmt - (sumAmt * (Double(CustomerViewController.GlobalValiable.disc) / 100))
            let formattedDbl = String(format: "%.2f", locale: Locale.current, balAmt)
            lblAmt.text = formattedDbl
            
            myTable.reloadData()
            
            sqlite3_finalize(stmt)
            sqlite3_close(db)
        }
        else
        {
            print("error opening database")
        }
    }
    
    func DeleteData(code: String, prod: String, packcode: String, colordsc: String, free: String)
    {
        //Open db
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
             var deleteStatement: OpaquePointer? = nil
             let deleteStatementStirng = String(format:"DELETE FROM odmst WHERE status = '' AND code = '%@' AND prodcode = '%@' AND packcode = '%@' AND colordesc = '%@' AND store = '%@'", code, prod, packcode, colordsc, free)
            
            if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {
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
            sqlite3_close(db)
        }
        else
        {
            print("error opening database")
        }
    }
}

extension TakeOrderViewController: UITableViewDataSource, UITableViewDelegate
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Orders.count
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return "          รุ่น:                          สี:                       แบบแพ็ค:                                                                        จำนวนคู่:"
    }
 
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let _Order = Orders[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! OrderCell
        cell.setData(Order: _Order)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let Order = Orders[indexPath.row]
        CustomerViewController.GlobalValiable.prod = String(Order.prodcode!.suffix(7))  //GS-52201M1   ตัดเอา 7 ตัวท้าย
        CustomerViewController.GlobalValiable.n_pack = Int(Order.npack!)!
        
        if (Order.prodcode!.count > 0 && CustomerViewController.GlobalValiable.blnSolidPackAsort == false)  //หาก Rows มีข้อมูล
        {
            if (CustomerViewController.GlobalValiable.n_pack == 1) //Asort
            {
                if let menu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "asort") as? AsortOnlyViewController
                {
                    menu.modalPresentationStyle = .fullScreen
                    self.present(menu, animated: true, completion: nil)
                }
            }
            else  //Solid
            {
                if let menu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "color") as? ColorsViewController
                {
                    menu.modalPresentationStyle = .fullScreen
                    self.present(menu, animated: true, completion: nil)
                }

            }
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete {

            let _packcode = Orders[indexPath.row].packcode!
            let _colordesc = Orders[indexPath.row].colordesc!
            
            DeleteData(code: CustomerViewController.GlobalValiable.myCode, prod: Orders[indexPath.row].prodcode!, packcode: _packcode, colordsc: _colordesc, free: Orders[indexPath.row].free!)
            self.Orders.remove(at: indexPath.row)
            self.myTable.deleteRows(at: [indexPath], with: .automatic)
            
            getData()
        }
    }

}

