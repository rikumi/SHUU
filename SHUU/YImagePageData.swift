//
//  EImagePageData.swift
//  SHUU
//
//  Created by Vhyme on 2016/11/26.
//  Copyright © 2016年 riku. All rights reserved.
//

import Foundation

class YImagePageData : BaseData {
    var page : Int = 1
    var images = [YImageData]()
    var prevPageUrl, nextPageUrl : String?
}
