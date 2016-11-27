//
//  InteractiveLabel.swift
//  SHUU
//
//  Created by Vhyme on 2016/11/26.
//  Copyright © 2016年 riku. All rights reserved.
//

import UIKit
import CPImageViewer

class InteractiveImageView : UIImageView, CPImageControllerProtocol {
    var touched : (() -> Void)?
    var loaded = false
    var original = false
    
    var animationImageView: UIImageView!
    var controller : CPImageViewerViewController!
    
    override func didMoveToSuperview() {
        animationImageView = self
        isUserInteractionEnabled = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touched?()
    }
    
    func show() {
        controller = CPImageViewerViewController()
        controller.transitioningDelegate = CPImageViewerAnimator()
        controller.image = self.image
        controller.viewerStyle = .presentation
        
        controller.view.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(self.showActions)))
        
        AppDelegate.instance.nav.present(controller, animated: true, completion: nil)
    }
    
    @objc func showActions() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "保存图片", style: .default) {
            action in self.save()
        })
        sheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        controller.present(sheet, animated: true, completion: nil)
    }
    
    func save() {
        if let image = image {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.saved), nil)
        }
    }
    
    @objc func saved(a: UIImage, b: NSError, c: Any) {
        AppDelegate.instance.nav.showMessage(message: "图片已保存到相册")
    }
}
