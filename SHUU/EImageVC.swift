//
//  BaseVC.swift
//  SHUU
//
//  Created by Vhyme on 2016/11/26.
//  Copyright © 2016年 riku. All rights reserved.
//

import UIKit
import SnapKit
import SDWebImage
import Alamofire
import Fuzi
import Toast_Swift

class EImageVC : UIViewController, UIScrollViewDelegate, UISearchBarDelegate, NavProtocol {
    
    let spacing = CGFloat(8)
    let tagSpacing = CGFloat(0)
    let tagHeight = CGFloat(30)
    
    var leftBottomView, rightBottomView : UIView?
    
    var curLeft = true
    
    var homeUrl = ""
    
    static func start(withUrl url : String, title: String) {
        let vc = EImageVC()
        vc.title = title
        vc.homeUrl = url
        AppDelegate.instance.nav.pushViewController(vc, animated: true)
    }
    
    var url : String = "" {
        willSet {
            showProgressDialog()
            EImagePageFetcher(url: newValue).fetchData(then: self.layoutData)
        }
    }
    
    func refresh() {
        showProgressDialog()
        EImagePageFetcher(url: url).fetchData(then: self.layoutData)
    }
    
    func hd() {
        if !isHD {
            isHD = true
            showMessage(message: "HD原图已开启")
            refresh()
        } else {
            isHD = false
            showMessage(message: "HD原图已关闭")
            refresh()
        }
    }
    
    var prevPageUrl : String = ""
    var nextPageUrl : String = ""
    
    let prevPageLabel = UILabel()
    let nextPageLabel = UILabel()
    
    let searchBar = UISearchBar()

    var scrollView = UIScrollView()
    
