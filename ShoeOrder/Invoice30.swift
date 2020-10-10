//
//  Invoice30.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 8/17/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit
class Invoice30
{
    var date : String?
    var invno : String?
    var prodcode : String?
    var color : String?
    var qty : Int?
    var snddate : String?
    var orderno : String?
    
    init(date: String?, invno: String?, prodcode: String?, color: String?, qty: Int?, snddate: String?, orderno: String?)
    {
        self.date = date
        self.invno = invno
        self.prodcode = prodcode
        self.color = color
        self.qty = qty
        self.snddate = snddate
        self.orderno = orderno
    }
}
