//
//  Protocols.swift
//  ATListView
//
//  Created by 凯文马 on 27/12/2017.
//

import UIKit

public protocol ListViewDelegate {
    func listView(_ listView: UIScrollView, emptyViewFor userinfo: [AnyHashable : Any]?) -> UIView?
    
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
