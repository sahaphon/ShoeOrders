//
//  CustomerViewController.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 10/12/18.
//  Copyright © 2018 rich_noname. All rights reserved.
//

import UIKit
import SQLite3

class CustomerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate
{
    @IBOutlet var SearchBar: UISearchBar!
    @IBOutlet var myTableview: UITableView!
    
    //ตัวแปรสำหรับกรองข้อมูล
    var searchActive : Bool = false
    //var filtered = [String:String]() //เก็บผลลัพธ์การกรองข้อมูล

    var db: OpaquePointer?
    var arList = [Ar]()  //ประกาศตัวแปรของคลาส
    
    //Create SQLite
    let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("order.sqlite")
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        /* Setup delegates */
        SearchBar.delegate = self
        
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.black,
             NSAttributedString.Key.font: UIFont(name: "PSL Display", size: 30)!]
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 256.0 / 255.0, green: 69.0 / 255.0, blue: 0.0 / 255.0, alpha: 100.0)
        query()  //Read data
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        let ar: Ar
        
        ar = arList[indexPath.row]
        //cell.backgroundColor = UIColor.gray
        
        cell.textLabel?.font = UIFont(name:"PSL Display", size: 30.0)
        cell.textLabel?.textColor = UIColor.purple
        cell.backgroundColor = UIColor.white
