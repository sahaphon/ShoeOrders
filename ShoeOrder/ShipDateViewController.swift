//
//  ShipDateViewController.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 1/3/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit

class ShipDateViewController: UIViewController {
    
    var strShipDate : String = ""
    @IBOutlet var Shipdate: UIDatePicker!
    
    @IBAction func btnAccept(_ sender: Any)
    {
        CustomerViewController.GlobalValiable.strShipDate = strShipDate
        CustomerViewController.GlobalValiable.blnEditShip = true
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Create date formatter
        let date = Date()
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        strShipDate = dateFormatter.string(from: date)
        
        // Add an event to call onDidChangeDate function when value is changed.
        Shipdate.addTarget(self, action: #selector(ShipDateViewController.datePickerValueChanged(_:)), for: .valueChanged)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker){
        
        // Create date formatter
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        strShipDate = dateFormatter.string(from: sender.date)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
