//
//  MainMenuViewController.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 12/6/18.
//  Copyright © 2018 rich_noname. All rights reserved.
//

import UIKit
import Alamofire
import SQLite3

class MainMenuViewController: UIViewController {
    
    var db: OpaquePointer?
    let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("order.sqlite")
    
    @IBAction func btnKeyOrder(_ sender: Any)
    {
        if let menu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Order") as? OrderViewController
        {
            //หากมีการสร้างตาราง dbf ทิ้งไว้ให้ลบออก กันสร้างไว้แล้วไม่มี od
            if (CustomerViewController.GlobalValiable.table_name != "")
            {
                ClearData() //ล้างข้อมูลตาราง odmst
                DropDbfTable()
            }
            
            CreateDbfTable()
            self.present(menu, animated: true, completion: nil)
        }
    }

    @IBAction func btnHistory(_ sender: Any)
    {
//        let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "OD") as! ODViewController
//        let navController = UINavigationController(rootViewController: VC1)
//        self.present(navController, animated:true, completion: nil)
    }
    
    @IBAction func btnOd45(_ sender: Any)
    {
        let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "ODNotSend") as! ODNotSendViewController
        let navController = UINavigationController(rootViewController: VC1)
        self.present(navController, animated:true, completion: nil)
    }
    
    @IBAction func btnInvoice(_ sender: Any)
    {
        
    }
    
    @IBAction func btnBack(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    func CreateDbfTable()
    {
        //URL
        //let URL_USER_LOGIN = "http://consign-ios.adda.co.th/KeyOrders/create_dbf.php"
        let URL_USER_LOGIN = "http://consign-ios.adda.co.th/KeyOrders/create_dbf2.php"
        
        //getting the username and password
        let parameters : Parameters=[
            "code": CustomerViewController.GlobalValiable.myCode
        ]
        
        //print("ค่าที่ส่งไป = ", CustomerViewController.GlobalValiable.myCode)
        //making a post request
        Alamofire.request(URL_USER_LOGIN, method: .post, parameters: parameters).responseJSON
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
                        var tables:String = ""
                        
                        for personDict in array
                        {
                            tables = (personDict["tb"] as! String).trimmingCharacters(in: .whitespacesAndNewlines)
                            //res = (personDict["result"] as! String).trimmingCharacters(in: .whitespacesAndNewlines)
                            //print("สร้างตาราง => ", tables)
                            //print("status => ", res)
                            CustomerViewController.GlobalValiable.table_name = tables //เก็บตารางที่จะบันทึก
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
    
    func DropDbfTable()
    {
        //URL
        let URL_USER_LOGIN = "http://consign-ios.adda.co.th/KeyOrders/dropDbfTable.php"
        
        //getting the username and password
        let parameters : Parameters=[
            "tbname": CustomerViewController.GlobalValiable.table_name
        ]
        
        //print("ลบตาราง = ", CustomerViewController.GlobalValiable.table_name)
        //making a post request
        Alamofire.request(URL_USER_LOGIN, method: .post, parameters: parameters).responseJSON
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
                        /*/var res:String = ""
                        var tables:String = ""
                        
                        for personDict in array
                        {
                            tables = (personDict["tb"] as! String).trimmingCharacters(in: .whitespacesAndNewlines)
                            //res = (personDict["result"] as! String).trimmingCharacters(in: .whitespacesAndNewlines)
                            //print("สร้างตาราง => ", tables)
                            //print("status => ", res)
                            CustomerViewController.GlobalValiable.table_name = tables //เก็บตารางที่จะบันทึก
                        }
                        */
                    }
                    
                }
            
        }
    }
}
