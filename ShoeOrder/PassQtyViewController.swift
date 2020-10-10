//
//  PassQtyViewController.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 1/11/19.
//  Copyright © 2019 rich_noname. All rights reserved.
///Users/sahaphon_mac/Desktop/ShoeOrder/ShoeOrder/PassQtyViewController.swift

import UIKit

class PassQtyViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtQty: UITextField!
    @IBOutlet weak var lblResult: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        txtQty.delegate = self
        
        lblResult.text = ""
        txtQty.text = ""
        
        txtQty.becomeFirstResponder()
    }
    
    @IBAction func btnAccept(_ sender: Any)
    {
        if (txtQty.text?.count)! > 0
        {
            let numQty = txtQty.text!
            let num = Int(numQty)
            //print(CustomerViewController.GlobalValiable.pairs)
            
            if (num!) % CustomerViewController.GlobalValiable.pairs != 0
            {
                lblResult.text = "ผิดพลาด! คุณกรอกจำนวนคู่ ไม่ถูกต้อง"
            }
            else
            {
                lblResult.text = ""
                CustomerViewController.GlobalValiable.qty = num!  //จำนวนคู่/กล่อง
                self.dismiss(animated: false, completion: nil)
            }
        }
        
    }
    
    // Called when the user click on the view (outside the UITextField).
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
    }
    
    //ซ่อนคีย์บอร์ด
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        txtQty.text = textField.text
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //เฉพาะตัวเลข ทศนิยม
        let allowCharactors = "0123456789."
        let allowCharactorSet = CharacterSet(charactersIn: allowCharactors)
        let typedCharactorSet = CharacterSet(charactersIn: string)
        
        return allowCharactorSet.isSuperset(of: typedCharactorSet)
    }

    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        lblResult.text = ""
        txtQty.text = ""
    }
}
