//
//  AsortColor.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 6/18/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit
class AsortColor
{
    var packno: Int?
    var colorcode: String?
    var colordesc: String?
    var qty: Int?
    var pairs: Int?
    
    init(packno: Int?, colorcode: String?, colordesc: String?, qty: Int?, pairs: Int?)
    {
        self.packno = packno
        self.colorcode = colorcode
        self.colordesc = colordesc
        self.qty = qty
        self.pairs = pairs
    }
}
