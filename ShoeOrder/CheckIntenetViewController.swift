//
//  CheckIntenetViewController.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 8/18/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit

class CheckIntenetViewController: UIViewController {

    @IBOutlet weak var lstTitle: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lstTitle.font = UIFont(name: "PSL Display", size: 38)
        
    }
    
    @IBAction func btnRecheck(_ sender: Any)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.isConnectedToNetwork()
        {
            if((self.presentingViewController) != nil)
            {
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
    
}
