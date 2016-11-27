//
//  ImageData.swift
//  SHUU
//
//  Created by Vhyme on 2016/11/26.
//  Copyright © 2016年 riku. All rights reserved.
//

import Foundation
import Fuzi

class ImageData : BaseData {
    var id : String
    var thumbnail : String
    var url : String
    
    var tags : [TagData]
    
    init(node: XMLElement) {
        id = node.attr("id")?.replacingOccurrences(of: "i", with: "") ?? ""
        thumbnail = "http://e-shuushuu.net" + (node.firstChild(css: "img")?.attr("src") ?? "")
        url = "http://e-shuushuu.net" + (node.firstChild(css: "a.thumb_image")?.attr("href") ?? "")
        tags = []
        for tagflow in node.css(".quicktag") {
            tags.append(contentsOf: tagflow.css(".tag").map { TagData(node: $0, id: tagflow.attr("id")) })
        }
        tags.sort { [4, 3, 1, 0, 2][$0.type] < [4, 3, 1, 0, 2][$1.type] }
    }
}
