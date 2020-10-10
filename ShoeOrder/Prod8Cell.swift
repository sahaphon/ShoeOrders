//
//  Prod8Cell.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 8/24/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit

protocol Prod8CellDelegate
{
    func Min(packcode : String)
    func Plus(packcode : String)
}

class Prod8Cell: UITableViewCell {

    @IBOutlet weak var lblPackcode: UILabel!
    @IBOutlet weak var lblPackno: UILabel!
    @IBOutlet weak var lblProdcode: UILabel!
    @IBOutlet weak var lblPairs: UILabel!
    @IBOutlet weak var lblFree: UILabel!
    @IBOutlet weak var lblPackdesc: UILabel!
    @IBOutlet weak var lblQty: UILabel!
    
    var items : Prod8!
    var delegate : Prod8CellDelegate?
    
    @IBAction func btnMin(_ sender: Any)
    {
        
    }
    
    @IBAction func btnPlus(_ sender: Any)
    {
        
    }
    
    func setData(Prod8: Prod8)
    {
        items = Prod8
        lblPackno.text = Prod8.packcode
        lblPackcode.text = Prod8.packcode
        lblProdcode.text = Prod8.prodcode
        
        let _pairs:Int = Prod8.pairs!
        let strPairs:String = String(describing: _pairs)
        lblPairs.text = strPairs
        
        lblFree.text = Prod8.free
        lblPackdesc.text = Prod8.packdesc
        
        let _qty:Int = Prod8.qty!
        let strQty:String = String(describing: _qty)
        lblQty.text = strQty
        
        //lblQty.layer.masksToBounds = true
        //lblQty.layer.cornerRadius = 23
    }
    

}
