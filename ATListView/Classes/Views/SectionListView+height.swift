//
//  ListView+height.swift
//  ATListView
//
//  Created by 凯文马 on 20/12/2017.
//

import UIKit

private var AutoHeightCacheKey : Void?

public extension SectionListView {
    
    private var autoHeightCache : [String:CGFloat]? {
        get {
            return objc_getAssociatedObject(self, &AutoHeightCacheKey) as? [String:CGFloat]
        }
        set {
            objc_setAssociatedObject(self, &AutoHeightCacheKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
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
}
