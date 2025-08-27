//
//  Invoice30ViewController.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 8/17/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit
import Alamofire

class Invoice30ViewController: UIViewController {
    
    @IBOutlet weak var myTable: UITableView!
    
    var inv30 = [Invoice30]()  //ประกาศตัวแปรของคลาส
    let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("order.sqlite")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 256.0 / 255.0, green: 69.0 / 255.0, blue: 0.0 / 255.0, alpha: 100.0)
        self.title = "อินวอยส์ย้อนหลัง 1 เดือน (\(CustomerViewController.GlobalValiable.desc)\(")")"
        
        UIBarButtonItem.appearance().setTitleTextAttributes(
            [
                NSAttributedString.Key.font : UIFont(name: "PSL Display", size: 28)!,
                NSAttributedString.Key.foregroundColor : UIColor.yellow,
                ], for: .normal)
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "PSL Display", size: 30)!]
        
        LoadData()
    }
    
    func LoadData()
    {
            //ProgressBar
            let progressHUD = ProgressHUD(text: "LOADING...")
            self.view.addSubview(progressHUD)
                        
            //URL
            let URL_USER_LOGIN = "http://111.223.38.24:3000/lstinv"
            
            //Set Parameter
            let parameters : Parameters=[
                "code": CustomerViewController.GlobalValiable.myCode,
                "sale": CustomerViewController.GlobalValiable.saleid
            ]
            print(CustomerViewController.GlobalValiable.saleid, CustomerViewController.GlobalValiable.myCode)
            
//            Alamofire.request(URL_USER_LOGIN, method: .get, parameters: parameters).responseJSON
//                {
//                    
//                    response in
//                    //print(response)
//                    
//                    if let array = response.result.value as? [[String: Any]] //หากมีข้อมูล
//                    {
//                        //Check nil data
//                        var blnHaveData = false
//                        for _ in array  //วนลูปเช็คค่าที่ส่งมา
//                        {
//                            blnHaveData = true
//                            break
//                        }
//                        
//                        //เช็คสิทธิการเข้าใช้งาน
//                        if (blnHaveData)
//                        {
//                            self.inv30.removeAll()
//                            
//                            for personDict in array
//                            {
//                                var date: String
//                                let invno: String
//                                let prodcode: String
//                                let color: String
//                                let qty: Int
//                                let snddate: String
//                                let orderno: String
//                                
//                                date = personDict["date"] as! String
//                                
//                                invno = personDict["docno"] as! String
//                                prodcode = personDict["prod"] as! String
//                                color = personDict["color"] as! String
//                                qty = personDict["qty"] as! Int
//                                snddate = personDict["retdate"] as! String
//                                orderno = ""
//                                
//                                //Add data to dictionary
//                                self.inv30.append(Invoice30(date: date, invno: invno, prodcode: prodcode, color: color, qty: qty, snddate: snddate, orderno: orderno))
//                            }
//                            
//                            //ProgressIndicator.hide()
//                            progressHUD.hide()
//                            self.myTable.reloadData()
//                        }
//                        else
//                        {
//                            progressHUD.hide()
//                            ProgressIndicator.hide()
//                            //Alert
//                            let alert = UIAlertController(title: "Not found data!", message: "ไม่พบข้อมูลในระบบ กรุณาลองใหม่อีกครั้ง..", preferredStyle: .alert)
//                            
//                            alert.addAction(UIAlertAction(title: "ตกลง", style: .default, handler: nil))
//                            self.present(alert, animated: true)
//                        }
//                    }
//            }
    }
    
    @IBAction func btnBack(_ sender: Any)
    {
        if let menu = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ListOD") as? ListOdViewController
        {
            menu.modalPresentationStyle = .fullScreen
            self.present(menu, animated: true, completion: nil)
        }
    }
    
}

extension Invoice30ViewController: UITableViewDataSource, UITableViewDelegate
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inv30.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let myOd = inv30[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! Invoice30Cell
        cell.viewData(Invoice30: myOd)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return "วันที่อินวอยส์:        เลขที่อินวอยส์:           รุ่น:                                         คู่:              วันที่ส่งจริง: "
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let odno = inv30[indexPath.row]
        CustomerViewController.GlobalValiable.invno = odno.invno!
        CustomerViewController.GlobalValiable.fromView = "Invoice30"
        
        let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "OdTrans") as! OdTransViewController
        let navController = UINavigationController(rootViewController: VC1)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated:true, completion: nil)
    }
}
