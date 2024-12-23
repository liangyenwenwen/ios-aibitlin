//
//  BoBAddPaymentMethodViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/11/25.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import OUICore

class BoBAddPaymentMethodViewController:UIViewController{
    var paymentType:Int = 0 //0银行卡，1支付宝，2微信
    var name:String?
    var paymentDetail:stringAndDatePOS?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .colorBackgroundAPP
        title = paymentDetail == nil ? "添加支付方式" : "编辑支付方式"
        if paymentDetail == nil{
            view.addSubview(chooseTypeTitleLabel)
            view.addSubview(chooseTypeView)
            view.addSubview(bankView)
            view.addSubview(aliView)
            view.addSubview(wxView)
            view.addSubview(sumbitBtn)
            chooseTypeTitleLabel.snp_makeConstraints { make in
                make.left.equalTo(16)
                make.top.equalTo(view.safeAreaLayoutGuide).offset(14)
                make.right.equalTo(-16)
            }
            chooseTypeView.snp_makeConstraints { make in
                make.left.right.equalTo(chooseTypeTitleLabel)
                make.top.equalTo(chooseTypeTitleLabel.snp_bottom).offset(18)
                make.height.equalTo(40)
            }
            bankView.snp_makeConstraints { make in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.top.equalTo(chooseTypeView.snp_bottom).offset(20)
                make.height.equalTo(250)
            }
            aliView.snp_makeConstraints { make in
                make.left.right.top.equalTo(bankView)
                make.height.equalTo(292)
            }
            wxView.snp_makeConstraints { make in
                make.left.right.top.equalTo(bankView)
                make.height.equalTo(242)

            }
            sumbitBtn.snp_makeConstraints { make in
                make.left.equalTo(16)
                make.right.equalTo(-16)
                make.height.equalTo(48)
                make.top.equalTo(bankView.snp_bottom).offset(20)
            }
            if paymentType == 1{
                aliBtn.border(.init(hexString: "#277FE6"),borderWidth: 1,cornerRadius: 8)
                aliBtn.selectStatusImageView.show()
                bankBtn.border(.init(hexString: "#D6DEE6"),borderWidth: 1,cornerRadius: 8)
                bankBtn.selectStatusImageView.hide()
                weixinBtn.border(.init(hexString: "#D6DEE6"),borderWidth: 1,cornerRadius: 8)
                weixinBtn.selectStatusImageView.hide()
                bankView.hide()
                aliView.show()
            }else if paymentType == 2{
                weixinBtn.border(.init(hexString: "#277FE6"),borderWidth: 1,cornerRadius: 8)
                weixinBtn.selectStatusImageView.show()
                bankBtn.border(.init(hexString: "#D6DEE6"),borderWidth: 1,cornerRadius: 8)
                bankBtn.selectStatusImageView.hide()
                aliBtn.border(.init(hexString: "#D6DEE6"),borderWidth: 1,cornerRadius: 8)
                aliBtn.selectStatusImageView.hide()
                bankView.hide()
                wxView.show()
            }
        }else{
            if let res = JsonTool.fromJson((paymentDetail?.stringValue)!, toClass: paymentDdetailData.self) {
                if paymentDetail?.type == "bank"{
                    view.addSubview(bankView)
                    view.addSubview(sumbitBtn)
                    bankView.snp_makeConstraints { make in
                        make.left.equalTo(16)
                        make.right.equalTo(-16)
                        make.top.equalTo(view.safeAreaLayoutGuide).offset(14)
                        make.height.equalTo(250)
                    }
                    sumbitBtn.snp_makeConstraints { make in
                        make.left.equalTo(16)
                        make.right.equalTo(-16)
                        make.height.equalTo(48)
                        make.top.equalTo(bankView.snp_bottom).offset(20)
                    }
                    bankView.nameView.textFieldView.text = res.name
                    bankView.bankNumberView.textFieldView.text = res.bankId
                    bankView.bankNameView.textFieldView.text = res.bankDeposit
                    bankView.bankSubView.textFieldView.text = res.bankBranch
                }else if paymentDetail?.type == "weiXin"{
                    view.addSubview(wxView)
                    view.addSubview(sumbitBtn)
                    wxView.snp_makeConstraints { make in
                        make.left.equalTo(16)
                        make.right.equalTo(-16)
                        make.top.equalTo(view.safeAreaLayoutGuide).offset(14)
                        make.height.equalTo(242)
                    }
                    sumbitBtn.snp_makeConstraints { make in
                        make.left.equalTo(16)
                        make.right.equalTo(-16)
                        make.height.equalTo(48)
                        make.top.equalTo(wxView.snp_bottom).offset(20)
                    }
                    paymentType = 2
                    wxView.show()
                    wxView.qrUrl = res.img
                    wxView.qrCodeImageView.sd_setImage(with: URL(string: res.img))
                    wxView.nameView.textFieldView.text = res.name
                    wxView.nickNameView.textFieldView.text = res.nickName
                }else{
                    view.addSubview(aliView)
                    view.addSubview(sumbitBtn)
                    aliView.snp_makeConstraints { make in
                        make.left.equalTo(16)
                        make.right.equalTo(-16)
                        make.top.equalTo(view.safeAreaLayoutGuide).offset(14)
                        make.height.equalTo(292)
                    }
                    sumbitBtn.snp_makeConstraints { make in
                        make.left.equalTo(16)
                        make.right.equalTo(-16)
                        make.height.equalTo(48)
                        make.top.equalTo(aliView.snp_bottom).offset(20)
                    }
                    paymentType = 1
                    aliView.show()
                    aliView.qrUrl = res.img
                    aliView.qrCodeImageView.sd_setImage(with: URL(string: res.img))
                    aliView.nameView.textFieldView.text = res.name
                    aliView.aliNumberView.textFieldView.text = res.zfbCode
                    aliView.nickNameView.textFieldView.text = res.nickName
                }

            }
        }
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {  _ in
            self.view.endEditing(true)
        }
        view.addGestureRecognizer(tap)
        
    }
    lazy var chooseTypeTitleLabel: UILabel = {
        let r = UILabel()
        r.font =  UIFont(name: "PingFangSC-Semibold", size: 16)
        r.textColor = .black333
        r.text = "选择支付方式".innerLocalized()
        return r
    }()
    lazy var chooseTypeView: UIView = {
        let r = UIView()
        r.addSubview(bankBtn)
        r.addSubview(aliBtn)
        r.addSubview(weixinBtn)
        let width = (kScreenWidth - 32 - 17*2)/3.0
        bankBtn.snp_makeConstraints { make in
            make.left.top.bottom.equalTo(0)
            make.width.equalTo(width)
        }
        aliBtn.snp_makeConstraints { make in
            make.left.equalTo(bankBtn.snp_right).offset(17)
            make.top.width.height.equalTo(bankBtn)
        }
        weixinBtn.snp_makeConstraints { make in
            make.left.equalTo(aliBtn.snp_right).offset(17)
            make.top.width.height.equalTo(bankBtn)
        }
        return r
    }()
    lazy var bankBtn: ChooseBtn = {
        let r = ChooseBtn()
        r.bindData(title: "银行卡", icon: UIImage(named: "mine_payment_method_bank_icon")!)
        r.border(.init(hexString: "#277FE6"),borderWidth: 1,cornerRadius: 8)
        r.selectStatusImageView.show()
        r.btn.rx.tap.subscribe(onNext: { [self] in
            if paymentType != 0{
                paymentType = 0
                r.border(.init(hexString: "#277FE6"),borderWidth: 1,cornerRadius: 8)
                r.selectStatusImageView.show()
                aliBtn.border(.init(hexString: "#D6DEE6"),borderWidth: 1,cornerRadius: 8)
                aliBtn.selectStatusImageView.hide()
                weixinBtn.border(.init(hexString: "#D6DEE6"),borderWidth: 1,cornerRadius: 8)
                weixinBtn.selectStatusImageView.hide()
                bankView.isHidden = false
                aliView.isHidden = true
                wxView.isHidden = true
                sumbitBtn.snp_remakeConstraints { make in
                    make.left.equalTo(16)
                    make.right.equalTo(-16)
                    make.height.equalTo(48)
                    make.top.equalTo(bankView.snp_bottom).offset(20)
                }
            }
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var aliBtn: ChooseBtn = {
        let r = ChooseBtn()
        r.bindData(title: "支付宝", icon: UIImage(named: "mine_payment_method_ali_icon")!)
        r.btn.rx.tap.subscribe(onNext: { [self] in
            if paymentType != 1{
                paymentType = 1
                r.border(.init(hexString: "#277FE6"),borderWidth: 1,cornerRadius: 8)
                r.selectStatusImageView.show()
                bankBtn.border(.init(hexString: "#D6DEE6"),borderWidth: 1,cornerRadius: 8)
                bankBtn.selectStatusImageView.hide()
                weixinBtn.border(.init(hexString: "#D6DEE6"),borderWidth: 1,cornerRadius: 8)
                weixinBtn.selectStatusImageView.hide()
                bankView.isHidden = true
                aliView.isHidden = false
                wxView.isHidden = true
                sumbitBtn.snp_remakeConstraints { make in
                    make.left.equalTo(16)
                    make.right.equalTo(-16)
                    make.height.equalTo(48)
                    make.top.equalTo(aliView.snp_bottom).offset(20)
                }
            }
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var weixinBtn: ChooseBtn = {
        let r = ChooseBtn()
        r.bindData(title: "微信", icon: UIImage(named: "mine_payment_method_weixin_icon")!)
        r.btn.rx.tap.subscribe(onNext: { [self] in
            if paymentType != 2{
                paymentType = 2
                r.border(.init(hexString: "#277FE6"),borderWidth: 1,cornerRadius: 8)
                r.selectStatusImageView.show()
                bankBtn.border(.init(hexString: "#D6DEE6"),borderWidth: 1,cornerRadius: 8)
                bankBtn.selectStatusImageView.hide()
                aliBtn.border(.init(hexString: "#D6DEE6"),borderWidth: 1,cornerRadius: 8)
                aliBtn.selectStatusImageView.hide()
                bankView.isHidden = true
                aliView.isHidden = true
                wxView.isHidden = false
                sumbitBtn.snp_remakeConstraints { make in
                    make.left.equalTo(16)
                    make.right.equalTo(-16)
                    make.height.equalTo(48)
                    make.top.equalTo(wxView.snp_bottom).offset(20)
                }
            }
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var bankView: BoBAddBankPaymentView = {
        let r = BoBAddBankPaymentView()
        r.chooseBankBlock = {
            let vc = BoBChooseBankListViewController()
            vc.chooseBankBlock = {[weak self] bankName in
                r.bankNameView.textFieldView.text = bankName
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        r.nameView.textFieldView.text = name
        r.corner(8)
        return r
    }()
    lazy var aliView: BoBAddAliPaymentView = {
        let r = BoBAddAliPaymentView(type: 1)
        r.nameView.textFieldView.text = name
        r.currentVC = self
        r.hide()
        return r
    }()
    lazy var wxView: BoBAddAliPaymentView = {
        let r = BoBAddAliPaymentView(type: 2)
        r.nameView.textFieldView.text = name
        r.currentVC = self
        r.hide()
        return r
    }()
    lazy var sumbitBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("Confirm".localized())
        r.setTitleColor(.white, for: .normal)
        r.corner(24)
        r.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 16)
        r.backgroundColor = .primaryColor
        r.rx.tap.subscribe(onNext: { [self] in
            var param : [String: Any]
            if paymentType == 0{
                if self.bankView.bankNumberView.textFieldView.isEmpty == true{
                    SuperToast.show(title: "请输入银行卡号")
                    return
                }
                if self.bankView.bankNameView.textFieldView.isEmpty == true{
                    SuperToast.show(title: "请选择开户银行")
                    return
                }
                param = ["name":name ?? "",
                         "bankId":self.bankView.bankNumberView.textFieldView.text ?? "",
                         "bankDeposit":self.bankView.bankNameView.textFieldView.text ?? "",
                         "bankBranch":self.bankView.bankSubView.textFieldView.text ?? ""]
            }else if paymentType == 1{
                if self.aliView.qrUrl?.isEmpty == true{
                    SuperToast.show(title: "请上传支付宝收款码")
                    return
                }
                if self.aliView.aliNumberView.textFieldView.isEmpty == true{
                    SuperToast.show(title: "请输入支付宝账号")
                    return
                }
                if self.aliView.nickNameView.textFieldView.isEmpty == true{
                    SuperToast.show(title: "请输入支付宝昵称")
                    return
                }
                param = ["name":name ?? "",
                         "zfbCode":self.aliView.aliNumberView.textFieldView.text ?? "",
                         "nickName":self.aliView.nickNameView.textFieldView.text ?? "",
                         "img":self.aliView.qrUrl ?? ""]
            }else{
                if self.wxView.qrUrl?.isEmpty == true{
                    SuperToast.show(title: "请上传微信收款码")
                    return
                }
                if self.wxView.nickNameView.textFieldView.isEmpty == true{
                    SuperToast.show(title: "请输入微信昵称")
                    return
                }
                param = ["name":name ?? "",
                         "nickName":self.wxView.nickNameView.textFieldView.text ?? "",
                         "img":self.wxView.qrUrl ?? ""]
            }
            var type = 1
            if paymentDetail != nil{
                param["id"] = paymentDetail?.id
                type = 2
            }
            BoBPaymentModel.AddPaymentMethod(type:type,paymentType: paymentType, param: param){errCode, errMsg in
                if errCode == 20000{
                    SuperToast.show(title:type == 1 ? "添加成功" : "修改成功")
                    NotificationCenter.default.post(name: Notification.Name("addPaymentSuccess"), object: nil)
                    self.navigationController?.popViewController(animated: true)
                }else{
                    SuperToast.show(title: errMsg)
                }
            }
            
        }).disposed(by: rx.disposeBag)
        return r
    }()
}
class ChooseBtn:UIView{
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
    func bindData(title:String,icon:UIImage){
        btn.setTitle(title, for: .normal)
        btn.setImage(icon, for: .normal)
    }
    lazy var btn: UIButton = {
        let r = UIButton()
        r.titleLabel?.font = UIFont(name: "PingFangSC-Semibold", size: 16)
        r.setTitleColor(.black333, for: .normal)
        r.border(.init(hexString: "#D6DEE6"),borderWidth: 1,cornerRadius: 8)
        let spacing: CGFloat = 10.0
        r.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: 0)
        r.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: spacing)
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
