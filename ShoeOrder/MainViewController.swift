//
//  MainViewController.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 10/13/18.
//  Copyright © 2018 rich_noname. All rights reserved.
//

import UIKit

class MainViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 247.0 / 255.0, green: 113.0 / 255.0, blue: 30.0 / 255.0, alpha: 1.0)
        self.title = "Welcom to order"
        
        //Add image to view
        let image: UIImage = UIImage(named: "nike-betrue-2018-feature.jpg")!
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
        self.view.addSubview(imageView)
        
        self.addSlideMenuButton()
    }

}
