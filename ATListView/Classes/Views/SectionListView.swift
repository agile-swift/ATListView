//
//  ListView.swift
//  ATListView
//
//  Created by 凯文马 on 19/12/2017.
//  组件核心文件

import UIKit
import ATRefresh

/// 模型拼接方式
///
/// - mergeLast: 当前分页数据的第一组合并到上一页最后一组中
/// - addToLast: 不合并，按照新分组保存
public enum ListViewSectionMode {
    case mergeLast
    case addToLast
}

/// 注册ListView代理类型，全局唯一，建议在AppDelegate等类中，切勿使用父类
///
/// - Parameter delegate: 代理对象
public func registerDefaultListViewDelegate(_ delegate : ListViewDelegate) {
    listViewDelegate = delegate
}

fileprivate var listViewDelegate : ListViewDelegate?

/// 带有section的ListView
open class SectionListView<SectionType,RowType>
    : UITableView
    , UITableViewDataSource
    , UITableViewDelegate
{
    /// 初始化方法
    ///
    /// - Parameters:
    ///   - style: 样式
    ///   - delegate: 代理
    ///   - headerType: 下拉刷新组件类
    ///   - footerType: 上拉加载更多组件类
    ///   - configCell: 配置cell闭包
    public init(style : UITableViewStyle = .plain,
                delegate : UITableViewDelegate? = nil,
                headerType : RefreshHeader.Type ,
                footerType : RefreshFooter.Type ,
                _ configCell:@escaping CellClosure) {
        
        super.init(frame: .zero, style: style)
        cellClosure = configCell
        self.tableFooterView = UIView()
        self.dataSource = nil
        self.delegate = delegate
        
        self.registerRefreshHeader(headerType, config: { (header) in
            
        }) { [unowned self] (header) in
            self.loadDataClosure?(self.sectionModels,true, self.refreshDatasCallback)
//            self.emptyView = nil
//            self.errorView = nil
        }
        self.registerRefreshFooter(footerType, config: { (footer) in
            footer.isInvalid = true
        }) { [unowned self] (footer) in
            self.emptyView = nil
            self.errorView = nil
            self.loadDataClosure?(self.sectionModels,false,self.loadMoreDatasCallback)
        }
    }
    
    /// 加载数据的回调闭包定义
    public typealias LoadDataCallback = (NSError?,[SectionModel<SectionType,RowType>]?,ListViewSectionMode,Bool)->()
    
    /// 加载数据的闭包定义
    public typealias LoadDataClosure = ([SectionModel<SectionType,RowType>]?, Bool, @escaping LoadDataCallback)->()
    
    /// 配置cell的闭包定义
    public typealias CellClosure = (SectionListView<SectionType,RowType>, RowType, IndexPath) -> UITableViewCell
    
    /// 获取所有数据
    public fileprivate(set) var sectionModels : [SectionModel<SectionType,RowType>] = []
    
    
    /// 配置数据的方法
    ///
    /// - Parameter datasClosure: 配置数据闭包
    open func configDatas(_ datasClosure : @escaping LoadDataClosure) {
        loadDataClosure = datasClosure
    }
    
    /// 加载数据，触发下拉刷新
    open func loadData() {
        self.refreshHeader?.beginRefresh()
    }
    
    //    open func configCell(_ cell : @escaping CellClosure) {
    //        self.cellClosure = cell
    //    }
    
    /// 配置空页面，如果没有实现此方法会通过代理方法获取空页面
    ///
    /// - Parameter closure: 获取空页面闭包
    open func configEmptyView(_ closure: @escaping (CGRect) -> UIView) {
        emptyViewClosure = closure
    }
    
    /// 配置错误页面，如果没有实现此方法会通过代理方法获取错误页面
    ///
    /// - Parameter closure: 获取错误页面闭包
    open func configErrorView(_ closure: @escaping (NSError,CGRect) -> UIView) {
        errorViewClosure = closure
    }
    
    /// MARK: 私有
    fileprivate var deallocing : Bool = false
    
    fileprivate var cellClosure : CellClosure?
    
    fileprivate var dataSourceProxy : DataSourceProxy?
    
    fileprivate var delegateProxy : DelegateProxy?
    
    fileprivate var emptyViewClosure : ((CGRect) -> UIView)?
    
    fileprivate var errorViewClosure : ((NSError,CGRect) -> UIView)?
    
    fileprivate weak var emptyView : UIView? {
        didSet {
            if oldValue == emptyView { return }
            oldValue?.removeFromSuperview()
            if emptyView != nil {
//                self.isHidden = true
                emptyView?.isHidden = false
//                emptyView?.alpha = 0
                emptyView?.frame = CGRect.init(x: 0, y: self.tableHeaderView?.frame.height ?? 0, width: self.frame.width, height: self.frame.size.height - (tableHeaderView?.frame.height ?? 0))
                self.addSubview(emptyView!)
//                self.superview?.insertSubview(emptyView!, aboveSubview: self)
//                UIView.animate(withDuration: 0.3, animations: {
//                    self.emptyView?.alpha = 1.0
//                })
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
//                self.isHidden = true
                errorView?.isHidden = false
//                errorView?.alpha = 0
                errorView?.frame = CGRect.init(x: 0, y: self.tableHeaderView?.frame.height ?? 0, width: self.frame.width, height: self.frame.size.height - (tableHeaderView?.frame.height ?? 0))
                self.addSubview(errorView!)
//                self.superview?.insertSubview(errorView!, aboveSubview: self)
//                UIView.animate(withDuration: 0.3, animations: {
//                    self.errorView?.alpha = 1.0
//                })
            } else {
                self.isHidden = false
            }
        }
    }
    
    fileprivate var loadDataClosure : LoadDataClosure?
    
    fileprivate lazy var loadMoreDatasCallback : LoadDataCallback = { [unowned self] (err, sections, mode, showMore) in
        self.errorView = nil
        self.emptyView = nil
        if err == nil {
            if sections == nil || sections!.isEmpty || sections!.first!.items.isEmpty {
                
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
        self.errorView = nil
        self.emptyView = nil
        if err == nil {
            if sections == nil || sections!.isEmpty || sections!.first!.items.isEmpty {
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
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var emptyUserInfo : [AnyHashable : Any]?
    
    // MARK: 私有方法
    fileprivate func loadEmptyView() {
        let frame = CGRect.init(x: 0, y: self.tableHeaderView?.frame.height ?? 0, width: self.frame.width, height: self.frame.size.height - (tableHeaderView?.frame.height ?? 0))
        var emptyView = self.emptyViewClosure?(frame)
        if emptyView == nil {
            emptyView = listViewDelegate?.listView(self, emptyView: frame, for: emptyUserInfo)
        }
        self.emptyView = emptyView
    }
    
    fileprivate func loadErrorView(_ error: NSError) {
        let frame = CGRect.init(x: 0, y: self.tableHeaderView?.frame.height ?? 0, width: self.frame.width, height: self.frame.size.height - (tableHeaderView?.frame.height ?? 0))
        var errorView = self.errorViewClosure?(error,frame)
        if errorView == nil {
            errorView = listViewDelegate?.listView(self, errorView: frame, for: error)
        }
        self.errorView = errorView
    }
    
    // MARK: 私有重写
    open override var delegate: UITableViewDelegate? {
        set {
            if deallocing {
                super.delegate = nil
                return
            }
            guard let newDelegate = newValue as? DelegateProxy else {
                let tempDelegate = DelegateProxy.delegate(withMainProxy: newValue, secondProxy: self, for: newValue)
                self.delegateProxy = tempDelegate
                super.delegate = tempDelegate
                return
            }
            super.delegate = newDelegate
        }
        get {
            return super.delegate
        }
    }
    
    deinit {
        deallocing = true
        removeRefreshViews()
    }
    
    open override var dataSource: UITableViewDataSource? {
        set {
            if deallocing {
                super.dataSource = nil
                return
            }
            guard let newDataSource = newValue as? DataSourceProxy else {
                let tempDelegate = DataSourceProxy.dataSource(withMainProxy: self, secondProxy: newValue, for: newValue)
                self.dataSourceProxy = tempDelegate
                super.dataSource = tempDelegate
                return
            }
            super.dataSource = newDataSource
        }
        get {
            return super.dataSource
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
    
    public func model(of indexPath: IndexPath) -> RowType {
        return sectionModels[indexPath]
    }
    
    public func sectionModel(of section: Int) -> SectionModel<SectionType,RowType> {
        return sectionModels[section]
    }
    
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

