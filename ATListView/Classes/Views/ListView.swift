//
//  ListView.swift
//  ATListView
//
//  Created by 凯文马 on 27/12/2017.
//

import UIKit
import ATRefresh

public struct EmptySection : CustomStringConvertible {
    private init() {}
    static var value : EmptySection {
        return EmptySection()
    }
    
    public var description: String {
        return "()"
    }
}

open class ListView<RowType> : SectionListView<EmptySection,RowType> {

    public typealias ListViewLoadDatasClosure = ([RowType]?, Bool, @escaping (NSError?, [RowType]?, Bool) -> ()) -> ()

    open func configDatasForListView(_ datasClosure: @escaping ListViewLoadDatasClosure) {
        let closure : LoadDataClosure = { (sm, isRefresh, callback) in
            datasClosure(sm?.first?.items,isRefresh, { (err, models, hasMore) in
                let sm = SectionModel<EmptySection,RowType>.init(title: EmptySection.value, items: models ?? [])
                callback(err, [sm], .mergeLast, hasMore)
            })
        }
        configDatas(closure)
    }

    public func model(of row: Int) -> RowType {
        return model(of: IndexPath.init(row: row, section: 0))
    }
    
    public var models : [RowType]? {
        return sectionModels.first?.items
    }
}

public extension ListView {

    public func insertModel(_ model: RowType, at row: Int) {
        insertModel(model, at: IndexPath.init(row: row, section: 0))
    }

    public func replaceModel(_ model: RowType, at row: Int) {
        replaceModel(model, at: IndexPath.init(row: row, section: 0))
    }

    public func deleteModel(at row: Int) {
        deleteModel(at: IndexPath.init(row: row, section: 0))
    }
}
