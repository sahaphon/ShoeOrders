//
//  OrderViewController.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 12/28/18.
//  Copyright © 2018 rich_noname. All rights reserved.
//

import UIKit
import SQLite3
import Alamofire

class OrderViewController: UIViewController {
    
    @IBOutlet weak var mainview: UIView!
    @IBOutlet var Secment: UISegmentedControl!
    @IBOutlet var lblCode: UILabel!
    @IBOutlet var lblDesc: UILabel!
    
    @IBOutlet var lblShipdate: UILabel!
    @IBOutlet var lblStore: UILabel!
    @IBOutlet var lblPO: UITextField!
    @IBOutlet var lblItem: UILabel!
    @IBOutlet var lblCredit: UILabel!
    
    //ตัวแปร CheckboxVat
    @IBOutlet weak var btnVat: UIButton!
    var checkBox = UIImage(named: "checked")
    var uncheckBox = UIImage(named: "unchecked")
    var blnCheckVate:Bool!
    
    //ตัวแปร Checkbox งานสั่งทำ
    @IBOutlet weak var btnRec: UIButton!
    var blnCheckRec:Bool!
    var version = ""
    
    
    @IBOutlet weak var btnPro: UIButton!
    var blnPro: Bool!
    
    //ปุ่มวันส่ง
    @IBOutlet weak var delivery: UIButton!
    

    
    //เพิ่มปุ่มเช็คธุรการสั่งจัด
    @IBOutlet weak var btnPK: UIButton!
    var blnPk: Bool!
    
    
    var db: OpaquePointer?
    let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("order.sqlite")
    
    var json = [[String: Any]]()  //Declare empty dictionary

    override func viewDidLoad() {
        
        super.viewDidLoad()

        lblCode.text = CustomerViewController.GlobalValiable.myCode
        lblDesc.text = CustomerViewController.GlobalValiable.desc
        version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        
        if CustomerViewController.GlobalValiable.strShipDate.count > 0
        {
            lblShipdate.text = CustomerViewController.GlobalValiable.strShipDate
        }
        else
        {
            //วันที่ส่ง
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            let result = formatter.string(from: date)
            lblShipdate.text = result
        }
       
        if CustomerViewController.GlobalValiable.sale_type
        {
            lblShipdate.alpha = 1
        }
        else
        {
            lblShipdate.alpha = 0.5
        }
        
        lblCredit.text = String(CustomerViewController.GlobalValiable.cr_term)
        lblItem.text = CustomerViewController.GlobalValiable.remark
        lblStore.text = CustomerViewController.GlobalValiable.logiCode +  " " + CustomerViewController.GlobalValiable.logiName + " " + CustomerViewController.GlobalValiable.logisCode
        
    }
    
