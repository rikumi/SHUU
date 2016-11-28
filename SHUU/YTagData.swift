//
//  ETagData.swift
//  SHUU
//
//  Created by Vhyme on 2016/11/26.
//  Copyright © 2016年 riku. All rights reserved.
//

import Foundation
import Fuzi

class YTagData : BaseData {
    var name : String
    
    init (str : String) {
        name = str
    }
    
    var url : String {
        return "https://yande.re/post?tags=" + name
    }
    
    @objc func open() {
        YImageVC.start(withUrl: url, title: name)
    }
}
