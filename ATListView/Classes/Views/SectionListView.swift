//
//  ListView.swift
//  ATListView
//
//  Created by 凯文马 on 19/12/2017.
//

import UIKit
import ATRefresh

public enum ListViewSectionMode {
    case mergeLast
    case addToLast
}

public func registerDefaultListViewDelegate(_ delegate : ListViewDelegate) {
    listViewDelegate = delegate
}

fileprivate var listViewDelegate : ListViewDelegate?

open class SectionListView<SectionType,RowType>
: UITableView
, UITableViewDataSource
, UITableViewDelegate
{
    public typealias LoadDataCallback = (NSError?,[SectionModel<SectionType,RowType>]?,ListViewSectionMode,Bool)->()
    
    public typealias LoadDataClosure = ([SectionModel<SectionType,RowType>]?, Bool, @escaping LoadDataCallback)->()
    
    public typealias CellClosure = (SectionListView<SectionType,RowType>, RowType, IndexPath) -> UITableViewCell
    
    public fileprivate(set) var sectionModels : [SectionModel<SectionType,RowType>] = []

    fileprivate var cellClosure : CellClosure?

    fileprivate var dataSourceProxy : DataSourceProxy!
    
    fileprivate var delegateProxy : DelegateProxy!
    
    fileprivate var emptyViewClosure : (() -> UIView)?
    
    fileprivate var errorViewClosure : ((NSError) -> UIView)?
    
    fileprivate weak var emptyView : UIView? {
        didSet {
            if oldValue == emptyView { return }
            oldValue?.removeFromSuperview()
            if emptyView != nil {
                self.isHidden = true
                emptyView?.isHidden = false
                emptyView?.alpha = 0
                self.superview?.insertSubview(emptyView!, aboveSubview: self)
                UIView.animate(withDuration: 0.3, animations: {
                    self.emptyView?.alpha = 1.0
                })
            } else {
                self.isHidden = false
            }
        }
    }
    
    fileprivate weak var errorView : UIView? {
        didSet {
            if oldValue == errorView { return }
            oldValue?.removeFromSuperview()
            if errorView != nil {
                self.isHidden = true
                errorView?.isHidden = false
                errorView?.alpha = 0
                self.superview?.insertSubview(errorView!, aboveSubview: self)
                UIView.animate(withDuration: 0.3, animations: {
                    self.errorView?.alpha = 1.0
                })
            } else {
                self.isHidden = false
            }
        }
    }

    fileprivate var loadDataClosure : LoadDataClosure?
    
    fileprivate lazy var loadMoreDatasCallback : LoadDataCallback = { [unowned self] (err, sections, mode, showMore) in
        if err == nil {
            if sections == nil || sections!.isEmpty {
                // empty
                self.loadEmptyView()
            } else {
                // has data
                switch mode {
                case .mergeLast:
                    var new = sections!
                    if let newFirst = new.first,
                       let oldLast = self.sectionModels.last {
                        self.sectionModels.removeLast()
                        new.removeFirst()
                        let mergeOne = SectionModel<SectionType,RowType>.init(title: newFirst.title, items: oldLast.items + newFirst.items)
                        self.sectionModels += ([mergeOne] + new)
                    }
                    break
                case .addToLast:
                    self.sectionModels += sections!
                    break
                }
            }
            self.reloadData()
            self.refreshFooter?.endRefresh(!showMore)
        } else {
            // error
            self.refreshFooter?.endRefresh(true)
            self.loadErrorView(err!)
        }
    }
    
    fileprivate lazy var refreshDatasCallback : LoadDataCallback = { [unowned self] (err, sections, mode, showMore) in
        if err == nil {
            if sections == nil || sections!.isEmpty {
                // count = 0
                self.sectionModels = []
                self.loadEmptyView()
            } else {
                // has data
                self.sectionModels = sections!
            }
            self.reloadData()
            self.refreshFooter?.isInvalid = !showMore
            self.refreshFooter?.reset()
        } else {
            // error
            self.loadErrorView(err!)
        }
        self.refreshHeader?.endRefresh()
    }
    
    public func model(of indexPath: IndexPath) -> RowType {
        return sectionModels[indexPath]
    }
    
    public func sectionModel(of section: Int) -> SectionModel<SectionType,RowType> {
        return sectionModels[section]
    }

    open func configDatas(_ datasClosure : @escaping LoadDataClosure) {
        loadDataClosure = datasClosure
    }
    
    open func loadData() {
        self.refreshHeader?.beginRefresh()
    }

    open func configCell(_ cell : @escaping CellClosure) {
        self.cellClosure = cell
    }
    
    open func configEmptyView(_ closure: @escaping () -> UIView) {
        emptyViewClosure = closure
    }
    
    open func configErrorView(_ closure: @escaping (NSError) -> UIView) {
        errorViewClosure = closure
    }

    public convenience init(style : UITableViewStyle = .plain ,_ configCell:@escaping CellClosure) {
        self.init(style: style, delegate: nil, configCell)
    }
    
    public init(style : UITableViewStyle = .plain, delegate : UITableViewDelegate?, headerType : RefreshHeader.Type = RefreshHeader.self , footerType : RefreshFooter.Type = RefreshFooter.self ,_ configCell:@escaping CellClosure) {
        super.init(frame: .zero, style: style)
        cellClosure = configCell
        self.tableFooterView = UIView()
        dataSourceProxy = DataSourceProxy.init(main: nil, second: self)
        delegateProxy = DelegateProxy.init(main: delegate, second: self)
        self.dataSource = dataSourceProxy
        self.delegate = delegateProxy
        
        self.registerRefreshHeader(headerType, config: { (header) in
            
        }) { [unowned self] (header) in
            self.emptyView = nil
            self.errorView = nil
            self.loadDataClosure?(self.sectionModels,true, self.refreshDatasCallback)
        }
        self.registerRefreshFooter(footerType, config: { (footer) in
            footer.isInvalid = true
        }) { [unowned self] (footer) in
            self.emptyView = nil
            self.errorView = nil
            self.loadDataClosure?(self.sectionModels,false,self.loadMoreDatasCallback)
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var emptyUserInfo : [AnyHashable : Any]?
    
    // MARK: 私有方法
    fileprivate func loadEmptyView() {
        var emptyView = self.emptyViewClosure?()
        if emptyView == nil {
            emptyView = listViewDelegate?.listView(self, emptyViewFor: emptyUserInfo)
        }
        self.emptyView = emptyView
    }
    
    fileprivate func loadErrorView(_ error: NSError) {
        var errorView = self.errorViewClosure?(error)
        if errorView == nil {
            errorView = listViewDelegate?.listView(self, errorViewFor: error)
        }
        self.errorView = errorView
    }
    
    // MARK: 私有重写
    open override var delegate: UITableViewDelegate? {
        set {
            if newValue !== delegateProxy {
                self.delegateProxy.mainProxy = newValue
            }
            super.delegate = delegateProxy
        }
        get {
            return super.delegate
        }
    }
    
    open override var dataSource: UITableViewDataSource? {
        set {
            if newValue === dataSourceProxy {
                super.dataSource = newValue
                return
            }
            self.dataSourceProxy.mainProxy = newValue
        }
        get {
            let temp = self.dataSourceProxy.mainProxy
            return temp
        }
    }
    
    // MARK: 数据源方法
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = sectionModels[section].items.count
        return count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellClosure!(self,sectionModels[indexPath],indexPath)
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        
        let count = sectionModels.count
        return count
    }
    
    // MARK: 代理方法
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let listView = tableView as! SectionListView<SectionType, RowType>
        return listView.cellHeight(for: indexPath, cacheKey: { (_) -> String? in
            return  nil
        })
    }
}

