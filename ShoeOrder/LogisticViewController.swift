//
//  LogisticViewController.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 1/4/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit
import Alamofire
import SQLite3


class LogisticViewController: UIViewController
{
    var store : [String] = [String]()
    var logiArr = [String]() //เก็บอาร์ยสถานที่ส่ง logicode เช่น 01, 02
    
    @IBOutlet var picRem: UIPickerView!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        picRem.dataSource = self
        picRem.delegate = self
        
        store.removeAll()
        logiArr.removeAll()
        getLogistic()
    }
    
    @IBAction func btmCancel(_ sender: Any)
    {
        CustomerViewController.GlobalValiable.logis = ""
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func btnAdd(_ sender: Any)
    {
        let alertController = UIAlertController(title: "เพิ่มข้อมูลสถานที่ส่งสินค้า", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "สาขาที่"
            
            var strNo = ""
            if (self.logiArr.count > 0)
            {
                var id = 0  // ตัวแปร let ไม่สาราถจำค่่าใน loop for ได้
                for items in self.logiArr
                {
                    id = Int(items)!
                }
                
                id = id + 1
                if id > 9
                {
                    strNo = String(id)
                }
                else
                {
                    strNo = "0" + String(id)
                }
                
            }
            else
            {
                strNo = "01"
            }
            
            textField.text = strNo   //Auto run ID
            textField.isEnabled = false
            
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "ชื่อ"
            }
            
            let saveAction = UIAlertAction(title: "บันทึก", style: UIAlertAction.Style.default, handler: { alert -> Void in
                let firstTextField = alertController.textFields![0] as UITextField
                let secondTextField = alertController.textFields![1] as UITextField
                
                if (secondTextField.text!.count > 0)
                {
                    CustomerViewController.GlobalValiable.locat_name = "\(firstTextField.text!)\(" ")\(secondTextField.text!)"
                    self.getLogistic()
                }
                else
                {
                    if (firstTextField.text!.count == 0)
                    {
                        firstTextField.textColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
                    }
                    
                }
            })
            let cancelAction = UIAlertAction(title: "ปิด", style: UIAlertAction.Style.default, handler: {
                (action : UIAlertAction!) -> Void in })
            
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func btnAccept(_ sender: Any)
    {
        if((self.presentingViewController) != nil)
        {
            
            if (store.count > 0 && CustomerViewController.GlobalValiable.logis.count == 0)
            {
                CustomerViewController.GlobalValiable.logis = String(store[0])
                
                if (logiArr.count > 0) //หากมีสถานที่ส่งเก่าในระบบ shoenew ให้เช็คว่ารายการที่เลือกเป็นสถานที่ส่งเก่าหรือเพิ่มมาใหม่
                {
                    for item in logiArr
                    {
                        
                        if (item == String(store[0].prefix(2)))
                        {
                            //print("ซำ้กัน \(item) = \(String(store[0].prefix(2)))")
                            CustomerViewController.GlobalValiable.blnNewLogicode = 0
                        }
                        else
                        {
                            //print("ไม่ซ้ำกัน \(item) = \(String(store[0].prefix(2)))")
                            CustomerViewController.GlobalValiable.blnNewLogicode = 1
                        }
                        
                    }
                }
                else
                {
                    CustomerViewController.GlobalValiable.blnNewLogicode = 1
                }
            }
            
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    struct Logistic: Decodable {
        let logicode: String
        let description: String
        let logisCode: String
        
        enum CodingKeys: String, CodingKey {
            case logicode, description
            case logisCode = "logis_code"
        }
    }
    
    func getLogistic()
    {
        CustomerViewController.GlobalValiable.blnNewLogicode = 0 //เคลียร์ให้เป็นค่าเริ่มค้น
        
        let URL = "http://111.223.38.24:4000/findLogistic"
        
        //getting the username and password
        let parameters : Parameters=[
            "code": CustomerViewController.GlobalValiable.myCode
        ]
        print("code: ", CustomerViewController.GlobalValiable.myCode)
        let progressHUD = ProgressHUD(text: "Please wait..")
        self.view.addSubview(progressHUD)
        
    
        AF.request(URL, method: .get, parameters: parameters)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: [Logistic].self) {  [weak self] response in
                
                guard let self = self else { return }
                
                switch response.result {
                    
                case .success(let data):
                    
                    print("data: ", data)
                    if (data.count == 0) {
                        showAlert(title: "Not found data", message: "โปรดลองใหม่อีกครั้ง")
                        progressHUD.hide()
                        return
                    }
                    
                    for item in data {
                        //Add data to dictionary
                        let line = "\(item.logicode) \(item.description) \(item.logisCode)"
                        self.store.append(line)
                        self.logiArr.append(item.logicode)  //Add data to record logicode
                    }
                    
                    
                    //กรณีมีเพิ่มสถานที่ส่งใหม่ให้ต่อท้าย
                    if (CustomerViewController.GlobalValiable.locat_name.count > 0)
                    {
                        self.store.append(CustomerViewController.GlobalValiable.locat_name)
                    }
                    
                    self.picRem.reloadAllComponents()
                    progressHUD.hide()
                    break
                    
                case .failure(let error):
                    
                    showAlert(title: "เกิดข้อผิลพลาด", message: "\(error) โปรดลองใหม่อีกครั้ง")
                    progressHUD.hide()
                    break
                }
            }
        
        //making a post request
        //        Alamofire.request(URL_USER_LOGIN, method: .post, parameters: parameters).responseJSON
        //        {
        //           response in
        //
        //            if let array = response.result.value as? [[String: Any]] //หากมีข้อมูล
        //            {
        //                //Check nil data
        //                var blnHaveData = false
        //                for _ in array  //วนลูปเช็คค่าที่ส่งมา
        //                {
        //                    blnHaveData = true
        //                    break
        //                }
        //
        //                if (blnHaveData)
        //                {
        //                    var Desc:String = ""
        //                    var logiscode:String = ""
        //                    var logis_code:String = ""
        //
        //                    self.store.removeAll() //Clear data
        //                    self.logiArr.removeAll()
        //
        //                    for personDict in array
        //                    {
        //
        //                            logiscode = (personDict["logiscode"] as! String).trimmingCharacters(in: .whitespacesAndNewlines)
        //                            Desc = (personDict["description"] as! String).trimmingCharacters(in: .whitespacesAndNewlines)
        //                            logis_code = (personDict["logis_code"] as! String).trimmingCharacters(in: .whitespacesAndNewlines)
        //
        //                            //Add data to dictionary
        //                        self.store.append(String(logiscode) + " " + String(Desc) + " " + String(logis_code))
        //                        self.logiArr.append(logiscode)  //Add data to record logicode
        //                    }
        //
        //                }
        //                else
        //                {
        //                    print("ไม่มีข้อมูล")
        //                }
        //
        //                //กรณีมีเพิ่มสถานที่ส่งใหม่ให้ต่อท้าย
        //                if (CustomerViewController.GlobalValiable.locat_name.count > 0)
        //                {
        //                    self.store.append(CustomerViewController.GlobalValiable.locat_name)
        //                }
        //
        //                    self.picRem.reloadAllComponents()
        //                    progressHUD.hide()
        //                }
        //
        //            }
        //        }
        
    }
}

    /*
     extension LogisticViewController: UIPickerViewDelegate, UIPickerViewDataSource
     {
     // Number of columns of data
     func numberOfComponents(in pickerView: UIPickerView) -> Int
     {
     return 1
     }
     
     // The number of rows of data
     func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
     {
     return store.count
     }
     
     func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
     {
     return String(store[row])
     }
     
     func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
     {
     var pickerLabel: UILabel? = (view as? UILabel)
     if pickerLabel == nil {
     pickerLabel = UILabel()
     pickerLabel?.font = UIFont(name: "PSL Display", size:30)
     pickerLabel?.textAlignment = .center
     }
     
     pickerLabel?.text = String(store[row])
     pickerLabel?.textColor = UIColor.black
     
     return pickerLabel!
     }
     
     func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
     {
     if store.count > 0
     {
     //print("logiscode : ",String(store[row].prefix(2)))  //ตัดเอา 2 ตัวแรก
     CustomerViewController.GlobalValiable.logis = String(store[row])
     
     if (logiArr.count > 0) //หากมีสถานที่ส่งเก่าในระบบ shoenew ให้เช็คว่ารายการที่เลือกเป็นสถานที่ส่งเก่าหรือเพิ่มมาใหม่
     {
     for item in logiArr
     {
     if (item == String(store[row].prefix(2)))
     {
     //print("ซำ้กัน \(item) = \(String(store[row].prefix(2)))")
     CustomerViewController.GlobalValiable.blnNewLogicode = 0
     }
     else
     {
     //print("ไม่ซ้ำกัน \(item) = \(String(store[row].prefix(2)))")
     CustomerViewController.GlobalValiable.blnNewLogicode = 1
     }
     
     }
     }
     else
     {
     CustomerViewController.GlobalValiable.blnNewLogicode = 1
     }
     
     }
     }
     }
     }
    */


// ===== วางนอกคลาส =====
extension LogisticViewController: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        store.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        store[row]
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int,
                    forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()
        label.font = UIFont(name: "PSL Display", size: 30)
        label.textAlignment = .center
        label.textColor = .black
        label.text = store[row]
        return label
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard store.indices.contains(row) else { return }
        CustomerViewController.GlobalValiable.logis = store[row]

        let candidateCode = String(store[row].prefix(2))
        let isOld = logiArr.contains(candidateCode)
        CustomerViewController.GlobalValiable.blnNewLogicode = isOld ? 0 : 1
    }
}
