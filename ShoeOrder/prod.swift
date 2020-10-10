//
//  prod.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 1/10/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit
class prod
{
    var prodcode: String?
    var style: String?
    var packcode: String?
    var packno: String?
    var npack: Int?
    var sizedesc: String?
    var pairs: Int?
    var qty: Int?
    
    init(prodcode: String?, style: String?, npack: Int?, packcode: String?, packno: String?, sizedesc: String?, pairs: Int?, qty: Int?)
    {
        self.prodcode = prodcode
        self.style = style
        self.npack = npack
        self.packcode = packcode
        self.packno = packno
        self.sizedesc = sizedesc
        self.pairs = pairs
        self.qty = qty
    }
}
