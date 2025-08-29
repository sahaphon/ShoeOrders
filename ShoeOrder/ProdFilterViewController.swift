//
//  ProdFilterViewController.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 1/8/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit
import Alamofire
import SQLite3

class ProdFilterViewController: UIViewController, UITextFieldDelegate {

    var prodDictionary = [String: String]()
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblResult: UILabel!
    @IBOutlet weak var txtSearch: UITextField!
    
    @IBOutlet weak var btnFree: UIButton!
    var blnFree:Bool!
    
    @IBOutlet weak var lblFree: UIButton!
    
    @IBOutlet weak var btnAsort: UIButton!
    
    @IBOutlet weak var btnSolid: UIButton!
    
    @IBOutlet weak var btnSoAsort: UIButton!
    
    var checkBox = UIImage(named: "checked")
    var uncheckBox = UIImage(named: "unchecked")
    var typePack:Int! = 1
    var blnAccessDenied = 0  //เช็คสิทธิ์การคีย์ product
    
    //ตัวแปรเช็ครุ่นรองเท้าที่คีย์
    var blnFoundData:Bool! = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if CustomerViewController.GlobalValiable.pro == 1
        {
            lblTitle.text = "กรอกข้อมูล (PROMOTION)"
            lblTitle.backgroundColor = UIColor.yellow
        }
        
        self.lblResult.text = ""
        
