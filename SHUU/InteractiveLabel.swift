//
//  InteractiveLabel.swift
//  SHUU
//
//  Created by Vhyme on 2016/11/26.
//  Copyright © 2016年 riku. All rights reserved.
//

import UIKit

class InteractiveLabel : UILabel {
    var touched : (() -> Void)?
    
    override func didMoveToSuperview() {
        isUserInteractionEnabled = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touched?()
    }
}
