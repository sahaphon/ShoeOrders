//
//  ListOdCell.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 8/1/19.
//  Copyright © 2019 rich_noname. All rights reserved.
//

import UIKit

class ListOdCell: UITableViewCell {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var odno: UILabel!
    @IBOutlet weak var od_date: UILabel!
    @IBOutlet weak var prod: UILabel!
    @IBOutlet weak var cr: UILabel!
    @IBOutlet weak var pono: UILabel!
    @IBOutlet weak var remark: UILabel!
    
    func viewData(ListOd: ListOd)
    {
        img.image = UIImage(named: (ListOd.od_status)!)
        odno.text = ListOd.orderno
        od_date.text = ListOd.date
        prod.text = ListOd.prodcode
        pono.text = ListOd.pono
        remark.text = ListOd.remark
        
        //Convert Int to string
        let _crterm:Int = ListOd.crterm!
        let strCr:String = String(describing: _crterm)
        cr.text = strCr
    }
}
