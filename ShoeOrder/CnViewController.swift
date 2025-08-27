//
//  CnViewController.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 1/7/20.
//  Copyright © 2020 rich_noname. All rights reserved.
//

import UIKit
import SQLite3
import Alamofire

class TypeTitleHeader {
    var name: String?
    var desc0: String?
    var desc1: String?
    var desc2: Double?
    var desc3: Double?
    
    init(name: String, desc0: String, desc1: String, desc2: Double, desc3: Double){
         self.name = name
         self.desc0 = desc0
         self.desc1 = desc1
         self.desc2 = desc2
         self.desc3 = desc3
    }
}

class CnViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var txtCode: UITextField!
    @IBOutlet weak var txtDesc: UITextField!
    @IBOutlet weak var txtStyle: UITextField!
    @IBOutlet weak var myTable: UITableView!
    
    var headerTitle = [TypeTitleHeader]()
    var blnHaveDt : Bool = false
    
    var db: OpaquePointer?
    let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("order.sqlite")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.black,
             NSAttributedString.Key.font: UIFont(name: "PSL Display", size: 30)!]
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 256.0 / 255.0, green: 69.0 / 255.0, blue: 0.0 / 255.0, alpha: 100.0)
        
        blnHaveDt = false

        headerTitle.append(TypeTitleHeader.init(name: "จำหน่ายครั้งเเรก :", desc0: "", desc1: "", desc2: 0, desc3: 0))
        headerTitle.append(TypeTitleHeader.init(name: "ปิดรับ OD :", desc0: "", desc1: "", desc2: 0, desc3: 0))
        headerTitle.append(TypeTitleHeader.init(name: "Latest invoice :", desc0: "", desc1: "", desc2: 0, desc3: 0))

        txtCode.delegate = self
        txtStyle.delegate = self
    }
    
    @IBAction func btnFind(_ sender: Any)
    {
        let _code = txtCode.text!
        let _style = txtStyle.text!
        
        /***** ล้างข้อมูลเก่าก่อน ******/
        headerTitle.removeAll()
        blnHaveDt = false

        headerTitle.append(TypeTitleHeader.init(name: "จำหน่ายครั้งเเรก :", desc0: "", desc1: "", desc2: 0, desc3: 0))
        headerTitle.append(TypeTitleHeader.init(name: "ปิดรับ OD :", desc0: "", desc1: "", desc2: 0, desc3: 0))
        headerTitle.append(TypeTitleHeader.init(name: "Latest invoice :", desc0: "", desc1: "", desc2: 0, desc3: 0))
        //**********************
        
        self.myTable.reloadData()
        
        if (_code.isEmpty) || (_style.isEmpty)
        {
            print("Empty..")
        }
        else
        {
            txtCode.resignFirstResponder()
            txtStyle.resignFirstResponder()
            findData()
        }
    }
    
    @IBAction func btnCustFind(_ sender: Any)
    {
        
    }
    
    @IBAction func btnClear(_ sender: Any)
    {
        self.clearAllData()
    }
    
    func clearAllData()
    {
        txtCode.text = ""
        txtDesc.text = ""
        txtStyle.text = ""
        
        headerTitle.removeAll()
        blnHaveDt = false

        headerTitle.append(TypeTitleHeader.init(name: "จำหน่ายครั้งเเรก :", desc0: "", desc1: "", desc2: 0, desc3: 0))
        headerTitle.append(TypeTitleHeader.init(name: "ปิดรับ OD :", desc0: "", desc1: "", desc2: 0, desc3: 0))
        headerTitle.append(TypeTitleHeader.init(name: "Latest invoice :", desc0: "", desc1: "", desc2: 0, desc3: 0))
        
        self.myTable.reloadData()
    }
    
    func findData()
    {
        //ProgressBar
        let progressHUD = ProgressHUD(text: "Please wait..")
        self.view.addSubview(progressHUD)
        
        let URL = "http://111.223.38.24:3000/cn_check"  
        
        //Set Parameter
        let parameters : Parameters=[
            "code": txtCode.text!,
            "style": txtStyle.text!
        ]
        
        print(parameters)
//        Alamofire.request(URL, method: .get, parameters: parameters).responseJSON
//        {
//            response in
//            //print(response)
//            
//            switch response.result
//            {
//                 case .success(_):
//                 
//                    if let array = response.result.value as? [[String: Any]] //หากมีข้อมูล
//                    {
//                        self.headerTitle.removeAll()
//                        for personDict in array
//                        {
//                            //let code : String
//                            let release_valid : String
//                            let release_price : Double
//                            let release_pnovat : Double
//                            let notsold : String
//                            var notsold_date : String = ""
//                            let first_inv : String
//                            var inv_date : String = ""
//                            //let srvdate : String
//                            
//                            //code = personDict["code"] as! String
//                            release_valid = personDict["release_valid"] as! String
//                                
//                            release_price = personDict["release_price"] as! Double
//                            release_pnovat = personDict["release_pnovat"] as! Double
//                            notsold_date = personDict["notsold_date"] as! String
//                            //notsold = personDict["notsold"] as! Bool
//                            
//                            if (personDict["notsold"] as! Bool)  // false = ปกติ
//                            {
//                                notsold = "YES"
//                                notsold_date = "  " + notsold_date
//                            }
//                            else
//                            {
//                                notsold = "NO"
//                                notsold_date = ""
//                            }
//                            
//                           
//                            first_inv = personDict["first_inv"] as! String
//                            inv_date = personDict["inv_date"] as! String
//                            if (inv_date == "30/12/1899")
//                            {
//                                inv_date = "-"
//                            }
//                            
//                            //srvdate = personDict["serv_date"] as! String
//                            
//                            self.blnHaveDt = true
//                            self.headerTitle.append(TypeTitleHeader(name: "จำหน่ายครั้งเเรก :", desc0: release_valid, desc1: "", desc2: release_price, desc3: release_pnovat))
//                            self.headerTitle.append(TypeTitleHeader(name: "ปิดรับ OD :", desc0: notsold, desc1: notsold_date, desc2: 0, desc3: 0))
//                            self.headerTitle.append(TypeTitleHeader(name: "Latest invoice :", desc0: inv_date, desc1: first_inv, desc2: 0, desc3: 0))
//                        }
//                        
//                        if (self.blnHaveDt)
//                        {
//                            self.myTable.reloadData()
//                        }
//                        else
//                        {
//                            let alertController = UIAlertController(title: "Not found data!", message: "ไม่พบข้อมูล กรุณาลองใหม่อีกครั้ง..", preferredStyle: .alert)
//                            let OKAction = UIAlertAction(title: "ปิด", style: .default) { (action:UIAlertAction!) in
//                                                                    
//                            }
//                                                            
//                            alertController.addAction(OKAction)
//                            self.present(alertController, animated: true, completion:nil)
//                        }
//                       
//                        progressHUD.hide()
//                }
//                else
//                {
//                    print("Empty data..")
//                    self.blnHaveDt = false
//                }
//                    
//                 case .failure(let error):
//                      print(error)
//                     // error handling
//                 }
//        }
    }
    
     private func textFieldShouldReturn(textField: UITextField) -> Bool {
  
         textField.resignFirstResponder()
         return true
     }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //print("---> ", textField.text!)
        let search : String = txtCode.text!  //textField.text!
        if search.caseInsensitiveCompare("") != ComparisonResult.orderedSame
        {
            textField.resignFirstResponder()
            filter(searchTxt: search)  //กรองข้อมูล ขั้นสุดท้าย เพื่อเช็คอีกครี้ง
        }
        else
        {
            txtDesc.text = ""
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        var returnValue = true
        let lowercaseRange = string.rangeOfCharacter(from: CharacterSet.lowercaseLetters)
        if let _ = lowercaseRange?.isEmpty {
            returnValue = false
        }

        if !returnValue {
            textField.text = (textField.text! + string).uppercased()
        }
        
        print(textField.text!)
        //กรองข้อมูลเฉพาะ code เท่านั้น
        if let txtField1 = self.view.viewWithTag(0) as? UITextField {
           print(txtField1.text!)
           filter(searchTxt: textField.text!)  //กรองข้อมูล
        }
        
        return returnValue
    }
    
    func filter(searchTxt:String)
       {
           //Open db
           if sqlite3_open(fileURL.path, &db) == SQLITE_OK
           {
               let queryString = String(format:"SELECT code, name FROM armstr WHERE code LIKE '%%%@%%' GROUP BY code, name", searchTxt)
               print(queryString)
               
               //statement pointer
               var stmt:OpaquePointer?
               
               //preparing the query
               if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                   let errmsg = String(cString: sqlite3_errmsg(db)!)
                   print("error preparing insert: \(errmsg)")
                   return
               }
              
               txtDesc.text = ""  //Clear ชื้อร้านค้า
               while(sqlite3_step(stmt) == SQLITE_ROW)
               {
                   let name = String(cString: sqlite3_column_text(stmt, 1))
                   txtDesc.text = name
               }
               
               sqlite3_finalize(stmt)
               sqlite3_close(db)
           }
           else
           {
               print("error opening database")
           }
       }
}

