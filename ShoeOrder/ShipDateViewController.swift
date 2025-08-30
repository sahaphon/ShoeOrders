//
//  ShipDateViewController.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 1/3/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//
/*
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
*/

import UIKit

class ShipDateViewController: UIViewController {
    var strShipDate: String = ""

    @IBOutlet weak var Shipdate: UIDatePicker!

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        return df
    }()

    // ช่วงอนาคตสูงสุด 45 วัน
    private var maxDate: Date {
        Calendar.current.date(byAdding: .day, value: 45, to: Date())!
    }

    @IBAction func btnAccept(_ sender: Any) {
        // เผื่อกรณีผู้ใช้เลื่อนไปเกินขอบเขตด้วยการสลับ timezone ฯลฯ
        clampIfNeeded()
        CustomerViewController.GlobalValiable.strShipDate = strShipDate
        CustomerViewController.GlobalValiable.blnEditShip = true
        dismiss(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 14.0, *) {
            Shipdate.preferredDatePickerStyle = .inline
        } else {
            if #available(iOS 13.4, *) {
                Shipdate.preferredDatePickerStyle = .wheels
            } else {
                // Fallback on earlier versions
            }
        }
        Shipdate.datePickerMode = .date

        // ✅ จำกัดช่วงเลือก: วันนี้ → +45 วัน
        Shipdate.minimumDate = Date()
        Shipdate.maximumDate = maxDate
        Shipdate.date = Date()

        strShipDate = dateFormatter.string(from: Shipdate.date)
        Shipdate.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
    }

    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        // ถ้าเผลอเลื่อนไปนอกช่วง ให้เด้งกลับเข้าช่วง
        clampIfNeeded()
        strShipDate = dateFormatter.string(from: Shipdate.date)
    }

    private func clampIfNeeded() {
        if let min = Shipdate.minimumDate, Shipdate.date < min {
            Shipdate.setDate(min, animated: true)
        } else if let max = Shipdate.maximumDate, Shipdate.date > max {
            Shipdate.setDate(max, animated: true)
        }
    }
}
