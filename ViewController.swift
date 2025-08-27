//
//  ViewController.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 10/6/18.
//  Copyright © 2018 rich_noname. All rights reserved.
//

import UIKit
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class MyTextField: UITextField
{  //overide = แทนที่
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return super.textRect(forBounds: bounds).insetBy(dx: 10, dy: 0)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return super.editingRect(forBounds: bounds).insetBy(dx: 10, dy: 0)
    }
}

extension UIImage
{
    public convenience init?(color: UIColor, size: CGSize = CGSize(width:1, height:1))
    {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else {
            return nil
        }
        self.init(cgImage: cgImage)
    }
}

/*
class ModelData: NSObject {
    static let shared: ModelData = ModelData()
    var name = "Fred"
    var age = 50
    var yourArray = [String]()
}
*/
