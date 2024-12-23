//
//  BoBConfirmPurchaseAlertView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/21.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import MMBAlertsPickers
import OUICore
import ProgressHUD
import RxCocoa
import RxSwift
import TangramKit
import UIKit
class BoBConfirmPurchaseAlertView: UIView {
    var currentVC:UIViewController?
    var payment:Int = 1 //支付方式
    var buyType:Int = 1 //按金额购买，2按数量购买
    var type:Int = 1 //1:购买 2:出售
    var walletType:CionTypeModel?//选中的出售钱包
    var paymentType:stringAndDatePOS?//选中的支付方式
    var unitPrice:String?//单价
    var count:String?//数量
    var money:String?//金额
    var code:String?//广告编码
    var commitSuccessBlock:(()->())!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        innerInit()

    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func innerInit() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5) // 半透明背景
        addSubview(contentView)
        contentView.addSubview(topView)
        contentView.addSubview(payMoneyView)
        contentView.addSubview(paymentBgView)
        contentView.addSubview(unitPriceView)
        contentView.addSubview(countView)
        contentView.addSubview(tipView)
        contentView.addSubview(bottomView)
    }
    // 自定义弹框视图
    func showMask(view: UIView) {
        self.frame = view.bounds
        view.addSubview(self)
        // 动画显示遮罩
        alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
    }
    
    // 隐藏遮罩
    func hideMask() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }
    lazy var contentView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.corner(MEDDLE_RADIUS)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_space = PADDING_MEDDLE
