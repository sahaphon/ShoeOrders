//
//  odsend.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 1/17/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit
class odsend
{
    var date: String?
    var code: String?
    var orderno: String?
    var no: Int?
    var prodcode: String?
    var n_pack: String?
    var packcode: String?
    var sizedesc: String?
    var colorcode: String?
    var colordesc: String?
    var qty: Int?
    var price: Decimal?
    var amt: Decimal?
    var packno: String?
    var pairs: Int?
    var dozen: Int?
    var disc: Decimal?
    var pono: String?
    var tax_rate: Decimal?
    var vat_type: String?
    var tax_amt: Decimal?
    var net_amt: Decimal?
    var cr_term: Int?
    var saleman: String?
    var remark: String?
    var recfirm: Int?
    var incvat: Int?
    var logis_code: String?
    var logicode: String?
    var ctrycode: String?
    var store: String?
    
    init(date: String?, code: String, orderno: String, no:Int, prodcode: String, n_pack: String, packcode: String, sizedesc: String, colorcode: String, colordesc: String, qty: Int, price: Decimal, amt: Decimal, packno: String, pairs: Int, dozen: Int, disc: Decimal, pono: String, tax_rate: Decimal, vat_type: String, tax_amt: Decimal, net_amt: Decimal, cr_term: Int, saleman: String, remark: String, recfirm: Int, incvat: Int, logis_code: String, logicode: String, ctrycode: String, store: String)
    {
        self.date = date
        self.code = code
        self.orderno = orderno
        self.no = no
        self.prodcode = prodcode
        self.n_pack = n_pack
        self.packcode = packcode
        self.sizedesc = sizedesc
        self.colorcode = colorcode
        self.colordesc = colordesc
        self.qty = qty
        self.price = price
        self.amt = amt
        self.packno = packno
        self.pairs = pairs
        self.dozen = dozen
        self.disc = disc
        self.pono = pono
        self.tax_rate = tax_rate
        self.vat_type = vat_type
        self.tax_amt = tax_amt
        self.net_amt = net_amt
        self.cr_term = cr_term
        self.saleman = saleman
        self.remark = remark
        self.recfirm = recfirm
        self.incvat = incvat
        self.logis_code = logis_code
        self.logicode = logicode
        self.ctrycode = ctrycode
        self.store = store
    }
}
