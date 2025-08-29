//
//  AlertHelper.swift
//  ShoeOrder
//
//  Created by SAHAPHON-M4 on 28/8/2568 BE.
//  Copyright © 2568 BE rich_noname. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(title: String,
                   message: String,
                   okTitle: String = "ตกลง",
                   cancelTitle: String? = nil,
                   okHandler: (() -> Void)? = nil,
                   cancelHandler: (() -> Void)? = nil) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        // ปุ่ม OK
        let okAction = UIAlertAction(title: okTitle, style: .default) { _ in
            okHandler?()
        }
        alert.addAction(okAction)
        
        // ปุ่ม Cancel (ถ้ามี)
        if let cancel = cancelTitle {
            let cancelAction = UIAlertAction(title: cancel, style: .cancel) { _ in
                cancelHandler?()
            }
            alert.addAction(cancelAction)
        }
        
        self.present(alert, animated: true, completion: nil)
    }
}