//        r.tg_width.equal(kScreenWidth)
////            confirmPurchaseView.tg_height.equal(.wrap)
//        r.tg_height.equal(500)
        r.tg_bottom.equal(0)
        r.tg_padding = UIEdgeInsets(top: 0, left: PADDING_OUTER, bottom: PADDING_MEDDLE+34, right: PADDING_OUTER)
        r.backgroundColor = .white
        return r
    }()
    func bindData(buyType:Int,type:Int,walletType:CionTypeModel,paymentType:stringAndDatePOS,unitPrice:String,money:String,count:String,code:String){
        self.type = type
        self.buyType = buyType
        self.walletType = walletType
        self.paymentType = paymentType
        self.unitPrice = unitPrice
        self.money = money
        self.count = count
        self.code = code
        payMoneyView.buyCounLabel.text = "¥" + money
       if type == 1 {
            //购买
            titleLbl.text = "确认购买"
           countView.buyCountTitleLabel.text = "购买数量" + String(format: "(%@)", walletType.currency ?? "C")
        }else{
            //出售
            titleLbl.text = "确认出售"
            countView.buyCountTitleLabel.text = "出售数量" + String(format: "(%@)", walletType.currency ?? "C")
        }
        paymentIcon.sd_setImage(with: URL(string: paymentType.icon))
        if paymentType.type == "bank"{
            paymentNameLabel.text = "银行卡"
            payment = 1
        }else if paymentType.type == "weiXin"{
            paymentNameLabel.text = "微信"
            payment = 3
        }else{
            paymentNameLabel.text = "支付宝"
            payment = 2
        }
    }
    lazy var topView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_top.equal(20)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_gravity = .vert.between
        r.addSubview(titleLbl)
        r.addSubview(closeBtn)
        return r
    }()
    lazy var titleLbl: UILabel = {
        let r = ViewFactoryUtil.customTilteLabelFill("确认购买", font: 18, textColor: .black333)
        r.font = .mediumFont(18)
        r.textColor = .black333
        return r
    }()
    lazy var closeBtn: QMUIButton = {
        let r = ViewFactoryUtil.imageBtn(R.image.close_cirle_icon()!, 28)
        r.rx.tap.subscribe(onNext: {[weak self] in
            self?.hideMask()
        })
        .disposed(by: rx.disposeBag)
        return r
    }()
    lazy var payMoneyView: buyAndSellTitleView = {
        let r = buyAndSellTitleView()
        r.tg_top.equal(20)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(16)
        r.buyCountTitleLabel.text = "付款金额"
        r.buyCountTitleLabel.font = .regularFont(16)
        r.buyCounLabel.text = "¥0.00"
        r.buyCounLabel.font = .mediumFont(18)
        r.buyCounLabel.textColor = .init(hexString: "#F32525")
        return r
    }()
    lazy var paymentBgView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_top.equal(6)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(24)
        r.tg_gravity = .horz.between
        r.tg_space = PADDING_MEDDLE
        r.addSubview(paymentTitleLabel)
        r.addSubview(paymentView)
        return r
    }()
    lazy var paymentTitleLabel: UILabel = {
        let r = UILabel()
        r.tg_width.equal(.wrap)
        r.tg_height.equal(.fill)
        r.textColor = .black666
        r.font = .regularFont(16)
        r.text = "支付方式"
        return r
    }()
    lazy var paymentView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(.wrap)
        r.tg_right.equal(0)
        r.tg_height.equal(24)
        r.addSubview(paymentIcon)
        r.addSubview(paymentNameLabel)
        return r
    }()
    lazy var paymentIcon: UIImageView = {
        let r = UIImageView()
        r.tg_width.equal(24)
        r.tg_height.equal(24)
        return r
    }()
    lazy var paymentNameLabel: UILabel = {
        let r = UILabel()
        r.tg_left.equal(2)
        r.tg_width.equal(.wrap)
        r.tg_height.equal(.fill)
        r.tg_right.equal(0)
        r.textColor = .black333
        r.font = .regularFont(16)
        return r
    }()
    lazy var unitPriceView: buyAndSellTitleView = {
        let r = buyAndSellTitleView()
        r.tg_top.equal(6)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(16)
        r.buyCountTitleLabel.text = "单价(CNY)"
        r.buyCountTitleLabel.font = .regularFont(16)
        r.buyCounLabel.text = "¥1.00"
        r.buyCounLabel.font = .regularFont(16)
        return r
    }()
    lazy var countView: buyAndSellTitleView = {
        let r = buyAndSellTitleView()
        r.tg_top.equal(10)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(16)
        r.buyCountTitleLabel.text = "购买数量(C)"
        r.buyCountTitleLabel.font = .regularFont(16)
        r.buyCounLabel.text = "100.00"
        r.buyCounLabel.font = .regularFont(16)
        return r
    }()
    lazy var tipView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_top.equal(12)
        r.tg_width.equal(kScreenWidth-32)
        r.tg_height.equal(.wrap)
        r.tg_padding = UIEdgeInsets(top: PADDING_OUTER, left: PADDING_OUTER, bottom: PADDING_OUTER, right: PADDING_OUTER)
        r.backgroundColor = .init(hexString: "#EAF5FF")
        r.corner(8)
        r.addSubview(tipTitleLabel)
        r.addSubview(tipContentLabel)
//        r.addSubview(tipDetailLabel)
        return r
    }()
    lazy var tipTitleLabel: UILabel = {
        let r = UILabel()
        r.tg_top.equal(0)
        r.tg_width.equal(.fill)
        r.tg_height.equal(18)
        r.textColor = .primaryColor
        r.font = .semiboldFont(18)
        r.text = "T+1安全保护"
        return r
    }()
    lazy var tipContentLabel: UILabel = {
        let r = UILabel()
        r.tg_top.equal(12)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.textColor = .black333
        r.font = .regularFont(16)
        r.text = "为了保护您的资金安全，我们将对买入的资产限制24小时；但不影响购买后立刻去我们合作平台进行虚拟币充值"
        r.numberOfLines = 0
        return r
    }()
//    lazy var tipDetailLabel: UILabel = {
//        let r = UILabel()
//        r.tg_top.equal(12)
//        r.tg_width.equal(.fill)
//        r.tg_height.equal(.wrap)
//        r.textColor = .black333
//        r.font = .regularFont(16)
//        r.text = "查看详情 >"
//        return r
//    }()
    lazy var bottomView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_top.equal(42)
        r.tg_width.equal(kScreenWidth-32)
        r.tg_height.equal(46)
