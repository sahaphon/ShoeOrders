//
//  ShipDateViewController.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 1/3/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit
import SQLite3

class ShipDateViewController: UIViewController {
    var strShipDate: String = ""

    @IBOutlet weak var Shipdate: UIDatePicker!
    
    //************ Declare sqlite *****************
    var db: OpaquePointer?
    let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("order.sqlite")
    
    // ******************
    

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        return df
    }()

    // ช่วงอนาคตสูงสุด 45 วัน
    private var maxDate: Date {
        let is_haveP4 = checkProduct4()
        return Calendar.current.date(byAdding: .day, value: is_haveP4 ? 365 : 45, to: Date())!
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
    
  // ถ้าต้องใช้ SQLITE_TRANSIENT ให้ประกาศแบบนี้สักที่หนึ่ง (เช่น ไฟล์เดียวกัน)
  let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
  func checkProduct4() -> Bool {
      var db: OpaquePointer?
          guard sqlite3_open(fileURL.path, &db) == SQLITE_OK else {
              if let msg = sqlite3_errmsg(db) { print("open db error: \(String(cString: msg))") }
              return false
          }
          defer { sqlite3_close(db) }
      
      let sql = "SELECT SUBSTRING(prodcode, 4, 1) prod, saleman, COUNT(*) rows FROM odmst WHERE saleman = ? AND SUBSTRING(prodcode, 4, 1) = '4' GROUP BY SUBSTRING(prodcode, 4,1), saleman"
      
      var stmt: OpaquePointer?
      guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
          if let msg = sqlite3_errmsg(db) { print("prepare error: \(String(cString: msg))") }
          return false
      }
      defer { sqlite3_finalize(stmt) }

      // bind parameter #1 = saleman
      let saleId = CustomerViewController.GlobalValiable.saleid
      saleId.withCString { cstr in
          sqlite3_bind_text(stmt, 1, cstr, -1, SQLITE_TRANSIENT)
      }

      guard sqlite3_step(stmt) == SQLITE_ROW else {
          if let msg = sqlite3_errmsg(db) { print("step error: \(String(cString: msg))") }
          return false
      }

      let count = sqlite3_column_int(stmt, 0)  // อ่าน COUNT(*)
      let havePro4 = count > 0
      print(">>>>>>> มีโปร 4:", havePro4, "count:", count)
      
      return havePro4
    }
}
