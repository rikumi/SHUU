//
//  EImageData.swift
//  SHUU
//
//  Created by Vhyme on 2016/11/26.
//  Copyright © 2016年 riku. All rights reserved.
//

import Foundation
import Fuzi

class YImageData : BaseData {
    var thumbnail : String
    var url : String
    
    var tags : [YTagData]
    
    init(node: XMLElement) {
        thumbnail = node.firstChild(css: "img")?.attr("src") ?? ""
        url = node.firstChild(css: ".directlink")?.attr("href") ?? ""
        tags = []
        let tagStr = node.firstChild(css: "img")?.attr("alt")
        
        var tagSections = tagStr?.replacingOccurrences(of: " Tags: ", with: "|").replacingOccurrences(of: " User: ", with: "|").components(separatedBy: "|") ?? []
        if tagSections.count > 1 {
            tagSections = tagSections[1].components(separatedBy: " ")
        }
        
        for tagStr in tagSections {
            tags.append(YTagData(str: tagStr))
        }
    }
}
