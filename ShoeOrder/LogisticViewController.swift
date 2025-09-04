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
        CustomerViewController.GlobalValiable.logiCode = ""
        CustomerViewController.GlobalValiable.logiName = ""
        CustomerViewController.GlobalValiable.logisCode = ""
        
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
        print("1111")
        if((self.presentingViewController) != nil)
        {
            print("22222")
            if (store.count > 0 && CustomerViewController.GlobalValiable.logiCode == "00")
            {
//                print("logicode: ", store[0])
//                print("logiName: ", store[1])
//                print("logisCode: ", store[2])
//                
//                CustomerViewController.GlobalValiable.logiCode = String(store[0])
//                CustomerViewController.GlobalValiable.logiName = String(store[1])
//                CustomerViewController.GlobalValiable.logisCode = String(store[2])
                
                
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
        let description: String?
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
//        print("code: ", CustomerViewController.GlobalValiable.myCode)
        let progressHUD = ProgressHUD(text: "Please wait..")
        self.view.addSubview(progressHUD)
        
    
        AF.request(URL, method: .get, parameters: parameters)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: [Logistic].self) {  [weak self] response in
                
//                print("responst: ", response)
                guard let self = self else { return }
                
                switch response.result {
                    
                    case .success(let data):
                        
                        //print("data: ", data)
                        if (data.count == 0) {
                            showAlert(title: "Not found data", message: "โปรดลองใหม่อีกครั้ง")
                            progressHUD.hide()
                            return
                        }
                        
                        for item in data {
                            //Add data to dictionary
                            let line = item.logicode + " : " + (item.description ?? "-") + " : " + item.logisCode
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
        
    }
}


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
        
//        showAlert(title: "เลอกรายการ", message: "\(store[row])")
        
        let sepLogis = store[row].components(separatedBy: " : ")
//        print(">>> 1: ", sepLogis[0])
//        print(">>> 2: ", sepLogis[1])
//        print(">>> 3: ", sepLogis[2])
        
        //เก็บค่า
        CustomerViewController.GlobalValiable.logiCode = sepLogis[0]
        CustomerViewController.GlobalValiable.logiName = sepLogis[1]
        CustomerViewController.GlobalValiable.logisCode = sepLogis[2]

        let candidateCode = String(store[row].prefix(2))
        let isOld = logiArr.contains(candidateCode)
        CustomerViewController.GlobalValiable.blnNewLogicode = isOld ? 0 : 1
    }
}
