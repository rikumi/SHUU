//
//  ETagData.swift
//  SHUU
//
//  Created by Vhyme on 2016/11/26.
//  Copyright © 2016年 riku. All rights reserved.
//

import Foundation
import Fuzi

class ETagData : BaseData {
    var name : String
    var id : String
    var type : Int
    
    init (node : XMLElement, id: String?) {
        name = node.firstChild(css: "a")?.stringValue ?? ""
        self.id = node.firstChild(css: "a")?.attr("href")?.replacingOccurrences(of: "/tags/", with: "") ?? ""
        type = Int(id?.components(separatedBy: "_")[0].replacingOccurrences(of: "quicktag", with: "") ?? "0") ?? 0
    }
    
    var url : String {
        return "http://e-shuushuu.net/search/results/?tags=" + id
    }
    
    @objc func open() {
        EImageVC.start(withUrl: url, title: name)
    }
    
    var displayName : String {
        return ["", "", "作品：", "画师：", "人物："][type] + name
    }
}
