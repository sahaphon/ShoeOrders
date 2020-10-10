//
//  CustomSegue.swift
//  ShoeOrder
//
//  Created by Sahaphon_mac on 10/14/18.
//  Copyright © 2018 rich_noname. All rights reserved.
//

import UIKit

class CustomSegue: UIStoryboardSegue {
    override func perform() {
        if let navigation = source.navigationController {
            navigation.pushViewController(destination, animated: false)
        }
    }
}
