//
//  ProductCell.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 1/10/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit

class ProductCell: UITableViewCell, UITextFieldDelegate
{

    @IBOutlet weak var lblProduct: UILabel!
    @IBOutlet weak var lblStyle: UILabel!
    @IBOutlet weak var lblPackcode: UILabel!
    @IBOutlet weak var lblPackno: UILabel!
    @IBOutlet weak var lblPairs: UILabel!
    @IBOutlet weak var lblSizedesc: UILabel!
    @IBOutlet weak var lblQty: UILabel!
    
    func setData(prod: prod)
    {
        lblProduct.text = prod.prodcode
        lblStyle.text = prod.style
        lblPackcode.text = prod.packcode
        lblPackno.text = prod.packno
        
        let _pairs:Int = prod.pairs!
        let strPairs:String = String(describing: _pairs)
        lblPairs.text = strPairs  //Convert Int to String
        lblSizedesc.text = prod.sizedesc
        
        let _qty:Int = prod.qty!
        let strQty:String = String(describing: _qty)
        lblQty.text = strQty
    }
}
