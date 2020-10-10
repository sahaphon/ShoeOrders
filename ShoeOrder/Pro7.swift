//
//  Pro7.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 3/5/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit
class Pro7
{
    var prodcode: String?
    var style: String?
    var packcode: String?
    var packno: String?
    var npack: Int?
    var sizedesc: String?
    var pairs: Int?
    var qty: Int?
    
    //ประกาศตัวแปรเก็บจำนวนแถม
    var qty_free : Int?
    
    init(prodcode: String?, style: String?, npack: Int?, packcode: String?, packno: String?, sizedesc: String?, pairs: Int?, qty: Int?, qty_free : Int?)
    {
        self.prodcode = prodcode
        self.style = style
        self.npack = npack
        self.packcode = packcode
        self.packno = packno
        self.sizedesc = sizedesc
        self.pairs = pairs
        self.qty = qty
        
        //เก็บจำนวนคู่แถม
        self.qty_free = qty_free
    }
    
}

