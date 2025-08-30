//
//  AsortOnlyViewController.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 6/18/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit
import SQLite3

class AsortOnlyViewController: UIViewController {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblProd: UILabel!
    @IBOutlet weak var lblPackDesc: UILabel!
    @IBOutlet weak var pkPack: UIPickerView!
    @IBOutlet weak var myTable: UITableView!
    @IBOutlet weak var lblTatal: UILabel!
    
    @IBOutlet weak var btnLock: UIButton!
    
    let _no: Int = 0
    var mainpack = "" //เก็บค่าเมื่อเลือก pickerview packsize

    var blnShow = false
    var blnInputQty = false
    var packall : [String] = [String]() //เก็บแบบแพ็ค
    var asorts = [AsortColor]()  //ประกาศตัวแปรของคลาส
    var intRownumber: Int = 0  //เก็บ Rows ที่กำลังแก้ไข
    
    var db: OpaquePointer?
    let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("order.sqlite")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pkPack.dataSource = self
        pkPack.delegate = self
        myTable.delegate = self
        
        if (CustomerViewController.GlobalValiable.free == "แถม")
        {
            lblTitle.text = "เลือกแบบแพ็ค Asort (รายการแถม)"
            lblTitle.textColor = UIColor.red
        }
        else
        {
            lblTitle.text = "เลือกแบบแพ็ค Asort"
            lblTitle.textColor = UIColor.black
        }
        
        
        lblProd.text = CustomerViewController.GlobalValiable.prod
        lblPackDesc.text = ""
        LoadPackcode()
    }
    
    @IBAction func btnSelcPack(_ sender: Any)
    {
        print(blnShow)
        if (blnShow)
        {
            blnShow = false
            pkPack.isUserInteractionEnabled = false  //disable
            btnLock.backgroundColor = UIColor.green
           

            btnLock.setImage(UIImage(named: "unlock-40.png"), for: .normal)
            btnLock.setTitle( "Unlock" , for: .normal )
        }
        else
        {
            blnShow = true
            pkPack.isUserInteractionEnabled = true  //enable
            btnLock.backgroundColor = UIColor.red
            btnLock.setImage(UIImage(named: "lock-40.png"), for: .normal)
            btnLock.setTitle( "Lock" , for: .normal )
        }
    }
    
    
    @IBAction func btnSave(_ sender: Any)
    {
        SaveData()
        CustomerViewController.GlobalValiable.free = "" //เคลียร์สถานะ "แถม"
        
        if let menu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Keyod") as? TakeOrderViewController
        {
            menu.modalPresentationStyle = .fullScreen
            self.present(menu, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnCancel(_ sender: Any)
    {
        CustomerViewController.GlobalValiable.free = "" //เคลียร์สถานะ "แถม"
        
        if let menu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Keyod") as? TakeOrderViewController
        {
            CustomerViewController.GlobalValiable.qty = 0
            menu.modalPresentationStyle = .fullScreen
            self.present(menu, animated: true, completion: nil)
        }
    }
    
    func LoadColor(_packcode: String)
    {
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
           let queryString = String(format:"SELECT a.packcode, a.packno, a.sizedesc, a.colorcode, a.colordesc, a.pairs, CASE WHEN b.qty IS NULL THEN 0 ELSE b.qty END AS qty FROM prodlist  AS a LEFT  OUTER JOIN (SELECT prodcode, packcode, packno, colorcode, colordesc, pairs, SUM(qty) as qty FROM odmst WHERE prodcode = '%@'  AND packcode = '%@' AND status = ''  AND code = '%@' AND store = '%@' GROUP BY prodcode, packcode, packno, colorcode, colordesc, pairs) AS b ON a.prodcode = b.prodcode AND a.packcode = b.packcode AND a.packno = b.packno AND a.colorcode = b.colorcode WHERE a.prodcode = '%@'  AND a.packcode ='%@' GROUP BY a.packcode, a.packno, a.sizedesc, a.colorcode, a.colordesc, a.pairs, b.qty ORDER BY a.colorcode","GS-" + CustomerViewController.GlobalValiable.prod, mainpack, CustomerViewController.GlobalValiable.myCode, CustomerViewController.GlobalValiable.free, "GS-" + CustomerViewController.GlobalValiable.prod, mainpack)
            
            //print("คิวรี่ : \(queryString)")
            
            var stmt:OpaquePointer?
            
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK
            {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing : \(errmsg)")
            }
            
            asorts.removeAll()
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                //let Packcode = String(cString: sqlite3_column_text(stmt, 0))
                let Packno = Int(sqlite3_column_int(stmt, 1))
                let Colorcode = String(cString: sqlite3_column_text(stmt, 3))
                let Colordesc = String(cString: sqlite3_column_text(stmt, 4))
                let pairs = Int(sqlite3_column_int(stmt, 5))
                
                asorts.append(AsortColor(packno: Packno, colorcode: Colorcode, colordesc: Colordesc, qty: Int(sqlite3_column_int(stmt, 6)), pairs: pairs))
            }
            
            myTable.reloadData()
            
            //แสดงจำนวนคู่เริ่มต้น
            var sumQty: Int = 0
            for (value) in asorts
            {
                sumQty = sumQty + value.qty!
            }
            
            lblTatal.text = String(format: "%ld", sumQty)
            
            //Disable pickerview
            blnShow = false
            pkPack.isUserInteractionEnabled = false  //disable
            
            btnLock.backgroundColor = UIColor.green
            btnLock.setImage(UIImage(named: "unlock-40.png"), for: .normal)
            btnLock.setTitle( "Unlock" , for: .normal )
            
            sqlite3_finalize(stmt)
            sqlite3_close(db)
        }
    }
    
    func LoadPackcode()
    {
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            let queryString = String(format:"SELECT prodcode, packcode, sizedesc FROM prodlist WHERE prodcode = '%@' AND n_pack = '%@' GROUP BY prodcode, packcode, sizedesc", "GS-" + CustomerViewController.GlobalValiable.prod, String(CustomerViewController.GlobalValiable.n_pack))
            //print("คิวรี่ : \(queryString)")
            
            var stmt:OpaquePointer?
            
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK
            {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing : \(errmsg)")
            }
            
            packall.removeAll()
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
               let Packcode = String(cString: sqlite3_column_text(stmt, 1))
               let PackDesc = String(cString: sqlite3_column_text(stmt, 2))

               self.packall.append(String(Packcode) + " = " + PackDesc)
            }
            
            self.pkPack.reloadAllComponents()
            
            //Default แบบแพ็ค
            let fullNameArr = packall[0].components(separatedBy: " = ")  //Split string
            mainpack = fullNameArr[0]         //เก็บรหัสแบบแพ็ค
            lblPackDesc.text = fullNameArr[1]
            LoadColor(_packcode: mainpack)    //โหดลช้อมูลสี
            
            sqlite3_finalize(stmt)
            sqlite3_close(db)
        }
        else
        {
            packall.removeAll()
        }
    }
    
    func SaveData()
    {
        var db1: OpaquePointer?
        
        if sqlite3_open(fileURL.path, &db1) == SQLITE_OK
        {
            //บันทึกข้อมูลชุดใหม่
            let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
           
            for value in asorts
            {
                //เช็คว่ามีการคีย์ก่อนหน้าแล้ว
                if (chkexitdata(prod: CustomerViewController.GlobalValiable.prod, packcode: mainpack, packno: value.packno!, colorcode: value.colorcode!)) {
                    
                    var UpdateSql = ""
                    
//                    print("----------------> ", CustomerViewController.GlobalValiable.free)
                    if (CustomerViewController.GlobalValiable.free == "แถม") //กันลบรายการผิด
                    {
//                       print("แถม")
                        UpdateSql = String(format:"UPDATE odmst SET qty = \(value.qty!) WHERE prodcode = '%@' AND code ='%@' AND packcode = '%@' AND packno = \(value.packno!) AND colorcode = '%@' AND n_pack = '%@' AND store = '%@'", "GS-" + CustomerViewController.GlobalValiable.prod, CustomerViewController.GlobalValiable.myCode, mainpack, value.colorcode!, String(CustomerViewController.GlobalValiable.n_pack), "แถม")
                    }
                    else
                    {
//                        print("ไม่แถม")
                            UpdateSql = String(format:"UPDATE odmst SET qty = \(value.qty!) WHERE prodcode = '%@' AND code ='%@' AND packcode = '%@' AND packno = \(value.packno!) AND colorcode = '%@' AND n_pack = '%@' AND store = ''", "GS-" + CustomerViewController.GlobalValiable.prod, CustomerViewController.GlobalValiable.myCode, mainpack, value.colorcode!, String(CustomerViewController.GlobalValiable.n_pack))
                    }
                    
                    
//                    let UpdateSql = String(format:"UPDATE odmst SET qty = \(value.qty!) WHERE prodcode = '%@' AND code ='%@' AND packcode = '%@' AND packno = \(value.packno!) AND colorcode = '%@' AND n_pack = '%@'", "GS-" + CustomerViewController.GlobalValiable.prod, CustomerViewController.GlobalValiable.myCode, mainpack, value.colorcode!, String(CustomerViewController.GlobalValiable.n_pack))
//                    print("อัพเดท : \(UpdateSql)")
                    
                    var updateStatement:OpaquePointer?
                    
                    if sqlite3_prepare(db1, UpdateSql, -1, &updateStatement, nil) == SQLITE_OK
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
                }
                else  //Insert new data
                {
                    if (value.qty! > 0)
                    {
                        //print("Insert...")
                        let insertSql = "INSERT INTO odmst (status, date, delivery, code, orderno, no, prodcode, n_pack, packcode, sizedesc, colorcode, colordesc, qty, price, amt, packno, pairs, dozen, disc1, pono, tax_rate, vat_type, tax_amt, net_amt, cr_term, saleman, remark, recfirm, incvat, logis_code, logicode, ctrycode, store)" + " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);"
                        
                        var statement: OpaquePointer?
                        if sqlite3_prepare(db1, insertSql, -1, &statement, nil) == SQLITE_OK
                        {
                            // Create date formatter
                            let date = Date()
                            let dateFormatter: DateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "dd/MM/yyyy"
                            
                            let numRec = getNumberOfRecAs()
                            //let intQty:Int = product[intRownumber].qty!
                            let intDozen:Int = value.qty! / 12
//                            var send = CustomerViewController.GlobalValiable.logiCode
//                            send = String(send.prefix(2))
                            
                            sqlite3_bind_text(statement, 1, "", -1, SQLITE_TRANSIENT)
                            sqlite3_bind_text(statement, 2, dateFormatter.string(from: date), -1, SQLITE_TRANSIENT)
                            sqlite3_bind_text(statement, 3, dateFormatter.string(from: date), -1, SQLITE_TRANSIENT)
                            sqlite3_bind_text(statement, 4, CustomerViewController.GlobalValiable.myCode, -1, SQLITE_TRANSIENT)
                            sqlite3_bind_text(statement, 5, "", -1, SQLITE_TRANSIENT)  //ยังไม่กำหนด เลขที่ od จนกว่าจะกดส่งข้อมูล
                            sqlite3_bind_int(statement, 6, Int32(numRec!))
                            sqlite3_bind_text(statement, 7, "GS-" + CustomerViewController.GlobalValiable.prod, -1, SQLITE_TRANSIENT)
                            sqlite3_bind_text(statement, 8, String(CustomerViewController.GlobalValiable.n_pack), -1, SQLITE_TRANSIENT)
                            sqlite3_bind_text(statement, 9, mainpack, -1, SQLITE_TRANSIENT)
                            sqlite3_bind_text(statement, 10, lblPackDesc.text!, -1, SQLITE_TRANSIENT)
                            sqlite3_bind_text(statement, 11, value.colorcode, -1, SQLITE_TRANSIENT)
                            sqlite3_bind_text(statement, 12, value.colordesc, -1, SQLITE_TRANSIENT)
                            sqlite3_bind_int(statement, 13, Int32(value.qty!))
                            sqlite3_bind_double(statement, 14, 0)
                            sqlite3_bind_double(statement, 15, 0)
                            sqlite3_bind_int(statement, 16, Int32(value.packno!))
                            sqlite3_bind_int(statement, 17, Int32(value.pairs!)) //เศษโหล
                            sqlite3_bind_int(statement, 18,  Int32(intDozen))  //จำนวนโหล
                            sqlite3_bind_int(statement, 19,  Int32(CustomerViewController.GlobalValiable.disc))  //จำนวนโหล
                            sqlite3_bind_text(statement, 20, "", -1, SQLITE_TRANSIENT)
                            sqlite3_bind_double(statement, 21, 7.00)
                            sqlite3_bind_text(statement, 22, "3", -1, SQLITE_TRANSIENT)
                            sqlite3_bind_double(statement, 23, 0.00)
                            sqlite3_bind_double(statement, 24, 0.00)
                            sqlite3_bind_int(statement, 25,  Int32(CustomerViewController.GlobalValiable.cr_term))  //cr_term
                            sqlite3_bind_text(statement, 26, CustomerViewController.GlobalValiable.saleid, -1, SQLITE_TRANSIENT)
                            sqlite3_bind_text(statement, 27, "", -1, SQLITE_TRANSIENT)
                            sqlite3_bind_int(statement, 28, Int32(CustomerViewController.GlobalValiable.recfirm))  //งานสั่งทำ
                            sqlite3_bind_int(statement, 29, 1)  //incvat
                            sqlite3_bind_text(statement, 30, CustomerViewController.GlobalValiable.logisCode, -1, SQLITE_TRANSIENT) //logis_code
                            sqlite3_bind_text(statement, 31, CustomerViewController.GlobalValiable.logiCode, -1, SQLITE_TRANSIENT)
                            sqlite3_bind_text(statement, 32, "TH", -1, SQLITE_TRANSIENT)
                            sqlite3_bind_text(statement, 33, CustomerViewController.GlobalValiable.free, -1, SQLITE_TRANSIENT)
                            
                            //executing the query to insert values
                            if sqlite3_step(statement) != SQLITE_DONE
                            {
                                let errmsg = String(cString: sqlite3_errmsg(db1)!)
                                print("failure Inserting armstr: \(errmsg)")
                                return
                            }
                            
                            sqlite3_finalize(statement)
                        }
                        else
                        {
                            let errmsg = String(cString: sqlite3_errmsg(db1)!)
                            print("error preparing insert: \(errmsg)")
                            return
                        }
                    }
                    
                }
                
            }
            
            sqlite3_close(db1)
        }
    }
    
    func getNumberOfRecAs() -> Int?
    {
        var id: Int = 0
        
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            let queryString = String(format:"SELECT no FROM odmst WHERE status = '' AND code = '%@' ORDER BY no DESC LIMIT 1", CustomerViewController.GlobalValiable.myCode)
            //print("Query : ", queryString)
            
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
                id = Int(sqlite3_column_int(stmt, 0))
            }
            
            if id == 0  //กรณีไม่มี od ให้เริ่มรหัสแรก
            {
                id = 1
            }
            else //กรณีมีการคีย์ od บ้างแล้ว
            {
                id = id + 1
            }
            
            sqlite3_finalize(stmt)
            sqlite3_close(db)
        }
        
        return id
    }
    
    func chkexitdata(prod: String, packcode: String, packno: Int, colorcode: String) ->Bool
    {
        var blnHaveData = false
        
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            let queryString = String(format:"SELECT * FROM odmst WHERE code = '%@' AND prodcode = '%@' AND packcode = '%@' AND colorcode = '%@' AND packno ='%@' AND n_pack ='%@' AND store = '%@'", CustomerViewController.GlobalValiable.myCode, "GS-" + prod, packcode, colorcode, String(packno), String(CustomerViewController.GlobalValiable.n_pack), CustomerViewController.GlobalValiable.free)
            //print("คิวรี่ : \(queryString)")
            
            var stmt:OpaquePointer?
            
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK
            {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing : \(errmsg)")
            }
            
            packall.removeAll()
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                blnHaveData = true
            }
            
            sqlite3_finalize(stmt)
            sqlite3_close(db)
        }
        
        return blnHaveData
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        if (blnInputQty)
        {
            asorts[intRownumber].qty = CustomerViewController.GlobalValiable.qty //ใส่จำนวนคู่ใน array
            myTable.reloadData()
            
            var sumQty: Int = 0
            
            for (value) in asorts
            {
                sumQty = sumQty + value.qty!
            }
            
            lblTatal.text = String(format: "%ld", sumQty)
            blnInputQty = false
        }

    }
}

