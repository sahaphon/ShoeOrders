//
//  SolidAsortCell.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 6/27/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit

protocol SolidAsortCellDelegate
{
    func Add(packcode : String)
    func Delete(packcode : String)
}

class SolidAsortCell: UITableViewCell
{

    @IBOutlet weak var lblPackno: UILabel!
    @IBOutlet weak var lblFree: UILabel!
    @IBOutlet weak var lblPackdesc: UILabel!
    @IBOutlet weak var lblQty: UILabel!
    
    var items : SolidAsort!
    var delegate : SolidAsortCellDelegate?
    
    @IBAction func btnAdd(_ sender: Any)
    {
        delegate?.Add(packcode: items.packcode!)
    }
    
    @IBAction func btnDel(_ sender: Any)
    {
        delegate?.Delete(packcode: items.packcode!)
    }
    
    func setData(SolidAsort: SolidAsort)
    {
        items = SolidAsort
        lblPackno.text = SolidAsort.packcode
        lblFree.text = SolidAsort.free
        lblPackdesc.text = SolidAsort.packdesc
        
        let _qty:Int = SolidAsort.qty!
        let strQty:String = String(describing: _qty)
        lblQty.text = strQty
        
        lblQty.layer.masksToBounds = true
        lblQty.layer.cornerRadius = 23
    }
    
}
