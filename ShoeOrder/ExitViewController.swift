//
//  ExitViewController.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 1/17/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit
import Darwin
import Alamofire

class ExitViewController: UIViewController {

    @IBAction func btnCancel(_ sender: Any)
    {
        let TabViewController = self.storyboard?.instantiateViewController(withIdentifier: "Tab") as! MyTabbar
        TabViewController.selectedIndex = 0
        UIApplication.shared.keyWindow?.rootViewController = TabViewController
    }
    
    @IBAction func btnOk(_ sender: Any)
    {
        exit(0)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
}
