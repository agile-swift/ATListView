//
//  DataSourceProxy.swift
//  ATListView
//
//  Created by 凯文马 on 21/12/2017.
//

import UIKit

class DataSourceProxy
: NSObject
, UITableViewDataSource
{
    
    weak var mainProxy : UITableViewDataSource?
    
    weak var secondProxy : UITableViewDataSource?
    
    func exchangeProxy() {
        if mainProxy == nil || secondProxy == nil {
            return
        }
        (mainProxy,secondProxy) = (secondProxy,mainProxy)
    }
    
    init(main: UITableViewDataSource?, second: UITableViewDataSource? = nil) {
        mainProxy = main
        secondProxy = second
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        return super.responds(to: aSelector) || (mainProxy?.responds(to: aSelector) ?? false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let proxy = secondProxy ?? mainProxy ?? self
        if !proxy.isEqual(self) {
            return proxy.tableView(tableView, numberOfRowsInSection: section)
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let proxy = secondProxy ?? mainProxy ?? self
        if !proxy.isEqual(self) {
            return proxy.tableView(tableView, cellForRowAt: indexPath)
        }
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var num = 1
        let proxy = secondProxy ?? mainProxy ?? self
        if !proxy.isEqual(self) {
             num = proxy.numberOfSections?(in: tableView) ?? 1
        }
        return num
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
        return "UITableViewDataSource<\n\(String(describing: mainProxy)),\n\(String(describing: secondProxy))>"
    }
}

