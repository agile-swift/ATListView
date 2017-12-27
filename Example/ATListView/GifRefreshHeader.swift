//
//  GifRefreshHeader.swift
//  ATRefresh_Example
//
//  Created by 凯文马 on 26/12/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import ATRefresh

class GifRefreshHeader: RefreshGifHeader {

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(refreshClosure: @escaping (RefreshHeader) -> Void) {
        super.init(refreshClosure: refreshClosure)
        var i1 : [UIImage] = []
        for index in 26...50 {
            i1.append(UIImage.init(named: "grayloading\(index)")!)
        }
        var i2 : [UIImage] = []
        for index in 1...25 {
            i2.append(UIImage.init(named: "grayloading\(index)")!)
        }
        for index in 1...25 {
            i2.append(UIImage.init(named: "grayloading\(26 - index)")!)
        }
        
        self.setAnimationImages(i1, for: .idle)
        self.setAnimationImages(i1, for: .isPulling)
        self.setAnimationImages(i2, for: .willRefresh)
        self.setAnimationImages(i2, for: .isRefreshing)
//        self.backgroundColor = UIColor.red
//        self.backgroundColor = UIColor.red
    }
    
    override var frame: CGRect {
        willSet {
            print(newValue)
        }
    }
}
