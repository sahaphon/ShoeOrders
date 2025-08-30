//
//  ODKardAllViewController.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 8/20/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit
import Alamofire
import SQLite3

class ODKardAllViewController: UIViewController, UISearchBarDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate
{

    func textFieldDidBeginEditing(_ textField: UITextField) {

        if textField == self.textbox
        {
          let alert = UIAlertController(title: "ค้นหาจาก", message: "\n\n\n\n\n\n", preferredStyle: .alert)
          alert.isModalInPopover = true

          let pickerFrame = UIPickerView(frame: CGRect(x: 5, y: 20, width: 250, height: 140))

            alert.view.addSubview(pickerFrame)
            pickerFrame.dataSource = self
            pickerFrame.delegate = self

            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
                
            }))
            self.present(alert,animated: true, completion: nil )
            textField.endEditing(true)
            
            typeValue = "CODE"
            textbox.text = "ค้นหา : \(typeValue)"
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
     
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return choices.count
    }
        
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return choices[row]
    }
        
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            typeValue = "CODE"
            textbox.text = "ค้นหา : \(typeValue)"
        } else if row == 1 {
            typeValue = "ชื่อร้าน"
            textbox.text = "ค้นหา : \(typeValue)"
        }
        else
        {
            typeValue = "CODE"
            textbox.text = "ค้นหา : \(typeValue)"
        }
    }
    
   
    
    @IBOutlet weak var lblCal: UIBarButtonItem!
    @IBOutlet weak var lblQty: UILabel!
    @IBOutlet weak var lblAmt: UILabel!
    @IBOutlet weak var Searchbar: UISearchBar!
    @IBOutlet weak var lblSort: UIBarButtonItem!
    
    @IBOutlet weak var myTable: UITableView!
    @IBOutlet weak var textbox: UITextField!

    
    var choices = ["CODE", "ชื่อร้าน"]
    var pickerView = UIPickerView()
    var typeValue = String()
    
    var OdK_All = [OdKardAll]()  //ประกาศตัวแปรของคลาส
    var searchActive : Bool = false
    
    var blnSort : Bool = false
    var strSearch = ""  //เก็บคำสืบค้น กรณีกรอง
    
    let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("order.sqlite")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textbox.delegate = self
        Searchbar.delegate = self
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 256.0 / 255.0, green: 69.0 / 255.0, blue: 0.0 / 255.0, alpha: 100.0)
        
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.black,
             NSAttributedString.Key.font: UIFont(name: "PSL Display", size: 30)!]
        
        lblCal.tintColor = .yellow
        lblSort.tintColor = .yellow
        //LoadData()
    }
    
    func query()
    {
        //กำหนด พาร์ท db
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("order.sqlite")
        
        var db: OpaquePointer?
        
        //Open db
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            var queryString = ""
            if (blnSort) //กดปุ่ม sort หรือไม่
            {
                //print("Sort อยู่นะ")
                if (searchActive) //มีการกรองอยู่หรือไม่
                {
                    if (typeValue == "CODE")
                    {
                        queryString = String(format:"SELECT custname, prodcode, pack, color, qty, kardqty, orderno, date, pono, amt FROM kardall WHERE code LIKE '%%%@%%' ORDER BY kardqty DESC, prodcode", strSearch)
                    }
                    else if (typeValue == "ชื่อร้าน")
                    {
                       queryString = String(format:"SELECT custname, prodcode, pack, color, qty, kardqty, orderno, date, pono, amt FROM kardall WHERE custname LIKE '%%%@%%' ORDER BY kardqty DESC, prodcode", strSearch)
                    }
                    
                }
                else
                {
                    queryString = String(format:"SELECT custname, prodcode, pack, color, qty, kardqty, orderno, date, pono, amt FROM kardall ORDER BY kardqty DESC")
                }
            }
            else
            {
                //print("ไม่ได้ sort")
                if (searchActive) //มีการกรองอยู่หรือไม่
                {
                    if (typeValue == "CODE")
                    {
                        queryString = String(format:"SELECT custname, prodcode, pack, color, qty, kardqty, orderno, date, pono, amt FROM kardall WHERE code LIKE '%%%@%%' ORDER BY prodcode",strSearch)
                    }
                    else
                    {
                         queryString = String(format:"SELECT custname, prodcode, pack, color, qty, kardqty, orderno, date, pono, amt FROM kardall WHERE custname LIKE '%%%@%%' ORDER BY prodcode",strSearch)
                    }
                }
                else
                {
                    queryString = String(format:"SELECT custname, prodcode, pack, color, qty, kardqty, orderno, date, pono, amt FROM kardall ORDER BY custname")
                }
            }
            
            //print(queryString)
            
            //statement pointer
            var stmt:OpaquePointer?
            
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK
            {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
          
            self.OdK_All.removeAll()
            var intKard: Int = 0
            var dblAmt: Double = 0
            
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                let Custnm = String(cString: sqlite3_column_text(stmt, 0))
                let Prod = String(cString: sqlite3_column_text(stmt, 1))
                let Pack = String(cString: sqlite3_column_text(stmt, 2))
                let Color = String(cString: sqlite3_column_text(stmt, 3))
                let Qty = Int(sqlite3_column_int(stmt, 4))
                let KardQty = Int(sqlite3_column_int(stmt, 5))
                let Orderno = String(cString: sqlite3_column_text(stmt, 6))
                let Date = String(cString: sqlite3_column_text(stmt, 7))
                let Pono = String(cString: sqlite3_column_text(stmt, 8))
                let Amt = Double(sqlite3_column_double(stmt, 9))
                
                intKard = intKard + KardQty
                dblAmt = dblAmt + Amt
                
                //adding values to list
                self.OdK_All.append(OdKardAll(customer: Custnm, prod: Prod, pack: Pack, color: Color, qty: Qty, pkqty: KardQty, orderno: Orderno, date: Date, remark: Pono))
                
            }
            
            let formattedInt = String(format: "%d", locale: Locale.current, intKard)
            let formatDbl = String(format: "%.2f", locale: Locale.current, dblAmt)
            
            self.lblQty.text = formattedInt
            self.lblAmt.text = formatDbl
            self.myTable.reloadData()
            
            sqlite3_finalize(stmt)
            sqlite3_close(db)
        }
        else
        {
            print("error opening database")
        }
    }
    
    @IBAction func Sort(_ sender: Any)
    {
        if (blnSort)
        {
            blnSort = false
        }
        else
        {
            blnSort = true
        }
    
        self.query()
    }
    
    struct odnotsend: Decodable {
        var prodcode: String
        var packtype: String
        var color: String
        var qty: Int
        var kard: Int
        var orderno: String
        var date: String
        var code: String
        var saleman: String
        var pono: String
        var custname: String
        var amt: Double
        
        enum CodingKeys: String, CodingKey {
            case prodcode, color, qty, kard, orderno, date, code, saleman, pono, custname, amt
            case packtype = "pack_type"
        }
    }
    
    func LoadData()
    {
        //ProgressBar
        let progressHUD = ProgressHUD(text: "LOADING...")
        self.view.addSubview(progressHUD)
        
        //URL
        let URL = "http://111.223.38.24:3000/cal_odkardall"
        
        //Set Parameter
        let parameters : Parameters=[
            "sale": CustomerViewController.GlobalValiable.saleid
        ]
        
        AF.request(URL, method: .get, parameters: parameters)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: [odnotsend].self) {  [weak self] response in
                guard let self = self else { return }
                
                    switch response.result {
                        
                        case .success(let value):
                        
                            if value.count == 0 {
                                showAlert(title: "Not found data!", message: "ไม่พบข้อมูลในระบบ กรุณาลองใหม่อีกครั้ง..")
                                progressHUD.hide()
                                ProgressIndicator.hide()
                                return
                            }

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
                                   let deleteStatementStirng = "DELETE FROM kardall"
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
       
                                   //บันทึกข้อมูลชุดใหม่
                                   let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
       
                                   self.OdK_All.removeAll()
                                   var intKard: Int = 0
                                   var dblAmt: Double = 0
       
                                   for i in value
                                   {

                                       intKard = intKard + i.kard
                                       dblAmt = dblAmt + i.amt
       
                                       //Add data to dictionary
                                       self.OdK_All.append(OdKardAll(customer: i.custname, prod: i.prodcode, pack: i.packtype, color: i.color, qty: i.qty, pkqty: i.kard, orderno: i.orderno, date: i.date, remark: i.pono))
       
                                       let insert = "INSERT INTO kardall (code, custname, prodcode, pack, color, qty, kardqty, orderno, date, pono, amt)" + "VALUES (?,?,?,?,?,?,?,?,?,?,?);"
                                       var statement: OpaquePointer?
       
                                       //preparing the query
                                       if sqlite3_prepare_v2(db, insert, -1, &statement, nil) == SQLITE_OK
                                       {
                                           sqlite3_bind_text(statement, 1, i.code, -1, SQLITE_TRANSIENT)
                                           sqlite3_bind_text(statement, 2, i.custname, -1, SQLITE_TRANSIENT)
                                           sqlite3_bind_text(statement, 3, i.prodcode, -1, SQLITE_TRANSIENT)
                                           sqlite3_bind_text(statement, 4, i.packtype, -1, SQLITE_TRANSIENT)
                                           sqlite3_bind_text(statement, 5, i.color, -1, SQLITE_TRANSIENT)
                                           sqlite3_bind_int(statement, 6, Int32(i.qty))
                                           sqlite3_bind_int(statement, 7, Int32(i.kard))
                                           sqlite3_bind_text(statement, 8, i.orderno, -1, SQLITE_TRANSIENT)
                                           sqlite3_bind_text(statement, 9, i.date, -1, SQLITE_TRANSIENT)
                                           sqlite3_bind_text(statement, 10, i.pono, -1, SQLITE_TRANSIENT)
                                           sqlite3_bind_double(statement, 11, i.amt)
       
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
       
                                       sqlite3_finalize(statement)
                                   }
       
                                   let formattedInt = String(format: "%d", locale: Locale.current, intKard)
                                   let formatDbl = String(format: "%.2f", locale: Locale.current, dblAmt)
       
                                   self.lblQty.text = formattedInt
                                   self.lblAmt.text = formatDbl
       
                                   //ProgressIndicator.hide()
                                   progressHUD.hide()
                                   self.myTable.reloadData()
                               }
                        
                            break
                            
                        case .failure(let error):
                            print("Error: \(error)")
                            break
                        
                    }
                
            }
