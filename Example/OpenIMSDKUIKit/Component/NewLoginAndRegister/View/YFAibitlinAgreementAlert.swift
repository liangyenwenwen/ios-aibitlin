//
//  YFAibitlinAgreementAlert.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/11/26.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import TangramKit
import BSText


class YFAibitlinAgreementAlert: TGRelativeLayout {
    var agreementBlock:(()->Void)?
    var currentVC: UIViewController?
    init() {
        super.init(frame: CGRect.zero)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews()  {
        
        corner(MEDDLE_RADIUS)
        tg_left.equal(67)
        tg_right.equal(67)
        tg_height.equal(.wrap)
        tg_space = 40
        tg_gravity = .horz.center
        tg_padding = UIEdgeInsets(top: 20, left: PADDING_OUTER, bottom: 20, right: PADDING_OUTER)
        backgroundColor = .colorBackgroundAPP
        addSubview(titleLabel)
        addSubview(agreementView)
        addSubview(trueBtn)
        addSubview(cancleBtn)
    }
    lazy var titleLabel: UILabel = {
        let r = UILabel()
        r.textColor = .black333
        r.font = .semiboldFont(18)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
//        r.tg_top.equal(27)
        r.text = "隐私协议和注册协议".localized()
        r.textAlignment = .center
        return r
    }()
    lazy var agreementView: BSLabel = {
        let r = BSLabel()
        r.tg_top.equal(titleLabel.tg_bottom, offset: 14)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.textAlignment = .left
        r.numberOfLines = 0
        r.isUserInteractionEnabled = true
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3 // 自定义行间距值
        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
        ]
        
        let agreementString = "我已阅读并同意AIbitlin《隐私协议》《注册协议》".localized()
        let agreeStr = NSMutableAttributedString(string: agreementString, attributes: attributes)
        agreeStr.bs_font = .systemFont(ofSize: TEXT_MEDDLE)
        agreeStr.bs_color = .placeholder
        
        
        // MARK: - 张亚飞打的标记  点击协议内容切换是否同意协议
        var range = agreementString.range(of: "我已阅读并同意AIbitlin《隐私协议》《注册协议》".localized())!
        agreeStr.bs_set(textHighlightRange: agreementString.nsRange(from: range), color: .placeholder, backgroundColor: nil) { [weak self] _, _, _, _ in
            
//            if self?.chooseDelegateBtn != nil  {
//                self?.chooseDelegateBtn.isSelected = !(self?.chooseDelegateBtn.isSelected)!
//            }
            
        }
        
        
        range = agreementString.range(of: "《隐私协议》".localized())!
        agreeStr.bs_set(textHighlightRange: agreementString.nsRange(from: range), color: .primaryColor, backgroundColor: nil) { [weak self] containerView, text, range, rect in
//            ProgressHUD.succeed("隐私协议")
            
            let language = String.getCurrentLanguage()
            if language.starts(with: "zh")  {
                SuperWebController.start((self?.currentVC?.navigationController!)!, uri: "https://deal.aibitlin.com/#/pages/privacy/index?lang=zh")
            } else if language.starts(with: "th"){
                SuperWebController.start((self?.currentVC?.navigationController!)!, uri: "https://deal.aibitlin.com/#/pages/privacy/index?lang=Thai")
            } else {
                SuperWebController.start((self?.currentVC?.navigationController!)!, uri: "https://deal.aibitlin.com/#/pages/privacy/index?lang=en")
            }
            

        }
        
        range = agreementString.range(of: "《注册协议》".localized())!
        agreeStr.bs_set(textHighlightRange: agreementString.nsRange(from: range), color: .primaryColor, backgroundColor: nil) { [weak self]  containerView, text, range, rect in

            let language = String.getCurrentLanguage()
            if language.starts(with: "zh")  {
                SuperWebController.start((self?.currentVC?.navigationController!)!, uri: "https://deal.aibitlin.com/#/pages/registration/index?lang=zh")
            } else if language.starts(with: "th"){
                SuperWebController.start((self?.currentVC?.navigationController!)!, uri: "https://deal.aibitlin.com/#/pages/registration/index?lang=Thai")
            } else {
                SuperWebController.start((self?.currentVC?.navigationController!)!, uri: "https://deal.aibitlin.com/#/pages/registration/index?lang=en")
            }
        }
       
        r.attributedText = agreeStr
        
        return r
    }()
    lazy var trueBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("同意并继续".localized())
        r.tg_top.equal(agreementView.tg_bottom, offset: 28)
        r.tg_left.equal(32)
        r.tg_right.equal(32)
        r.tg_height.equal(36)
        r.setTitleColor(.white, for: .normal)
        r.backgroundColor = .primaryColor
        r.titleLabel?.font = .mediumFont(14)
        r.corner(18)
        r.rx.tap.subscribe(onNext: { [self] in
            if self.agreementBlock != nil{
                self.agreementBlock!()
            }
            GKCover.hide()
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var cancleBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("不同意".localized())
        r.tg_top.equal(trueBtn.tg_bottom, offset: 10)
        r.tg_left.equal(32)
        r.tg_right.equal(32)
        r.tg_height.equal(36)
        r.setTitleColor(.black666, for: .normal)
        r.titleLabel?.font = .mediumFont(12)
        r.rx.tap.subscribe(onNext: { [self] in
            GKCover.hide()
        }).disposed(by: rx.disposeBag)
        return r
    }()
}
