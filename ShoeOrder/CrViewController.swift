//
//  aViewController.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 11/2/18.
//  Copyright © 2018 rich_noname. All rights reserved.
//

import UIKit
import SQLite3

class CrViewController: UIViewController {

    var db: OpaquePointer?
    var cr_term : [Int] = [Int]()
    var discount : [Int] = [Int]()
    var crterm = 0
    var disc = 0
    
    //Create SQLite
    let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("order.sqlite")
    
    @IBOutlet var picker: UIPickerView!
    
    @IBAction func blnOK(_ sender: Any)
    {
        CustomerViewController.GlobalValiable.blnEditCrterm = true
        CustomerViewController.GlobalValiable.cr_term = crterm
        CustomerViewController.GlobalValiable.disc = disc  //เก็บส่วนลดจาก เครดิตเทอมที่เลือก
        
        if((self.presentingViewController) != nil)
        {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        picker.dataSource = self
        picker.delegate = self
     
        LoadCrdit(ar: CustomerViewController.GlobalValiable.myCode)
    }
    
    func LoadCrdit(ar:String)
    {
        //Open db
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            //first empty array
            cr_term.removeAll()
            
            let queryString = String(format:"SELECT cr_term, disc FROM armstr WHERE code = '%@'", ar)
            //print(queryString)
            
            //statement pointer
            var stmt:OpaquePointer?
            
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing : \(errmsg)")
                return
            }
            
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                cr_term.append(Int(sqlite3_column_int(stmt, 0)))
                discount.append(Int(sqlite3_column_int(stmt, 1)))
            }

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

extension CrViewController: UIPickerViewDelegate, UIPickerViewDataSource
{
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return cr_term.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return String(cr_term[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
           pickerLabel = UILabel()
           pickerLabel?.font = UIFont(name: "PSL Display", size:60)
           pickerLabel?.textAlignment = .center
        }
        pickerLabel?.text = String(cr_term[row])
        pickerLabel?.textColor = UIColor.blue
        
        return pickerLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        crterm = cr_term[row]
        disc = discount[row]
        
//        print("เครดิต : ",cr_term[row])
//        print("ส่วนลด : ",discount[row])
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        //กำหนดค่าเริ่มต้น
        crterm = cr_term[0]
        disc = discount[0]
    }
}
