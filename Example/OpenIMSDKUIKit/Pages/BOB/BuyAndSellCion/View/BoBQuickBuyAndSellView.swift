//
//  BoBQuickBuyAndSellView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/10.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import JXSegmentedView
import OUICore


class BoBQuickBuyAndSellView: UIView {
    var currentVC:UIViewController?
    var titleArray = ["100","500","1000","3000","5000","10000","20000","30000"]
    var chooseMoney = ""
    var selectBtn = QMUIButton()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        addSubview(titleLabel)
        addSubview(buyTypeBtn)
        addSubview(countView)
        addSubview(lineView)
        addSubview(typeView)
        addSubview(paymentMethodView)
        addSubview(buyBtn)
        titleLabel.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(13)
            make.height.equalTo(20)
            make.width.equalTo(120)
        }
        buyTypeBtn.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalTo(titleLabel)
            make.height.equalTo(30)
            make.left.equalTo(titleLabel.snp_right).offset(15)
        }
        countView.snp_makeConstraints { make in
            make.top.equalTo(titleLabel.snp_bottom).offset(5)
            make.left.right.equalTo(0)
            make.height.equalTo(28)
        }
        lineView.snp_makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(countView.snp_bottom).offset(5)
            make.height.equalTo(1)
        }
        typeView.snp_makeConstraints { make in
            make.top.equalTo(lineView.snp_bottom).offset(12)
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(88)
        }
        paymentMethodView.snp_makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(typeView.snp_bottom).offset(22+12)
            make.height.equalTo(178)
        }
        buyBtn.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(50)
            make.top.equalTo(paymentMethodView.snp_bottom).offset(24)
        }
        
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private lazy var titleLabel: UILabel = {
        let r = UILabel()
        r.font = .mediumFont(16)
        r.textColor = .black
        r.text = "数量"
        return r
    }()
    private lazy var buyTypeBtn: UIButton = {
        let r = UIButton()
        r.setImage(UIImage(named: "mine_buy_and_sell_buy_type_icon"), for: .normal)
        r.setTitle("按金额购买", for: .normal)
        r.setTitle("按数量购买", for: .selected)
        r.isSelected = false
        r.titleLabel?.font = .regularFont(16)
        r.setTitleColor(.primaryColor, for: .normal)
        r.contentHorizontalAlignment = .right
        // 间距可能需要根据图片和文字大小调整
        let spacing: CGFloat = 3
        r.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: 0)
        r.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: spacing)
        r.rx.tap.subscribe(onNext: { [self] in
            r.isSelected = !r.isSelected
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var countView: UIView = {
        let r = UIView()
        r.addSubview(cionImageView)
        r.addSubview(countTF)
        cionImageView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalTo(r)
            make.width.height.equalTo(18)
        }
        countTF.snp_makeConstraints { make in
            make.left.equalTo(cionImageView.snp_right).offset(10)
            make.right.equalTo(-16)
            make.centerY.equalTo(r)
        }
        return r
    }()
    private lazy var cionImageView: UIImageView = {
        let r = UIImageView(image: UIImage(named: "mine_home_cion_c_icon"))
        return r
    }()
    private lazy var countTF: QMUITextField = {
        let r = QMUITextField()
        r.tg_height.equal(50)
        r.tg_top.equal(0)
        r.tg_left.equal(16)
        r.tg_width.equal(240)
        r.font = .regularFont(16)
        r.tintColor = .black333
        r.keyboardType = .decimalPad
        r.setPlaceHolderTextColor(.black999)
        r.placeholder = "限额￥100~30,000 C"
        r.rx.controlEvent(.editingChanged).subscribe(onNext: { [weak self] in
            if ((r.text?.range(of:".")) != nil){
                //带小数点
                if r.text!.filter({ "." == $0 }).count == 2{
                    guard let range = r.text!.range(of: ".", options: [.backwards, .caseInsensitive], range: nil, locale: nil) else {
                        return
                    }
                    r.text =  r.text!.replacingCharacters(in: range, with: "")
                }else if r.text!.filter({ "." == $0 }).count > 2{
                    r.text = ""
                }
                let arr = r.text?.components(separatedBy: ".")
                if arr![1].count > 2{
                    r.text = arr![0] + "." + arr![1].prefix(2)
                }
            }else{
                if r.text!.length > 1 {
                    let str = r.text?.prefix(1)
                    if str == "0"{
                        r.text = "0"
                    }
                }
            }
            if self?.chooseMoney.isEmpty == false && Int(r.text ?? "0") != Int(self?.chooseMoney ?? "0"){
                if self?.selectBtn != nil{
                    self?.selectBtn.border(.init(hexString: "#EAEAEA"),borderWidth: 1,cornerRadius: 6)
                    self?.selectBtn.setTitleColor(.black666, for: .normal)
                    self?.selectBtn.backgroundColor = .white
                }
                self?.chooseMoney = ""
            }
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var lineView: UIView = {
        let r = UIView()
        r.backgroundColor = .init(hexString: "#F5F5F5")
        return r
    }()
    lazy var typeView: UIView = {
        let r = UIView()
        let width = (kScreenWidth-64-24)/4
        for (index,item) in titleArray.enumerated() {
            let btn = QMUIButton()
            btn.setTitle(item, for: .normal)
            btn.titleLabel?.font = .semiboldFont(16)
            btn.border(.init(hexString: "#EAEAEA"),borderWidth: 1,cornerRadius: 6)
            btn.setTitleColor(.black666, for: .normal)
            btn.backgroundColor = .white
            btn.rx.tap.subscribe(onNext: { [weak self] in
                if self?.selectBtn != btn{
                    if self?.selectBtn != nil{
                        self?.selectBtn.border(.init(hexString: "#EAEAEA"),borderWidth: 1,cornerRadius: 6)
                        self?.selectBtn.setTitleColor(.black666, for: .normal)
                        self?.selectBtn.backgroundColor = .white
                    }
                    btn.border(.primaryColor,borderWidth: 1,cornerRadius: 6)
                    btn.setTitleColor(.primaryColor, for: .normal)
                    btn.backgroundColor = .init(hexString: "#F3F8FF")
                    self?.selectBtn = btn
                    self?.chooseMoney = item
                    self?.countTF.text = item
                }
            }).disposed(by: rx.disposeBag)
            r.addSubview(btn)
            btn.snp_makeConstraints { make in
                make.left.equalTo((Int(width)+8)*(index%4))
                make.top.equalTo(r).offset((40+8)*(index/4))
                make.width.equalTo(width)
                make.height.equalTo(40)
            }
        }
        return r
    }()
    private lazy var paymentMethodView: UIView = {
        let r = UIView()
        r.backgroundColor = .white
        r.corner(8)
        r.addSubview(paymentMethodTitleLabel)
        r.addSubview(paymentBgView)
        r.addSubview(exchangeRateView)
        r.addSubview(expectedIncomeLabel)
        r.addSubview(expectedIncomeTitleLabel)
        paymentMethodTitleLabel.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(14)
            make.height.equalTo(20)
            make.right.equalTo(-16)
        }
        paymentBgView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(paymentMethodTitleLabel.snp_bottom).offset(12)
            make.height.equalTo(72)
            make.right.equalTo(-16)
        }
        exchangeRateView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.height.equalTo(16)
            make.bottom.equalTo(-16)
            make.width.equalTo(124)
        }
        expectedIncomeLabel.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalTo(exchangeRateView)
        }
        expectedIncomeTitleLabel.snp_makeConstraints { make in
            make.right.equalTo(expectedIncomeLabel.snp_left)
            make.centerY.equalTo(exchangeRateView)
        }
        
        return r
    }()
    private lazy var paymentMethodTitleLabel: UILabel = {
        let r = UILabel()
        r.textColor = .black333
        r.font = .mediumFont(16)
        r.text = "选择支付方式"
        return r
    }()
    private lazy var paymentBgView: UIView = {
        let r = UIView()
        r.backgroundColor = .init(hexString: "#EAF5FF")
        r.border(.init(hexString: "#BEDFFF"),borderWidth: 1,cornerRadius: 8)
        r.addSubview(addView)
        addView.snp_makeConstraints { make in
            make.left.right.top.bottom.equalTo(r)
        }
        return r
    }()
    private lazy var exchangeRateView: UIView = {
        let r = UIView()
        r.addSubview(exchangeRateLabel)
        r.addSubview(refreshImageView)
        exchangeRateLabel.snp_makeConstraints { make in
            make.left.top.bottom.equalTo(r)
//            make.right.equalTo(refreshImageView.snp_left).offset(-1)
        }
        refreshImageView.snp_makeConstraints { make in
            make.centerY.equalTo(r)
            make.width.equalTo(11)
            make.height.equalTo(11)
            make.left.equalTo(exchangeRateLabel.snp_right).offset(2)
        }
        return r
    }()
    private lazy var exchangeRateLabel: UILabel = {
        let r = UILabel()
        r.textColor = .black333
        r.font = .regularFont(14)
        r.text = "参考汇率 ￥1.00"
        return r
    }()
    private lazy var refreshImageView: UIView = {
        let r = UIImageView(image: UIImage(named: "mine_home_refresh_icon")?.changeImageColor(color: .primaryColor))
        return r
    }()
    private lazy var expectedIncomeTitleLabel: UILabel = {
        let r = UILabel()
        r.textColor = .black333
        r.font = .mediumFont(14)
        r.text = "预计获得："
        r.textAlignment = .right
        return r
    }()
    private lazy var expectedIncomeLabel: UILabel = {
        let r = UILabel()
        r.textColor = .init(hexString: "#F32525")
        r.font = .mediumFont(20)
        r.text = "0.00 C"
        r.textAlignment = .right
        return r
    }()
    
    private lazy var addView: UIView = {
        let r = UIView()
        let label1 = UILabel()
        label1.text = "添加支付方式"
        label1.textColor = .white
        label1.font = .regularFont(14)
        label1.backgroundColor = .init(hexString: "#388CEF")
        label1.textAlignment = .center
        label1.corner(16)
        r.addSubview(label1)
        let label2 = UILabel()
        label2.text = "请点击按钮添加支付方式"
        label2.textColor = .black666
        label2.font = .regularFont(16)
        r.addSubview(label2)
        label1.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalTo(r)
            make.width.equalTo(107)
            make.height.equalTo(32)
        }
        label2.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalTo(r)
            make.right.equalTo(label1.snp_left).offset(-10)
        }
        return r
    }()
    private lazy var choosePaymentView: UIView = {
        let r = UIView()
        r.hide()
        let v = UIImageView(image: UIImage(named: "superChevronRight")?.changeImageColor(color: .primaryColor))
        v.contentMode = .scaleAspectFit
        r.addSubview(v)
        r.addSubview(paymentMethodIcon)
        r.addSubview(paymentMethodName)
        r.addSubview(paymentMethodNumber)
        paymentMethodIcon.snp_makeConstraints { make in
            make.left.equalTo(20)
            make.centerY.equalTo(r)
            make.width.height.equalTo(30)
        }
        paymentMethodName.snp_makeConstraints { make in
            make.top.equalTo(15)
            make.left.equalTo(paymentMethodIcon.snp_right).offset(13)
            make.height.equalTo(16)
            make.right.equalTo(-45)
        }
        paymentMethodNumber.snp_makeConstraints { make in
            make.bottom.equalTo(-15)
            make.left.right.equalTo(paymentMethodName)
            make.height.equalTo(16)
        }
        v.snp_makeConstraints { make in
            make.right.equalTo(16)
            make.centerY.equalTo(r)
            make.width.height.equalTo(16)
        }
        
        return r
    }()
    private lazy var paymentMethodIcon: UIImageView = {
        let r = UIImageView()
        
        return r
    }()
    private lazy var paymentMethodName: UILabel = {
        let r = UILabel()
        r.textColor = .black333
        r.font = .mediumFont(16)
        return r
    }()
    private lazy var paymentMethodNumber: UILabel = {
        let r = UILabel()
        r.textColor = .black666
        r.font = .regularFont(14)
        return r
    }()
    private lazy var choosePaymentMethodView: UIView = {
        let r = UIView()
        r.hide()
        let v = UIImageView(image: UIImage(named: "superChevronRight")?.changeImageColor(color: .primaryColor))
        v.contentMode = .scaleAspectFit
        r.addSubview(v)
        let label = UILabel()
        label.textColor = .black666
        label.font = .regularFont(16)
        label.text = "选择支付方式"
        r.addSubview(label)
        label.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalTo(r)
            make.right.equalTo(-45)
        }
        v.snp_makeConstraints { make in
            make.right.equalTo(16)
            make.centerY.equalTo(r)
            make.width.height.equalTo(16)
        }
        
        return r
    }()
    
    private lazy var buyBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("购买C".localized())
        r.setTitleColor(.white, for: .normal)
        r.corner(25)
        r.titleLabel?.font = .semiboldFont(16)
        r.backgroundColor = .primaryColor
        r.rx.tap.subscribe(onNext: { [weak self] in
            
            if IMController.shared.certificationLevel == 0 {
                let alert = UIAlertController(title: "提示", message: "请先进行实名认证".innerLocalized(), preferredStyle: .alert)
                // 创建UIAlertAction，用于处理用户的选择
                let cancleAction = UIAlertAction(title: "取消", style: .default) { _ in
                }
                let okAction = UIAlertAction(title: "去认证", style: .default) { _ in
                    let vc =  BoBRealNameMainViewController()
                    self?.currentVC?.navigationController?.pushViewController(vc, animated: true)
                }
                // 将action添加到alertController上
                alert.addAction(cancleAction)
                alert.addAction(okAction)
                // 弹出alert
                self?.currentVC?.present(alert, animated: true, completion: nil)
            }else{
                if IMController.shared.isSetPayPassWord {
                    let passWordView = BoBPayPassWordView()
                    passWordView.tg_width.equal(.fill)
                    passWordView.tg_height.equal(210)
                    passWordView.payBtnClickBlock = { [weak self] passWord in
                        

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

extension BoBQuickBuyAndSellView: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self
    }
}

