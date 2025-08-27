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
    
  func SearchData()
  {
    if txtSearch.text!.count >= 3
    {
        CustomerViewController.GlobalValiable.n_pack = typePack
        self.ClearProdData(strProd: txtSearch.text!) //ล้างข้อมูลตาราง prodlist ก่อนเสมอ กันข้อมูลเบิ้ล
        
        //getting the username and password
        let parameters : Parameters=[
            "prod": txtSearch.text!,
            "npack": String(typePack),
            "sale": CustomerViewController.GlobalValiable.saleid,
            "code": CustomerViewController.GlobalValiable.myCode,
            "credit": CustomerViewController.GlobalValiable.cr_term
        ]
        

        let progressHUD = ProgressHUD(text: "Please wait..")
        self.view.addSubview(progressHUD)
        
        let URL_USER_LOGIN = "http://111.223.38.24:4000/findProd"
        
        //making a post request เดิม .post
//        Alamofire.request(URL_USER_LOGIN, method: .get, parameters: parameters).responseJSON
//        {
//                response in
//            //print(response)
//                
//                switch response.result
//                {
//                    case .success(_):
//                     //print("ค่าที่ส่งมา : \(value)")  //หากไม่มีข้อผิดพลาด
//                    
//
//                          if let array = response.result.value as? [[String: Any]] //หากมีข้อมูล
//                          {
//                              var blnHaveData = false
//                    
//                              //Check nil data
//                              for myData in array  //วนลูปเช็คค่าที่ส่งมา
//                              {
//                                  self.blnAccessDenied = myData["AccessDenied"] as! Int
//                                  blnHaveData = true
//                                  break
//                              }
//                              
//                              
//                              //print("====== สิทธิ์การคีย์ :",self.blnAccessDenied)
//                              if (self.blnAccessDenied == 1)
//                              {
//                                  self.lblResult.text = "สินค้านี้ขายโดยพนักงานคนอื่น!.. หรือเครดิตเทอมผิด"
//                                  progressHUD.hide()
//                              }
//                              else
//                              {
//                                  if (blnHaveData)
//                                  {
//                                      self.blnFoundData = true
//                                      self.lblResult.text = ""
//                                      
//                                      CustomerViewController.GlobalValiable.n_pack = self.typePack
//                                      CustomerViewController.GlobalValiable.oldprod = self.txtSearch.text!  //เก็บรุ่นที่เคยคีย์
//                                      
//                                      //กำหนด พาร์ท db
//                                      let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//                                          .appendingPathComponent("order.sqlite")
//                                      
//                                      var db: OpaquePointer?
//                                      
//                                      if sqlite3_open(fileURL.path, &db) != SQLITE_OK
//                                      {
//                                          print("error opening database")
//                                      }
//                                      else
//                                      {
//                                          
//                                          //บันทึกข้อมูลชุดใหม่
//                                          let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
//                                          
//                                          for personDict in array
//                                          {
//                                              
//                                              let update = "INSERT INTO prodlist (prodcode, style, n_pack, packtype, type, packcode, packno, colorcode, colordesc, sizedesc, pairs, price, p_novat, validdate, sfixdue, efixdue)" + "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);"
//                                              var statement: OpaquePointer?
//                                              
//                                              //preparing the query
//                                              if sqlite3_prepare_v2(db, update, -1, &statement, nil) == SQLITE_OK
//                                              {
//                                                  let Prod = (personDict["prod"] as! String).trimmingCharacters(in: .whitespacesAndNewlines)
//                                                  let Style = (personDict["style"] as! String).trimmingCharacters(in: .whitespacesAndNewlines)
//                                                  let N_pack = (personDict["n_pack"] as! Int8)
//                                                  let Packtype = (personDict["packtype"] as! String).trimmingCharacters(in: .whitespacesAndNewlines)
//                                                  let Type = (personDict["type"] as! String).trimmingCharacters(in: .whitespacesAndNewlines)
//                                                  let Packcode = (personDict["packcode"] as! String).trimmingCharacters(in: .whitespacesAndNewlines)
//                                                  let Packno = (personDict["packno"] as! Int8)
//                                                  let Colorcode = (personDict["colorcode"] as! String).trimmingCharacters(in: .whitespacesAndNewlines)
//                                                  let Colordesc = (personDict["description"] as!String).trimmingCharacters(in: .whitespacesAndNewlines)
//                                                  let Sizedesc = (personDict["sizedesc"] as! String).trimmingCharacters(in: .whitespacesAndNewlines)
//                                                  let Pairs =  (personDict["pairs"] as! Int8)
//                                                  
//
//                                                  let Price = personDict["price"]!
//                                                  let P_novat = personDict["p_novat"]!
//                                                  let Validdate = (personDict["validdate"] as! String).trimmingCharacters(in: .whitespacesAndNewlines)
//                                                  
//                                                  let Sfixdue = (personDict["sfixdue"] as! String).trimmingCharacters(in: .whitespacesAndNewlines)
//                                                  let Efixdue = (personDict["efixdue"] as! String).trimmingCharacters(in: .whitespacesAndNewlines)
//                                                  
//                                                  
//                                                  //print("วันที่เริ่มขาย : ",Validdate)
//                                                  
//                                                  
//                                                  CustomerViewController.GlobalValiable.sevdate = (personDict["serv_date"] as! String).trimmingCharacters(in: .whitespacesAndNewlines) //เก็บวันที่ Server
//                                                  //print("วันที่ Server : ",CustomerViewController.GlobalValiable.sevdate)
//                                                  
//                                                  sqlite3_bind_text(statement, 1, Prod, -1, SQLITE_TRANSIENT)
//                                                  sqlite3_bind_text(statement, 2, Style, -1, SQLITE_TRANSIENT)
//                                                  sqlite3_bind_int(statement, 3, Int32(N_pack))
//                                                  sqlite3_bind_text(statement, 4, Packtype, -1, SQLITE_TRANSIENT)
//                                                  sqlite3_bind_text(statement, 5, Type, -1, SQLITE_TRANSIENT)
//                                                  sqlite3_bind_text(statement, 6, Packcode, -1, SQLITE_TRANSIENT)
//                                                  sqlite3_bind_int(statement, 7, Int32(Packno))
//                                                  sqlite3_bind_text(statement, 8, Colorcode, -1, SQLITE_TRANSIENT)
//                                                  sqlite3_bind_text(statement, 9, Colordesc, -1, SQLITE_TRANSIENT)
//                                                  sqlite3_bind_text(statement, 10, Sizedesc, -1, SQLITE_TRANSIENT)
//                                                  sqlite3_bind_int(statement, 11, Int32(Pairs))
//                                                  sqlite3_bind_double(statement, 12, Double(Price as! String)!)
//                                                  sqlite3_bind_double(statement, 13, Double(P_novat as! String)!)
//                                                  sqlite3_bind_text(statement, 14, Validdate, -1, SQLITE_TRANSIENT)
//                                                  sqlite3_bind_text(statement, 15, Sfixdue, -1, SQLITE_TRANSIENT)
//                                                  sqlite3_bind_text(statement, 16, Efixdue, -1, SQLITE_TRANSIENT)
//                                                  
//                                                  //executing the query to insert values
//                                                  if sqlite3_step(statement) != SQLITE_DONE
//                                                  {
//                                                      let errmsg = String(cString: sqlite3_errmsg(db)!)
//                                                      print("failure inserting armstr: \(errmsg)")
//                                                      return
//                                                  }
//                                              }
//                                              else
//                                              {
//                                                  let errmsg = String(cString: sqlite3_errmsg(db)!)
//                                                  print("error preparing insert: \(errmsg)")
//                                                  return
//                                              }
//                                              
//                                              progressHUD.hide()
//                                              sqlite3_finalize(statement)
//                                          } //Close loop arrays
//                                          
//                                          sqlite3_close(db)
//                                      }
//                                      
//                                      //sqlite3_close(db)
//                                      
//                                      if let menu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProdSelc") as? ProdFilterViewController2
//                                      {
//                                          menu.modalPresentationStyle = .fullScreen
//                                          self.present(menu, animated: true, completion: nil)
//                                      }
//                                      
//                                  }
//                                  else
//                                  {
//                                      self.lblResult.text = "***Not found data!!"
//                                      self.blnFoundData = false
//                                      
//                                      progressHUD.hide()
//                                  }
//                              }
//                              
//                          }//Close เช็คมีข้อมูล
//                    
//                    
//                    case .failure(let error): //หาก process error..
//                        
//                      let alertController = UIAlertController(title: "ผิดพลาด!", message: "ERROR : เกิดข้อผิดพลาดขณะค้นหาข้อมูล โปรดลองใหม่อีกครั้ง!..\(error)", preferredStyle: .alert)
//                                                                                                      
//                             let OKAction = UIAlertAction(title: "ปิด", style: .default) { (action:UIAlertAction!) in
//                                    self.dismiss(animated: false, completion: nil)
//
//                             }
//                                                                              
//
//                                alertController.addAction(OKAction)
//                                self.present(alertController, animated: true, completion:nil)
//                    
//                }
//                
//                
//                 self.txtSearch.text = ""
//                
//        } //Close Alamofire!
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
