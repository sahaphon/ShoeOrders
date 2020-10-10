//
//  SolidAsort.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 6/27/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit
class SolidAsort
{
    var packcode : String?
    var free : String?
    var packdesc : String?
    var qty : Int?
    
    init(packcode: String?, free: String?, packdesc: String?, qty: Int?)
    {
        self.packcode = packcode
        self.free = free
        self.packdesc = packdesc
        self.qty = qty
    }
}
