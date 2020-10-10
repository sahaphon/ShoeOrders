//
//  LoginViewController.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 10/5/18.
//  Copyright © 2018 rich_noname. All rights reserved.
//

import UIKit
import Alamofire
import SQLite3

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var lblResult: UILabel!
    
    //สร้างกรอบสี่เหลี่ยมใหม่
    var container: UIView = {
        let V = UIView(frame: CGRect(x:0, y:0,  width: 500, height: 450))  //400
        V.backgroundColor = UIColor(red: 247/255,
            green:113/255,
            blue:30/255,
            alpha:1.0)   //UIColor(red: 69/255, green: 159/255, blue: 134/255, alpha: 1.0)
        
        V.layer.cornerRadius = 10
        return V
        }()
    
    //Textbox USERNAME
    lazy var user : MyTextField = {
        let luser = MyTextField(frame: CGRect(x: 45, y: 200, width: 410, height: 40))
        luser.backgroundColor = .white
//        luser.textColor = .black
        luser.placeholder = "username"
        luser.keyboardType = .default
        luser.font = UIFont (name: "PSL Display", size: 25)
        luser.leftViewMode = .always
        luser.leftView = getLeftView(image: #imageLiteral(resourceName: "user"))
        return luser
    }()
    
    
    //Textbox PASSWORD
    lazy var password : MyTextField = {
        let lpassw = MyTextField(frame: CGRect(x:45, y: 250, width: 410, height: 40))
        lpassw.backgroundColor = .white
//        lpassw.textColor = .blue
        lpassw.placeholder = "password"
        lpassw.keyboardType = .numberPad
        lpassw.isSecureTextEntry = true
        lpassw.font = UIFont (name: "PSL Display", size: 25)
        lpassw.leftViewMode = .always
        lpassw.leftView = getLeftView(image: #imageLiteral(resourceName: "passw"))
        return lpassw
    }()
    
    //ฟังก์ชั่นเพิ่มรูปหน้า textbox
    func getLeftView(image: UIImage) -> UIView
    {
        let leftV = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        let img = UIImageView(frame: CGRect(x: 5, y:5, width: 30, height: 30))
        img.image = image
        img.contentMode = .scaleAspectFit
        leftV.backgroundColor = UIColor(red: 146/225, green: 173/255, blue: 184/255, alpha: 1.0)
        leftV.addSubview(img)
        
        return leftV
    }
    
    //the defaultvalues to store user data
    let defaultValues = UserDefaults.standard
    var ver = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    //URL
    let URL_USER_LOGIN = "http://111.223.38.24:3000/checklogin_test"   //"http://consign-ios.adda.co.th/KeyOrders/checklogin.php"  **** เปลี่ยนไปใช้ SERVER Node เมื่อ 150819
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        user.delegate = self
        password.delegate = self
        user.becomeFirstResponder()  //Set focus textfield

        //Create Table
        self.CreateDatabase()
        
        //เก็บเวอร์ชั่น app
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        {
            ver = version
        }
 
        password.delegate = self
        
        self.view.backgroundColor = UIColor(red: 146/225, green: 173/255, blue: 184/255, alpha: 1.0)
        self.view.addSubview(self.container)
        
        
        //สร้างวงกลมในกรอบสี่เหลี่ยม
        let CircleImage = UIImageView(frame: CGRect(x: self.container.frame.midX - 50, y: 30, width: 100, height: 100))
        CircleImage.backgroundColor = .clear
        CircleImage.layer.cornerRadius = 50
        CircleImage.clipsToBounds = true
        CircleImage.image = #imageLiteral(resourceName: "logo")
        self.container.addSubview(CircleImage)
        
        self.container.addSubview(self.user)
        self.container.addSubview(self.password)
        
        //Title Program
        let lblTitle = UILabel(frame: CGRect(x: 45, y: 130, width: 410, height: 60))
        lblTitle.text = "Shoe Orders"
        lblTitle.textColor = UIColor.yellow
        lblTitle.shadowColor = UIColor.black
        lblTitle.font = UIFont (name: "EFECTIVA", size: 30)
        lblTitle.textAlignment = .center
        
        
        let lblVersion = UILabel(frame: CGRect(x: 245, y: 400, width: 410, height: 60))
        lblVersion.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String //"Version 1.0.20"     ////******** อัพเดทเวอร์ชั่นอัพตรงนี้ด้วย
        lblVersion.textColor = UIColor.yellow
        lblVersion.shadowColor = UIColor.black
        lblVersion.font = UIFont (name: "PSL Display", size: 22)
        lblVersion.textAlignment = .center
    
        
        //ปุ่ม Login
        let btnLogin = UIButton(frame: CGRect(x: 45, y: 310, width: 410, height: 60))
        btnLogin.setBackgroundImage(UIImage(color: UIColor(red: 242/255,green:125/255,blue:52/255,alpha:1.0)), for: .normal)
        btnLogin.setTitle("LOGIN", for: .normal)
        btnLogin.titleLabel?.font = UIFont (name: "PSL Display", size: 30)
        btnLogin.addTarget(self, action: #selector(loginAction(_:)), for: .touchUpInside)
        
        //lable Result
        lblResult = UILabel(frame: CGRect(x: 45, y: 360, width: 410, height: 60))
        lblResult.text = ""
        lblResult.textColor = UIColor.black
        lblResult.shadowColor = UIColor.white
        lblResult.font = UIFont (name: "PSL Display", size: 25)
        lblResult.textAlignment = .center
        
        self.container.addSubview(lblTitle)
        self.container.addSubview(btnLogin)
        self.container.addSubview(lblResult)
        self.container.addSubview(lblVersion)
        self.container.center = self.view.center
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //การใ่่ส่! หลังตัวแปรเพื่อดัก eror จากการ crash
    @objc func loginAction(_ sender: AnyObject)
    {
        self.view.endEditing(true)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.isConnectedToNetwork()
        {
            //print("Internet Connection Available!")
            if user.text == "" || password.text == ""
            {
                let alert = UIAlertController(title: "ผิดพลาด!", message: "โปรดกรอก Username หรือ Password ให้ครบถ้วน..", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "ตกลง", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
            else
            {
                //Clear valiable
                CustomerViewController.GlobalValiable.table_name = ""
                
                let progressHUD = ProgressHUD(text: "Checking...")
                self.view.addSubview(progressHUD)
                
                //print("pass : ", self.password.text!)
                AppDelegate.GlobalValiable.user = self.user.text!  //เก็บ userlogi
            
                //print("_user : ", AppDelegate.GlobalValiable.user)
                
                //getting the username and password
                let parameters : Parameters=[
                    "username": user.text!,
                    "password": password.text!,
                    "version": ver!
                ]
                
                //making a post request
                Alamofire.request(URL_USER_LOGIN, method: .get, parameters: parameters).responseJSON
                {
                    response in
                    //print(response)
                    
                    switch response.result
                    {
                        case .success(_):
       
                            if let array = response.result.value as? [[String: Any]] //หากมีข้อมูล
                            {
                                //Clear textfield
                                self.user.text = ""
                                self.password.text = ""
                                
                                //Check nil data
                                var blnHaveData = false
                                for _ in array  //วนลูปเช็คค่าที่ส่งมา
                                {
                                    blnHaveData = true
                                    break
                                }
                                
                                //เช็คสิทธิการเข้าใช้งาน
                                if (blnHaveData)
                                {
                                
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
                                        //ลบข้อมูลเก่าออกก่อน
                                        var deleteStatementStirng = "DELETE FROM armstr"
                                        var deleteStatement: OpaquePointer? = nil
                                        
                                        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK
                                        {
                                            if sqlite3_step(deleteStatement) != SQLITE_DONE
                                            {
                                                print("Could not delete row.")
                                            }
                                        } else
                                        {
                                            print("DELETE statement could not be prepared")
                                        }
                                        
                                        sqlite3_finalize(deleteStatement)
                                        
                                        //ลบข้อมูลเก่าออกก่อน odmst
                                        deleteStatementStirng = "DELETE FROM odmst"
                                        var deleteStatement2: OpaquePointer? = nil
                                        
                                        if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement2, nil) == SQLITE_OK
                                        {
                                            if sqlite3_step(deleteStatement2) != SQLITE_DONE
                                            {
                                                print("Could not delete row.")
                                            }
                                        } else
                                        {
                                            print("DELETE statement could not be prepared")
                                        }
                                        
                                        sqlite3_finalize(deleteStatement2)
                                        
                                        
                                        //บันทึกข้อมูลชุดใหม่
                                        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
                                        var serv_ver = ""
                                        var rowno = 0
                                        
                                        for personDict in array
                                        {
                                            if (rowno == 0)  //เก็บเวอร์ชั่นจาก Server
                                            {
                                               serv_ver = (personDict["curr_ver"] as! String).trimmingCharacters(in: .whitespacesAndNewlines)    //เก็บเวอร์ชั่น จาก Server
                                            }
                                            

                                            let update = "INSERT INTO armstr (code, name, cr_term, disc, sale, salenm, typevat)" + "VALUES (?,?,?,?,?,?,?);"
                                            var statement: OpaquePointer?
                                            
                                            //preparing the query
                                            if sqlite3_prepare_v2(db, update, -1, &statement, nil) == SQLITE_OK
                                            {
                                                //Declear Valiable
                                                let code = (personDict["code"] as! String).trimmingCharacters(in: .whitespacesAndNewlines)
                                                let name = (personDict["arname"] as! String).trimmingCharacters(in: .whitespacesAndNewlines)
                                                
                                                let crterm:String = String(format: "%@", personDict["crterm"] as! CVarArg)
                                                let disc:String = String(format: "%@", personDict["disc"] as! CVarArg)
                                                //let disc = Double(personDict["disc"] as! String)!
                                                let sale = (personDict["id"] as! String).trimmingCharacters(in: .whitespacesAndNewlines)
                                                let sname = (personDict["name"] as! String).trimmingCharacters(in: .whitespacesAndNewlines)
                                                let typevat = (personDict["typevat"] as! Int)
                                                
                                                
                                                //sqlite3_bind_double(statement, 4, disc)
                                                sqlite3_bind_text(statement, 1, code, -1, SQLITE_TRANSIENT)
                                                sqlite3_bind_text(statement, 2, name, -1, SQLITE_TRANSIENT)
                                                sqlite3_bind_text(statement, 3, crterm, -1, SQLITE_TRANSIENT)
                                                sqlite3_bind_text(statement, 4, disc, -1, SQLITE_TRANSIENT)
                                                sqlite3_bind_text(statement, 5, sale, -1, SQLITE_TRANSIENT)
                                                sqlite3_bind_text(statement, 6, sname, -1, SQLITE_TRANSIENT)
                                                sqlite3_bind_int(statement, 7, Int32(typevat))
                                            
                                                
                                                CustomerViewController.GlobalValiable.saleid = sale //เก็บ รหัส sale
                                                
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
                                            
                                            rowno = rowno + 1
                                            
                                            sqlite3_finalize(statement)
                                        }  //forloop
                                        
                                        sqlite3_close(db)
                                        
                                        //ProgressIndicator.hide()
                                        progressHUD.hide()
                                        
                                        print("เวอร์ชั่นแอพ : \(String(describing: self.ver)) : server : \(serv_ver)")
                                        if (self.ver == serv_ver)
                                           {
                                               if let delegate = UIApplication.shared.delegate as? AppDelegate
                                               {
                                                   let storyboard : UIStoryboard? = UIStoryboard(name: "Main", bundle: nil)
                                                   let rootController = storyboard!.instantiateViewController(withIdentifier: "Tab")
                                                   delegate.window?.rootViewController = rootController
                                               }
                                           }
                                           else
                                           {
    //                                            print("Out of version..")
                                                let alertController = UIAlertController(title: "กรุณาอัพเดท", message: "แอพพลิเคชั่นคีย์ออเดอร์มีเวอร์ชั่นใหม่ โปรดอัพเดทเพื่อการใช้งานที่ราบรื่น..", preferredStyle: .alert)
                                                                                        
                                                let OKAction = UIAlertAction(title: "ปิด", style: .default) { (action:UIAlertAction!) in
                                                    //
                                                }
                                                
                                                let Resend = UIAlertAction(title: "อัพเดท", style: .default) { (action:UIAlertAction!) in
                                                    //Link AppStore update apps
                                                    UIApplication.shared.open((URL(string: "itms://itunes.apple.com/app/apple-store/id" + "1450217925")!), options:[:], completionHandler: nil)
                                                }
                                                
                                              
                                                alertController.addAction(Resend)
                                                alertController.addAction(OKAction)
                                                self.present(alertController, animated: true, completion:nil)
                                            
                                           }
                                        

                                    } //open database
                                    
                                }
                            }
                            break
                        case .failure(let error) :
                            print(error)
                            
                            progressHUD.hide()
                            
                            //Alert
                            let alert = UIAlertController(title: "ผิดพลาด!", message: "ไม่พบผู้ใช้งานในระบบ กรุณาลองใหม่อีกครั้ง..", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "ตกลง", style: .default, handler: nil))
                            self.present(alert, animated: true)
                            
                            break
                    }
                    
                }
            }
        }
        else
        {
            print("Internet Connection not Available!")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let chkView = storyboard.instantiateViewController(withIdentifier: "internet") as! CheckIntenetViewController
            let navController = UINavigationController(rootViewController: chkView)
            self.present(navController, animated:true, completion: nil)
        }
        
    }
    
    @objc func ForgetPW(_ sender: AnyObject)
    {
        
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
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        lblResult.text = nil
    }

    //Set Max length textfield
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        //limit password with 4 charactor
        if textField == password
        {
            let char = string.cString(using: String.Encoding.utf8)
            let isBackSpace = strcmp(char, "\\b")
            if isBackSpace == -92 {
                return true
            }
            return textField.text!.count <= 3
        }
        else
        {
          //set text upercase
           textField.text = (textField.text! as NSString).replacingCharacters(in: range, with: string.uppercased())
           return false
        }
        
        //return true
    }
    
    func CreateDatabase()
    {
        //print("=======> ทำ CreateDatabase ")
        //Create SQLite
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("order.sqlite")
            print("พาร์ท : ",fileURL.path)
        
        var db: OpaquePointer?
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK
        {
            print("error opening database")
        }
        else
        {
            //ลบตารางเก่าออกก่อน แก้ปัญหากรณี มีการเพิ่มฟิวด์ Table
            let del_armstr = String(format:"DROP TABLE armstr")
            var delstm_tb: OpaquePointer? = nil
            
            if sqlite3_prepare_v2(db, del_armstr, -1, &delstm_tb, nil) == SQLITE_OK
            {
                if sqlite3_step(delstm_tb) != SQLITE_DONE
                {
                    print("Could not clear table.")
                }
            }
            else
            {
                print("statement could not be prepared")
            }
            
            sqlite3_finalize(delstm_tb)
            
            
            //Create Table
            if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS armstr (code CHAR(255), name CHAR(255), cr_term DOUBLE, disc DOUBLE, sale CHAR(5), salenm CHAR(255), typevat INTEGER)", nil, nil, nil) != SQLITE_OK
            {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error creating armstr table: \(errmsg)")
            }
            
            //เก็บ รุ่นที่เลือก
            if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS prodlist (prodcode CHAR(12), style CHAR(20), n_pack CHAR(1), packtype CHAR(10), type CHAR(20), packcode CHAR(50), packno INTEGER, colorcode CHAR(10), colordesc CHAR(20), sizedesc CHAR(255), pairs INTEGER, price DOUBLE, p_novat DOUBLE, validdate DATE)", nil, nil, nil) != SQLITE_OK
            {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error creating prodlist table: \(errmsg)")
            }
            
            //ตารางเก็บรายการ​ OD ทีคีย์
            if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS odmst (status CHAR(1), date DATE, delivery DATE, code CHAR(6), orderno CHAR(9), no INTEGER, prodcode CHAR(10), n_pack CHAR(1), packcode CHAR(50), sizedesc CHAR(100), colorcode CHAR(5), colordesc CHAR(50), qty DECIMAL(12,2), price DECIMAL(6,2), amt DECIMAL(12,2), packno INTEGER, pairs INTERGER, dozen DECIMAL(6,2), disc1 DECIMAL(6,2), pono CHAR(255), tax_rate DECIMAL(6,2), vat_type CHAR(1), tax_amt DECIMAL(8,2), net_amt DECIMAL(18,2), cr_term INTEGER, saleman CHAR(2), remark CHAR(255), recfirm INTEGER, incvat INTEGER, logis_code CHAR(150), logicode CHAR(50), ctrycode CHAR(5), store CHAR(20))", nil, nil, nil) != SQLITE_OK
            {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error creating odmst table: \(errmsg)")
            }
            
            //ตารางเก็บรายการ​ OD ทีคีย์ เฉพาะงาน solid เท่านั้น
            if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS tmp_odmst (status CHAR(1), date DATE, delivery DATE, code CHAR(6), orderno CHAR(9), no INTEGER, prodcode CHAR(10), n_pack CHAR(1), packcode CHAR(50), sizedesc CHAR(100), colorcode CHAR(5), colordesc CHAR(50), qty DECIMAL(12,2), price DECIMAL(6,2), amt DECIMAL(12,2), packno INTEGER, pairs INTERGER, dozen DECIMAL(6,2), disc1 DECIMAL(6,2), pono CHAR(255), tax_rate DECIMAL(6,2), vat_type CHAR(1), tax_amt DECIMAL(8,2), net_amt DECIMAL(18,2), cr_term INTEGER, saleman CHAR(2), remark CHAR(255), recfirm INTEGER, incvat INTEGER, logis_code CHAR(150), logicode CHAR(50), ctrycode CHAR(5), store CHAR(20))", nil, nil, nil) != SQLITE_OK
            {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error creating odmst table: \(errmsg)")
            }
            
            //ตาราง od shoenew
            if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS od (od_status CHAR(20), date CHAR(10), orderno CHAR(20), confirm CHAR(1), crterm INTEGER, prodcode CHAR(20), pono CHAR(150), remark CHAR(50))", nil, nil, nil) != SQLITE_OK
            {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error creating od table: \(errmsg)")
            }
            
            //ให้ลบตาราง remmst ก่อนหากมีการสร้างไว้แล้ว กันอัพเดทแอพแล้วตารางมีการแก้ไขภายหลัง
            if sqlite3_exec(db, "DROP TABLE IF EXISTS remmst", nil, nil, nil) != SQLITE_OK
            {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error drop remmst table: \(errmsg)")
            }
            
            
            //ตาราง หมายเหตุ
            if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS remarks (remark CHAR(150), type CHAR(1))", nil, nil, nil) != SQLITE_OK
            {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error creating remmst table: \(errmsg)")
            }
            
            //ตาราง solide จัด asort
            if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS solidasort (prodcode CHAR(12), packcode CHAR(8), packdesc CHAR(60), pairs INTEGER, packsale CHAR(8), sizedesc CHAR(60))", nil, nil, nil) != SQLITE_OK
            {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error creating remmst table: \(errmsg)")
            }
            
            //ตาราง ยอดค้างรวม
            if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS kardall (code CHAR(150), custname CHAR(150), prodcode CHAR(20), pack CHAR(10), color CHAR(20), qty INTEGER, kardqty INTEGER, orderno CHAR(20), date DATE, pono CHAR(150), amt DECIMAL(12,2))", nil, nil, nil) != SQLITE_OK
            {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error creating remmst table: \(errmsg)")
            }
            
            //Clear Table
            let deltable = String(format:"DELETE FROM tmp_odmst")
            var updateStatement: OpaquePointer? = nil
            
            if sqlite3_prepare_v2(db, deltable, -1, &updateStatement, nil) == SQLITE_OK
            {
                if sqlite3_step(updateStatement) != SQLITE_DONE
                {
                    print("Could not clear table.")
                }
            }
            else
            {
                print("statement could not be prepared")
            }
            
            sqlite3_finalize(updateStatement)
        
            //=========== Clear talble prodlist =============
            let deltable2 = String(format:"DELETE FROM prodlist")
            var updateStatement2: OpaquePointer? = nil
            
            if sqlite3_prepare_v2(db, deltable2, -1, &updateStatement2, nil) == SQLITE_OK
            {
                if sqlite3_step(updateStatement2) != SQLITE_DONE
                {
                    print("Could not clear table.")
                }
            }
            else
            {
                print("statement could not be prepared")
            }
            
            sqlite3_finalize(updateStatement2)
            
            //********** Delete table kardall ***************
            let del_table = String(format:"DELETE FROM kardall")
            var delStatement2: OpaquePointer? = nil
            
            if sqlite3_prepare_v2(db, del_table, -1, &delStatement2, nil) == SQLITE_OK
            {
                if sqlite3_step(delStatement2) != SQLITE_DONE
                {
                    print("Could not clear table.")
                }
            }
            else
            {
                print("statement could not be prepared")
            }
            
            sqlite3_finalize(delStatement2)
        }
        
        //CREATE UNIQUE INDEX team_leader ON person(team_id)
       sqlite3_close(db)
    }

}
