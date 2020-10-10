//
//  OdKardall.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 8/20/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit
class OdKardAll
{
    var customer : String?
    var prod : String?
    var pack : String?
    var color : String?
    var qty : Int?
    var pkqty : Int?
    var orderno : String?
    var date :String?
    var remark : String?
    
    init(customer: String?, prod: String?, pack: String?, color: String?, qty: Int?, pkqty: Int?, orderno: String?, date: String?, remark: String?)
    {
        self.customer = customer
        self.prod = prod
        self.pack = pack
        self.color = color
        self.qty = qty
        self.pkqty = pkqty
        self.orderno = orderno
        self.date = date
        self.remark = remark
    }
}
