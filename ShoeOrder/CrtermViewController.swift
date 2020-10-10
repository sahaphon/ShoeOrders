//
//  CrtermViewController.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 11/1/18.
//  Copyright © 2018 rich_noname. All rights reserved.
//

import UIKit
import SQLite3

class CrtermViewController: UITabBarController, UIPickerViewDelegate
{
    var db: OpaquePointer?
    var cr_term : [Int] = [Int]()
    var code = ""
    
    //Create SQLite
    let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("order.sqlite")
    
    @IBAction func btnOK(_ sender: Any)
    {
        
    }
    
    @IBAction func btnCancel(_ sender: Any)
    {
        
    }
    
    
    @IBOutlet var myPicker: UIPickerView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //myPicker.delegate = self
        LoadCrdit(ar: code)
    }
    
    func LoadCrdit(ar:String)
    {
        //Open db
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            //first empty array
            cr_term.removeAll()
            
            let queryString = String(format:"SELECT cr_term FROM armstr WHERE code = ?", ar)
            print(queryString)
            
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
                //let cust_id = String(cString: sqlite3_column_text(stmt, 0))
                //let name = String(cString: sqlite3_column_text(stmt, 1))
                
                cr_term.append(Int(sqlite3_column_int(stmt, 0)))
            }
            /* วนลูปแสดงค่าใน array
             for (code,name) in custm
             {
             print("\(code):\(name)")
             }
             */
            //myTableview.reloadData()
            
            // 6
            sqlite3_finalize(stmt)
            sqlite3_close(db)
        }
        else
        {
            print("error opening database")
        }
    }
    
}
