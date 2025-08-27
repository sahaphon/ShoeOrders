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
       
        btnBack.tintColor = UIColor.yellow
        
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
    
    func LoadDataFromInvoice()
    {
        let progressHUD = ProgressHUD(text: "LOADING...")
        self.view.addSubview(progressHUD)
        
        let URL_USER_LOGIN = "http://111.223.38.24:3000/cal_invtran"
        
        //Set Parameter
        let parameters : Parameters=[
            "sale":CustomerViewController.GlobalValiable.saleid,
            "code": CustomerViewController.GlobalValiable.myCode,
            "invno":CustomerViewController.GlobalValiable.invno
        ]
        //print(CustomerViewController.GlobalValiable.od)
        
//        Alamofire.request(URL_USER_LOGIN, method: .get, parameters: parameters).responseJSON
//            {
//                
//                response in
//                //print(response)
//                
//                if let array = response.result.value as? [[String: Any]] //หากมีข้อมูล
//                {
//                    //Check nil data
//                    var blnHaveData = false
//                    for _ in array  //วนลูปเช็คค่าที่ส่งมา
//                    {
//                        blnHaveData = true
//                        break
//                    }
//                    
//                    //เช็คสิทธิการเข้าใช้งาน
//                    if (blnHaveData)
//                    {
//                        self.Odtrans.removeAll()
//                        var intQty: Int = 0
//                        var dblAmt: Double = 0
//                        
//                        for personDict in array
//                        {
//                            let No: Int
//                            var Prodcode: String
//                            let Color: String
//                            let Size: String
//                            let Qty: Int
//                            let pkqty: Int
//                            let Amt: Double
//                            let Store: String
//                            let Packcode: String
//                            
//                            No = personDict["no"] as! Int
//                            Prodcode = personDict["prodcode"] as! String
//                            Size = personDict["size"] as! String
//                            Color = personDict["color"] as! String
//                            Qty = personDict["qty"] as! Int
//                            pkqty = 0
//                            Amt = 0
//                            Store = ""
//                            Packcode = personDict["packcode"] as! String
//                            
//                            intQty = intQty + Qty
//                            dblAmt = dblAmt + Amt
//                            
//                            //Add data to dictionary
//                            self.Odtrans.append(Odtrn(no: No, prodcode: Prodcode, size: Size, color: Color, qty: Qty, pkqty: pkqty, amt: Amt, store: Store, packcode: Packcode))
//                        }
//                        
//                        self.lblQty.text = String(format: "%d", locale: Locale.current, intQty)
//                        self.lblTot.text = String(format: "%.2f", locale: Locale.current, dblAmt)  //ไม่แสดงราคา
//                        
//                        //ProgressIndicator.hide()
//                        progressHUD.hide()
//                        self.myTable.reloadData()
//                    }
//                    else
//                    {
//                        progressHUD.hide()
//                        ProgressIndicator.hide()
//                        //Alert
//                        let alert = UIAlertController(title: "Not found data!", message: "ไม่พบข้อมูลในระบบ กรุณาลองใหม่อีกครั้ง..", preferredStyle: .alert)
//                        
//                        alert.addAction(UIAlertAction(title: "ตกลง", style: .default, handler: nil))
//                        self.present(alert, animated: true)
//                    }
//                }
//        }
    }
    
    func LoadData()
    {
        print("LoadData")
        let progressHUD = ProgressHUD(text: "LOADING...")
        self.view.addSubview(progressHUD)
        
        //URL
        let URL_USER_LOGIN = "http://consign-ios.adda.co.th/KeyOrders/getODtrn_new.php"
        
        //Set Parameter
        let parameters : Parameters=[
            "odno": CustomerViewController.GlobalValiable.od
        ]
        print(CustomerViewController.GlobalValiable.od)
        
//        Alamofire.request(URL_USER_LOGIN, method: .post, parameters: parameters).responseJSON
//        {
//           
//                response in
//                //print(response)
//                
//                if let array = response.result.value as? [[String: Any]] //หากมีข้อมูล
//                {
//                    //Check nil data
//                    var blnHaveData = false
//                    for _ in array  //วนลูปเช็คค่าที่ส่งมา
//                    {
//                        blnHaveData = true
//                        break
//                    }
//                    
//                    //เช็คสิทธิการเข้าใช้งาน
//                    if (blnHaveData)
//                    {
//
//                        self.Odtrans.removeAll()
//                        var intQty: Int = 0
//                        var dblAmt: Double = 0
//                        
//                        for personDict in array
//                        {
//                            let No: Int
//                            var Prodcode: String
//                            let Color: String
//                            let Size: String
//                            let Qty: Int
//                            let pkqty: Int
//                            let Amt: Double
//                            let Store: String
//                            let Packcode: String
//                            
//                            No = personDict["no"] as! Int
//                            Prodcode = personDict["prodcode"] as! String
//                            Size = personDict["size"] as! String
//                            Color = personDict["color"] as! String
//                            Qty = personDict["qty"] as! Int
//                            pkqty = personDict["pkqty"] as! Int
//                            Amt = Double(personDict["amt"] as! String)!
//                            Store = personDict["store"] as! String
//                            Packcode = personDict["packcode"] as! String
//                            
//                            intQty = intQty + Qty
//                            dblAmt = dblAmt + Amt
//                            
//                            //Add data to dictionary
//                            self.Odtrans.append(Odtrn(no: No, prodcode: Prodcode, size: Size, color: Color, qty: Qty, pkqty: pkqty, amt: Amt, store: Store, packcode: Packcode))
//                        }
//                        
//                        self.lblQty.text = String(format: "%d", locale: Locale.current, intQty)
//                        self.lblTot.text = String(format: "%.2f", locale: Locale.current, dblAmt)  //ไม่แสดงราคา
//                        
//                        //ProgressIndicator.hide()
//                        progressHUD.hide()
//                        self.myTable.reloadData()
//                    }
//                    else
//                    {
//                        progressHUD.hide()
//                        ProgressIndicator.hide()
//                        //Alert
//                        let alert = UIAlertController(title: "Not found data!", message: "ไม่พบข้อมูลในระบบ กรุณาลองใหม่อีกครั้ง..", preferredStyle: .alert)
//                        
//                        alert.addAction(UIAlertAction(title: "ตกลง", style: .default, handler: nil))
//                        self.present(alert, animated: true)
//                    }
//                }
//        }
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