    //วันส่ง
    @IBAction func btnShip(_ sender: Any)
    {
        
        if #available(iOS 13.4, *) {
            if let menu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Ship") as? ShipDateViewController
            {
                CustomerViewController.GlobalValiable.blnEditShip = true
                menu.modalPresentationStyle = .fullScreen
                self.present(menu, animated: true, completion: nil)
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    //ส่งที่
    @IBAction func btnStore(_ sender: Any)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.isConnectedToNetwork()
        {
            if let menu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "logis") as? LogisticViewController
            {
                CustomerViewController.GlobalValiable.blnEditLogistic = true
                menu.modalPresentationStyle = .fullScreen
                self.present(menu, animated: true, completion: nil)
            }
        }
        else
        {
            print("Internet Connection not Available!")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let chkView = storyboard.instantiateViewController(withIdentifier: "internet") as! CheckIntenetViewController
            let navController = UINavigationController(rootViewController: chkView)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated:true, completion: nil)
        }
    }
    
    //item
    @IBAction func btnItem(_ sender: Any)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.isConnectedToNetwork()
        {
            if let menu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Rem") as? RemarkViewController
            {
                CustomerViewController.GlobalValiable.blnEditRemark = true
                menu.modalPresentationStyle = .fullScreen
                self.present(menu, animated: true, completion: nil)
            }
        }
        else
        {
            print("Internet Connection not Available!")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let chkView = storyboard.instantiateViewController(withIdentifier: "internet") as! CheckIntenetViewController
            let navController = UINavigationController(rootViewController: chkView)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated:true, completion: nil)
        }
    }
    
    //Credit
    @IBAction func btnCredit(_ sender: Any)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.isConnectedToNetwork()
        {
            if let menu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "credit") as? CrViewController
            {
                menu.modalPresentationStyle = .fullScreen
                self.present(menu, animated: true, completion: nil)
            }
        }
        else
        {
            print("Internet Connection not Available!")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let chkView = storyboard.instantiateViewController(withIdentifier: "internet") as! CheckIntenetViewController
            let navController = UINavigationController(rootViewController: chkView)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated:true, completion: nil)
        }
    }
    
    //ปุ่มธุรการสั่งจัด
    @IBAction func btnPK(_ sender: Any) {
        if blnPk == true
          {
              btnPK.setImage(checkBox, for: UIControl.State.normal)
              CustomerViewController.GlobalValiable.sale_type = true
              
              delivery.isEnabled = true  //เปิดปุ่มวันส่ง
              blnPk = false
          }
          else
          {
              btnPK.setImage(uncheckBox, for: UIControl.State.normal)
              CustomerViewController.GlobalValiable.sale_type = false
              
              delivery.isEnabled = false  //ปิดปุ่มวันส่ง
              blnPk = true
          }
    }
    

    //บันทึกออร์เดอร์
    @IBAction func btnODSave(_ sender: Any)
    {
//        self.UpdateOdNo()
//        self.PrepareOd()
//        
//        if (json.count == 0) {
//            showAlert(title: "แจ้งเตือน!", message: "โปรดเพิ่มรายการก่อนส่งข้อมูล")
//            return
//        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.isConnectedToNetwork()
        {

            if self.CheckHaveData() == true
            {
                let alertController = UIAlertController(title: "ยืนยันส่งข้อมูล..", message: "คุณต้องการส่งข้อมูลออเดอร์ ใช่หรือไม่?", preferredStyle: .alert)
                
                let OKAction = UIAlertAction(title: "ใช่", style: .default) { (action:UIAlertAction!) in
                    
                    let x = self.getODNumber()
                    CustomerViewController.GlobalValiable.odnumber = String(x!)
        
                    self.UpdateOdNo()
                    self.PrepareOd()
//                    self.SendToOD()
                    self.SendOD() // ตัวเทส
            
                }
                
                alertController.addAction(UIAlertAction(title: "ไม่ใช่", style: .default, handler: nil))
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion:nil)
            }
            else
            {
                let alert = UIAlertController(title: "Empty!", message: "ไม่พบข้อมูลในระบบ กรุณาลองใหม่อีกครั้ง..", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ตกลง", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
        else
        {
            print("Internet Connection not Available!")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let chkView = storyboard.instantiateViewController(withIdentifier: "internet") as! CheckIntenetViewController
            let navController = UINavigationController(rootViewController: chkView)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated:true, completion: nil)
        }
    }
    
    //ยกเลิก
    @IBAction func btnODCancel(_ sender: Any)
    {
        ClearAllData()
        
        if let menu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ListOD") as? ListOdViewController
        {
            menu.modalPresentationStyle = .fullScreen
            self.present(menu, animated: true, completion: nil)
        }
    }
    
    @IBAction func indexChanged(_ sender: Any)
    {
        switch Secment.selectedSegmentIndex
        {
            case 0:
                print("First Segment Selected");
                
            case 1:
                //print("Second Segment Selected");
                if let menu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Keyod") as? TakeOrderViewController
                {
                    menu.modalPresentationStyle = .fullScreen
                    self.present(menu, animated: true, completion: nil)
                }
                
            default:
                break
            }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        print("viewWillAppear")
        
        if (CustomerViewController.GlobalValiable.pro == 1)
        {
            mainview.backgroundColor = UIColor.red.withAlphaComponent(0.5)
            btnPro.setImage(checkBox, for: UIControl.State.normal)
            blnPro = true
        }
            
        
        if CustomerViewController.GlobalValiable.blnEditShip
        {
            lblShipdate.text = CustomerViewController.GlobalValiable.strShipDate
            CustomerViewController.GlobalValiable.blnEditShip = false
        }
        
        if CustomerViewController.GlobalValiable.blnEditCrterm
        {
            lblCredit.text = String(CustomerViewController.GlobalValiable.cr_term)
            CustomerViewController.GlobalValiable.blnEditCrterm =  false
        }
       
        if CustomerViewController.GlobalValiable.blnEditLogistic
        {
            lblStore.text = CustomerViewController.GlobalValiable.logiCode + " " + CustomerViewController.GlobalValiable.logiName + " " + CustomerViewController.GlobalValiable.logisCode
            CustomerViewController.GlobalValiable.blnEditLogistic = false
        }
        
        if CustomerViewController.GlobalValiable.blnEditRemark
        {
            lblItem.text = CustomerViewController.GlobalValiable.remark
            CustomerViewController.GlobalValiable.blnEditRemark = false
        }


        //ปุ่มงานสั่งทำ
        if CustomerViewController.GlobalValiable.recfirm == 1
        {
            btnRec.setImage(checkBox, for: UIControl.State.normal)
            blnCheckRec = false
        }
        else
        {
            btnRec.setImage(uncheckBox, for: UIControl.State.normal)
            blnCheckRec = true
        }
        
        //ปุ่ม vat
        if  CustomerViewController.GlobalValiable.vat == 1
        {
            btnVat.setImage(checkBox, for: UIControl.State.normal)
            blnCheckVate = false
        }
        else
        {
            btnVat.setImage(uncheckBox, for: UIControl.State.normal)
            blnCheckVate = true
        }
        
        if CustomerViewController.GlobalValiable.sale_type
        {
            btnPK.setImage(checkBox, for: UIControl.State.normal)
            delivery.isEnabled = true
            lblShipdate.alpha = 1
        }
        else
        {
            
            //ปุ่ม ธุรการสั่งจัด
            //1. หากไม่มีการกรอก remark ไม่ต้องแสดงปุ่มธุรการสั่งจัด
            //2. หากมี remark และใน remark ไม่มีคำว่า "ส่งได้" >> แสดงปุ่ม default เป็น ไม่ติ๊ก
            //3. หากมี remark และมีคำว่า "ส่งได้" >> ไม่ต้องแสดงปุ่ม ค่าเป็น false (ไม่ติ๊ก)
            let strFind:String = "ส่งได้"
            let strRemark = CustomerViewController.GlobalValiable.remark
//            print("strRemark : \(strRemark)")
            
            if !strRemark.isEmpty && !strRemark.contains(strFind)
            {
                //ระบุหมายเหตุ ไม่มี "ส่งได้"
                print("ระบุหมายเหตุ ไม่มีส่งได้")
                btnPK.setImage(uncheckBox, for: UIControl.State.normal)
                btnPK.isHidden = false
                blnPk = false
            }
            else if (!strRemark.isEmpty && strRemark.contains(strFind))
            {
                //ระบุหมายเหตุ แต่มี "ส่งได้"
                print("ระบุหมายเหตุ แต่มีส่งได้")
                btnPK.setImage(uncheckBox, for: UIControl.State.normal)
                btnPK.isHidden = true
                blnPk = false
            } else {
                //ไม่ระบุหมายเหตุ
                print("ไม่ระบุหมายเหตุ")
                btnPK.setImage(uncheckBox, for: UIControl.State.normal)
                btnPK.isHidden = true
                blnPk = false
            }
            
            
            delivery.isEnabled = false
            lblShipdate.alpha = 0.5
        }
        
       
        Secment.selectedSegmentIndex = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //print("viewDidAppear")
        
        lblPO.text = CustomerViewController.GlobalValiable.pono
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        CustomerViewController.GlobalValiable.pono = lblPO.text!
        //print("viewWillDisappear -- หายไป")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //print("viewDidDisappear")
    }
    
    @IBAction func CheckPro(_ sender: Any)
    {
        var intSet = 0;
        
        if blnPro == true
        {
            CustomerViewController.GlobalValiable.pro = 1
            btnPro.setImage(checkBox, for: UIControl.State.normal)
            blnPro = false
            mainview.backgroundColor = UIColor.red.withAlphaComponent(0.5)
            
            ClearListOD() //ล้างข้อมูล order ทิ้ง
        }
        else
        {
            print(blnPro)
            if blnPro != nil
            {
                // create the alert
                let alert = UIAlertController(title: "ยกเลิกการคีย์ โปรโมชั่น!..", message: "คำเตือน! ออเดอร์ที่คีย์ไว้จะถูกล้างทิ้ง", preferredStyle: .alert)

                  // add an action (button)
                alert.addAction(UIAlertAction(title: "ตกลง", style: UIAlertAction.Style.default, handler: { [self] (action: UIAlertAction!) in
                      intSet = 1;

                    CustomerViewController.GlobalValiable.pro = 0
                    self.btnPro.setImage(self.uncheckBox, for: UIControl.State.normal)
                    blnPro = true
                    mainview.backgroundColor = UIColor.white

                    ClearListOD() //ล้างข้อมูล order ทิ้ง
                }))

                alert.addAction(UIAlertAction(title: "ยกเลิก", style: UIAlertAction.Style.cancel, handler: { [self] (action: UIAlertAction!) in
                    intSet = 0;

              }))

                  // show the alert
                  self.present(alert, animated: true, completion: nil)
                  
            }
            else
            {
                ClearListOD() //ล้างข้อมูล order ทิ้ง
            }
            
            if intSet == 1
            {
                CustomerViewController.GlobalValiable.pro = 0
                btnPro.setImage(self.uncheckBox, for: UIControl.State.normal)
                blnPro = true
                mainview.backgroundColor = UIColor.white
            }
            else
            {
                CustomerViewController.GlobalValiable.pro = 1
                btnPro.setImage(checkBox, for: UIControl.State.normal)
                blnPro = false
                mainview.backgroundColor = UIColor.red.withAlphaComponent(0.5)
            }
            
        }
    }
    
    @IBAction func CheckVate(_ sender: Any)
    {
        if blnCheckVate == true
        {
            CustomerViewController.GlobalValiable.vat = 1
            btnVat.setImage(checkBox, for: UIControl.State.normal)
            blnCheckVate = false
        }
        else
        {
            CustomerViewController.GlobalValiable.vat = 0
            btnVat.setImage(uncheckBox, for: UIControl.State.normal)
            blnCheckVate = true
        }
    }
    
    @IBAction func CheckRec(_ sender: Any)
    {
        if blnCheckRec == true
        {
            CustomerViewController.GlobalValiable.recfirm = 1
            btnRec.setImage(checkBox, for: UIControl.State.normal)
            blnCheckRec = false
        }
        else
        {
            CustomerViewController.GlobalValiable.recfirm = 0
            btnRec.setImage(uncheckBox, for: UIControl.State.normal)
            blnCheckRec = true
        }
    }
    
    func getODNumber() -> String?
    {
        var id: String = ""
        
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            let queryString = String(format:"SELECT orderno FROM odmst ORDER BY orderno DESC LIMIT 1")
            
            //statement pointer
            var stmt:OpaquePointer?
            
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK
            {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing : \(errmsg)")
            }
            
            
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                id = String(cString: sqlite3_column_text(stmt, 0))
            }
            
            // Create date formatter
            let date = Date()
            let dateFormatter: DateFormatter = DateFormatter()
            //dateFormatter.dateFormat = "dd/MM/yyyy"
            
            if id == ""  //กรณีไม่มี od ให้เริ่มรหัสแรก
            {
                //dateFormatter.dateFormat = "yyyyMM"
                dateFormatter.dateFormat = "yyyy"
                var engYear = Int(dateFormatter.string(from: date))
                if engYear! > 2500
                {
                    engYear = engYear! - 543
                    dateFormatter.dateFormat = "MM"
                    id = "OD" + String(engYear!) + dateFormatter.string(from: date) + "0001"
                }
                else
                {
                    dateFormatter.dateFormat = "yyyyMM"
                    id = "OD" + dateFormatter.string(from: date) + "0001"
                }
            }
            else //กรณีมีการคีย์ od บ้างแล้ว
            {
                let indexEndOfText = id.index(id.endIndex, offsetBy: -10) //นับจากท้ายมา 10 ตัว 2019010001
                let substring = id[indexEndOfText...]  //ได้ 10 ตัวท้าย _______(1)
                
                let runningOD = id.index(id.endIndex, offsetBy: -4)  //ตัดเอา 4 ตัวท้าย(ลำดับ OD) 0001
                let substring2 = id[runningOD...] //ได้ 4 ตัวท้าย   __________(2)
                
                //ตัดเอาปีเดือน
                let start = substring.index(substring.startIndex, offsetBy: 2)
                let end = substring.index(substring.endIndex, offsetBy: -4)
                let range = start..<end
                
                let mySubstring = substring[range]  //201901   ____________(3)
                
                //ถ้าอยู่ในปีเดือนเดียวกัน
                dateFormatter.dateFormat = "yyyyMM"
                var currDate = dateFormatter.string(from: date)  //ปีเดือนปัจจุบัน
                let strYear = currDate.prefix(4) //cut year
                var intYear = Int(strYear)
                
                if intYear! > 2500
                {
                    intYear = intYear! - 543
                    dateFormatter.dateFormat = "MM"
                    currDate = String(intYear!) + dateFormatter.string(from: date)
                    //print("มีแล้ว > 2500 => ",currDate )
                }
                
                if (currDate.contains(String(mySubstring)))
                {
                    let newOrderNo = Int(substring2)! + 1
                    
                    //เติม 0 นำหน้า
                    id = "OD" + currDate + String(format: "%04d", arguments: [newOrderNo])
                }
                else
                {
                    dateFormatter.dateFormat = "yyyyMM"
                    id = "OD" + currDate + "0001"
                }
                
            }
           
            sqlite3_finalize(stmt)
            sqlite3_close(db)
        }
        
        return id
    }
    
    
    func CheckHaveData() ->Bool
    {
        var blnHaveDt = false
        
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            let queryString = String(format:"SELECT * FROM odmst WHERE status = '' ORDER BY no DESC LIMIT 1")
            
            //statement pointer
            var stmt:OpaquePointer?
            
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK
            {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing : \(errmsg)")
            }
            
            
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                blnHaveDt = true
            }
            
            sqlite3_finalize(stmt)
            sqlite3_close(db)
        }
        
        return blnHaveDt
    }
    
    func UpdateOdNo()
    {
        
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            //หากมีการเพิ่มสถานที่สงใหม่
            var logist_nm = ""
            if (CustomerViewController.GlobalValiable.locat_name.count > 0 && CustomerViewController.GlobalValiable.logiCode == "00")
            {
                logist_nm = CustomerViewController.GlobalValiable.locat_name
            }
            else
            {
                logist_nm = CustomerViewController.GlobalValiable.logiName
            }
            //print("===> ",logist_nm)
            
            
            //Update First  -----(1)
            let updateStatementString = String(format:"UPDATE odmst SET status = '%@', delivery = '%@', orderno = '%@', pono = '%@', remark = '%@', logicode = '%@' WHERE status = ''", "1", lblShipdate.text!, CustomerViewController.GlobalValiable.odnumber, lblPO.text!, lblItem.text!, logist_nm)
            //print("===> ", updateStatementString)
            var updateStatement: OpaquePointer? = nil
            
            if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK
            {
                if sqlite3_step(updateStatement) != SQLITE_DONE
                {
                     print("Could not update row.")
                }
            }
            else
            {
                print("UPDATE statement could not be prepared")
            }
            
            sqlite3_finalize(updateStatement)
            
            //Update cr_term --------------(2)
            let UpdateStirng = "UPDATE odmst SET cr_term = ?, recfirm = ? WHERE status = ''"
            
            var UpdateStatement2: OpaquePointer? = nil
            if sqlite3_prepare_v2(db, UpdateStirng, -1, &UpdateStatement2, nil) == SQLITE_OK
            {
                sqlite3_bind_int(UpdateStatement2, 1, Int32(CustomerViewController.GlobalValiable.cr_term))
                sqlite3_bind_int(UpdateStatement2, 2, Int32(CustomerViewController.GlobalValiable.recfirm))
                
                if sqlite3_step(UpdateStatement2) != SQLITE_DONE
                {
                     print("Could not delete row.")
                }
            }
            else
            {
                print("DELETE statement could not be prepared")
            }
            
            sqlite3_finalize(UpdateStatement2)
            sqlite3_close(db)
        }
    }
    
    func PrepareOd()
    {
        var _date: String = ""
        var _delivery: String = ""
        var _code: String = ""
        var _odno: String = ""
        var _no: Int = 0
        var _prodcode: String = ""
        var _npack: String = ""
        var _packcode: String = ""
        var _sizedesc: String = ""
        var _color: String = ""
        var _colordesc: String = ""
        var _qty: Int = 0
        var _price: Decimal = 0
        var _amt: Decimal = 0
        var _packno: String = ""
        var _pairs: Int = 0
        var _dozen: Int = 0
        var _disc: Decimal = 0
        var _pono: String = ""
        var _taxrate: Decimal = 0
        var _vattype: String = ""
        var _tax_amt: Decimal = 0
        var _netamt: Decimal = 0
        var _crterm: Int = 0
        var _saleman: String = ""
        var _remark: String = ""
        var _recfirm: Int = 0
        var _incvat: Int = 0
        var _logis_code: String = ""
        var _logicode: String = ""
        var _ctrycode: String = ""
        var _store: String = ""
        var _logi_name: String = ""
//        var _fixdue: String = ""
        
        //Get data from server
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
           let queryString = String(format:"SELECT * FROM odmst WHERE status = '1' AND qty > 0 AND orderno = '%@' AND code = '%@' ORDER BY no", CustomerViewController.GlobalValiable.odnumber, CustomerViewController.GlobalValiable.myCode)
            
            //statement pointer
            var stmt:OpaquePointer?
            
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK
            {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing : \(errmsg)")
            }
            
            //remove all
            json.removeAll()
            
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
               _date = String(cString: sqlite3_column_text(stmt, 1))
               _date = changeEngYear(mydate: _date)  //Change EngYear

               _delivery = String(cString: sqlite3_column_text(stmt, 2))
               _delivery = changeEngYear(mydate: _delivery)
                                
               _code = String(cString: sqlite3_column_text(stmt, 3))  //
               _odno = String(cString: sqlite3_column_text(stmt, 4))  //
               _no = Int(sqlite3_column_int(stmt, 5))
               _prodcode = String(cString: sqlite3_column_text(stmt, 6))  //
               _npack = String(cString: sqlite3_column_text(stmt, 7))  //
               _packcode = String(cString: sqlite3_column_text(stmt, 8)) //
               _sizedesc = String(cString: sqlite3_column_text(stmt, 9)) //
               _color = String(cString: sqlite3_column_text(stmt, 10))   //
               _colordesc = String(cString: sqlite3_column_text(stmt, 11)) //
               _qty = Int(sqlite3_column_int(stmt, 12))
               _price = 0
               _amt = 0
               _packno = String(cString: sqlite3_column_text(stmt, 15))
               _pairs = Int(sqlite3_column_int(stmt, 16))
               _dozen = Int(sqlite3_column_int(stmt, 17))
               _disc = Decimal(sqlite3_column_double(stmt, 18))
               _pono = String(cString: sqlite3_column_text(stmt, 19))
               _taxrate = Decimal(sqlite3_column_double(stmt, 20))
                
               if (CustomerViewController.GlobalValiable.type_vat == 1)  //หากร้านค้า vat
               {
                  _vattype = "1"
               }
                else
               {
                 _vattype = "3"
               }
                
               //_vattype = String(cString: sqlite3_column_text(stmt, 21))
               _tax_amt = Decimal(sqlite3_column_double(stmt, 22))
               _netamt = Decimal(sqlite3_column_double(stmt, 23))
               _crterm = Int(sqlite3_column_int(stmt, 24))
               _saleman = String(cString: sqlite3_column_text(stmt, 25))
               _remark = String(cString: sqlite3_column_text(stmt, 26))
               _recfirm = Int(sqlite3_column_int(stmt, 27))
               _incvat = Int(sqlite3_column_int(stmt, 28))
               _logis_code = String(cString: sqlite3_column_text(stmt, 29))
               _logicode = String(String(cString: sqlite3_column_text(stmt, 30)).prefix(2)) //String(cString: sqlite3_column_text(stmt, 30))
               _ctrycode = String(cString: sqlite3_column_text(stmt, 31))
               _store = String(cString: sqlite3_column_text(stmt, 32))
               _logi_name = String(cString: sqlite3_column_text(stmt, 30)) //เพิ่มมาใหม่เอาเฉพาะ detail ไม่เอา code  ...รอแก้ไข
                
                //ตัดเอา
                if (_logi_name.count > 0 && CustomerViewController.GlobalValiable.blnNewLogicode == 1)  //หากระบุสถานที่ส่ง
                {
                    let intChar = _logi_name.count - 3 // 01 : ส่งโกดัง
                    let index = _logi_name.index(_logi_name.endIndex, offsetBy: -intChar)
                    let mySubstring = _logi_name.suffix(from: index)  // playground
                    _logi_name = String(mySubstring)
                    
                    //print("รายละเอียด : \(mySubstring), logicode : \(_logicode)") // เครื่องหมาย \() คือการ cash ให้เป็นสตริง
                }
                else
                {
                    _logi_name = ""
                }

                //Add data to dictionary 
//                let mydic : [String:Any] = [
//                    "date": _date,
//                    "delivery": _delivery,
//                    "code": _code,
//                    "orderno": _odno,
//                    "no": _no,
//                    "prodcode": _prodcode,
//                    "n_pack": _npack,
//                    "packcode": _packcode,
//                    "sizedesc": _sizedesc,
//                    "colorcode": _color,
//                    "colordesc": _colordesc,
//                    "qty": _qty,
//                    "price": _price,
//                    "amt": _amt,
//                    "packno": _packno,
//                    "pairs": _pairs,
//                    "dozen": _dozen,
//                    "disc": _disc,
//                    "pono": _pono,
//                    "tax_rate": _taxrate,
//                    "vat_type": _vattype,
//                    "tax_amt": _tax_amt,
//                    "net_amt": _netamt,
//                    "cr_term": _crterm,
//                    "saleman": _saleman,
//                    "remark": _remark,
//                    "recfirm": _recfirm,
//                    "incvat": _incvat,
//                    "logis_code": _logis_code,
//                    "logicode": _logicode,
//                    "ctrycode": _ctrycode,
//                    "store": _store,
//                    "logi_name": _logi_name,
//                    "sale_type":  CustomerViewController.GlobalValiable.sale_type,
//                    "fixdue": CustomerViewController.GlobalValiable.pro
//                ]
                
                let mydic : [String:Any] = [
                    "date": _date,
                    "delivery": _delivery,
                    "code": _code,
                    "orderno": _odno,
                    "no": _no,
                    "prodcode": _prodcode,
                    "n_pack": _npack,
                    "packcode": _packcode,
                    "sizedesc": _sizedesc,
                    "colorcode": _color,
                    "colordesc": _colordesc,
                    "qty": _qty,
                    "price": _price,
                    "amt": _amt,
                    "packno": _packno,
                    "pairs": _pairs,
                    "dozen": _dozen,
                    "disc": _disc,
                    "pono": _pono,
                    "tax_rate": _taxrate,
                    "vat_type": _vattype,
                    "tax_amt": _tax_amt,
                    "net_amt": _netamt,
                    "cr_term": _crterm,
                    "saleman": _saleman,
                    "remark": _remark,
                    "recfirm": _recfirm,
                    "incvat": _incvat,
                    "logis_code": CustomerViewController.GlobalValiable.logisCode,
                    "logicode": CustomerViewController.GlobalValiable.logiCode,
                    "ctrycode": _ctrycode,
                    "store": _store,
                    "logi_name": CustomerViewController.GlobalValiable.logiName,
                    "sale_type":  CustomerViewController.GlobalValiable.sale_type,
                    "fixdue": CustomerViewController.GlobalValiable.pro
                ]
                
                //Add data 
                json.append(mydic)
            }
            
            //print("จำนวนข้อมูล : ", json.count)            
            //print("==>PrepareOd")
            sqlite3_finalize(stmt)
            sqlite3_close(db)
        }

    }
    
    func changeEngYear(mydate : String) -> String
    {
        var index = mydate.index(mydate.endIndex, offsetBy: -4)  //4 ตัวท้าย
        let mySubstring2 = mydate[index...] // 2562
        var intYear = Int(mySubstring2)
        var result = mydate
        
        if (intYear! > 2500)
        {
            index = mydate.index(mydate.startIndex, offsetBy: 6)
            let mySubstring = mydate[..<index] // ได้ 21/12/
            
            intYear = intYear! - 543
            result = mySubstring + String(intYear!)
        }
        
        return result
    }
    
    func ClearAllData()
    {
        ClearListOD()  //เคลียร์ตาราง odmst, prodlist
        
        CustomerViewController.GlobalValiable.blnEditShip = false
        CustomerViewController.GlobalValiable.blnEditCrterm = false
        CustomerViewController.GlobalValiable.blnEditLogistic = false
        CustomerViewController.GlobalValiable.blnEditRemark = false
        
        CustomerViewController.GlobalValiable.strShipDate = ""
        
        //ส่งของที่
        CustomerViewController.GlobalValiable.logiCode = ""
        CustomerViewController.GlobalValiable.logiName = ""
        CustomerViewController.GlobalValiable.logisCode = ""
        
        
        CustomerViewController.GlobalValiable.remark = ""
  
        CustomerViewController.GlobalValiable.recfirm = 0
        CustomerViewController.GlobalValiable.vat = 0
        CustomerViewController.GlobalValiable.sale_type = false  //รอส่ง
        
        CustomerViewController.GlobalValiable.prod = ""
        CustomerViewController.GlobalValiable.n_pack = 0
        CustomerViewController.GlobalValiable.color = ""
        CustomerViewController.GlobalValiable.colorcode = ""
        CustomerViewController.GlobalValiable.free = ""
        
        CustomerViewController.GlobalValiable.pairs = 0
        CustomerViewController.GlobalValiable.qty = 0
        CustomerViewController.GlobalValiable.odnumber = ""
        CustomerViewController.GlobalValiable.pono = ""
        
        CustomerViewController.GlobalValiable.locat_name = ""      //เคลียร์สถานที่ส่งใหม่
        CustomerViewController.GlobalValiable.oldprod = ""
        CustomerViewController.GlobalValiable.blnSolidPackAsort = false
        CustomerViewController.GlobalValiable.pro = 0
        

        //Reset control
        lblStore.text = ""
        btnVat.setImage(uncheckBox, for: UIControl.State.normal)
        btnRec.setImage(uncheckBox, for: UIControl.State.normal)
        lblPO.text = ""
        lblItem.text = ""
        lblCredit.text = "0"
    }
    
    // ช่วยห่อ Any ให้ Encodable ได้
    // Helper: Wrapper ทำให้ค่า Any ส่งเข้า JSONEncoder ได้
    struct AnyEncodable: Encodable {
        private let _encode: (Encoder) throws -> Void
        init<T: Encodable>(_ value: T) { self._encode = value.encode }
        func encode(to encoder: Encoder) throws { try _encode(encoder) }
    }

    
    struct SendODRequest: Encodable {
        let od: [[String: AnyEncodable]]  // << od เป็น Array ของ Object
        let user: String
        let code: String
    }

    struct SendData: Decodable {
        let success: Bool   // ให้ตรงกับ response จากเซิร์ฟเวอร์ เช่น { "result": true }
        let message: String
        // เพิ่มฟิลด์อื่น ๆ ถ้ามี
    }
    
    // แปลง Any → AnyEncodable โดยแก้กรณี Decimal/NSDecimalNumber และทำงานแบบ recursive
    func toEncodable(_ value: Any) -> AnyEncodable {
        // 1) Decimal → Double
        if let d = value as? Decimal {
            return AnyEncodable(NSDecimalNumber(decimal: d).doubleValue)
        }
        // 2) NSDecimalNumber → Double
        if let n = value as? NSDecimalNumber {
            return AnyEncodable(n.doubleValue)
        }
        // 3) NSNumber → Double/Int/Bool (ปล่อยให้ Encodable เดิมทำงาน)
        if let n = value as? NSNumber {
            // NSNumber อาจเป็น Bool ด้วย
            if CFGetTypeID(n) == CFBooleanGetTypeID() {
                return AnyEncodable(n.boolValue)
            } else {
                return AnyEncodable(n.doubleValue) // บังคับเป็นตัวเลข
            }
        }
        // 4) String / Bool / Int / Double ตรง ๆ
        if let s = value as? String { return AnyEncodable(s) }
        if let b = value as? Bool   { return AnyEncodable(b) }
        if let i = value as? Int    { return AnyEncodable(i) }
        if let d = value as? Double { return AnyEncodable(d) }
        if let f = value as? Float  { return AnyEncodable(Double(f)) }

        // 5) Array -> ทำ recursive
        if let arr = value as? [Any] {
            return AnyEncodable(arr.map { toEncodable($0) })
        }

        // 6) Dictionary -> ทำ recursive
        if let dict = value as? [String: Any] {
            let mapped = dict.mapValues { toEncodable($0) }
            return AnyEncodable(mapped)
        }

        // 7) fallback — แปลงเป็น String
        return AnyEncodable(String(describing: value))
    }
    
    func SendOD() {
        // แปลง [[String:Any]] → [[String:AnyEncodable]] พร้อมแก้ Decimal เป็น Double
          let odArray: [[String: AnyEncodable]] = json.map { dict in
              dict.mapValues { toEncodable($0) }
          }
        
        let body = SendODRequest(
            od: odArray,
            user: AppDelegate.GlobalValiable.user,
            code: CustomerViewController.GlobalValiable.myCode
        )

        let url = "http://111.223.38.24:4000/gentextfile_new"

        // HUD
        let progressHUD = ProgressHUD(text: "กำลังส่งข้อมูล...")
        self.view.addSubview(progressHUD)
        
//        print(odArray)

        // ถ้าบอดี้ใหญ่มาก แนะนำสร้าง Session กำหนด timeout เอง (ดูตัวอย่างส่วนล่าง)
        AF.request(
            url,
            method: .post,
            parameters: body,                       // ← ส่งเป็น Encodable
            encoder: JSONParameterEncoder.default,  // ← เข้ารหัสเป็น JSON ใน HTTP Body
            headers: [.accept("application/json")]
        )
        .validate(statusCode: 200..<300)
        .responseDecodable(of: [SendData].self) { [weak self] response in
            guard let self = self else { return }

            // ให้แน่ใจว่า HUD ถูกซ่อนเสมอ
            defer { progressHUD.hide() }

            switch response.result {
            case .success(let values):
                // ถ้าคืนมาเป็น array เช่น [{ "result": "1" }]
                guard let first = values.first else {
                    self.showAlert(title: "Data is empty", message: "ไม่พบข้อมูลจากเซิร์ฟเวอร์")
                    return
                }
            
                if first.success {
                    //ปุ่มส่งสำเร็จ
                    let alert = UIAlertController(title: "Success!",
                                                  message: "ส่งข้อมูลออเดอร์สำเร็จ!..",
                                                  preferredStyle: .alert)

                    let okAction = UIAlertAction(title: "ตกลง", style: .default) { _ in
                        // ปิด ViewController ปัจจุบัน
//                      self.dismiss(animated: true, completion: nil)
                        
                        //back viewcontroller
                        if let menu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ListOD") as? ListOdViewController
                        {
                            menu.modalPresentationStyle = .fullScreen
                            self.present(menu, animated: true, completion: nil)
                        }
                    }
                    
                    alert.addAction(okAction)
                    self.present(alert, animated: true)

                    
                } else {
                    self.showAlert(
                        title: "ผิดพลาด!",
                        message: "ERR03: การส่งข้อมูลล้มเหลว กรุณาลองใหม่อีกครั้ง! \(first.message)"
                    )
                }


            case .failure(let error):
                self.showAlert(title: "ผิดพลาด!", message: "ERR: การส่งข้อมูลล้มเหลว\n\(error.localizedDescription)")
            }
        }
    }

    func SendToOD()
    {
        //ส่งผ่าน parameter แบบเดิมติดปัญหาไฟล์ขนาดใหญ่ส่งไม่ได้ เปลี่ยนเป็นส่งผ่าน BODY แทน 25/12/2019
        let params: NSMutableDictionary? = [
            "od" : json,
            "user" : AppDelegate.GlobalValiable.user,
            "code" : CustomerViewController.GlobalValiable.myCode
        ];
        
        
        let progressHUD = ProgressHUD(text: "กำลังส่งข้อมูล...")
        self.view.addSubview(progressHUD)
        
         var request = URLRequest(url: NSURL(string: "http://111.223.38.14:9999/gentextfile_new")! as URL)
         request.httpMethod = "POST"
         request.setValue("application/json", forHTTPHeaderField: "Content-Type")
         let data = try! JSONSerialization.data(withJSONObject: params!, options: JSONSerialization.WritingOptions.prettyPrinted)

         let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
         if let json = json {
             print(json)
         }
         request.httpBody = json!.data(using: String.Encoding.utf8.rawValue);
    }
    
    //Alert function
    func AlertResult(mainTxt: String, Title: String)
    {
        let alertController = UIAlertController(title: mainTxt, message: Title, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "ตกลง", style: .default) { (action:UIAlertAction!) in
            
            // Code in this block will trigger when OK button tapped.
            // Clear orderno after send data
            self.ClearAllData()
            
            //back viewcontroller
            if let menu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ListOD") as? ListOdViewController
            {
                menu.modalPresentationStyle = .fullScreen
                self.present(menu, animated: true, completion: nil)
            }
        }
        
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion:nil)
    }
    
    func ClearListOD()
    {
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            ///======== เคลียร์ตาราง odmst =======
            let deleteStatementString = String(format:"DELETE FROM odmst")
            var delStatement: OpaquePointer? = nil
            
            if sqlite3_prepare_v2(db, deleteStatementString, -1, &delStatement, nil) == SQLITE_OK
            {
                if sqlite3_step(delStatement) != SQLITE_DONE
                {
                    print("Could not update row.")
                }
            }
            else
            {
                print("Delete statement could not be prepared")
            }
            
            sqlite3_finalize(delStatement)
            
            ///======== เคลียร์ตาราง tmp_odmst =======
            let delStm = String(format:"DELETE FROM tmp_odmst")
            var delStatement_tmpodmst: OpaquePointer? = nil
            
            if sqlite3_prepare_v2(db, delStm, -1, &delStatement_tmpodmst, nil) == SQLITE_OK
            {
                if sqlite3_step(delStatement_tmpodmst) != SQLITE_DONE
                {
                    print("Could not update row.")
                }
            }
            else
            {
                print("Delete statement could not be prepared")
            }
            
            sqlite3_finalize(delStatement_tmpodmst)
            
            
            ///======== เคลียร์ตาราง prodlist =======
            let deleteStatementString2 = String(format:"DELETE FROM prodlist")
            var delStatement2: OpaquePointer? = nil
            
            if sqlite3_prepare_v2(db, deleteStatementString2, -1, &delStatement2, nil) == SQLITE_OK
            {
                if sqlite3_step(delStatement2) != SQLITE_DONE
                {
                    print("Could not update row.")
                }
            }
            else
            {
                print("Delete statement could not be prepared")
            }
            
            sqlite3_finalize(delStatement2)
            sqlite3_close(db)
        }
    }
    
    func RollBackOD()  //แก้สถานะ od หากเกิด error ขณะส่งข้อมูล
    {
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            //Update First  -----(1)
            let updateStatementString = String(format:"UPDATE odmst SET status = '%@' WHERE status = '1' AND orderno = '%@' AND code = '%@'", "", CustomerViewController.GlobalValiable.odnumber, CustomerViewController.GlobalValiable.myCode)
            
            var updateStatement: OpaquePointer? = nil
            
            if sqlite3_prepare_v2(db, updateStatementString, -1, &updateStatement, nil) == SQLITE_OK
            {
                if sqlite3_step(updateStatement) != SQLITE_DONE
                {
                    print("Could not update row.")
                }
            }
            else
            {
                print("UPDATE statement could not be prepared")
            }
            
            sqlite3_finalize(updateStatement)
            sqlite3_close(db)
        }
    }

}
