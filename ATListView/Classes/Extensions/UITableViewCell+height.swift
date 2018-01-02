//
//  UITableViewCell+height.swift
//  ATListView
//
//  Created by 凯文马 on 20/12/2017.
//

import UIKit

private var BottomViewSpaceKey : Void?

private var BottomViewKey : Void?

// MARK: - cell 计算高度扩展
public extension UITableViewCell {
    
    fileprivate enum ViewTag : Int {
        case ignore = 1317749
        case unignore = 1317748
    }
    
    /// contentView最底部视图距cell底部的距离
    public var autoBottomViewSpace : CGFloat? {
        get {
            let v = objc_getAssociatedObject(self, &BottomViewSpaceKey) as? NSNumber
            return  v != nil ? CGFloat(v!.floatValue) : nil
        }
        set {
            var value = newValue
            if value != nil {
                value = max(0, value!)
            }
            let v = value != nil ? NSNumber.init(value: Float(value!)) : nil
            objc_setAssociatedObject(self, &BottomViewSpaceKey, v, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// 自动计算高度时指定的最底部视图，设置该值可免去系统获取最底部视图的步骤
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
                        autoBottomView = view
                        return max(btm, maxBottom)
                }
                return maxBottom + (autoBottomViewSpace ?? 0)
            })
        }
        return bottom! + (autoBottomViewSpace ?? 0)
    }
}

// MARK: - cell高度相关UIView扩展
public extension UIView {
    
    /// 在自动计算高度时永久忽略该UIView
    public func ignoreAlwaysInCell() {
        self.tag = UITableViewCell.ViewTag.ignore.rawValue
    }
    
    /// 在自动计算高度时永久计算该UIView
    public func unignoreAlwaysInCell() {
        self.tag = UITableViewCell.ViewTag.unignore.rawValue
    }
}
