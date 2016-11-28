//
//  RecentFetcher.swift
//  SHUU
//
//  Created by Vhyme on 2016/11/26.
//  Copyright © 2016年 riku. All rights reserved.
//

import Foundation
import Fuzi

class EImagePageFetcher {
    
    var url : String
    
    init(url : String) {
        self.url = url
    }
    
    func fetchData(then closure : @escaping (EImagePageData) -> Void) {
        
        let data = EImagePageData()
        
        httpGet(url: url) {
            if let str = $0 {
                if let html = try? HTMLDocument(string: str) {
                    for thread in html.css(".image_thread") {
                        data.images.append(EImageData(node: thread))
                    }
                    if let url = html.firstChild(css: ".next")?.firstChild(css: "a")?.attr("href") {
                        if url.hasPrefix("/") {
                            data.nextPageUrl = "http://e-shuushuu.net" + url
                        } else {
                            data.nextPageUrl = self.url.components(separatedBy: "?")[0] + url
                        }
                    } else {
                        data.nextPageUrl = nil
                    }
                    if let url = html.firstChild(css: ".prev")?.firstChild(css: "a")?.attr("href") {
                        if url.hasPrefix("/") {
                            data.prevPageUrl = "http://e-shuushuu.net" + url
                        } else {
                            data.prevPageUrl = self.url.components(separatedBy: "?")[0] + url
                        }
                    } else {
                        data.prevPageUrl = nil
                    }
                    data.page = Int(html.firstChild(css: ".page")?.stringValue.replacingOccurrences(of: "Page ", with: "") ?? "1") ?? 1
                }
            }
            closure(data)
        }
    }
}
