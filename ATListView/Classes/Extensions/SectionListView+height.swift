//
//  ListView+height.swift
//  ATListView
//
//  Created by 凯文马 on 20/12/2017.
//

import UIKit

private var AutoHeightCacheKey : Void?

// MARK: - SectionListView扩展，高度缓存
public extension SectionListView {
    
    /// 请在heightForRow代理方法中调用该方法返回高度
    /// 动态改变高度的cell请谨慎使用自动高度计算
    /// - Parameters:
    ///   - indexPath: 索引
    ///   - cacheKey: 缓存关键字
    /// - Returns: cell 高度
    public func cellHeight(for indexPath: IndexPath, cacheKey: (RowType) -> String? ) -> CGFloat {
        let ck = cacheKey(model(of: indexPath))
        if ck != nil {
            if autoHeightCache == nil {
                autoHeightCache = [:]
            }
            let height = autoHeightCache![ck!]
            if height != nil {
                return height!
            }
        }
        let cell = self.tableView(self, cellForRowAt: indexPath)
        let h = cell.autoHeight
        if ck != nil {
            autoHeightCache![ck!] = h
        }
        if h <= 0.1 {
            return UITableViewAutomaticDimension
        }
        return h
    }
    
    private var autoHeightCache : [String:CGFloat]? {
        get {
            return objc_getAssociatedObject(self, &AutoHeightCacheKey) as? [String:CGFloat]
        }
        set {
            objc_setAssociatedObject(self, &AutoHeightCacheKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