extension AsortOnlyViewController: UIPickerViewDelegate, UIPickerViewDataSource
{
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return packall.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return String(packall[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil
        {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "PSL Display", size:40)
            pickerLabel?.textAlignment = .center
        }
        
        let fullNameArr = packall[row].components(separatedBy: " = ")  //Split string
        pickerLabel?.text = fullNameArr[1] //String(packall[row])
        pickerLabel?.textColor = UIColor.blue
        
        return pickerLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        let fullNameArr = packall[row].components(separatedBy: " = ")  //Split string
        mainpack = fullNameArr[0]  //ได้รหัสแบบแพ็ค
        lblPackDesc.text = fullNameArr[1]
        
        //load สี
        LoadColor(_packcode: mainpack)
    }
}

extension AsortOnlyViewController: UITableViewDataSource, UITableViewDelegate
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return asorts.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return "                     สี:                                                                         จำนวนคู่:"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let _colorset = asorts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! AsortTableViewCell
        cell.setData(AsortColor: _colorset)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let _color = asorts[indexPath.row]
        intRownumber = indexPath.row         //เก็บ row ปัจจุบันที่แก้ไข
        blnInputQty =  true
        
        if let menu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "qty") as? PassQtyViewController
        {
            CustomerViewController.GlobalValiable.pairs = _color.pairs!
            menu.modalPresentationStyle = .fullScreen
            self.present(menu, animated: true, completion: nil)
        }
    }
}

