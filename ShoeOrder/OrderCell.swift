//
//  OrderCell.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 1/16/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit

class OrderCell: UITableViewCell {

    @IBOutlet weak var lblNo: UILabel!
    @IBOutlet weak var lblProd: UILabel!
    @IBOutlet weak var lblColorDesc: UILabel!
    @IBOutlet weak var lblSizedesc: UILabel!
    @IBOutlet weak var lblQty: UILabel!
    @IBOutlet weak var lblFree: UILabel!
    @IBOutlet weak var lbln_pack: UILabel!
    
    
    func setData(Order: Order)
    {
        lblNo.text = Order.packcode
        lblProd.text = Order.prodcode
        lblColorDesc.text = Order.colordesc
        lblSizedesc.text = Order.sizedesc
        lbln_pack.text = Order.npack
        
        if (Order.free == "แถม")
        {
            lblFree.text = Order.free
        }
        else{
            lblFree.text = Order.free
        }
        
        
        
        //ใส่ commar คั้นจำนวนเงิน
        let _qty:Int = Order.qty!
        let formattedInt = String(format: "%d", locale: Locale.current, _qty)
        lblQty.text = formattedInt
    }
}
