//
//  TabBarVC.swift
//  SHUU
//
//  Created by Vhyme on 2016/11/28.
//  Copyright © 2016年 riku. All rights reserved.
//

import UIKit

class TabBarVC : UITabBarController {
    
    @IBOutlet var segmentedControl : UISegmentedControl!
    
    @IBAction func changeTab() {
        selectedIndex = segmentedControl.selectedSegmentIndex
    }
    
    @IBAction func home() {
        if let vc = selectedViewController {
            (vc as? NavProtocol)?.home()
        }
    }
    @IBAction func refresh() {
        if let vc = selectedViewController {
            (vc as? NavProtocol)?.refresh()
        }
    }
    @IBAction func hd() {
        if let vc = selectedViewController {
            (vc as? NavProtocol)?.hd()
        }
    }
    @IBAction func random() {
        if let vc = selectedViewController {
            (vc as? NavProtocol)?.random()
        }
    }
    
    override func viewDidLoad() {
        tabBar.isHidden = true
    }
}

protocol NavProtocol {
    func home()
    func refresh()
    func hd()
    func random()
}