extension CnViewController: UITableViewDataSource, UITableViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerTitle[section].name
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        //check section index
        switch indexPath.section
        {
        case 0:
            
            if (blnHaveDt)
            {
                cell.textLabel?.text = headerTitle[indexPath.section].desc0! + "   ราคาป้าย(บาท) : " + String(format: "%.02f", headerTitle[indexPath.section].desc2!) + "   ราคาส่ง(บาท) : " + String(format: "%.02f", headerTitle[indexPath.section].desc3!)
            }
            else
            {
                cell.textLabel?.text = headerTitle[indexPath.section].desc0! + headerTitle[indexPath.section].desc1!
            }

        case 1:
               cell.textLabel?.text = headerTitle[indexPath.section].desc0! + headerTitle[indexPath.section].desc1!

        case 2:
               cell.textLabel?.text = headerTitle[indexPath.section].desc0! + "  " + headerTitle[indexPath.section].desc1!

        default:
              cell.textLabel?.text = headerTitle[indexPath.section].desc0! + "  " + headerTitle[indexPath.section].desc1!
        }

        cell.textLabel?.font = UIFont(name:"PSL Display", size: 25.0)
               cell.textLabel?.textColor = UIColor.purple
               cell.backgroundColor = UIColor.white
        return cell
    }
}
