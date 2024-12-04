//
//  BoBSendRedPacketViewController.swift
//  Alamofire
//
//  Created by mac on 2024/12/3.
//

import Foundation

class BoBSendRedPacketViewController: BaseTitleController {
    override func initViews() {
        super.initViews()
        setBackGroundColor(.init(hexString: "#388CEF"))
        initScrollSafeArea()
        title = "红包"
        scrollViewContainer.tg_padding = UIEdgeInsets(top: PADDING_OUTER, left: PADDING_OUTER, bottom: PADDING_OUTER, right: PADDING_OUTER)
        scrollViewContainer.tg_space = 10
        superFooterContainerContainer.tg_bottom.equal(0)
        scrollViewContainer.addSubview(redPacketTypeBtn)

    }
    lazy var redPacketTypeBtn: UIButton = {
        let r = UIButton()
        r.setImage(UIImage(named: "mine_assets_transfer_accounts_icon"), for: .normal)
        r.setTitle("普通红包", for: .normal)
        r.titleLabel?.font = .mediumFont(16)
        r.setTitleColor(.primaryColor, for: .normal)
        r.contentHorizontalAlignment = .left
        // 间距可能需要根据图片和文字大小调整
        let spacing: CGFloat = 6.0
        r.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: 0)
        r.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: spacing)
        r.rx.tap.subscribe(onNext: { [self] in

        }).disposed(by: rx.disposeBag)
        return r
    }()
}
