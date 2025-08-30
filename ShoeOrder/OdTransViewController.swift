//
//  OdTransViewController.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 2/18/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit
import Alamofire

class OdTransViewController: UIViewController
{
    @IBOutlet weak var lblQty: UILabel!
    @IBOutlet weak var lblTot: UILabel!
    @IBOutlet weak var myTable: UITableView!
    @IBOutlet weak var btnBack: UIBarButtonItem!
    
    var Odtrans = [Odtrn]()  //ประกาศตัวแปรของคลาส
    let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("order.sqlite")
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        navigationController?.navigationBar.barTintColor = UIColor(red: 256.0 / 255.0, green: 69.0 / 255.0, blue: 0.0 / 255.0, alpha: 100.0)
       
        btnBack.tintColor = UIColor.red
        
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.black,
             NSAttributedString.Key.font: UIFont(name: "PSL Display", size: 30)!]
        //Invoice30
        if (CustomerViewController.GlobalValiable.fromView == "Invoice30")  //หากเรียกจาก from invoice ย้อนหลัง 1
        {
             self.title = CustomerViewController.GlobalValiable.invno 
             LoadDataFromInvoice()
        }
        else  //หากเรียกผ่าน od ค้างส่ง
        {
             self.title = CustomerViewController.GlobalValiable.od
             LoadData()
        }
    }
    
    struct DataInvoice: Decodable
    {
        let no: Int
        let docno: String
        let code: String
        let refno: String
        let retdate: String
        let prodcode: String
        let colorcode: String
        let color: String
        let size: String
        let qty: Int
        let packcode: String
    }
    
    struct OD: Decodable
    {
        let date: String
        let no: Int
        let orderno: String
        let prodcode: String
        let packcode: String
        let colorcode: String
        let qty: Int
        let amt: Double
        let code: String
        let pkqty: Int
        let store: String
        let color: String
        let size: String
        
        enum CodingKeys: String, CodingKey {
            case date, no, orderno, prodcode, packcode, colorcode, qty, amt, code, pkqty, store, color
            case size = "pack_desc"
        }
    }
    
    func LoadDataFromInvoice()
    {
        let progressHUD = ProgressHUD(text: "LOADING...")
        self.view.addSubview(progressHUD)
        
        let URL = "http://111.223.38.24:3000/cal_invtran"
        
        //Set Parameter
        let parameters : Parameters=[
            "sale":CustomerViewController.GlobalValiable.saleid,
            "code": CustomerViewController.GlobalValiable.myCode,
            "invno":CustomerViewController.GlobalValiable.invno
        ]
        //print(CustomerViewController.GlobalValiable.od)
        
        AF.request(URL, method: .get, parameters: parameters)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: [DataInvoice].self) {  [weak self] response in
                guard let self = self else { return }
                
                switch response.result {
                    
                    case .success(let value):
                    
                        if value.count == 0 {
                            showAlert(title: "Not found data!", message: "ไม่พบข้อมูลในระบบ กรุณาลองใหม่อีกครั้ง..")
                            progressHUD.hide()
                            ProgressIndicator.hide()
                            return
                        }

                         self.Odtrans.removeAll()
                   
                         var intQty: Int = 0
                    
                        for i in value {
                        
                            intQty = intQty + i.qty
                            
                            //Add data to dictionary
                            self.Odtrans.append(Odtrn(no: i.no, prodcode: i.prodcode, size: i.size, color: i.colorcode, qty: i.qty, pkqty: 0, amt: 0, store: "", packcode: i.packcode))
                        }
                    
                           self.lblQty.text = String(format: "%d", locale: Locale.current, intQty)
                           self.lblTot.text = String(format: "%.2f", locale: Locale.current, 0)  //ไม่แสดงราคา
 
                           progressHUD.hide()
                           self.myTable.reloadData()
                        
                        break
                        
                    case .failure(let error):
                        print("Error: \(error)")
                        progressHUD.hide()
                        showAlert(title: "เกิดข้อผิลพลาด", message: "\(error) โปรดลองใหม่อีกครั้ง")
                    
                        break
                }
                
        }
        
    }
    
    func LoadData()
    {
        let progressHUD = ProgressHUD(text: "กำลังโหลดข้อมูล...")
        self.view.addSubview(progressHUD)
        
        let URL = "http://111.223.38.24:3000/cal_odtrans"
        
        //Set Parameter
        let parameters : Parameters=[
            "odno": CustomerViewController.GlobalValiable.od
        ]
        print("OD: ", CustomerViewController.GlobalValiable.od)
        
    
        AF.request(URL, method: .post, parameters: parameters)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: [OD].self) {  [weak self] response in
                guard let self = self else { return }
                
                switch response.result {
                    
                    case .success(let value):
                    
                        if value.count == 0 {
                            showAlert(title: "Not found data!", message: "ไม่พบข้อมูลในระบบ กรุณาลองใหม่อีกครั้ง..")
                            progressHUD.hide()
                            ProgressIndicator.hide()
                            return
                        }
                    
                         self.Odtrans.removeAll()
                         var intQty: Int = 0
                    
                        for i in value {
                        
                            intQty = intQty + i.qty
                            
                            //Add data to dictionary
                            self.Odtrans.append(Odtrn(no: i.no, prodcode: i.prodcode, size: i.size, color: i.color, qty: i.qty, pkqty: i.pkqty, amt: i.amt, store: i.store, packcode: i.packcode))
                            
                        }
                    
                           self.lblQty.text = String(format: "%d", locale: Locale.current, intQty)
                           self.lblTot.text = String(format: "%.2f", locale: Locale.current, 0)  //ไม่แสดงราคา
   
                           progressHUD.hide()
                           self.myTable.reloadData()
                        
                        break
                        
                    case .failure(let error):
                        print("Error: \(error)")
                        progressHUD.hide()
                        showAlert(title: "เกิดข้อผิลพลาด", message: "\(error) โปรดลองใหม่อีกครั้ง")
                        break
                }
                
        }
        
    }
    
    @IBAction func btnBack(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }
}

extension OdTransViewController: UITableViewDataSource, UITableViewDelegate
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Odtrans.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let myOd = Odtrans[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! OdtrnCell
        cell.viewData(Odtrn: myOd)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        var strTitle = ""
        if (CustomerViewController.GlobalValiable.fromView == "Invoice30")
        {
            strTitle = "      รุ่น:             สี                       Size:                                                                         คู่:"
        }
        else
        {
             strTitle = "     รุ่น:              สี                        Size:                                                                         คู่:        สั่งจัด/คู่:    "
        }
        return strTitle
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        selectedCell.contentView.backgroundColor = UIColor.lightText  //lightText
    }
    
}
