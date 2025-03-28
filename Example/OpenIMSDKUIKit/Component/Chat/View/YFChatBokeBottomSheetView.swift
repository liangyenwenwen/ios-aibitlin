//
//  YFChatBokeBottomSheetView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/5/15.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import UIKit
import TangramKit
import RxSwift
import RxCocoa
import OUICore
import NSObject_Rx

class YFChatBokeBottomSheetView: TGLinearLayout {

    var chooseBoke:((myBlogShowBlogPOModel)->())!
    var hideSheetView:(()->())!
    var data : [myBlogShowBlogPOModel] =  []
    
    var showAll: Bool  = false
    var isRemoveRecommendData: Bool  = false //是否剔除已推荐网站的数据
    var isRemoveTableMoreData: Bool  = false //是否剔除已添加的快捷网站数据
    init() {
        super.init(frame: .zero, orientation: .vert)
        innerInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        innerInit()
    }
    
    func innerInit() {
        
        corner(MEDDLE_RADIUS)
        tg_width.equal(.fill)
        tg_height.equal(.wrap)
        tg_space = PADDING_MEDDLE
        tg_gravity = .horz.center
        tg_padding = UIEdgeInsets(top: PADDING_OUTER, left: PADDING_OUTER, bottom: PADDING_MEDDLE, right: PADDING_OUTER)
        backgroundColor = .colorBackgroundAPP
        
        addSubview(topView)
        addSubview(tableView)
        
        if showAll {
            getAllBlog()
        } else {
            getMyBlog()
        }
       
    }
    
    lazy var topView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_gravity = .vert.center
        
        r.addSubview(cancleBtn)
        r.addSubview(titleLbl)
        r.addSubview(trueBtn)
        
        return r
    }()
    
    lazy var cancleBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("取消".localized())
        r.setTitleColor(.placeholder, for: .normal)
        r.rx.tap.subscribe(onNext: { [self] in
            hideSheetView()
        }).disposed(by: rx.disposeBag)
        return r
    }()
    
    lazy var titleLbl: UILabel = {
        let r = ViewFactoryUtil.customBoldTilteLable("选择网站".localized(), font: 16)
        r.textAlignment = .center
        return r
    }()
    
    lazy var trueBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("确定".localized())
        r.setTitleColor(.primaryColor, for: .normal)
        r.rx.tap.subscribe(onNext: { [self] in
            hideSheetView()
        }).disposed(by: rx.disposeBag)
        return r
    }()
    
    lazy var tableView: UITableView = {
        let r = ViewFactoryUtil.tableView()
        r.backgroundColor = .white
        r.corner()
        r.delegate = self
        r.dataSource = self
        r.register(YFChatBottomSheetBokeListCell.self, forCellReuseIdentifier: YFChatBottomSheetBokeListCell.className)
        return r
    }()
    
    deinit {
        print(#file)
    }

}

extension YFChatBokeBottomSheetView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: YFChatBottomSheetBokeListCell.className, for: indexPath) as! YFChatBottomSheetBokeListCell
        cell.bindData(item: data[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        chooseBoke(data[indexPath.row])

    }
}

extension YFChatBokeBottomSheetView {
    
    func getMyBlog() {
//        if let IMUser = IMController.shared.currentUserRelay.value {
//            
//            YFMineNetViewModel.mineBlog(limit: "20", page: "1", hash: "") { [weak self] data in
//                var array = data.filter({ item -> Bool in
//                    return item.myBlogShowBlogPO.state == .normal
//                })
//                if self?.isRemoveRecommendData == true{
//                    let recommedData = YFFileDataUtil.readDataToFile(.recommend)
//                    for item in recommedData {
//                        array.removeAll(where: { $0.myBlogShowBlogPO.id == item.myBlogShowBlogPO.id })
//                    }
//                    self?.data = array
//                }else{
//                    if self?.isRemoveTableMoreData == true {
//                        let tableMoreData = YFFileDataUtil.readDataToFile(.home)
//                        for item in tableMoreData {
//                            array.removeAll(where: { $0.myBlogShowBlogPO.id == item.myBlogShowBlogPO.id })
//                        }
//                        self?.data = array
//                    }else{
//                        self?.data = array
//                    }
//                }
//                
//                self?.tableView.reloadData()
//            } completionHandler: { errCode, errMsg in
//                
//            }
//        }
    }
    
    
    func getAllBlog() {
        if let IMUser = IMController.shared.currentUserRelay.value {
            
            YFMineNetViewModel.mineBlog(limit: "20",page: "1",hash: "") { [weak self] data in
                
                self?.data = data ?? []
                self?.tableView.reloadData()
            } completionHandler: { errCode, errMsg in
                
            }
        }
    }
}
