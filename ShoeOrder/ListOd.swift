//
//  ListOd.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 8/1/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit
class ListOd
{
    var od_status : String?
    var date : String?
    var orderno : String?
    var confirm : String?
    var crterm : Int?
    var prodcode : String?
    var pono : String?
    var remark : String?
    
    init(od_status: String?, date: String?, orderno: String?, confirm: String?, crterm: Int?, prodcode: String?, pono: String?, remark: String?)
    {
        self.od_status = od_status
        self.date = date
        self.orderno = orderno
        self.confirm = confirm
        self.crterm = crterm
        self.prodcode = prodcode
        self.pono = pono
        self.remark = remark
    }
}
