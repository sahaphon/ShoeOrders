//
//  Order.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 1/16/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import Foundation
class Order{
    
    //var no : String?
    var prodcode : String?
    var colordesc : String?
    var packcode : String?
    var sizedesc : String?
    var qty : Int?
    var free : String?
    var npack : String?
    
    init(packcode: String?, prodcode: String?, colordesc: String?, sizedesc: String?, qty: Int?, free: String?, npack: String?)
    {
        //self.no = no
        self.packcode = packcode
        self.prodcode = prodcode
        self.colordesc = colordesc
        self.sizedesc = sizedesc
        self.qty = qty
        self.free = free
        self.npack = npack
    }
}
