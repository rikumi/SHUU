//
//  BaseNavigationController.swift
//  SHUU
//
//  Created by Vhyme on 2016/11/26.
//  Copyright © 2016年 riku. All rights reserved.
//

import UIKit

class BaseNavigationController : UINavigationController {
    override func viewDidLoad() {
        AppDelegate.instance.nav = self
    }
}
