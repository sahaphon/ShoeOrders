//
//  AsortTableViewCell.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 6/18/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit

protocol AsortTableViewCellDelegate
{
    func Add(colorcode : String, pairs : Int, qty : Int)
    func Delete(colorcode : String, pairs : Int, qty : Int)
}

class AsortTableViewCell: UITableViewCell {

    @IBOutlet weak var lblPackno: UILabel!
    @IBOutlet weak var lblQty: UILabel!
    @IBOutlet weak var lblColorcode: UILabel!
    @IBOutlet weak var lblPairs: UILabel!
    @IBOutlet weak var lblColorDesc: UILabel!
    
    var Item : AsortColor!
    var delegate : AsortTableViewCellDelegate?
    
    @IBAction func btnAdd(_ sender: Any)
    {
        delegate?.Add(colorcode: Item.colorcode!, pairs: Item.pairs!, qty: Item.qty!)
    }
    
    
    @IBAction func btnMin(_ sender: Any)
    {
        delegate?.Delete(colorcode: Item.colorcode!, pairs: Item.pairs!, qty: Item.qty!)
    }
    
    
    func setData(AsortColor: AsortColor)
    {
        Item = AsortColor
        lblColorcode.text = AsortColor.colorcode
        lblColorDesc.text = AsortColor.colordesc
        
        let _packno:Int = AsortColor.packno!
        let strPackno:String = String(describing: _packno)
        lblPackno.text = strPackno

        let _qty:Int = AsortColor.qty!
        let strQty:String = String(describing: _qty)
        lblQty.text = strQty
        
        let _pairs:Int = AsortColor.pairs!
        let strPairs:String = String(describing: _pairs)
        lblPairs.text = strPairs
    }
    
}
