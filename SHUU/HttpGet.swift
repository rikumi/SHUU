//
//  HttpGet.swift
//  SHUU
//
//  Created by Vhyme on 2016/11/26.
//  Copyright © 2016年 riku. All rights reserved.
//

import Foundation
import Alamofire

func httpGet(url : String, _ handler : @escaping (String?) -> Void) {
    Alamofire.request(url).responseString { response in
        handler(response.result.value)
    }
}
