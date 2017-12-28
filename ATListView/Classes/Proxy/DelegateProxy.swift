//
//  DataSourceProxy.swift
//  ATListView
//
//  Created by 凯文马 on 21/12/2017.
//

import UIKit

class DelegateProxy
: NSObject
, UITableViewDelegate
{
    
    weak var mainProxy : UITableViewDelegate?
    
    weak var secondProxy : UITableViewDelegate?
    
    func exchangeProxy() {
        if mainProxy == nil || secondProxy == nil {
            return
        }
        (mainProxy,secondProxy) = (secondProxy,mainProxy)
    }
    
    init(main: UITableViewDelegate?, second: UITableViewDelegate? = nil) {
        mainProxy = main
        secondProxy = second
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        return super.responds(to: aSelector) || (mainProxy?.responds(to: aSelector) ?? false) || (secondProxy?.responds(to: aSelector) ?? false)
    }

    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        if mainProxy != nil && mainProxy!.responds(to: aSelector) {
            return mainProxy!
        } else if secondProxy != nil && secondProxy!.responds(to: aSelector) {
            return secondProxy!
        }
        return super.forwardingTarget(for: aSelector)
    }
    
    override var description: String {
        return debugDescription
    }
    
    override var debugDescription: String {
        return "UITableViewDelegate<\n\(String(describing: mainProxy)),\n\(String(describing: secondProxy))>"
    }
}

