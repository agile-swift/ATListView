//
//  ViewController.swift
//  ATListView
//
//  Created by devkevinma@gmail.com on 12/19/2017.
//  Copyright (c) 2017 devkevinma@gmail.com. All rights reserved.
//

import UIKit
import ATListView
import ATRefresh

class ViewController: UIViewController {

    var listView : UIScrollView?
//    let listView = ListView<String,String>.init { (_, m, _) -> UITableViewCell in
//        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "")
//        cell.textLabel?.text = m
//        return cell
//    }
    let sections = [
        SectionModel.init(title: "", items: ["kevin1","ma1"]),
        SectionModel.init(title: "", items: ["kevin2","ma2"]),
        SectionModel.init(title: "", items: ["kevin3","ma3"]),
        SectionModel.init(title: "", items: ["kevin4","ma4"]),
        SectionModel.init(title: "", items: ["kevin1","ma1"]),
        SectionModel.init(title: "", items: ["kevin2","ma2"]),
        SectionModel.init(title: "", items: ["kevin3","ma3"]),
        SectionModel.init(title: "", items: ["kevin4","ma4"]),
//        SectionModel.init(title: "", items: ["kevin1","ma1"]),
//        SectionModel.init(title: "", items: ["kevin2","ma2"]),
//        SectionModel.init(title: "", items: ["kevin3","ma3"]),
//        SectionModel.init(title: "", items: ["kevin4","ma4"]),
//        SectionModel.init(title: "", items: ["kevin1","ma1"]),
//        SectionModel.init(title: "", items: ["kevin2","ma2"]),
//        SectionModel.init(title: "", items: ["kevin3","ma3"]),
//        SectionModel.init(title: "", items: ["kevin4","ma4"])
    ]


    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let view = UISegmentedControl.init(items: <#T##[Any]?#>)
        
//        self.navigationItem.titleView
        automaticallyAdjustsScrollViewInsets = false
        
        registerDefaultListViewDelegate(self)
        
//        loadSectionListView()
        loadListView()
    }
    
    func loadListView() {
        let listView = ListView<String>.init(style: .plain, delegate: self, headerType: GifRefreshHeader.self, footerType: RefreshFooter.self) { (lv, m, index) -> UITableViewCell in
            let cell = UITableViewCell.init(style: .default, reuseIdentifier: "")
            cell.textLabel?.text = m + " in \(index)"
            if let view = cell.contentView.viewWithTag(1317749) {
                view.frame = CGRect.init(x: 10, y: 30, width: 20, height: 20)
                
            } else {
                let v = UIView.init(frame: CGRect.init(x: 10, y: 30, width: 20, height: 20 ))
                v.backgroundColor = UIColor.purple
                v.tag = 1317749
                cell.contentView.addSubview(v)
                cell.autoBottomViewSpace = 20
                cell.autoBottomView = v
            }
            return cell
        }
        listView.frame = CGRect.init(x: 0, y: 64, width: view.frame.width, height: view.frame.height - 64)
        listView.tableHeaderView = UIView.init(frame: CGRect.init(x: 0, y: 100, width: listView.frame.width, height: 100))
        listView.configDatasForListView { (models, isRefresh, cb) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                var a = (self.sections.first?.items)!
                a += a
                a += a
                a += a
                cb(nil,a,true)
//                cb(NSError.init(domain: "fdf", code: 434, userInfo: [NSLocalizedDescriptionKey : "fdfds"]),nil,false)
            })
        }
//        listView.loadDatasConfig { (sm, r, cb) in
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
//                cb(NSError.init(domain: "com.makaiwen.err.test", code: 4321, userInfo: [NSLocalizedDescriptionKey : "测试错误"]),nil,.addToLast,false)
//            })
//        }
        view.addSubview(listView)
        listView.loadData()
        
