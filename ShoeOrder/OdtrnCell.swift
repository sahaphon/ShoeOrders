//
//  OdtrnCell.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 2/18/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit

class OdtrnCell: UITableViewCell {

    @IBOutlet weak var lblNo: UILabel!
    @IBOutlet weak var lblProd: UILabel!
    @IBOutlet weak var lblSize: UILabel!
    @IBOutlet weak var lblQty: UILabel!
    @IBOutlet weak var lblColor: UILabel!
    @IBOutlet weak var lblPkqty: UILabel!
    @IBOutlet weak var lblStore: UILabel!
    @IBOutlet weak var lblAmt: UILabel!
    
    func viewData(Odtrn: Odtrn)
    {
        let _no:Int = Odtrn.no!
        let strNo:String = String(describing: _no)
        lblNo.text = strNo + "."
        
        lblProd.text = Odtrn.prodcode
        lblSize.text = Odtrn.size
        
        let _qty:Int = Odtrn.qty!
        let strQty:String = String(describing: _qty)
        lblQty.text = strQty
        lblColor.text = Odtrn.color
        
        if (CustomerViewController.GlobalValiable.fromView == "Invoice30")
        {
            lblPkqty.isHidden = true
        }
        else
        {
            let _pkqty:Int = Odtrn.pkqty!
            let strPk:String = String(describing: _pkqty)
            lblPkqty.text = strPk
            lblPkqty.isHidden = false
        }
        
        lblStore.text = Odtrn.store
     
        let _amt:Double = Odtrn.amt!
        let formattedInt = String(format: "%.2f", locale: Locale.current, _amt)
        lblAmt.text = formattedInt
    }
}
