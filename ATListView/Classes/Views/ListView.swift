//
//  ListView.swift
//  ATListView
//
//  Created by 凯文马 on 27/12/2017.
//

import UIKit
import ATRefresh

/// ListView 中单一section的占位类型
public struct EmptySection : CustomStringConvertible {
    private init() {}
    static var value : EmptySection {
        return EmptySection()
    }
    
    public var description: String {
        return "()"
    }
}

/// 单一section的列表视图
open class ListView<RowType> : SectionListView<EmptySection,RowType> {

    public typealias ListViewLoadDatasClosure = ([RowType]?, Bool, @escaping (NSError?, [RowType]?, Bool) -> ()) -> ()

    /// 配置cell的闭包定义
    public typealias ListViewCellClosure = (ListView<RowType>, RowType, Int) -> UITableViewCell
    
    public init(style: UITableViewStyle, delegate: UITableViewDelegate?, headerType: RefreshHeader.Type, footerType: RefreshFooter.Type, _ configCell: @escaping ListViewCellClosure) {
        super.init(style: style, delegate: delegate, headerType: headerType, footerType: footerType) { (listView, model, indexPath) -> UITableViewCell in
            configCell(listView as! ListView<RowType>,model,indexPath.row)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 配置加载数据的方法
    ///
    /// - Parameter datasClosure: 加载数据的闭包
    open func configDatasForListView(_ datasClosure: @escaping ListViewLoadDatasClosure) {
        let closure : LoadDataClosure = { (sm, isRefresh, callback) in
            datasClosure(sm?.first?.items,isRefresh, { (err, models, hasMore) in
                let sm = SectionModel<EmptySection,RowType>.init(title: EmptySection.value, items: models ?? [])
                callback(err, [sm], .mergeLast, hasMore)
            })
        }
        configDatas(closure)
    }
}

// MARK: - 模型相关
public extension ListView {

    /// 获取模型
    ///
    /// - Parameter row: 行
    /// - Returns: 模型
    public func model(of row: Int) -> RowType {
        return model(of: IndexPath.init(row: row, section: 0))
    }
    
    /// 获取模型数组
    public var models : [RowType]? {
        return sectionModels.first?.items
    }
    
    /// 插入模型
    ///
    /// - Parameters:
    ///   - model: 模型
    ///   - row: 行
    public func insertModel(_ model: RowType, at row: Int) {
        insertModel(model, at: IndexPath.init(row: row, section: 0))
    }

    /// 替换模型
    ///
    /// - Parameters:
    ///   - model: 模型
    ///   - row: 行
    public func replaceModel(_ model: RowType, at row: Int) {
        replaceModel(model, at: IndexPath.init(row: row, section: 0))
    }

    /// 删除模型
    ///
    /// - Parameter row: 行
    public func deleteModel(at row: Int) {
        deleteModel(at: IndexPath.init(row: row, section: 0))
    }
}
