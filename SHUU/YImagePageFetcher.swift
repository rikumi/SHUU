//
//  RecentFetcher.swift
//  SHUU
//
//  Created by Vhyme on 2016/11/26.
//  Copyright © 2016年 riku. All rights reserved.
//

import Foundation
import Fuzi

class YImagePageFetcher {
    
    var url : String
    
    init(url : String) {
        self.url = url
    }
    
    func fetchData(then closure : @escaping (YImagePageData) -> Void) {
        
        let data = YImagePageData()
        
        httpGet(url: url) {
            if let str = $0 {
                if let html = try? HTMLDocument(string: str) {
                    for thread in html.css(".thumb") {
                        data.images.append(YImageData(node: thread))
                    }
                    if let url = html.firstChild(css: ".next_page")?.attr("href") {
                        if url.hasPrefix("/") {
                            data.nextPageUrl = "https://yande.re" + url
                        } else {
                            data.nextPageUrl = self.url.components(separatedBy: "?")[0] + url
                        }
                    } else {
                        data.nextPageUrl = nil
                    }
                    if let url = html.firstChild(css: ".previous_page")?.attr("href") {
                        if url.hasPrefix("/") {
                            data.prevPageUrl = "https://yande.re" + url
                        } else {
                            data.prevPageUrl = self.url.components(separatedBy: "?")[0] + url
                        }
                    } else {
                        data.prevPageUrl = nil
                    }
                    data.page = Int(html.firstChild(css: ".current")?.stringValue ?? "1") ?? 1
                }
            }
            closure(data)
        }
    }
}
