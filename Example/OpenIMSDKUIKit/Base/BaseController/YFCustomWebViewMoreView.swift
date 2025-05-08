//
//  YFCustomWebViewMoreView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2025/5/8.
//  Copyright © 2025 rentsoft. All rights reserved.
//

import MMBAlertsPickers
import OUICore
import ProgressHUD
import RxCocoa
import RxSwift
import TangramKit
import UIKit
class YFCustomWebViewMoreView: TGLinearLayout {
    var h5DetailInfo:h5Model?
    var btnClickBlock: ((Int) -> ())!
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
        backgroundColor = .colorBackgroundAPP
        tg_width.equal(.fill)
        tg_height.equal(.wrap)
        tg_gravity = .horz.left
        tg_padding = UIEdgeInsets(top: 17, left: PADDING_OUTER, bottom: 10, right: PADDING_OUTER)
        addSubview(topView)
        addSubview(lineView)
        addSubview(bottomView)
    }
    func updateContentUI(model:h5Model){
        h5DetailInfo = model
        iconImageView.sd_setImage(with: URL(string: model.data?.info?.logo ?? ""))
        nameLabel.text = model.data?.info?.name ?? ""
        
    }
    lazy var topView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(.fill)
        r.tg_height.equal(28)
        r.tg_gravity = .vert.center
        r.addSubview(iconImageView)
        r.addSubview(nameLabel)
        r.addSubview(closeBtn)
        return r
    }()
    lazy var iconImageView: UIImageView = {
        let r = UIImageView()
        r.tg_width.equal(24)
        r.tg_height.equal(24)
        r.corner(4)
        return r
    }()
    lazy var nameLabel: UILabel = {
        let r = UILabel()
        r.tg_left.equal(6)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_right.equal(33)
        r.textColor = .black333
        r.font = .mediumFont(16)
        return r
    }()
    lazy var closeBtn: QMUIButton = {
        let r = QMUIButton()
        r.tg_width.equal(28)
        r.tg_height.equal(28)
        r.setImage(UIImage(named: "web_more_close_icon"), for: .normal)
        r.rx.tap.subscribe(onNext: { [weak self] in
            GKCover.hide()
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var lineView: UIView = {
        let r = UIView()
        r.tg_top.equal(17)
        r.tg_width.equal(.fill)
        r.tg_height.equal(1)
        r.backgroundColor = .init(hexString: "#EAEAEA")
        return r
    }()
    lazy var bottomView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_top.equal(20)
        r.tg_width.equal(.fill)
        r.tg_height.equal(82)
        let iconArray = ["web_share_icon","web_star_icon","web_small_icon","web_report_icon","web_more_close_all_icon"]
        let titleArray = ["分享","收藏","收起","举报","关闭"]
        for (i,item) in iconArray.enumerated() {
            let t = UIButton()
            t.titleLabel?.font = .mediumFont(11)
            t.setTitleColor(.black666, for: .normal)
            t.setTitle(titleArray[i], for: .normal)
            t.setImage(UIImage(named: item), for: .normal)
            t.translatesAutoresizingMaskIntoConstraints = false
            t.imageEdgeInsets = UIEdgeInsets(top: -24, left: 0, bottom: 0, right: -18)
            t.titleEdgeInsets = UIEdgeInsets(top: 0, left: -58, bottom: -64, right: 0)
            t.rx.tap.subscribe(onNext: { [weak self] in
                GKCover.hide()
                self?.btnClickBlock?(i)
            }).disposed(by: rx.disposeBag)
            r.addSubview(t)
            t.snp_makeConstraints { make in
                make.top.bottom.equalTo(r)
                make.width.equalTo(58)
                make.left.equalTo(r).offset(i*(58+10))
            }
        }
        return r
    }()
}


