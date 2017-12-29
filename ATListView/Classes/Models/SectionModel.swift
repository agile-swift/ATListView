//
//  SectionModel.swift
//  ATListView
//
//  Created by 凯文马 on 19/12/2017.
//

import UIKit

/// section 模型协议
public protocol SectionModelType {
    associatedtype SectionElement
    associatedtype RowElement
    
    var items : [RowElement] {get}
    
    init(title : SectionElement,items:[RowElement])
}

/// section 模型类
public struct SectionModel<SectionElement,RowElement> : SectionModelType {
    typealias S = SectionElement
    typealias R = RowElement
    public var title : SectionElement
    private var rows : [R]
    
    public var items: [RowElement] {
        return rows
    }
    
    public init(title : SectionElement,items:[RowElement]) {
        self.title = title
        self.rows = items
    }
}

public extension Array where Element : SectionModelType {
    public subscript(indexPath: IndexPath) -> Element.RowElement {
        return self[indexPath.section].items[indexPath.row]
    }

}
