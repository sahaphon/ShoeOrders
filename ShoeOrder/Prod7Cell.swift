//
//  Prod7Cell.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 3/5/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit

protocol Prod7CellDelegate
{
    func Add(prodcode : String, packcode : String, pairs : Int)
    func Delete(prodcode : String, packcode : String, pairs : Int)
    func SaveRecCurrent(prodcode : String, packcode : String, pairs : Int)
    
    //เพิ่มรายการแถม Free
    func SaveQtyFree(prodcode : String, packcode : String, pairs : Int)
}

class Prod7Cell: UITableViewCell
{
    @IBOutlet weak var lblProd: UILabel!
    @IBOutlet weak var lblStyle: UILabel!
    @IBOutlet weak var lblPack: UILabel!
    @IBOutlet weak var lblPackNo: UILabel!
    @IBOutlet weak var lblPairs: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var txtQty: UITextField!
    
    //รายการแถม 
    @IBOutlet weak var txtFree: UITextField!
    @IBOutlet weak var btnFqty: UIButton!
    
    var pro7Item : Pro7!
    var delegate : Prod7CellDelegate?
    
    
    @IBAction func btnFeeQty(_ sender: Any)
    {
        delegate?.SaveQtyFree(prodcode: pro7Item.prodcode!, packcode: pro7Item.packcode!, pairs: pro7Item.pairs!)
    }
    
    
    @IBAction func btnMinus(_ sender: Any)
    {
         //print("\(String(describing: prod.style!)): \(String(describing: prod.sizedesc!)): \(String(describing: prod.packcode!)): \(String(describing: prod.qty!))") */
        delegate?.Delete(prodcode: pro7Item.prodcode!, packcode: pro7Item.packcode!, pairs: pro7Item.pairs!)
    }
    
    @IBAction func btnPlus(_ sender: Any)
    {
         //print("\(String(describing: prod.style!)): \(String(describing: prod.sizedesc!)): \(String(describing: prod.packcode!)): \(String(describing: prod.qty!))")
        delegate?.Add(prodcode: pro7Item.prodcode!, packcode: pro7Item.packcode!, pairs: pro7Item.pairs!)
    }
    
    @IBAction func btnRecSave(_ sender: Any)
    {
         delegate?.SaveRecCurrent(prodcode: pro7Item.prodcode!, packcode: pro7Item.packcode!, pairs: pro7Item.pairs!)
    }
    
    
    func setData(Pro7: Pro7, stat: Bool)
    {
        pro7Item = Pro7
        lblProd.text = Pro7.prodcode
        lblStyle.text = Pro7.style
        lblPack.text = Pro7.packcode
        lblPackNo.text = Pro7.packno
        
        let _pairs:Int = Pro7.pairs!
        let strPairs:String = String(describing: _pairs)
        lblPairs.text = strPairs                              //Convert Int to String
        lblDesc.text = Pro7.sizedesc
        
        let _qty:Int = Pro7.qty!
        let strQty:String = String(describing: _qty)
        txtQty.text = strQty
        
        //ซ่อนปุ่ม
        txtFree.isHidden = stat
        btnFqty.isHidden = stat
        
        //จำนวนแถม
        let _qtyfree:Int = Pro7.qty_free!
        let strFQty:String = String(describing: _qtyfree)
        txtFree.text = strFQty
    }
}
