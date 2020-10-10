//
//  Invoice30Cell.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 8/17/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit

class Invoice30Cell: UITableViewCell {

    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblInv: UILabel!
    @IBOutlet weak var lblProd: UILabel!
    @IBOutlet weak var lblColor: UILabel!
    @IBOutlet weak var lblQty: UILabel!
    @IBOutlet weak var lblSndDate: UILabel!
    @IBOutlet weak var lblOd: UILabel!
    
    
    func viewData(Invoice30: Invoice30)
    {
        //Convert Int to string
//        let _no:Int = Odtrn.no!
//        let strNo:String = String(describing: _no)
//        lblNo.text = strNo + "."
        
        lblDate.text = Invoice30.date
        lblInv.text = Invoice30.invno

        lblProd.text = Invoice30.prodcode
        lblColor.text = Invoice30.color

        let _qty:Int = Invoice30.qty!
        let strQty:String = String(describing: _qty)
        lblQty.text = strQty

        lblSndDate.text = Invoice30.snddate
        lblOd.text = Invoice30.orderno
        
    }
}