//        cell.detailTextLabel?.font = UIFont(name:"PSL Display", size: 28.0)
//        cell.detailTextLabel?.textColor = UIColor.black
        
        cell.textLabel?.text = ar.code! + " : " +  ar.name!
        
        return cell
    }
    
    func query()
    {
        //Open db
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            //first empty the list of ar
            arList.removeAll()
            
            let queryString = "SELECT code, name FROM armstr GROUP BY code, name"
            
            //statement pointer
            var stmt:OpaquePointer?
            
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            
            //Clear dicictionary
            arList.removeAll()
            
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                let cust_id = String(cString: sqlite3_column_text(stmt, 0))
                let name = String(cString: sqlite3_column_text(stmt, 1))
                
                //adding values to list
                arList.append(Ar(code: String(describing: cust_id), name: String(describing: name)))
            }

            myTableview.reloadData()
            
            // 6
            sqlite3_finalize(stmt)
            sqlite3_close(db)
        }
        else
        {
            print("error opening database")
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
        self.SearchBar.endEditing(true)
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
    
    func filter(searchTxt:String)
    {
        //Open db
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            //first empty the list of ar
            arList.removeAll()
            
            let queryString = String(format:"SELECT code, name FROM armstr WHERE name LIKE '%%%@%%' GROUP BY code, name", searchTxt)
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
            arList.removeAll()
           
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                let cust_id = String(cString: sqlite3_column_text(stmt, 0))
                let name = String(cString: sqlite3_column_text(stmt, 1))
                
                //adding values to list
                arList.append(Ar(code: String(describing: cust_id), name: String(describing: name)))
            }
            
            myTableview.reloadData()
            
            sqlite3_finalize(stmt)
            sqlite3_close(db)
        }
        else
        {
            print("error opening database")
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let delegate = UIApplication.shared.delegate as? AppDelegate
        {
            let cell = tableView.cellForRow(at: indexPath)
            let str = (cell?.textLabel?.text)!
            let result = str.components(separatedBy: " : ")
            GlobalValiable.myCode = result[0]
            GlobalValiable.desc = result[1]
            
            LoadCrdit(ar: GlobalValiable.myCode)
            
            let storyboard : UIStoryboard? = UIStoryboard(name: "Main", bundle: nil)
            let rootController = storyboard!.instantiateViewController(withIdentifier: "ListOD")
            delegate.window?.rootViewController = rootController
        }
        
//        if let menu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ListOD") as? ListOdViewController
//        {
//            let cell = tableView.cellForRow(at: indexPath)
//
//            let str = (cell?.textLabel?.text)!
//            let result = str.components(separatedBy: " : ")
//            GlobalValiable.myCode = result[0]
//            GlobalValiable.desc = result[1]
//
//            LoadCrdit(ar: GlobalValiable.myCode)
//
//            //print("ส่วนลด : ",arList[indexPath.row].disc!)
//            self.present(menu, animated: true, completion: nil)
//        }
    }
    
    func LoadCrdit(ar:String)
    {
        //Open db
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            //let queryString = String(format:"SELECT cr_term, disc FROM armstr WHERE code = '%@' AND cr_term <> 75", ar)
            let queryString = String(format:"SELECT cr_term, disc, typevat FROM armstr WHERE code = '%@' ORDER BY cr_term LIMIT 1", ar)
            
            var stmt:OpaquePointer?
            
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing : \(errmsg)")
                return
            }
            
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                GlobalValiable.cr_term = Int(sqlite3_column_int(stmt, 0))
                GlobalValiable.disc = Int(sqlite3_column_int(stmt, 1))
                GlobalValiable.type_vat = Int(sqlite3_column_int(stmt, 2))
            }
            
            //print("ส่วนลดที่เลือก : ",  GlobalValiable.cr_term)
            sqlite3_finalize(stmt)
            sqlite3_close(db)
        }
        else
        {
            print("error opening database")
        }
    }
    
    //ประกาศ GlobalValiable
    struct GlobalValiable
    {
        static var blnEditShip = false     //กรณีมีการแก้ไขวันที่ส่ง
        static var blnEditCrterm = false   //กรณีมีการแก้ไขเครดิตเทอม
        static var blnEditLogistic = false  //แก้ขสถานที่ส่ง
        static var blnEditRemark = false    //หมายเหตุ
        
        static var myCode = String()
        static var desc = String()
        static var strShipDate = String()
        static var cr_term : Int = 0  //เดิม Int
        static var saleid = String()
        
        
        //ส่งที่
        static var logiCode = String()  //เช่น 01
        static var logiName = String()   //เช่น เบบี้
        static var logisCode = String() //เช่่น สพ.
        
        
        
        static var remark = String()
        static var disc : Int = 0
        static var recfirm : Int = 0 //งานสั่งทำ
        static var vat : Int = 0 //vat
        static var pono = String()
        static var pro : Int = 0 //จัดโปรโมชั่น
        
        
        
        //ปุ่มรอส่ง
        static var sale_type = false //งานสั่งทำ(เลิกใช้) เดิม waitsend
        
        
        static var prod = String() //รุ่นที่เลือก
        static var n_pack : Int = 0
        static var color = String() //สีทีเลือก
        static var colorcode = String() //รหัสสี
        static var free = "" // แถม
        
        //เลือกแบบแพ็ค จำนวนคู่
        static var pairs: Int = 0 //จำนวนคู่ ต่อ กล่อง
        static var qty: Int = 0 //เก็บจำนวนคู่ ที่คีย์ต่อกล่อง
        static var odnumber = String() //เจน เลขที่ od
        static var od = String() //รายละเอียด od ที่สั่งไปแล้ว
        
        //prod 7 solid
        static var packcode7 = String()
        static var invno = String()  //เก็บเลขที่อินวอยส์ หน้าอินวอยส์ค้าง 30 วัน
        static var fromView = String()
        
        //เก็บตาราง DBF serverCAT สำหรับบันทึก OD
        static var table_name = String()
        static var locat_name = String() //กรณีเพิ่มสถานที่ส่งใหม่ ให้เก้บในเครื่องแล้วพี่เจษจะเพิ่มให้ทีหลัง
        static var blnNewLogicode = 0 //ระบุว่าเป็นสถานท่ี่ส่งใหม่ที่เพิ่มเข้ามา
        
        //เก็บข้อมูลรุ่นที่เคยคีย์ก่อนหน้าง
        static var oldprod = String()
        //static var main_npack: Int = 0 //กำหนดให้ 1 OD มีแค่ 1 แบบแพ็คเท่านั้น
        
        //Solid จัด Asort
        static var blnSolidPackAsort = false
        
        //วันที่ Server
        static var sevdate = String()
        static var type_vat: Int = 0  //vat รายร้านค้า
        
        //ธุรการสั่งจัด
//        static var blnadmin_pk = false
    }
}