//        listView.configEmptyView { [unowned self] (frame) -> UIView in
//            self.listView = listView
//            let v = UIView.init(frame: frame)
//            v.backgroundColor = UIColor.orange
//            let b = UIButton()
//            b.setTitle(" 重新加载 ", for: .normal)
//            b.setTitleColor(UIColor.white, for: .normal)
//            b.setTitleColor(UIColor.gray, for: .highlighted)
//            b.sizeToFit()
//            v.addSubview(b)
//            b.center = CGPoint.init(x: v.frame.width * 0.5, y: v.frame.height * 0.5)
//            b.addTarget(self, action: #selector(self.reload), for: .touchUpInside)
//            return v
//        }
//        listView.configErrorView { (err,frame) -> UIView in
//            self.listView = listView
//            let c = UIView.init(frame: frame)
//            let v = UILabel.init(frame: c.bounds)
//            v.backgroundColor = UIColor.purple
//            v.textAlignment = .center
//            v.isUserInteractionEnabled = true
//            v.text = err.userInfo[NSLocalizedDescriptionKey] as! String
//            let b = UIButton()
//            b.setTitle(" (失败)重新加载 ", for: .normal)
//            b.sizeToFit()
//            c.addSubview(v)
//            c.addSubview(b)
//            b.center = CGPoint.init(x: v.frame.width * 0.5, y: v.frame.height * 0.3)
//            b.addTarget(self, action: #selector(self.reload), for: .touchUpInside)
//            return c
//        }
        
//        listView.sectionModels
//        listView.dele
        
    }
    
    func loadSectionListView() {
        let listView = SectionListView<String,String>.init(style: .plain, delegate: self, headerType: GifRefreshHeader.self, footerType: RefreshFooter.self) { (lv, m, ip) -> UITableViewCell in
            let cell = UITableViewCell.init(style: .default, reuseIdentifier: "")
            cell.textLabel?.text = m
            if let view = cell.contentView.viewWithTag(1317749) {
                view.frame = CGRect.init(x: 10, y: 30, width: 20, height: 20 * ip.section)
                
            } else {
                let v = UIView.init(frame: CGRect.init(x: 10, y: 30, width: 20, height: 20 * ip.section))
                v.backgroundColor = UIColor.purple
                v.tag = 1317749
                cell.contentView.addSubview(v)
                cell.autoBottomViewSpace = 20
                cell.autoBottomView = v
            }
            return cell
        }
        
        listView.frame = CGRect.init(x: 0, y: 64, width: view.frame.width, height: view.frame.height - 64)
        
        listView.delegate = self
        
        listView.configDatas { (sm, isRefresh, callback) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                callback(nil,self.sections, .addToLast,true)
            })
        }
        view.addSubview(listView)
        listView.loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension ViewController : UITableViewDelegate {
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let listView = tableView as! ListView<String, String>
//        return listView.cellHeight(for: indexPath, cacheKey: { (model) -> String? in
//            return model + "\(indexPath)"
//        })
//        return 44
//    }
}

extension ViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        let count = sections.count
        print("count:\(count)")
        return count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}

extension ViewController : ListViewDelegate {
    func listView(_ listView: UIScrollView, errorView frame: CGRect, for error: NSError) -> UIView? {
        self.listView = listView
        let c = UIView.init(frame: frame)
        let v = UILabel.init(frame: c.bounds)
        v.backgroundColor = UIColor.yellow
        v.textAlignment = .center
        v.isUserInteractionEnabled = true
        v.text = error.userInfo[NSLocalizedDescriptionKey] as! String
        let b = UIButton()
        b.setTitle(" (失败)重新加载 ", for: .normal)
        b.sizeToFit()
        c.addSubview(v)
        c.addSubview(b)
        b.center = CGPoint.init(x: v.frame.width * 0.5, y: v.frame.height * 0.3)
        b.addTarget(self, action: #selector(self.reload), for: .touchUpInside)
        return c
    }
    
    func listView(_ listView: UIScrollView, emptyView frame: CGRect, for userinfo: [AnyHashable : Any]?) -> UIView? {
        self.listView = listView
        let v = UIView.init(frame: frame)
        v.backgroundColor = UIColor.green
        let b = UIButton()
        b.setTitle(" 重新加载 ", for: .normal)
        b.sizeToFit()
        v.addSubview(b)
        b.center = CGPoint.init(x: v.frame.width * 0.5, y: v.frame.height * 0.5)
        b.addTarget(self, action: #selector(reload), for: .touchUpInside)
        return v
    }
    
    @objc func reload() {
        self.listView?.refreshHeader?.beginRefresh()
    }
    
}