        txtSearch.delegate = self
        txtSearch.text = CustomerViewController.GlobalValiable.oldprod
        txtSearch.becomeFirstResponder()  //Set focus textfield
    }
    
    @IBAction func btnFind(_ sender: Any)
    {
        if txtSearch.text != ""
        {
            SearchData()
        }
    }
    
    @IBAction func btnClose(_ sender: Any)
    {
       self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func CheckOdFree(_ sender: Any)
    {
        if blnFree == true
        {
            CustomerViewController.GlobalValiable.free = ""
            btnFree.setImage(uncheckBox, for: UIControl.State.normal)
            blnFree = false
        }
        else
        {
            CustomerViewController.GlobalValiable.free = "แถม"
            btnFree.setImage(checkBox, for: UIControl.State.normal)
            blnFree = true
        }
    }
    
    @IBAction func CheckAsort(_ sender: Any)
    {
        typePack = 1 //Asort
        btnAsort.setImage(checkBox, for: UIControl.State.normal)
        btnSolid.setImage(uncheckBox, for: UIControl.State.normal)
        btnSoAsort.setImage(uncheckBox, for: UIControl.State.normal)

        CustomerViewController.GlobalValiable.blnSolidPackAsort = false
        blnFree = true     //เปิดปุ่มแถม
        btnFree.isHidden = false
        lblFree.isHidden = false
    }
    
    @IBAction func CheckSolid(_ sender: Any)
    {
        //CustomerViewController.GlobalValiable.n_pack = typePack!
        typePack = 2 //Solid
        btnSolid.setImage(checkBox, for: UIControl.State.normal)
        btnAsort.setImage(uncheckBox, for: UIControl.State.normal)
        btnSoAsort.setImage(uncheckBox, for: UIControl.State.normal)
        
        CustomerViewController.GlobalValiable.blnSolidPackAsort = false
        btnFree.isHidden = true  //ปิดปุ่มแถม
        lblFree.isHidden = true
        blnFree = true
    }
    
    @IBAction func CheckSoAsort(_ sender: Any)
    {
        typePack = 2 //SolidAsort
        btnSolid.setImage(uncheckBox, for: UIControl.State.normal)
        btnAsort.setImage(uncheckBox, for: UIControl.State.normal)
        btnSoAsort.setImage(checkBox, for: UIControl.State.normal)
        
        CustomerViewController.GlobalValiable.blnSolidPackAsort = true
        
        //เปิดปุ่มแถม
        blnFree = true
        btnFree.isHidden = false
        lblFree.isHidden = false
    }
    
    struct Shoe: Decodable {
        let not_access: Int
        let prodcode: String
        let style: String
        let n_pack: Int
        let packtype: String
        let type: String
        let packcode: String
        let packno: Int
        let colorcode: String
        let color_name: String
        let sizedesc: String
        let pairs: Int
        let price: String
        let p_novat: String
        let validdate: String
        let sfixdue: String
        let efixdue: String
        let server_date: String
        
        enum CodingKeys: String, CodingKey {
            case style, n_pack, packtype, type, packcode, packno, colorcode, sizedesc, pairs, price, p_novat, validdate, sfixdue, efixdue
            case not_access = "AccessDenied"
            case prodcode = "prod"
            case color_name = "description"
            case server_date = "serv_date"
        }
    }
    
  func SearchData()
  {
    if txtSearch.text!.count >= 3
    {
        CustomerViewController.GlobalValiable.n_pack = typePack
        self.ClearProdData(strProd: txtSearch.text!) //ล้างข้อมูลตาราง prodlist ก่อนเสมอ กันข้อมูลเบิ้ล
        
        let parameters : Parameters=[
            "prod": txtSearch.text!,
            "npack": String(typePack),
            "sale": CustomerViewController.GlobalValiable.saleid,
            "code": CustomerViewController.GlobalValiable.myCode,
            "credit": CustomerViewController.GlobalValiable.cr_term
        ]
        

        let progressHUD = ProgressHUD(text: "Please wait..")
        self.view.addSubview(progressHUD)
        
        let URL = "http://111.223.38.24:4000/findProd"
        
        AF.request(URL, method: .get, parameters: parameters)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: [Shoe].self) {  [weak self] response in
                guard let self = self else { return }
                
                switch response.result {
                    
                case .success(let value):
                    print("VALUE ", value)
                    print("COUNT: >>>>> ", value.count)
                        
                    if value.count == 0 {
                        showAlert(title: "Data is empty", message: "ไม่พบข้อมูลกรุณาลองใหม่อีกครั้ง")
                        print("value.coutn = 0")
                        progressHUD.hide()
                        return  // ⬅️ ออกจากฟังก์ชันทันที
                    }
                        let notaccess = value[0].not_access
                    
                        if (notaccess == 1) {
                            self.lblResult.text = "สินค้านี้ขายโดยพนักงานคนอื่น! หรือเครดิตเทอมผิด"
                            progressHUD.hide()
                        }
                        
                        // โค้ดทำงานต่อเมื่อ value มีข้อมูลและเข้าเงื่อนไขปกติ
                        self.blnFoundData = true
                        self.lblResult.text = ""
                        
                        CustomerViewController.GlobalValiable.n_pack = self.typePack
                        CustomerViewController.GlobalValiable.oldprod = self.txtSearch.text!  //เก็บรุ่นที่เคยคีย์
                        
                          //กำหนด พาร์ท db
                          let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                              .appendingPathComponent("order.sqlite")

                          var db: OpaquePointer?

                          if sqlite3_open(fileURL.path, &db) != SQLITE_OK
                          {
                              print("error opening database")
                          }
                          else
                          {
                              //บันทึกข้อมูลชุดใหม่
                              let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
                              
                              for item in value {
                                  
                                  let update = "INSERT INTO prodlist (prodcode, style, n_pack, packtype, type, packcode, packno, colorcode, colordesc, sizedesc, pairs, price, p_novat, validdate, sfixdue, efixdue)" + "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);"
                                  
                                    var statement: OpaquePointer?

                                    //preparing the query
                                    if sqlite3_prepare_v2(db, update, -1, &statement, nil) == SQLITE_OK
                                    {
                                       
                                        CustomerViewController.GlobalValiable.sevdate = item.server_date
                                        //print("วันที่ Server : ",CustomerViewController.GlobalValiable.sevdate)

                                        sqlite3_bind_text(statement, 1, item.prodcode, -1, SQLITE_TRANSIENT)
                                        sqlite3_bind_text(statement, 2, item.style, -1, SQLITE_TRANSIENT)
                                        sqlite3_bind_int(statement, 3, Int32(item.n_pack))
                                        sqlite3_bind_text(statement, 4, item.packtype, -1, SQLITE_TRANSIENT)
                                        sqlite3_bind_text(statement, 5, item.type, -1, SQLITE_TRANSIENT)
                                        sqlite3_bind_text(statement, 6, item.packcode, -1, SQLITE_TRANSIENT)
                                        sqlite3_bind_int(statement, 7, Int32(item.packno))
                                        sqlite3_bind_text(statement, 8, item.colorcode, -1, SQLITE_TRANSIENT)
                                        sqlite3_bind_text(statement, 9, item.color_name, -1, SQLITE_TRANSIENT)
                                        sqlite3_bind_text(statement, 10, item.sizedesc, -1, SQLITE_TRANSIENT)
                                        sqlite3_bind_int(statement, 11, Int32(item.pairs))
                                        sqlite3_bind_double(statement, 12, Double(item.price)!)
                                        sqlite3_bind_double(statement, 13, Double(item.p_novat)!)
                                        sqlite3_bind_text(statement, 14, item.validdate, -1, SQLITE_TRANSIENT)
                                        sqlite3_bind_text(statement, 15, item.sfixdue, -1, SQLITE_TRANSIENT)
                                        sqlite3_bind_text(statement, 16, item.efixdue, -1, SQLITE_TRANSIENT)

                                        //executing the query to insert values
                                        if sqlite3_step(statement) != SQLITE_DONE
                                        {
                                            let errmsg = String(cString: sqlite3_errmsg(db)!)
                                            print("failure inserting armstr: \(errmsg)")
                                            return
                                        }
                                    }
                                    else
                                    {
                                        let errmsg = String(cString: sqlite3_errmsg(db)!)
                                        print("error preparing insert: \(errmsg)")
                                        return
                                    }

                                    progressHUD.hide()
                                    sqlite3_finalize(statement)
                                } //Close loop arrays

                                sqlite3_close(db)
                          }
                          
                     if let menu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProdSelc") as? ProdFilterViewController2
                     {
                         menu.modalPresentationStyle = .fullScreen
                         self.present(menu, animated: true, completion: nil)
                     }
                    
                    break
                    
                case .failure(let error):
                    
                    let alertController = UIAlertController(title: "ผิดพลาด!", message: "ERROR : เกิดข้อผิดพลาดขณะค้นหาข้อมูล โปรดลองใหม่อีกครั้ง!..\(error)", preferredStyle: .alert)

                    let OKAction = UIAlertAction(title: "ปิด", style: .default) { (action:UIAlertAction!) in
                             self.dismiss(animated: false, completion: nil)
                    }


                    alertController.addAction(OKAction)
                    self.present(alertController, animated: true, completion:nil)
             
                    self.txtSearch.text = ""
                    break
                }
                
            }
    }
    else
    {
        lblResult.text = "โปรดกรอกข้อมูลอีกครั้ง!.."
    }
  }
    
    func ClearProdData(strProd: String)
        {
            var db: OpaquePointer?
    
            //Create SQLite
            let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent("order.sqlite")
    
            //Open db
            if sqlite3_open(fileURL.path, &db) == SQLITE_OK
            {
    
                let deltable = String(format:"DELETE FROM prodlist WHERE prodcode LIKE '%%%@%%' AND n_pack ='%@'", strProd, String(typePack))
//                print("ลบตาราง ", deltable)
                var delStatement: OpaquePointer? = nil
                
                if sqlite3_prepare_v2(db, deltable, -1, &delStatement, nil) == SQLITE_OK
                {
                    if sqlite3_step(delStatement) != SQLITE_DONE
                    {
                        print("Could not clear table.")
                    }
                }
                else
                {
                    print("statement could not be prepared")
                }
                
                sqlite3_finalize(delStatement)
                sqlite3_close(db)
            }
            else
            {
                print("error opening database")
            }
        }
    
    // Called when the user click on the view (outside the UITextField).
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
    //ซ่อนคีย์บอร์ด
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        txtSearch.text = textField.text
    }
    
    //Set Max length textfield
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
         //Uppercase text
         textField.text = (textField.text! as NSString).replacingCharacters(in: range, with: string.uppercased())

        if (textField.text == "7")
        {
            typePack = 2 //Solid
            btnSolid.setImage(checkBox, for: UIControl.State.normal)
            btnAsort.setImage(uncheckBox, for: UIControl.State.normal)
            btnSoAsort.setImage(uncheckBox, for: UIControl.State.normal)
            
            CustomerViewController.GlobalValiable.blnSolidPackAsort = false
            
            btnFree.isHidden = true //ปิดปุ่มแถม
            lblFree.isHidden = true
            blnFree = true
        }
        
         lblResult.text = ""
         return false
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        //print("viewWillAppear")
        
        self.lblResult.text = ""
        self.blnAccessDenied = 0  //Clear เช็คสิทธิ์การคีย์ product
        CustomerViewController.GlobalValiable.free = ""
    }
}
