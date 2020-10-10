//
//  OdKardAllCell.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 8/20/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit

class OdKardAllCell: UITableViewCell {

    @IBOutlet weak var lblCutomer: UILabel!
    @IBOutlet weak var lblProd: UILabel!
    @IBOutlet weak var lblPackdesc: UILabel!
    @IBOutlet weak var llblcolor: UILabel!
    @IBOutlet weak var lblQty: UILabel!
    @IBOutlet weak var lblPkqty: UILabel!
    @IBOutlet weak var lblOrderno: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblRemark: UILabel!
    
    func viewData(OdKardAll: OdKardAll)
    {
        lblCutomer.text = OdKardAll.customer
        lblProd.text = OdKardAll.prod
        lblPackdesc.text = OdKardAll.pack
        llblcolor.text = OdKardAll.color
    
        let _qty:Int = OdKardAll.qty!
        let strQty:String = String(describing: _qty)
        lblQty.text = strQty
        
        let _pkqty:Int = OdKardAll.pkqty!
        let strPkQty:String = String(describing: _pkqty)
        lblPkqty.text = strPkQty
        
        lblOrderno.text = OdKardAll.orderno
        lblDate.text = OdKardAll.date
        lblRemark.text = OdKardAll.remark
    }
}