extension AsortOnlyViewController: AsortTableViewCellDelegate
{
    func Add(colorcode : String, pairs : Int, qty : Int)
    {
        var i : Int = 0
        var sumQty: Int = 0
        var total : Int = 0
        
        for (value) in asorts
        {

            if (value.colorcode! == colorcode)
            {
                sumQty = value.qty! + value.pairs!
                total = total + sumQty
                asorts[i].qty! = sumQty
            }
            else
            {
                total = total + value.qty!
            }
            
            i = i + 1
        }
        
        myTable.reloadData()
        lblTatal.text = String(format: "%ld", total)
        blnInputQty = false
    }

    func Delete(colorcode : String, pairs : Int, qty : Int)
    {
        var i : Int = 0
        var sumQty: Int = 0
        var total : Int = 0
        
        for (value) in asorts
        {
            
            if (value.colorcode! == colorcode)
            {
                if (value.qty! == 0)
                {
                    sumQty = 0
                }
                else
                {
                    sumQty = value.qty! - value.pairs!
                }
               
                total = total + sumQty
                asorts[i].qty! = sumQty
            }
            else
            {
                total = total + value.qty!
            }
            
            i = i + 1
        }
        
        myTable.reloadData()
        lblTatal.text = String(format: "%ld", total)
        blnInputQty = false
    }
}



