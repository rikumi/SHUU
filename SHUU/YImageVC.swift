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

class YImageVC : UIViewController, UIScrollViewDelegate, UISearchBarDelegate, NavProtocol {
    
    let spacing = CGFloat(8)
    let tagSpacing = CGFloat(0)
    let tagHeight = CGFloat(30)
    
    var leftBottomView, rightBottomView : UIView?
    
    var curLeft = true
    
    var homeUrl = ""
    
    override var title: String? {
        set {
            tabBarController?.navigationItem.title = title
        }
        get {
            return tabBarController?.navigationItem.title
        }
    }
    
    var bigTitle : String?
    
    static func start(withUrl url : String, title: String) {
        let vc = YImageVC()
        vc.bigTitle = title
        vc.homeUrl = url
        AppDelegate.instance.nav.pushViewController(vc, animated: true)
    }
    
    var url : String = "" {
        willSet {
            showProgressDialog()
            YImagePageFetcher(url: newValue).fetchData(then: self.layoutData)
        }
    }
    
    func refresh() {
        showProgressDialog()
        YImagePageFetcher(url: url).fetchData(then: self.layoutData)
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
        searchBar.placeholder = "# 搜标签，P 搜页码，逗号分隔"
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
            url = "https://yande.re"
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
    
    func layoutData(_ data : YImagePageData) {
        
        hideProgressDialog()
        clearView()
        
        UIView.beginAnimations(nil, context: nil)
        
        let itemWidth = (view.frame.width - spacing * 3) / 2
        
        for i in 0 ..< data.images.count {
            let curBottomView = curLeft ? leftBottomView : rightBottomView
            let item = data.images[i]
            if item.explicit && (searchBar.text ?? "") != "*" {
                continue
            }
            
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
                if let url = URL(string: isHD ? item.url : item.thumbnail) {
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
                if tag.name == bigTitle {
                    continue
                }
                
                let tagView = InteractiveLabel()
                tagView.font = UIFont.systemFont(ofSize: 14)
                tagView.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                tagView.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
                tagView.text = "  " + tag.name + "  "
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
        
        let comps = url.components(separatedBy: "?")
        var left = comps[0]
        if left.hasSuffix("yande.re") {
            left += "/post"
        }
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
        
        if !(map["tags"] ?? "").contains(" order:random") {
            map.updateValue((map["tags"]?.appending(" ") ?? "") + "order:random", forKey: "tags")
        }
        url = left + "?" + map.map { $0.0 + "=" + $0.1 }.joined(separator: "&")
        bigTitle = "随机"
    }
    
    func home() {
        url = "https://yande.re"
        bigTitle = "最新"
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
            if keyword == "*" {
                return
            }
            
            keyword = keyword.replacingOccurrences(of: "，", with: ",")
            while keyword.contains(", ") {
                keyword = keyword.replacingOccurrences(of: ", ", with: ",")
            }
            let tags = keyword.components(separatedBy: ",")
            
            var page : String?
            
            var tagParam = ""
            for tag in tags {
                if tag.contains("#") {
                    let tag = tag.replacingOccurrences(of: "#", with: "").trimmingCharacters(in: [" "])
                    
                    if tagParam == "" {
                        tagParam = tag
                    } else {
                        tagParam += "+" + tag
                    }
                    break
                } else if tag.contains("P") {
                    page = tag.replacingOccurrences(of: "P", with: "").trimmingCharacters(in: [" "])
                }
            }
            
            if tagParam != "" {
                bigTitle = "搜索结果"
                var newUrl = "https://yande.re/post?tags=" + tagParam
                if let pageStr = page, let page = Int(pageStr) {
                    newUrl += "&page=" + String(page)
                }
                url = newUrl
            } else if let pageStr = page, let page = Int(pageStr) {
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
