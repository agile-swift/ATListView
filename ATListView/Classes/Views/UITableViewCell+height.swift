//
//  UITableViewCell+height.swift
//  ATListView
//
//  Created by 凯文马 on 20/12/2017.
//

import UIKit

private var BottomViewSpaceKey : Void?

private var BottomViewKey : Void?

public extension UITableViewCell {
    
    fileprivate enum ViewTag : Int {
        case ignore = 1317749
        case unignore = 1317748
    }
    
    public var autoBottomViewSpace : CGFloat? {
        get {
            return objc_getAssociatedObject(self, &BottomViewSpaceKey) as? CGFloat
        }
        set {
            var value = newValue
            if value != nil {
                value = max(0, value!)
            }
            objc_setAssociatedObject(self, &BottomViewSpaceKey, value, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    public var autoBottomView : UIView? {
        get {
            return objc_getAssociatedObject(self, &BottomViewKey) as? UIView
        }
        set {
            if newValue != nil && contentView.subviews.contains(newValue!) {
                objc_setAssociatedObject(self, &BottomViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    var autoHeight : CGFloat {
        var bottom = self.autoBottomView?.frame.maxY
        if bottom == nil {
            bottom = contentView.subviews.reduce(0, { (maxBottom, view) -> CGFloat in
                if (view.tag != ViewTag.unignore.rawValue && view.tag != ViewTag.ignore.rawValue && !view.isHidden && view.alpha >= 0.1) ||
                    view.tag == ViewTag.unignore.rawValue{
                        let btm = view.frame.maxY
                        return max(btm, maxBottom)
                }
                return maxBottom + (autoBottomViewSpace ?? 0)
            })
        }
        return bottom! + (autoBottomViewSpace ?? 0)
    }
}

public extension UIView {
    public func ignoreAlwaysInCell() {
        self.tag = UITableViewCell.ViewTag.ignore.rawValue
    }
    
    public func unignoreAlwaysInCell() {
        self.tag = UITableViewCell.ViewTag.unignore.rawValue
    }
}
