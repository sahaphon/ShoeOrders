//
//  OdNotSend.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 2/14/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit
class notSend
{
    var prodcode: String?
    var packtype: String?
    var color: String?
    var qty: Int?
    var qty_kard: Int?
    var qty_send: Int?
    var invoice: String?
    var inv_date: String?
    var od: String?
    var od_date: String?
    var pono: String?
    var code: String?
    var sale: String?
    
    init(prodcode: String?, packtype: String?, color: String?, qty: Int?, qty_kard: Int?, qty_send: Int?, invoice: String?, inv_date: String?, od: String?, od_date: String?, pono: String?, code: String?, sale: String?)
    {
        self.prodcode = prodcode
        self.packtype = packtype
        self.color = color
        self.qty = qty
        self.qty_kard = qty_kard
        self.qty_send = qty_send
        self.invoice = invoice
        self.inv_date = inv_date
        self.od = od
        self.od_date = od_date
        self.pono = pono
        self.code = code
        self.sale = sale
    }
}
