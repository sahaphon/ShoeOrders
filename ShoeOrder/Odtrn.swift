//
//  Odtrn.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 2/18/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit
class Odtrn
{
    var no : Int?
    var prodcode : String?
    var size : String?
    var color : String?
    var qty : Int?
    var pkqty : Int?
    var amt : Double?
    var store : String?
    var packcode : String?
    
    init(no: Int?, prodcode: String?, size: String?, color: String?, qty: Int?, pkqty: Int?, amt: Double?, store: String?, packcode: String?)
    {
        self.no = no
        self.prodcode = prodcode
        self.size = size
        self.color = color
        self.qty = qty
        self.pkqty = pkqty
        self.amt = amt
        self.store = store
        self.packcode = packcode
    }
}