//        r.tg_gravity = .vert.between
        r.tg_hspace = 18
        r.addSubview(cancleBtn)
        r.addSubview(sureBtn)
//        r.addSubview(tipDetailLabel)
        return r
    }()
    lazy var cancleBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("取消")
        r.tg_height.equal(46)
        r.tg_width.equal((kScreenWidth-32-18)/2)
        r.setTitleColor(.black666, for: .normal)
        r.titleLabel?.font = .mediumFont(16)
        r.border(.init(hexString: "#EAEAEA"),borderWidth: 1,cornerRadius: 23)
        r.rx.tap.subscribe(onNext: { [weak self] in
            self?.hideMask()
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var sureBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("确认")
        r.tg_height.equal(46)
        r.tg_width.equal((kScreenWidth-32-18)/2)
        r.setTitleColor(.white, for: .normal)
        r.titleLabel?.font = .mediumFont(16)
        r.backgroundColor = .primaryColor
        r.corner(23)
        r.rx.tap.subscribe(onNext: { [weak self] in
            if self?.type == 1{
                //购买
                BoBBuyAndSellCionModel.IntendedBuyRequest(code: self?.code ?? "", amount: self?.money ?? "", payment: String(format: "%d", self?.payment ?? 1), quantity: self?.count ?? "", exchangeRate: self?.unitPrice ?? "", type: self?.type ?? 1){[weak self] errCode, errMsg in
                    if errCode == 20000{
                        SuperToast.show(title:"购买成功")
                        if self?.commitSuccessBlock != nil{
                            self?.commitSuccessBlock()
                        }
                        self?.hideMask()
                    }else{
                        SuperToast.show(title: errMsg)
                    }
                }
            }else{
                //出售
                if IMController.shared.isSetPayPassWord {
                   
                    let passWordView = BoBPayPassWordView()
                    passWordView.tg_width.equal(.fill)
                    passWordView.tg_height.equal(210)
                    passWordView.payBtnClickBlock = { [weak self] passWord in
                        BoBBuyAndSellCionModel.IntendedSellRequest(code: self?.code ?? "", amount: self?.money ?? "",currencyWallet:self?.walletType?.cionType ?? "0" ,payment: String(format: "%d", self?.payment ?? 1), quantity: self?.count ?? "", exchangeRate: self?.unitPrice ?? "",paymentId:String(format: "%d", self?.paymentType?.id ?? 0),type: self?.type ?? 1,pwd:passWord){[weak self] errCode, errMsg in
                            if errCode == 20000{
                                SuperToast.show(title:"出售成功")
                                if self?.commitSuccessBlock != nil{
                                    self?.commitSuccessBlock()
                                }
                                self?.hideMask()
                            }else{
                                SuperToast.show(title: errMsg)
                            }
                        }
                    }
                    GKCover.cover(from: self?.currentVC?.view.window, contentView: passWordView, style: .translucent, showStyle: .center, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
                    
                }else{
                    let alert = UIAlertController(title: "提示", message: "为了您的财产安全，请设置安全密码".innerLocalized(), preferredStyle: .alert)
                    // 创建UIAlertAction，用于处理用户的选择
                    let cancleAction = UIAlertAction(title: "取消", style: .default) { _ in
                    }
                    let okAction = UIAlertAction(title: "去设置", style: .default) { _ in
                        let vc = BoBChangePayPassWordViewController()
                        vc.passWordType = 0
                        self?.currentVC?.navigationController?.pushViewController(vc,animated: true)
                    }
                    // 将action添加到alertController上
                    alert.addAction(cancleAction)
                    alert.addAction(okAction)
                    // 弹出alert
                    self?.currentVC?.present(alert, animated: true, completion: nil)
                }
            }
        }).disposed(by: rx.disposeBag)
        return r
    }()
}

