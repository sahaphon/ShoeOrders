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
    
    struct Inv: Decodable {
        let date: String
        let docno: String
        let code: String
        let refno: String
        let retdate: String
        let prod: String
        let colorcode: String
        let orderno: String
        let qty: Int
        let color: String
    }
    
    func LoadData()
    {
            //ProgressBar
            let progressHUD = ProgressHUD(text: "LOADING...")
            self.view.addSubview(progressHUD)
                        
            //URL
            let URL = "http://111.223.38.24:3000/lstinv"
            
            //Set Parameter
            let parameters : Parameters=[
                "code": CustomerViewController.GlobalValiable.myCode,
                "sale": CustomerViewController.GlobalValiable.saleid
            ]
            print(CustomerViewController.GlobalValiable.saleid, CustomerViewController.GlobalValiable.myCode)
            
            AF.request(URL, method: .get, parameters: parameters)
                .validate(statusCode: 200..<300)
                .responseDecodable(of: [Inv].self) {  [weak self] response in
                    guard let self = self else { return }
                    
                    switch response.result {
                            
                        case .success(let value):
                        
                        
                            if value.count == 0 {
                                showAlert(title: "Not found data!", message: "ไม่พบข้อมูลในระบบ กรุณาลองใหม่อีกครั้ง..")
                                progressHUD.hide()
                                ProgressIndicator.hide()
                                return
                            }
                        
                            for i in value {
                            
                                //Add data to dictionary
                                self.inv30.append(Invoice30(date: i.date, invno: i.docno, prodcode: i.prod, color: i.color, qty: i.qty, snddate: i.retdate, orderno: i.orderno))
                            
                            }
                        
                                progressHUD.hide()
                                self.myTable.reloadData()
                            break
                            
                        case .failure(let error):
                            print("Error: \(error)")
                            showAlert(title: "Error", message: "\(error)")
                            break
                    }
                    
                }
                    
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
