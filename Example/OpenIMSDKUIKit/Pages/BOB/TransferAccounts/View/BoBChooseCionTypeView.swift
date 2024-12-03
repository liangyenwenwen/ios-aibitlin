//
//  BoBChooseCionTypeView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/11/28.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import MMBAlertsPickers
import OUICore
import ProgressHUD
import RxCocoa
import RxSwift
import TangramKit
import UIKit

class BoBChooseCionTypeView: TGLinearLayout {
    var chooseCionBlock:((_ chooseCionTypeModel:CionTypeModel,_ array:[CionTypeModel])->())!
    var listArray:[CionTypeModel] = []
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
        backgroundColor = .white
        
        addSubview(topView)
        
        addSubview(tableView)
        tableView.snp_makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(topView.snp_bottom).offset(3)
            make.bottom.equalTo(self.snp_bottomMargin)
        }
    }
    func reloadListArray(array:[CionTypeModel]){
        listArray = array
        tableView.reloadData()
    }
    
    lazy var topView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_gravity = .vert.center
        r.tg_space = 7
        r.addSubview(titleLbl)
        r.addSubview(closeBtn)
        return r
    }()
    
    lazy var titleLbl: UILabel = {
        let r = ViewFactoryUtil.customTilteLabelFill("选择币种".localized(), font: 18, textColor: .black333)
        r.font = .mediumFont(18)
        r.textColor = .black333
        return r
    }()
    lazy var closeBtn: QMUIButton = {
        let r = ViewFactoryUtil.imageBtn(R.image.close_cirle_icon()!, 28)
        r.rx.tap.subscribe(onNext: {
            GKCover.hide()
        })
        .disposed(by: rx.disposeBag)
        return r
    }()

    private lazy var tableView: UITableView = {
        let v = UITableView()
        v.register(BoBChooseCionTypeCell.self, forCellReuseIdentifier: BoBChooseCionTypeCell.className)
        v.delegate = self
        v.dataSource = self
        v.isScrollEnabled = false
        v.tableFooterView = UIView()
        v.separatorStyle = .none
        if #available(iOS 15.0, *) {
            v.sectionHeaderTopPadding = 0
        }
        return v
    }()
}
extension BoBChooseCionTypeView: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = listArray[indexPath.row]
        
        let cell =  tableView.dequeueReusableCell(withIdentifier: BoBChooseCionTypeCell.className, for: indexPath) as! BoBChooseCionTypeCell
        cell.cionTypeImageView.sd_setImage(with: URL(string: item.icon))
        cell.cionNameLabel.text = item.biZhong
        if item.type == 0{
            cell.cionTypeLabel.text = "T+0钱包"
            cell.cionTypeLabel.textColor = .init(hexString: "#00AA3C")
            cell.cionTypeLabel.backgroundColor = .init(hexString: "#E5F6EB")
        }else{
            cell.cionTypeLabel.text = "T+1钱包"
            cell.cionTypeLabel.textColor = .init(hexString: "#FFA756")
            cell.cionTypeLabel.backgroundColor = .init(hexString: "#FFF7E5")
        }
        cell.moneyLabel.text = "可用 " + String(format: "%.2f ",item.money ?? 0.00)
        cell.moneyLabel.textColor = item.money ?? 0 > 0 ? .primaryColor : .black666
        cell.contentView.backgroundColor = item.isSelect ? .init(hexString: "#F5F5F5"): .white
        return cell
        
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.h
    }
    
    public func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        for (index, model) in listArray.enumerated() {
            model.isSelect = index == indexPath.row ? true : false
        }
        if chooseCionBlock != nil{
            chooseCionBlock(listArray[indexPath.row],listArray)
        }
        GKCover.hide()
    }
}



