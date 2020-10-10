//
//  OdShoenwCell.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 2/15/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit

class OdShoenwCell: UITableViewCell {

    @IBOutlet weak var imgSta: UIImageView!
    @IBOutlet weak var lblOrder: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblProdcode: UILabel!
    @IBOutlet weak var lblConfirm: UILabel!
    @IBOutlet weak var lblCrterm: UILabel!
    @IBOutlet weak var lblPono: UILabel!
    @IBOutlet weak var lblRemark: UILabel!
    
     func viewData(OdShoenw: OdShoenw)
     {
        imgSta.image = UIImage(named: (OdShoenw.od_status)!)
        lblOrder.text = OdShoenw.orderno
        lblDate.text = OdShoenw.date
        lblProdcode.text = OdShoenw.prodcode
        lblConfirm.text = OdShoenw.confirm
        lblPono.text = OdShoenw.pono
        lblRemark.text = OdShoenw.remark
        
        //Convert Int to string
        let _crterm:Int = OdShoenw.crterm!
        let strCr:String = String(describing: _crterm)
        lblCrterm.text = strCr
     }
}
