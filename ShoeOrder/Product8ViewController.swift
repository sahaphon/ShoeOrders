//
//  Product8ViewController.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 8/24/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit
import Alamofire
import SQLite3

class Product8ViewController: UIViewController {

    @IBOutlet weak var lblTile: UILabel!
    @IBOutlet weak var lblProd: UILabel!
    @IBOutlet weak var lblColor: UILabel!
    @IBOutlet weak var lblNpack: UILabel!
    @IBOutlet weak var myTable: UITableView!
    
    @IBOutlet weak var lblSumQty: UILabel!
    
    var P8 = [Prod8]()          //ประกาศตัวแปรของคลาส
    var intRownumber: Int = 0     //เก็บ Rows ที่กำลังแก้ไข
    
    var db: OpaquePointer?
    let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("order.sqlite")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblProd.text = CustomerViewController.GlobalValiable.prod
        lblColor.text = CustomerViewController.GlobalValiable.color
        
        if (CustomerViewController.GlobalValiable.n_pack == 1)
        {
            lblNpack.text = "แพ็ค Asort"
        }
        else
        {
            lblNpack.text = "แพ็ค Solid"
        }
        
        self.myTable.delegate = self
        QueryData()
    }
    
    @IBAction func btnSave(_ sender: Any)
    {
        
    }
    
    @IBAction func btnCancel(_ sender: Any)
    {
        
    }
    
    func QueryData()
    {
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            let queryString = String(format:"select prodcode, packcode, packno, colorcode, sizedesc, pairs FROM prodlist WHERE prodcode = '%@' AND colorcode = '%@' AND n_pack = '%@'", "GS-" + CustomerViewController.GlobalValiable.prod, CustomerViewController.GlobalValiable.colorcode, CustomerViewController.GlobalValiable.n_pack)
            print("คิวรี่ : \(queryString)")
            
            var stmt:OpaquePointer?
            
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK
            {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing : \(errmsg)")
            }
            
            self.P8.removeAll()
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                let prodcode = String(cString: sqlite3_column_text(stmt, 0))
                let packcode = String(cString: sqlite3_column_text(stmt, 1))
                let packno = String(cString: sqlite3_column_text(stmt, 2))
                //let colorcode = String(cString: sqlite3_column_text(stmt, 3))
                let sizedesc = String(cString: sqlite3_column_text(stmt, 4))
                let pairs = String(cString: sqlite3_column_text(stmt, 5))
                
                self.P8.append(Prod8(packcode: packcode, prodcode: prodcode, pairs: Int(pairs), packno: packno, free: "แถม", packdesc: sizedesc, qty: 0))
            }
            
            sqlite3_finalize(stmt)
            sqlite3_close(db)
        }
    }
}

extension Product8ViewController: UITableViewDataSource, UITableViewDelegate
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return P8.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return "       แบบแพ็ค:                                                                                             จำนวนคู่:"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let _P8 = P8[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! Prod8Cell
        cell.setData(Prod8: _P8)
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
        //blnInputQty = true
        
        if let menu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "qty") as? PassQtyViewController
        {
            CustomerViewController.GlobalValiable.pairs = 6  //default 6 คู่/กล่อง
            self.present(menu, animated: true, completion: nil)
        }
    }
}

extension Product8ViewController: Prod8CellDelegate
{
    func Plus(packcode: String)
    {
//        var i : Int = 0
//        var sumQty: Int = 0
//        var total : Int = 0
//
//        for (value) in solidasorts
//        {
//
//            if (value.packcode! == packcode)
//            {
//                sumQty = value.qty! + 6
//                total = total + sumQty
//                solidasorts[i].qty! = sumQty
//            }
//            else
//            {
//                total = total + value.qty!
//            }
//
//            i = i + 1
//        }
//
//        myTable.reloadData()
//        lblSumQty.text = String(format: "%ld", total)
    }
    
    func Min(packcode: String)
    {
//        var i : Int = 0
//        var sumQty: Int = 0
//        var total : Int = 0
//
//        for (value) in solidasorts
//        {
//
//            if (value.packcode! == packcode)
//            {
//                if (value.qty! != 0)
//                {
//                    sumQty = value.qty! - 6
//                    total = total + sumQty
//                    solidasorts[i].qty! = sumQty
//                }
//
//            }
//            else
//            {
//                total = total - value.qty!
//            }
//
//            i = i + 1
//        }
//
//        myTable.reloadData()
//        lblSumQty.text = String(format: "%ld", total)
    }
}

