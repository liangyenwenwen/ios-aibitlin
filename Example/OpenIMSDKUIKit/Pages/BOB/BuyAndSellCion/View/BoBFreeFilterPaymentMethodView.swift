//
//  BoBFreeFilterPaymentMethodView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/12.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import MMBAlertsPickers
import OUICore
import ProgressHUD
import RxCocoa
import RxSwift
import TangramKit
import UIKit
class BoBFreeFilterPaymentMethodView: TGLinearLayout {
    var chooseMoneyBlock:((_ isChooseAll:Bool,_ isChooseBank:Bool,_ isChooseAli:Bool,_ isChooseWx:Bool)->())!
    var titleArray = [String]()
    var allBtn = paymentMethodTypeBtn()
    var bankBtn = paymentMethodTypeBtn()
    var aliBtn = paymentMethodTypeBtn()
    var wxBtn = paymentMethodTypeBtn()
    var isChooseAll:Bool = false
    var isChooseBank:Bool = false
    var isChooseAli:Bool = false
    var isChooseWx:Bool = false
    init(titles:[String],isChooseAllBtn:Bool,isChooseBankBtn:Bool,isChooseAliBtn:Bool,isChooseWxBtn:Bool) {
        super.init(frame: .zero, orientation: .vert)
        titleArray = titles
        isChooseAll = isChooseAllBtn
        isChooseBank = isChooseBankBtn
        isChooseAli = isChooseAliBtn
        isChooseWx = isChooseWxBtn
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
        
        addSubview(titleLbl)
        addSubview(closeBtn)
        addSubview(typeView)
        addSubview(cancleBtn)
        addSubview(sureBtn)
        titleLbl.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(closeBtn.snp_left).offset(-15)
            make.top.equalTo(20)
        }
        