    override func viewDidLoad() {
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
        scrollView.isScrollEnabled = true
        if navigationController?.viewControllers.count == 1 {
            scrollView.contentInset = UIEdgeInsets(top: 65, left: 0, bottom: 0, right: 0)
        }
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view)
        }
        
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "@ 人物，@@ 画师，# 标签，## 作品，P 页码"
        scrollView.addSubview(searchBar)
        searchBar.snp.makeConstraints {
            $0.width.equalTo(view)
            $0.left.equalTo(scrollView)
            $0.right.equalTo(scrollView)
            $0.top.equalTo(scrollView)
        }
        
        prevPageLabel.font = UIFont.systemFont(ofSize: 15)
        prevPageLabel.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        prevPageLabel.textAlignment = .center
        scrollView.addSubview(prevPageLabel)
        prevPageLabel.snp.makeConstraints {
            $0.left.equalTo(scrollView)
            $0.right.equalTo(scrollView)
            $0.bottom.equalTo(scrollView.snp.top)
            $0.height.equalTo(25)
        }
        
        nextPageLabel.font = UIFont.systemFont(ofSize: 15)
        nextPageLabel.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        nextPageLabel.textAlignment = .center
        scrollView.addSubview(nextPageLabel)
        nextPageLabel.snp.makeConstraints {
            $0.left.equalTo(scrollView)
            $0.width.equalTo(view)
            $0.right.equalTo(scrollView)
            $0.top.equalTo(scrollView.snp.bottom)
            $0.top.greaterThanOrEqualTo(scrollView).offset(view.frame.height - 70)
            $0.height.equalTo(25)
        }
        
        if homeUrl != "" {
            url = homeUrl
        } else if url == "" {
            url = "http://e-shuushuu.net"
        }
    }
    
    func clearView() {
        for view in scrollView.subviews {
            if view != prevPageLabel && view != nextPageLabel && view != searchBar {
                view.removeFromSuperview()
            }
        }
        leftBottomView = nil
        rightBottomView = nil
        curLeft = true
        scrollView.contentOffset.y = -scrollView.contentInset.top
    }
    
    func layoutData(_ data : EImagePageData) {
        
        hideProgressDialog()
        clearView()
        
        UIView.beginAnimations(nil, context: nil)
        
        let itemWidth = (view.frame.width - spacing * 3) / 2
        
        for i in 0 ..< data.images.count {
            let curBottomView = curLeft ? leftBottomView : rightBottomView
            let item = data.images[i]
            
            let itemView = UIView()
            itemView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            itemView.layer.cornerRadius = 5
            itemView.clipsToBounds = true
            scrollView.addSubview(itemView)
            itemView.snp.makeConstraints {
                if let curBottomView = curBottomView {
                    $0.left.equalTo(curBottomView)
                    $0.right.equalTo(curBottomView)
                    $0.top.equalTo(curBottomView.snp.bottom).offset(spacing)
                } else if curLeft {
                    $0.left.equalTo(spacing)
                    $0.right.equalTo(scrollView.snp.left).offset(spacing + itemWidth)
                    $0.top.equalTo(searchBar.snp.bottom)
                } else {
                    $0.left.equalTo(2 * spacing + itemWidth)
                    $0.width.equalTo(itemWidth)
                    $0.right.equalTo(scrollView).offset(-spacing)
                    $0.top.equalTo(searchBar.snp.bottom)
                }
                $0.bottom.lessThanOrEqualTo(scrollView).offset(-spacing)
            }
            if curLeft {
                leftBottomView = itemView
            } else {
                rightBottomView = itemView
            }
            curLeft = !curLeft
            
            let image = InteractiveImageView()
            image.clipsToBounds = true
            image.contentMode = .scaleAspectFill
            itemView.addSubview(image)
            image.snp.makeConstraints {
                $0.left.equalTo(itemView)
                $0.right.equalTo(itemView)
                $0.top.equalTo(itemView)
                $0.height.equalTo(image.snp.width)
            }
            
            func loadImage() {
                if let url = URL(string: (isHD || item.thumbnail.contains("spoiler.png")) ? item.url : item.thumbnail) {
                    image.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "pic_loading"), options: SDWebImageOptions(rawValue: 0)) { img, err, type, url in
                        if let img = img {
                            image.loaded = true
                            image.original = isHD
                            
                            image.snp.removeConstraints()
                            image.snp.makeConstraints {
                                $0.left.equalTo(itemView)
                                $0.right.equalTo(itemView)
                                $0.top.equalTo(itemView)
                                $0.height.equalTo(image.snp.width).multipliedBy(img.size.height / img.size.width)
                            }
                        }
                        if err != nil {
                            image.loaded = false
                            image.original = false
                            
                            image.image = #imageLiteral(resourceName: "pic_fail")
                            image.snp.removeConstraints()
                            image.snp.makeConstraints {
                                $0.left.equalTo(itemView)
                                $0.right.equalTo(itemView)
                                $0.top.equalTo(itemView)
                                $0.height.equalTo(image.snp.width)
                            }
                        }
                    }
                }
            }
            
            loadImage()
            
            image.touched = {
                if !image.loaded {
                    loadImage()
                } else if !image.original {
                    if !isHD {
                        self.showProgressDialog()
                    }
                    if let url = URL(string: item.url) {
                        image.sd_setImage(with: url, placeholderImage: image.image, options: SDWebImageOptions(rawValue: 0)) { _, _, _, _ in
                            if !isHD {
                                self.hideProgressDialog()
                            }
                            image.original = true
                            image.show()
                        }
                    }
                } else {
                    image.show()
                }
            }
            
            let tagflow = UIScrollView()
            tagflow.isScrollEnabled = true
            tagflow.showsHorizontalScrollIndicator = false
            itemView.addSubview(tagflow)
            tagflow.snp.makeConstraints {
                $0.left.equalTo(itemView)
                $0.right.equalTo(itemView)
                $0.bottom.equalTo(itemView)
                $0.top.equalTo(image.snp.bottom)
                $0.height.equalTo(tagHeight + 2 * tagSpacing)
            }
            //let allTags =  + item.tags + item.source + item.characters
            
            var first = true
            for tag in item.tags {
                if tag.name == title {
                    continue
                }
                
                let tagView = InteractiveLabel()
                tagView.font = UIFont.systemFont(ofSize: 14)
                tagView.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                tagView.backgroundColor = [#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1), #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)][tag.type]
                tagView.text = "  " + tag.displayName + "  "
                tagView.clipsToBounds = true
                tagView.layer.cornerRadius = 0
                tagflow.addSubview(tagView)
                tagView.snp.makeConstraints {
                    $0.left.greaterThanOrEqualTo(tagflow).offset(tagSpacing)
                    $0.right.lessThanOrEqualTo(tagflow).offset(-tagSpacing)
                    $0.top.equalTo(tagflow).offset(tagSpacing)
                    $0.height.equalTo(tagHeight)
                    $0.bottom.equalTo(tagflow).offset(-tagSpacing)
                    if !first {
                        $0.left.equalTo(tagflow.subviews[tagflow.subviews.count - 2].snp.right).offset(tagSpacing)
                    } else {
                        first = false
                    }
                }
                tagView.touched = tag.open
            }
        }
        
        if data.images.count == 0 {
            let label = UILabel()
            label.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            label.font = UIFont.systemFont(ofSize: 15)
            label.textAlignment = .center
            label.text = "啥也没有 ╮(￣▽￣\")╭"
            scrollView.addSubview(label)
            label.snp.makeConstraints {
                $0.edges.equalTo(scrollView)
            }
        }
        
        UIView.commitAnimations()
        
        title = (title ?? "最新") + " · " + String(data.page)
        nextPageUrl = data.images.count == 0 ? "" : data.nextPageUrl ?? ""
        prevPageUrl = data.images.count == 0 ? "" : data.prevPageUrl ?? ""
        prevPageLabel.text = "当前第 \(data.page) 页 / " + (prevPageUrl != "" ? "上一页" : "没有上一页了")
        nextPageLabel.text = nextPageUrl != "" ? "下一页" : "没有下一页了"
    }
    
    func nextPage() {
        if nextPageUrl != "" {
            url = nextPageUrl
        }
    }
    
    func prevPage() {
        if prevPageUrl != "" {
            url = prevPageUrl
        }
    }
    
    func random() {
        showProgressDialog()
        let request = Alamofire.request("http://e-shuushuu.net/random.php")
        request.responseString { response in
            if response.result.isSuccess {
                if let str = response.result.value {
                    if let html = try? HTMLDocument(string: str) {
                        if let children = html.firstChild(css: ".submit")?.css("input") {
                            for input in children {
                                if (input.attr("name") ?? "") == "referer" {
                                    self.url = "http://e-shuushuu.net" + (input.attr("value") ?? "")
                                    return
                                }
                            }
                        }
                    }
                }
            }
        }
        title = "随机"
    }
    
    func home() {
        url = "http://e-shuushuu.net"
        title = "最新"
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y < -64 - 30 {
            prevPage()
        }
        else if scrollView.contentOffset.y + scrollView.frame.height >= scrollView.contentSize.height + 30 {
            nextPage()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        if var keyword = searchBar.text {
            keyword = keyword.replacingOccurrences(of: "，", with: ",")
            while keyword.contains(", ") {
                keyword = keyword.replacingOccurrences(of: ", ", with: ",")
            }
            let tags = keyword.components(separatedBy: ",")
            
            var page : String?
            
            var params : [String : String] = [:]
            let marks = ["@@": "artist", "##": "source", "@": "char", "#": "tags", "P": "page", "p": "page"]
            for tag in tags {
                var key = "tags"
                for (mark, meaning) in marks {
                    if tag.contains(mark) {
                        
                        key = meaning
                        let tag = tag.replacingOccurrences(of: mark, with: "").trimmingCharacters(in: [" "])
                        
                        if meaning == "page" {
                            page = tag
                        } else if params.contains(where: { $0.0 == key }) {
                            params.updateValue(params[key]! + " " + "\"\(tag)\"", forKey: key)
                        } else {
                            params.updateValue("\"\(tag)\"", forKey: key)
                        }
                        break
                    }
                }
            }
            
            if params.count != 0 {
                showProgressDialog()
                title = "搜索结果"
                let request = Alamofire.request("http://e-shuushuu.net/search/process/", method: .post, parameters: params)
                request.responseString { response in
                    if response.result.isSuccess {
                        if let str = response.result.value {
                            if let html = try? HTMLDocument(string: str) {
                                if let children = html.firstChild(css: ".submit")?.css("input") {
                                    for input in children {
                                        if (input.attr("name") ?? "") == "referer" {
                                            var url = input.attr("value") ?? ""
                                            if url.hasPrefix("/") {
                                                url = "http://e-shuushuu.net" + url
                                            } else {
                                                url = "http://e-shuushuu.net/search/process/" + url
                                            }
                                            if let page = page {
                                                url += "&page=" + page
                                            }
                                            self.url = url
                                            return
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } else if let pageStr = page, let page = Int(pageStr) {
                if title == "随机" {
                    title = "最新"
                }
                
                let comps = url.components(separatedBy: "?")
                let left = comps[0]
                var map : [String : String] = [:]
                
                if comps.count > 1 {
                    let right = comps[1]
                    let params = right.components(separatedBy: "&")
                    for param in params {
                        if param.contains("=") {
                            let keyVal = param.components(separatedBy: "=")
                            map.updateValue(keyVal[1], forKey: keyVal[0])
                        }
                    }
                }
                
                map.updateValue(String(page), forKey: "page")
                url = left + "?" + map.map { $0.0 + "=" + $0.1 }.joined(separator: "&")
            } else {
                showMessage(message: "请输入有效关键词")
            }
        }
    }
}