//        Alamofire.request(URL_USER_LOGIN, method: .get, parameters: parameters).responseJSON
//            {
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
//                        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//                            .appendingPathComponent("order.sqlite")
//                        
//                        var db: OpaquePointer?
//                        
//                        if sqlite3_open(fileURL.path, &db) != SQLITE_OK
//                        {
//                            print("error opening database")
//                        }
//                        else
//                        {
//                            //ลบข้อมูลเก่าออกก่อน
//                            let deleteStatementStirng = "DELETE FROM kardall"
//                            var deleteStatement: OpaquePointer? = nil
//                            
//                            if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK
//                            {
//                                if sqlite3_step(deleteStatement) != SQLITE_DONE
//                                {
//                                    print("Could not delete row.")
//                                }
//                            } else
//                            {
//                                print("DELETE statement could not be prepared")
//                            }
//                            
//                            sqlite3_finalize(deleteStatement)
//                            
//                            //บันทึกข้อมูลชุดใหม่
//                            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
//                            
//                            self.OdK_All.removeAll()
//                            var intKard: Int = 0
//                            var dblAmt: Double = 0
//                            
//                            for personDict in array
//                            {
//                                let Code: String
//                                let CustName: String
//                                let Prodcode: String
//                                let Pack: String
//                                let Color: String
//                                let Qty: Int
//                                let KardQty: Int
//                                let Orderno: String
//                                let Date: String
//                                let Pono: String
//                                let Amt : Double
//                                
//                                Orderno = (personDict["orderno"] as! String).trimmingCharacters(in: .whitespacesAndNewlines)
//                                Date = personDict["date"] as! String
//                                
//                                //ตัด GS- ออก
//                                Prodcode = personDict["prodcode"] as! String
//                                Pack = personDict["pack_type"] as! String
//                                Color = personDict["color"] as! String
//                                Qty = personDict["qty"] as! Int
//                                KardQty = personDict["kard"] as! Int
//                                CustName = personDict["custname"] as! String
//                                Pono = personDict["pono"] as! String
//                                Amt = personDict["amt"] as! Double
//                                Code = personDict["code"] as! String
//                                
//                                
//                                intKard = intKard + KardQty
//                                dblAmt = dblAmt + Amt
//                                
//                                //Add data to dictionary
//                                self.OdK_All.append(OdKardAll(customer: CustName, prod: Prodcode, pack: Pack, color: Color, qty: Qty, pkqty: KardQty, orderno: Orderno, date: Date, remark: Pono))
//                                
//                                let insert = "INSERT INTO kardall (code, custname, prodcode, pack, color, qty, kardqty, orderno, date, pono, amt)" + "VALUES (?,?,?,?,?,?,?,?,?,?,?);"
//                                var statement: OpaquePointer?
//                                
//                                //preparing the query
//                                if sqlite3_prepare_v2(db, insert, -1, &statement, nil) == SQLITE_OK
//                                {
//                                    sqlite3_bind_text(statement, 1, Code, -1, SQLITE_TRANSIENT)
//                                    sqlite3_bind_text(statement, 2, CustName, -1, SQLITE_TRANSIENT)
//                                    sqlite3_bind_text(statement, 3, Prodcode, -1, SQLITE_TRANSIENT)
//                                    sqlite3_bind_text(statement, 4, Pack, -1, SQLITE_TRANSIENT)
//                                    sqlite3_bind_text(statement, 5, Color, -1, SQLITE_TRANSIENT)
//                                    sqlite3_bind_int(statement, 6, Int32(Qty))
//                                    sqlite3_bind_int(statement, 7, Int32(KardQty))
//                                    sqlite3_bind_text(statement, 8, Orderno, -1, SQLITE_TRANSIENT)
//                                    sqlite3_bind_text(statement, 9, Date, -1, SQLITE_TRANSIENT)
//                                    sqlite3_bind_text(statement, 10, Pono, -1, SQLITE_TRANSIENT)
//                                    sqlite3_bind_double(statement, 11, Amt)
//                         
//                                    //executing the query to insert values
//                                    if sqlite3_step(statement) != SQLITE_DONE
//                                    {
//                                        let errmsg = String(cString: sqlite3_errmsg(db)!)
//                                        print("failure inserting armstr: \(errmsg)")
//                                        return
//                                    }
//                                }
//                                else
//                                {
//                                    let errmsg = String(cString: sqlite3_errmsg(db)!)
//                                    print("error preparing insert: \(errmsg)")
//                                    return
//                                }
//                                
//                                sqlite3_finalize(statement)
//                            }
//                            
//                            let formattedInt = String(format: "%d", locale: Locale.current, intKard)
//                            let formatDbl = String(format: "%.2f", locale: Locale.current, dblAmt)
//                            
//                            self.lblQty.text = formattedInt
//                            self.lblAmt.text = formatDbl
//                            
//                            //ProgressIndicator.hide()
//                            progressHUD.hide()
//                            self.myTable.reloadData()
//                        }
// 
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
    
    
    @IBAction func btnCal(_ sender: Any)
    {
        OdK_All.removeAll()
        myTable.reloadData()
        lblQty.text = "0"
        lblAmt.text = "0.00"
        searchActive = false
        
        LoadData()
    }
     
    
    //เหตุการณ์ ช่องค้นหาได้รับ focus
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        searchActive = true
    }
    
    //เหตุการณ์กดปุ่ม search
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchActive = false
        self.Searchbar.endEditing(true)
    }
    
    //เหตุการณ์ กดซ่อนคีย์บอร์ด
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar)
    {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        searchActive = false
    }
    
    //เหตุการณ์ กรอกตัวอักษรใดๆ ในช่องค้นหา
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if (searchText != "")
        {
            filter(searchTxt: searchText)
            strSearch = searchText //เก็บรุ่นที่กรอง
            searchActive = true
        }
        else
        {
           searchActive =  false
           self.query()
        }
    }
    
    func filter(searchTxt:String)
    {
        //กำหนด พาร์ท db
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("order.sqlite")

        var db: OpaquePointer?

        //Open db
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            //first empty the list of ar
            self.OdK_All.removeAll()

            var queryString = String()
            if (typeValue == "CODE")
            {
                queryString = String(format:"SELECT custname, prodcode, pack, color, qty, kardqty, orderno, date, pono, amt FROM kardall WHERE code LIKE '%%%@%%' ORDER BY prodcode", searchTxt)
            }
            else
            {
                queryString = String(format:"SELECT custname, prodcode, pack, color, qty, kardqty, orderno, date, pono, amt FROM kardall WHERE custname LIKE '%%%@%%' ORDER BY prodcode", searchTxt)
            }
         
            //print(queryString)

            //statement pointer
            var stmt:OpaquePointer?

            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            
            var intKard: Int = 0
            var dblAmt: Double = 0
            
            //od_status, date, orderno, confirm, crterm, prodcode, pono, remark
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                let Custnm = String(cString: sqlite3_column_text(stmt, 0))
                let Prod = String(cString: sqlite3_column_text(stmt, 1))
                let Pack = String(cString: sqlite3_column_text(stmt, 2))
                let Color = String(cString: sqlite3_column_text(stmt, 3))
                let Qty = Int(sqlite3_column_int(stmt, 4))
                let KardQty = Int(sqlite3_column_int(stmt, 5))
                let Orderno = String(cString: sqlite3_column_text(stmt, 6))
                let Date = String(cString: sqlite3_column_text(stmt, 7))
                let Pono = String(cString: sqlite3_column_text(stmt, 8))
                let Amt = Double(sqlite3_column_double(stmt, 9))

                intKard = intKard + KardQty
                dblAmt = dblAmt + Amt
                
                //adding values to list
                self.OdK_All.append(OdKardAll(customer: Custnm, prod: Prod, pack: Pack, color: Color, qty: Qty, pkqty: KardQty, orderno: Orderno, date: Date, remark: Pono))
            }

            let formattedInt = String(format: "%d", locale: Locale.current, intKard)
            let formatDbl = String(format: "%.2f", locale: Locale.current, dblAmt)
            
            self.lblQty.text = formattedInt
            self.lblAmt.text = formatDbl
            
            self.myTable.reloadData()

            sqlite3_finalize(stmt)
            sqlite3_close(db)
        }
        else
        {
            print("error opening database")
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        //กำหนดค่าเริ่มต้น
        typeValue = "CODE"
        textbox.text = "ค้นหา : \(typeValue)"
    }
}

extension ODKardAllViewController: UITableViewDataSource, UITableViewDelegate
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return OdK_All.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let myOd = OdK_All[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! OdKardAllCell
        cell.viewData(OdKardAll: myOd)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return "ลูกค้า:                     รุ่น:               แพ็ค:                         สั่ง:      ค้าง:     เลขที่OD:       วันที่:         "
    }
}
