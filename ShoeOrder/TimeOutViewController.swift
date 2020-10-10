//
//  TimeOutViewController.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 11/22/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit
import Alamofire

class TimeOutViewController: UIViewController
{
    @IBOutlet weak var txtView: UITextView!
    @IBOutlet weak var loginItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginItem.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor : UIColor.red,
            NSAttributedString.Key.font : UIFont (name: "PSL Display", size: 28) as Any], for: .normal)

        txtView.textColor = UIColor.black
        txtView.font = UIFont (name: "PSL Display", size: 28)
        txtView.textAlignment = .center
        
        //print("ตาราง : ", CustomerViewController.GlobalValiable.table_name)
        //หากมีการสร้างตาราง dbf ทิ้งไว้ให้ลบออก กันสร้างไว้แล้วไม่มี od
        if (CustomerViewController.GlobalValiable.table_name != "")
        {
            DropDbfTable()
        }
    }
    
    @IBAction func btnLogin(_ sender: Any)
    {
        let vc = LoginViewController()      //change this to your class name
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
     func DropDbfTable()
        {
            //URL
            let URL_USER_LOGIN = "http://consign-ios.adda.co.th/KeyOrders/dropDbfTable.php"
            
            //getting the username and password
            let parameters : Parameters=[
                "tbname": CustomerViewController.GlobalValiable.table_name
            ]
            
            //print("ลบตาราง = ", CustomerViewController.GlobalValiable.table_name)
            //making a post request
            Alamofire.request(URL_USER_LOGIN, method: .post, parameters: parameters).responseJSON
            {
                response in

            }
        }
}