public extension SectionListView {
    public func insertSectionModel(_ model: SectionModel<SectionType,RowType>, at section: Int) {
        sectionModels.insert(model, at: section)
    }
    
    public func insertModel(_ model: RowType, at indexPath: IndexPath) {
        var items = sectionModels[indexPath.section].items
        items.insert(model, at: indexPath.row)
        let sm = SectionModel<SectionType,RowType>.init(title: sectionModels[indexPath.section].title, items: items)
        replaceSectionModel(sm, at: indexPath.section)
        
    }
    
    public func replaceSectionModel(_ model: SectionModel<SectionType,RowType>, at section: Int) {
        sectionModels[section] = model
    }
    
    public func replaceModel(_ model: RowType, at indexPath: IndexPath) {
        var items = sectionModels[indexPath.section].items
        items[indexPath.row] = model
        let sm = SectionModel<SectionType,RowType>.init(title: sectionModels[indexPath.section].title, items: items)
        replaceSectionModel(sm, at: indexPath.section)
    }
    
    public func deleteSectionModel(at section: Int) {
        sectionModels.remove(at: section)
    }
    
    public func deleteModel(at indexPath: IndexPath) {
        var items = sectionModels[indexPath.section].items
        items.remove(at: indexPath.row)
        let sm = SectionModel<SectionType,RowType>.init(title: sectionModels[indexPath.section].title, items: items)
        replaceSectionModel(sm, at: indexPath.section)
    }
}

