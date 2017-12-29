//
//  Protocols.swift
//  ATListView
//
//  Created by 凯文马 on 27/12/2017.
//

import UIKit

/// ListView 代理协议
public protocol ListViewDelegate {
    
    /// 设置空页面
    ///
    /// - Parameters:
    ///   - listView: ListView
    ///   - userinfo: 自定义参数
    /// - Returns: 空页面
    func listView(_ listView: UIScrollView, emptyViewFor userinfo: [AnyHashable : Any]?) -> UIView?
    
    /// 设置错误页面
    ///
    /// - Parameters:
    ///   - listView: ListView
    ///   - error: 错误信息
    /// - Returns: 错误页面
    func listView(_ listView: UIScrollView, errorViewFor error: NSError) -> UIView?
}

public extension ListViewDelegate {

    public func listView(_ listView: UIScrollView, errorViewFor error: NSError) -> UIView? {
        return nil
    }
    
    public func listView(_ listView: UIScrollView, emptyViewFor userinfo: [AnyHashable : Any]?) -> UIView? {
        return nil
    }
}
