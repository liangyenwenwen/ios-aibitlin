//
//  MineHomeWalletView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/11/22.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
class MineHomeWalletView: UIView{
    var walletData:MineWalletMoneyData?
    var itemArray = [itemView]()
    var refreshBlock:(()->Void)!
    var mineAssetsBlock:((_ quantityOfMoneyPOS:QuantityOfMoneyPOS)->Void)!
    var isRefresh:Bool = false
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews()  {
        addSubview(titleLabel)
        addSubview(privateBtn)
        addSubview(totalLabel)
        addSubview(refreshBtn)
        addSubview(listView)
        addSubview(openBtn)
        titleLabel.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(0)
            make.height.equalTo(30)
        }
        privateBtn.snp_makeConstraints { make in
            make.left.equalTo(titleLabel.snp_right).offset(6)
            make.centerY.equalTo(titleLabel)
            make.height.width.equalTo(30)
        }
        totalLabel.snp_makeConstraints { make in
            make.right.equalTo(refreshBtn.snp_left).offset(-8)
            make.left.equalTo(privateBtn.snp_right).offset(6)
            make.centerY.equalTo(titleLabel)
        }
        refreshBtn.snp_makeConstraints { make in
            make.right.equalTo(-6)
            make.centerY.equalTo(titleLabel)
            make.width.height.equalTo(30)
        }
        listView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(titleLabel.snp_bottom).offset(14)
            make.height.equalTo(0)
        }
        openBtn.snp_makeConstraints{make in
            make.width.equalTo(88)
            make.centerX.equalTo(self.snp_centerX)
            make.top.equalTo(listView.snp_bottom)
            make.height.equalTo(18)
        }
    }
    func stopRote(){
        self.refreshBtn.layer.removeAllAnimations()
        self.isRefresh = false
    }
    func rotateImageView() {
            // 定义旋转动画
//        UIView.animate(withDuration: 0.45,delay: 0,options: .curveLinear, animations: {
//                self.refreshBtn.transform = self.refreshBtn.transform.rotated(by:.pi)
//            }) { (completed) in
//                if self.isRefresh == true{
//                    self.rotateImageView()
//                }
//            }
        self.refreshBtn.layer.removeAllAnimations()
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(value: Double.pi * 2)
        rotationAnimation.duration = 0.45
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = 140
        rotationAnimation.isRemovedOnCompletion = false
        self.refreshBtn.layer.add(rotationAnimation, forKey: nil)
        }
    func bindData(walletMoneyData:MineWalletMoneyData){
        if walletMoneyData.quantityOfMoneyPOS?.count != walletData?.quantityOfMoneyPOS?.count{
            itemArray.removeAll()
            if itemArray.count > 0{
                for v in self.subviews as [UIView] {
                    if v.isKind(of: itemView.self){
                        v.removeFromSuperview()
                    }
                }
            }
            for i in 0..<walletMoneyData.quantityOfMoneyPOS!.count {
               let v = itemView()
                let tap = UITapGestureRecognizer()
                tap.rx.event.subscribe {  _ in
                    if self.mineAssetsBlock != nil{
                        let data = self.walletData?.quantityOfMoneyPOS![i]
                        self.mineAssetsBlock(data!)
                    }
                }.disposed(by: rx.disposeBag)
                v.addGestureRecognizer(tap)
                listView.addSubview(v)
                v.bindData(quantityOfMoneyPOS: walletMoneyData.quantityOfMoneyPOS![i],isPrivate: !privateBtn.isSelected)
                v.snp_makeConstraints { make in
                    make.left.right.equalTo(0)
                    make.height.equalTo(68)
                    make.top.equalTo((68 + 2)*i)
                }
                itemArray.append(v)
            }
            if openBtn.isSelected {
                listView.snp_updateConstraints { make in
                    make.height.equalTo((walletMoneyData.quantityOfMoneyPOS?.count ?? 0)*70-2)
                }
                openBtn.snp_updateConstraints { make in
                    make.top.equalTo(listView.snp_bottom).offset(12)
                }
                self.snp_updateConstraints { make in
                    make.height.equalTo(30+14+(walletMoneyData.quantityOfMoneyPOS?.count ?? 0)*70-2+12+18)
                }
            }else{
                listView.snp_updateConstraints { make in
                    make.height.equalTo(0)
                }
                openBtn.snp_updateConstraints { make in
                    make.top.equalTo(listView.snp_bottom).offset(0)
                }
                self.snp_updateConstraints { make in
                    make.height.equalTo(68)
                }
            }
        }else{
            for i in 0..<itemArray.count {
                let v = itemArray[i]
                v.bindData(quantityOfMoneyPOS: walletMoneyData.quantityOfMoneyPOS![i],isPrivate: !privateBtn.isSelected)
            }
        }
        if privateBtn.isSelected{
            let attributedString = NSMutableAttributedString(string: String(format: "￥%.2f",walletMoneyData.totalAssets!))
            attributedString.addAttribute(.font, value:UIFont(name: "PingFangSC-Regular", size: 16) as Any , range: NSRange(location: 0, length: 1))
            totalLabel.attributedText = attributedString
        }else{
            totalLabel.text = "******"
        }
        walletData = walletMoneyData
    }
    lazy var titleLabel: UILabel = {
        let r = UILabel()
        r.font = UIFont(name: "PingFangSC-Regular", size: 16)
        r.textColor = .black333
        r.text = "总资产"
        return r
    }()
    lazy var privateBtn: UIButton = {
        let r = UIButton()
        r.setImage(UIImage(named: "mine_home_close_eye_icon"), for: .normal)
        r.setImage(UIImage(named: "mine_home_open_eye_icon"), for: .selected)
        r.rx.tap.subscribe(onNext: { [weak self] in
            r.isSelected = !r.isSelected
            if r.isSelected{
                let attributedString = NSMutableAttributedString(string: String(format: "￥%.2f",self?.walletData?.totalAssets ?? 0))
                attributedString.addAttribute(.font, value:UIFont(name: "PingFangSC-Regular", size: 16) as Any , range: NSRange(location: 0, length: 1))
                self?.totalLabel.attributedText = attributedString
            }else{
                self?.totalLabel.text = "******"
            }
            for i in 0..<(self?.itemArray.count ?? 0) {
                let v = self?.itemArray[i]
                v?.privateBtnClick(isPrivate: !r.isSelected)
            }
        }).disposed(by: rx.disposeBag)
        return r
    }()
    
    lazy var totalLabel: UILabel = {
        let r = UILabel()
        r.font = .mediumFont(20)
        r.textColor = .init(hexString: "#388CEF")
        r.textAlignment = .right
        r.text = "******"
        return r
    }()
    lazy var refreshBtn: UIButton = {
        let r = UIButton()
        r.setImage(UIImage(named: "mine_home_refresh_icon"), for: .normal)
        r.rx.tap.subscribe(onNext: { [self] in
            if isRefresh == false {
                isRefresh = true
                if refreshBlock != nil{
                    refreshBlock()

                }
                rotateImageView()
            }
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var listView: UIView = {
        let r = UIView()
        r.hide()
        return r
    }()
    lazy var openBtn: UIButton = {
        let r = UIButton()
        r.setImage(UIImage(named: "mine_home_wallet_close_icon"), for: .normal)
        r.setImage(UIImage(named: "mine_home_wallet_open_icon"), for: .selected)
        r.setTitle("全部展开", for: .normal)
        r.setTitle("全部收起", for: .selected)
        r.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 14)
        r.setTitleColor(.black333, for: .normal)
        r.contentHorizontalAlignment = .left
        // 间距可能需要根据图片和文字大小调整
        let spacing: CGFloat = 10.0
        r.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: 0)
        r.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: spacing)
        r.rx.tap.subscribe(onNext: { [self] in
            r.isSelected = !r.isSelected
            if r.isSelected {
                //展开
                listView.show()
                listView.snp_updateConstraints { make in
                    make.height.equalTo((self.walletData?.quantityOfMoneyPOS?.count ?? 0)*70-2)
                }
                r.snp_updateConstraints { make in
                    make.top.equalTo(listView.snp_bottom).offset(12)
                }
                self.snp_updateConstraints { make in
                    make.height.equalTo(30+14+(self.walletData?.quantityOfMoneyPOS?.count ?? 0)*70-2+12+18)
                }
            }else{
                //收起
                listView.hide()
                listView.snp_updateConstraints { make in
                    make.height.equalTo(0)
                }
                r.snp_updateConstraints { make in
                    make.top.equalTo(listView.snp_bottom).offset(0)
                }
                self.snp_updateConstraints { make in
                    make.height.equalTo(68)
                }
            }
            
        }).disposed(by: rx.disposeBag)
        return r
    }()
}
class itemView:UIView {
    var data:QuantityOfMoneyPOS?
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func initViews()  {
        backgroundColor = .white
        corner(10)
        addSubview(iconImageView)
        addSubview(currencyLabel)
        addSubview(officialExchangeRateLabel)
        addSubview(cionTypeLabel)
        addSubview(fallImageView)
        addSubview(totalLabel)
        addSubview(equivalentToRMBLabel)
        iconImageView.snp_makeConstraints { make in
            make.left.equalTo(20)
            make.centerY.equalTo(self.snp_centerY)
            make.width.height.equalTo(44)
        }
        currencyLabel.snp_makeConstraints { make in
            make.top.equalTo(14)
            make.left.equalTo(iconImageView.snp_right).offset(10)
            make.width.equalTo(100)
        }
        officialExchangeRateLabel.snp_makeConstraints { make in
            make.bottom.equalTo(-14)
            make.left.equalTo(currencyLabel)
        }
        cionTypeLabel.snp_makeConstraints { make in
            make.left.equalTo(officialExchangeRateLabel.snp_right).offset(6)
            make.centerY.equalTo(officialExchangeRateLabel)
        }
        fallImageView.snp_makeConstraints { make in
            make.left.equalTo(cionTypeLabel.snp_right).offset(6)
            make.centerY.equalTo(officialExchangeRateLabel)
        }
        
        totalLabel.snp_makeConstraints { make in
            make.right.equalTo(-28)
            make.centerY.equalTo(currencyLabel)
            make.left.equalTo(currencyLabel.snp_right).offset(8)
        }
        equivalentToRMBLabel.snp_makeConstraints { make in
            make.left.right.equalTo(totalLabel)
            make.centerY.equalTo(officialExchangeRateLabel)
        }
    }
    lazy var iconImageView: UIImageView = {
        let r = UIImageView()
        return r
    }()
    lazy var currencyLabel: UILabel = {
        let r = UILabel()
        r.font = UIFont(name: "PingFangSC-Regular", size: 18)
        r.textColor = .init(hexString: "#388CEF")
        return r
    }()
    lazy var officialExchangeRateLabel: UILabel = {
        let r = UILabel()
        r.font = UIFont(name: "PingFangSC-Regular", size: 12)
        r.textColor = .init(hexString: "#00AA3C")
        return r
    }()
    lazy var cionTypeLabel: UILabel = {
        let r = UILabel()
        r.font = UIFont(name: "PingFangSC-Regular", size: 12)
        r.textColor = .black999
        r.text = "RMB"
        return r
    }()
    lazy var fallImageView: UIImageView = {
        let r = UIImageView()
        r.image = UIImage(named: "mine_home_official_exchange_rate_fall_icon")
        return r
    }()
    lazy var totalLabel: UILabel = {
        let r = UILabel()
        r.font = .mediumFont(16)
        r.textColor = .init(hexString: "#388CEF")
        r.textAlignment = .right
        return r
    }()
    lazy var equivalentToRMBLabel: UILabel = {
        let r = UILabel()
        r.font = .mediumFont(14)
        r.textColor = .init(hexString: "#388CEF")
        r.textAlignment = .right
        return r
    }()
    func bindData(quantityOfMoneyPOS:QuantityOfMoneyPOS,isPrivate:Bool){
        data = quantityOfMoneyPOS
        iconImageView.sd_setImage(with: URL(string: quantityOfMoneyPOS.logoAddr))
        currencyLabel.text = quantityOfMoneyPOS.currency
        officialExchangeRateLabel.text = String(format: "%.2f",quantityOfMoneyPOS.officialExchangeRate!)
        if isPrivate{
            totalLabel.text = "******"
            equivalentToRMBLabel.text = "≈￥******"
        }else{
            totalLabel.text = String(format: "%.2f",quantityOfMoneyPOS.quantityOfMoney!)
            equivalentToRMBLabel.text = String(format: "≈￥%.2f",quantityOfMoneyPOS.equivalentToRMB!)
        }
    }
    func privateBtnClick(isPrivate:Bool){
        if isPrivate{
            totalLabel.text = "******"
            equivalentToRMBLabel.text = "≈￥******"
        }else{
            totalLabel.text = String(format: "%.2f",data?.quantityOfMoney ?? 0.00)
            equivalentToRMBLabel.text = String(format: "≈￥%.2f",data?.equivalentToRMB ?? 0.00)
        }
    }
}