        closeBtn.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalTo(titleLbl)
            make.width.height.equalTo(28)
        }
        typeView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(titleLbl.snp_bottom).offset(16)
            make.height.equalTo(88)
        }
        cancleBtn.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(typeView.snp_bottom).offset(22)
            make.height.equalTo(46)
            make.width.equalTo((kScreenWidth-32-18)/2)
        }
        sureBtn.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.top.width.height.equalTo(cancleBtn)
        }
    }
    lazy var titleLbl: UILabel = {
        let r = ViewFactoryUtil.customTilteLabelFill("支付方式", font: 18, textColor: .black333)
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
    
    lazy var typeView: UIView = {
        let r = UIView()
        let width = (kScreenWidth-32-8)/2
        for (index,item) in titleArray.enumerated() {
            let paymentBtn = paymentMethodTypeBtn()
            paymentBtn.btn.setTitle(item, for: .normal)
            if index == 0{
                allBtn = paymentBtn
                if isChooseAll{
                    paymentBtn.btn.border(.init(hexString: "#277FE6"),borderWidth: 1,cornerRadius: 8)
                    paymentBtn.selectStatusImageView.show()
                    paymentBtn.btn.backgroundColor = .init(hexString: "#F3F7FB")
                }
            }else if index == 1{
                bankBtn = paymentBtn
                if isChooseBank{
                    paymentBtn.btn.border(.init(hexString: "#277FE6"),borderWidth: 1,cornerRadius: 8)
                    paymentBtn.selectStatusImageView.show()
                    paymentBtn.btn.backgroundColor = .init(hexString: "#F3F7FB")
                }
            }else if index == 2{
                aliBtn = paymentBtn
                if isChooseAli{
                    paymentBtn.btn.border(.init(hexString: "#277FE6"),borderWidth: 1,cornerRadius: 8)
                    paymentBtn.selectStatusImageView.show()
                    paymentBtn.btn.backgroundColor = .init(hexString: "#F3F7FB")
                }
            }else if index == 3{
                wxBtn = paymentBtn
                if isChooseWx{
                    paymentBtn.btn.border(.init(hexString: "#277FE6"),borderWidth: 1,cornerRadius: 8)
                    paymentBtn.selectStatusImageView.show()
                    paymentBtn.btn.backgroundColor = .init(hexString: "#F3F7FB")
                }
            }
            paymentBtn.btn.rx.tap.subscribe(onNext: { [weak self] in
                if paymentBtn == self?.allBtn{
                    self?.isChooseAll = true
                    paymentBtn.btn.border(.init(hexString: "#277FE6"),borderWidth: 1,cornerRadius: 8)
                    paymentBtn.selectStatusImageView.show()
                    paymentBtn.btn.backgroundColor = .init(hexString: "#F3F7FB")
                    
                    self?.isChooseBank = false
                    self?.bankBtn.btn.border(.init(hexString: "#D6DEE6"),borderWidth: 1,cornerRadius: 8)
                    self?.bankBtn.selectStatusImageView.hide()
                    self?.bankBtn.btn.backgroundColor = .white
                    self?.isChooseAli = false
                    self?.aliBtn.btn.border(.init(hexString: "#D6DEE6"),borderWidth: 1,cornerRadius: 8)
                    self?.aliBtn.selectStatusImageView.hide()
                    self?.aliBtn.btn.backgroundColor = .white
                    self?.isChooseWx = false
                    self?.wxBtn.btn.border(.init(hexString: "#D6DEE6"),borderWidth: 1,cornerRadius: 8)
                    self?.wxBtn.selectStatusImageView.hide()
                    self?.wxBtn.btn.backgroundColor = .white
                }else if paymentBtn == self?.bankBtn{
                    self?.isChooseAll = false
                    self?.allBtn.btn.border(.init(hexString: "#D6DEE6"),borderWidth: 1,cornerRadius: 8)
                    self?.allBtn.selectStatusImageView.hide()
                    self?.allBtn.btn.backgroundColor = .white
                    self?.isChooseBank = !(self?.isChooseBank ?? false)
                    if self?.isChooseBank == true{
                        self?.bankBtn.btn.border(.init(hexString: "#277FE6"),borderWidth: 1,cornerRadius: 8)
                        self?.bankBtn.selectStatusImageView.show()
                        self?.bankBtn.btn.backgroundColor = .init(hexString: "#F3F7FB")
                    }else{
                        self?.bankBtn.btn.border(.init(hexString: "#D6DEE6"),borderWidth: 1,cornerRadius: 8)
                        self?.bankBtn.selectStatusImageView.hide()
                        self?.bankBtn.btn.backgroundColor = .white
                    }
                }else if paymentBtn == self?.aliBtn{
                    self?.isChooseAll = false
                    self?.allBtn.btn.border(.init(hexString: "#D6DEE6"),borderWidth: 1,cornerRadius: 8)
                    self?.allBtn.selectStatusImageView.hide()
                    self?.allBtn.btn.backgroundColor = .white
                    self?.isChooseAli = !(self?.isChooseAli ?? false)
                    if self?.isChooseAli == true{
                        self?.aliBtn.btn.border(.init(hexString: "#277FE6"),borderWidth: 1,cornerRadius: 8)
                        self?.aliBtn.selectStatusImageView.show()
                        self?.aliBtn.btn.backgroundColor = .init(hexString: "#F3F7FB")
                    }else{
                        self?.aliBtn.btn.border(.init(hexString: "#D6DEE6"),borderWidth: 1,cornerRadius: 8)
                        self?.aliBtn.selectStatusImageView.hide()
                        self?.aliBtn.btn.backgroundColor = .white
                    }
                }else if paymentBtn == self?.wxBtn{
                    self?.isChooseAll = false
                    self?.allBtn.btn.border(.init(hexString: "#D6DEE6"),borderWidth: 1,cornerRadius: 8)
                    self?.allBtn.selectStatusImageView.hide()
                    self?.allBtn.btn.backgroundColor = .white
                    self?.isChooseWx = !(self?.isChooseWx ?? false)
                    if self?.isChooseWx == true{
                        self?.wxBtn.btn.border(.init(hexString: "#277FE6"),borderWidth: 1,cornerRadius: 8)
                        self?.wxBtn.selectStatusImageView.show()
                        self?.wxBtn.btn.backgroundColor = .init(hexString: "#F3F7FB")
                    }else{
                        self?.wxBtn.btn.border(.init(hexString: "#D6DEE6"),borderWidth: 1,cornerRadius: 8)
                        self?.wxBtn.selectStatusImageView.hide()
                        self?.wxBtn.btn.backgroundColor = .white
                    }
                }
                
                if self?.isChooseAll == false && self?.isChooseBank == false && self?.isChooseAli == false && self?.isChooseWx == false{
                    self?.isChooseAll = true
                    self?.allBtn.btn.border(.init(hexString: "#277FE6"),borderWidth: 1,cornerRadius: 8)
                    self?.allBtn.selectStatusImageView.show()
                    self?.allBtn.btn.backgroundColor = .init(hexString: "#F3F7FB")
                }
            }).disposed(by: rx.disposeBag)
            r.addSubview(paymentBtn)
            paymentBtn.snp_makeConstraints { make in
                make.left.equalTo((Int(width)+8)*(index%2))
                make.top.equalTo(r).offset((40+8)*(index/2))
                make.width.equalTo(width)
                make.height.equalTo(40)
            }
        }
        return r
    }()
    lazy var cancleBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("重置")
        r.setTitleColor(.black666, for: .normal)
        r.titleLabel?.font = .mediumFont(16)
        r.border(.init(hexString: "#EAEAEA"),borderWidth: 1,cornerRadius: 23)
        r.rx.tap.subscribe(onNext: { [weak self] in
            self?.isChooseAll = true
            self?.allBtn.btn.border(.init(hexString: "#277FE6"),borderWidth: 1,cornerRadius: 8)
            self?.allBtn.selectStatusImageView.show()
            self?.allBtn.btn.backgroundColor = .init(hexString: "#F3F7FB")
            
            self?.isChooseBank = false
            self?.bankBtn.btn.border(.init(hexString: "#D6DEE6"),borderWidth: 1,cornerRadius: 8)
            self?.bankBtn.selectStatusImageView.hide()
            self?.bankBtn.btn.backgroundColor = .white
            self?.isChooseAli = false
            self?.aliBtn.btn.border(.init(hexString: "#D6DEE6"),borderWidth: 1,cornerRadius: 8)
            self?.aliBtn.selectStatusImageView.hide()
            self?.aliBtn.btn.backgroundColor = .white
            self?.isChooseWx = false
            self?.wxBtn.btn.border(.init(hexString: "#D6DEE6"),borderWidth: 1,cornerRadius: 8)
            self?.wxBtn.selectStatusImageView.hide()
            self?.wxBtn.btn.backgroundColor = .white
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var sureBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("确认")
        r.setTitleColor(.white, for: .normal)
        r.titleLabel?.font = .mediumFont(16)
        r.backgroundColor = .primaryColor
        r.corner(23)
        r.rx.tap.subscribe(onNext: { [weak self] in
            if self?.chooseMoneyBlock != nil{
                self?.chooseMoneyBlock(self?.isChooseAll ?? true,self?.isChooseBank ?? false,self?.isChooseAli ?? false,self?.isChooseWx ?? false)
            }
            GKCover.hide()
        }).disposed(by: rx.disposeBag)
        return r
    }()
}
class paymentMethodTypeBtn:UIView{
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews()  {
        addSubview(btn)
        btn.snp_makeConstraints { make in
            make.edges.equalTo(0)
        }
    }
    func bindData(title:String){
        btn.setTitle(title, for: .normal)
    }
    lazy var btn: UIButton = {
        let r = UIButton()
        r.titleLabel?.font = .mediumFont(16)
        r.setTitleColor(.black333, for: .normal)
        r.border(.init(hexString: "#D6DEE6"),borderWidth: 1,cornerRadius: 8)
        r.addSubview(selectStatusImageView)
        selectStatusImageView.snp_makeConstraints { make in
            make.right.bottom.equalTo(0)
            make.width.height.equalTo(20)
        }
        return r
    }()
    lazy var selectStatusImageView: UIImageView = {
        let r = UIImageView(image: UIImage(named: "mine_payment_method_btn_select_icon"))
        r.hide()
        return r
    }()
    
}

