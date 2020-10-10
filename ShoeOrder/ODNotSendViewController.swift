//
//  ODNotSendViewController.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 2/14/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit
import Alamofire

class ODNotSendViewController: UIViewController {
    
    @IBOutlet weak var lblQty: UILabel!
    @IBOutlet weak var lblTotprice: UILabel!
    @IBOutlet weak var myTable: UITableView!
    
    var OdNotSends = [notSend]()  //ประกาศตัวแปรของคลาส
    let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("order.sqlite")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "ยอดค้างส่ง (" + CustomerViewController.GlobalValiable.desc + ")"
        //Set barbuttonItem font
        UIBarButtonItem.appearance().setTitleTextAttributes(
            [
                NSAttributedString.Key.font : UIFont(name: "PSL Display", size: 28)!,
                NSAttributedString.Key.foregroundColor : UIColor.yellow,
                ], for: .normal)
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 256.0 / 255.0, green: 69.0 / 255.0, blue: 0.0 / 255.0, alpha: 100.0)
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "PSL Display", size: 30)!]
        
        LoadData()
    }
    
    @IBAction func blnBack(_ sender: Any)
    {
        if((self.presentingViewController) != nil)
        {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func Reload(_ sender: Any)
    {
        OdNotSends.removeAll()
        myTable.reloadData()
        lblQty.text = "0"
        lblTotprice.text = "0.00"
        
        LoadData()
    }
    
    func LoadData()
    {
        //ProgressBar
        let progressHUD = ProgressHUD(text: "LOADING...")
        self.view.addSubview(progressHUD)
        
        //let URL_USER_LOGIN = "http://consign-ios.adda.co.th/KeyOrders/getODkard.php"
        let URL_USER_LOGIN = "http://111.223.38.24:3000/cal_odkard"  
        
        //Set Parameter
        let parameters : Parameters=[
            "sale": CustomerViewController.GlobalValiable.saleid,
            "code": CustomerViewController.GlobalValiable.myCode
        ]
 
        print("ข้อมูลที่ส่งไป : ", CustomerViewController.GlobalValiable.saleid)
        print("Shop : ", CustomerViewController.GlobalValiable.myCode)
        Alamofire.request(URL_USER_LOGIN, method: .get, parameters: parameters).responseJSON
        {
            response in
            print(response)
        
            if let array = response.result.value as? [[String: Any]] //หากมีข้อมูล
            {
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
                    print("มีข้อมูล od")
                    self.OdNotSends.removeAll()
                    var intKard: Int = 0
                    
                    for personDict in array
                    {
                    
                        let Ordern: String
                        let Date: String
                        var Prodcode: String
                        let Pack: String
                        let Color: String
                        let Qty: Int
                        let Qty_kard: Int
                        let Qty_send: Int
                        let Lst_invno: String
                        let Lst_inv: String
                        let Code: String
                        let Sale: String
                        let Pono: String
                        
                        Ordern = (personDict["orderno"] as! String).trimmingCharacters(in: .whitespacesAndNewlines)
                        Date = personDict["date"] as! String
                        
                        //ตัด GS- ออก
                        Prodcode = personDict["prodcode"] as! String
                        let indexStartOfText = Prodcode.index(Prodcode.startIndex, offsetBy: 3) //ตัวที่4 เป็นตันไป
                        Prodcode = String(Prodcode[indexStartOfText...])
                        
                        Pack = personDict["pack_type"] as! String
                        Color = personDict["color"] as! String
                        Qty = personDict["qty"] as! Int
                        Qty_kard = personDict["kard"] as! Int
                        Qty_send = personDict["invqty"] as! Int
                        Lst_invno = personDict["latest_inv_no"] as! String
                        Lst_inv = personDict["latest_inv"] as! String       //วันที่อินวอยส์
                        Code = personDict["code"] as! String
                        Sale = personDict["saleman"] as! String
                        Pono = personDict["pono"] as! String
                        print("code :", Code)

                        intKard = intKard + Qty_kard
                        
                        //Add data to dictionary
                        self.OdNotSends.append(notSend(prodcode: Prodcode, packtype: Pack, color: Color, qty: Qty, qty_kard: Qty_kard, qty_send: Qty_send, invoice: Lst_invno, inv_date: Lst_inv, od: Ordern, od_date: Date, pono: Pono, code: Code, sale: Sale))
                    }
                    
                      let formattedInt = String(format: "%d", locale: Locale.current, intKard)
                      self.lblQty.text = formattedInt
                      self.lblTotprice.text = "0.00"
                    
                      //ProgressIndicator.hide()
                      progressHUD.hide()
                      self.myTable.reloadData()
                }
                else
                {
                    progressHUD.hide()
                    ProgressIndicator.hide()
                    //Alert
                    let alert = UIAlertController(title: "Not found data!", message: "ไม่พบข้อมูลในระบบ กรุณาลองใหม่อีกครั้ง..", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "ตกลง", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
}

extension ODNotSendViewController: UITableViewDataSource, UITableViewDelegate
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OdNotSends.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return "รุ่น:             แพ็ค:          สี:            สั่ง:      ค้าง:      ส่ง:         อินวอยส์:  วันที่อินวอยส์: "
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let _NotSend = OdNotSends[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! NotSendCell
        cell.viewData(notSend: _NotSend)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let _prod = OdNotSends[indexPath.row]
        CustomerViewController.GlobalValiable.od = _prod.od!
        CustomerViewController.GlobalValiable.fromView = ""
        
        let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "OdTrans") as! OdTransViewController
        let navController = UINavigationController(rootViewController: VC1)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated:true, completion: nil)
    }
    
}
