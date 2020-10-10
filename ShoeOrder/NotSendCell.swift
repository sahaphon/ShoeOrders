//
//  NotSendCell.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 2/14/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit

class NotSendCell: UITableViewCell {

    @IBOutlet weak var prodcode: UILabel!
    @IBOutlet weak var packtype: UILabel!
    @IBOutlet weak var color: UILabel!
    @IBOutlet weak var qty: UILabel!
    @IBOutlet weak var qty_kard: UILabel!
    @IBOutlet weak var qty_send: UILabel!
    @IBOutlet weak var invoice: UILabel!
    @IBOutlet weak var inv_date: UILabel!
    @IBOutlet weak var od: UILabel!
    @IBOutlet weak var od_date: UILabel!
    @IBOutlet weak var pono: UILabel!
    
    func viewData(notSend: notSend)
    {
        prodcode.text = notSend.prodcode
        packtype.text = notSend.packtype
        color.text = notSend.color
        
        //Convert Int to string
        let _qty:Int = notSend.qty!
        let strQty:String = String(describing: _qty)
        qty.text = strQty
        
        let _qty_kard:Int = notSend.qty_kard!
        let strQty_kard:String = String(describing: _qty_kard)
        qty_kard.text = strQty_kard
        
        let _qty_send:Int = notSend.qty_send!
        let strQty_send:String = String(describing: _qty_send)
        qty_send.text = strQty_send
        
        invoice.text = notSend.invoice
        inv_date.text = notSend.inv_date
        od.text = notSend.od
        od_date.text = notSend.od_date
        pono.text = notSend.pono
    }
}
