//
//  ColorsViewController.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 1/9/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit
import SQLite3

class ColorsViewController: UIViewController {

    @IBOutlet weak var picColor: UIPickerView!
    
    var db: OpaquePointer?
    var color : [String] = [String]()
    
    @IBOutlet weak var lblTitle: UILabel!
    //Create SQLite
    let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("order.sqlite")
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if CustomerViewController.GlobalValiable.pro == 1
        {
            lblTitle.text = "เลือกสี (PROMOTION)"
            lblTitle.backgroundColor = UIColor.yellow
        }

        picColor.dataSource = self
        picColor.delegate = self
        LoadData()
    }

    @IBAction func btnAccept(_ sender: Any)
    {
            if (color.count > -1 &&  CustomerViewController.GlobalValiable.color == "")  //กรณีไม่ได้เลือน pickerview ให้ใช้ row แรก
            {
                let template = String(color[0])
                let indexStartOfText = template.index(template.startIndex, offsetBy: 4) //ตัวที่5 เป็นตันไป
                //let indexEndOfText = template.index(template.endIndex, offsetBy: -3) //นับจากท้ายมา 3 ตัว
                
                let substring = template[indexStartOfText...]
                //print("สี : ", substring)
                
                CustomerViewController.GlobalValiable.color = String(substring)
                CustomerViewController.GlobalValiable.colorcode = String(color[0].prefix(2))
            }
        
//            let str = CustomerViewController.GlobalValiable.prod
//            let index = str.index(str.startIndex, offsetBy: 1)  //ตัดอักษรตัวแรก
//            let prod = str[..<index]
        
            if (CustomerViewController.GlobalValiable.n_pack == 2)  //หากเป็นงาน Solid สามารถคีย์แยก Size ได้และ ไม่ครบกล่องก็ Save ได้
            {
                //เช็คว่า solid จัด asort หรือไม่
                if (CustomerViewController.GlobalValiable.blnSolidPackAsort)
                {
                    if let menu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "solidasort") as? SolidAsortViewController
                    {
                        menu.modalPresentationStyle = .fullScreen
                        self.present(menu, animated: true, completion: nil)
                    }
                }
                else
                {
                    if let menu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Prod7Solid") as? Prod7SolidViewController
                    {
                        menu.modalPresentationStyle = .fullScreen
                        self.present(menu, animated: true, completion: nil)
                    }
                }
            }
    }
    
    func LoadData()
    {
        //Open db
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            color.removeAll()
            let prod = CustomerViewController.GlobalValiable.prod
            let npack = CustomerViewController.GlobalValiable.n_pack
            
            let queryString = String(format:"SELECT colorcode, colordesc FROM prodlist WHERE prodcode = '%@' AND n_pack = '%@' GROUP BY colorcode, colordesc ORDER BY colorcode", "GS-" + prod, String(npack))
            //print(queryString)
            
            var stmt:OpaquePointer?
            
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing : \(errmsg)")
                return
            }
            
            
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                //print(String(cString: sqlite3_column_text(stmt, 0)))
                let color = String(cString: sqlite3_column_text(stmt, 0))
                let color_desc = String(cString: sqlite3_column_text(stmt, 1))
                
                self.color.append(color + "  " + color_desc)
            }
            
            sqlite3_finalize(stmt)
            sqlite3_close(db)
            
            self.picColor.reloadAllComponents()
        }
        else
        {
            print("error opening database")
        }
    }
}

extension ColorsViewController: UIPickerViewDelegate, UIPickerViewDataSource
{
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return color.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return color[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "PSL Display", size:38)
            pickerLabel?.textAlignment = .left
        }
        
        pickerLabel?.text = color[row]
        pickerLabel?.textColor = UIColor.blue
        
        return pickerLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        //print("color : ",String(color[row].prefix(2)))
      
        //Substring
        let template = String(color[row])
        let indexStartOfText = template.index(template.startIndex, offsetBy: 4) //ตัวที่5 เป็นตันไป
        //let indexEndOfText = template.index(template.endIndex, offsetBy: -3) //นับจากท้ายมา 3 ตัว
        
        // Swift 4
        let substring = template[indexStartOfText...]
        //print("สี : ", substring)
        
        CustomerViewController.GlobalValiable.color = String(substring)
        CustomerViewController.GlobalValiable.colorcode = String(color[row].prefix(2))
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        //print("viewWillAppear")

        CustomerViewController.GlobalValiable.color = ""
    }
}
