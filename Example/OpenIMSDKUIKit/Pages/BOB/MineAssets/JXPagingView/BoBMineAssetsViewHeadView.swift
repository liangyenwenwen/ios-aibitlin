//
//  BoBMineAssetsViewHeadView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/2.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import TangramKit

class BoBMineAssetsViewHeadView: UIView {
    var currentVC: UIViewController?
    var quantityOfMoneyPOS:QuantityOfMoneyPOS?
    override init(frame: CGRect) {
        super.init(frame: frame)
        innerInit()
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func innerInit(){
        addSubview(topView)
        addSubview(totalLabel)
        addSubview(moneyLabel)
        addSubview(lineView)
        addSubview(bottomView)
        totalLabel.snp_makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(57)
            make.height.equalTo(46)
        }
        moneyLabel.snp_makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(totalLabel.snp_bottom).offset(5)
            make.height.equalTo(16)
        }
        lineView.snp_makeConstraints { make in
            make.left.right.equalTo(0)
            make.height.equalTo(1)
            make.bottom.equalTo(-80)
        }
        bottomView.snp_makeConstraints { make in
            make.left.right.equalTo(0)
            make.bottom.equalTo(0)
            make.height.equalTo(80)
        }
    }
    func bindData(quantityOfMoneyPOS:QuantityOfMoneyPOS?){
        self.quantityOfMoneyPOS = quantityOfMoneyPOS
        cionImageView.sd_setImage(with: URL(string: quantityOfMoneyPOS?.logoAddr))
        cionLabel.text = quantityOfMoneyPOS?.currency
        totalLabel.text = String(format: "%.2f",(quantityOfMoneyPOS?.quantityOfMoney)!)
        moneyLabel.text = String(format: "≈￥%.2f",(quantityOfMoneyPOS?.equivalentToRMB)!)
        leftLabel.text = String(format: "%.2f",(quantityOfMoneyPOS?.usable)!)
        rightLabel.text = String(format: "%.2f",(quantityOfMoneyPOS?.frozen)!)
    }
    lazy var topView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(.wrap)
        r.tg_height.equal(26)
        r.tg_centerX.equal(0)
        r.tg_space = 9
        r.tg_gravity = .vert.center
        r.tg_top.equal(22)
        r.addSubview(cionImageView)
        r.addSubview(cionLabel)
        return r
    }()
    lazy var cionImageView: UIImageView = {
        let r = UIImageView()
        r.tg_width.equal(26)
        r.tg_height.equal(26)
        return r
    }()
    lazy var cionLabel: UILabel = {
        let r = UILabel()
        r.tg_width.equal(.wrap)
        r.tg_height.equal(.wrap)
        r.textColor = .black333
        r.font = .mediumFont(16)
        return r
    }()
    lazy var totalLabel: UILabel = {
        let r = UILabel()
        r.textAlignment = .center
        r.textColor = .black333
        r.font = .regularFont(46)
        return r
    }()
    lazy var moneyLabel: UILabel = {
        let r = UILabel()
        r.textAlignment = .center
        r.textColor = .primaryColor
        r.font = .regularFont(16)
        return r
    }()
    lazy var lineView: UIView = {
        let r = UIView()
        r.backgroundColor = .init(hexString: "#EAEAEA")
        return r
    }()
    lazy var bottomView: UIView = {
        let r = UIView()
        r.addSubview(leftView)
        r.addSubview(lineView1)
        r.addSubview(rightView)
        leftView.snp_makeConstraints { make in
            make.left.top.bottom.equalTo(0)
            make.right.equalTo(lineView1.snp_left)
        }
        lineView1.snp_makeConstraints { make in
            make.center.equalTo(r)
            make.width.equalTo(1)
            make.height.equalTo(46)
        }
        rightView.snp_makeConstraints { make in
            make.right.top.bottom.equalTo(0)
            make.left.equalTo(lineView1.snp_right)
        }
        return r
    }()
    lazy var leftView: UIView = {
        let r = UIView()
        r.addSubview(leftTitleView)
        r.addSubview(leftLabel)
        leftLabel.snp_makeConstraints { make in
            make.left.equalTo(5)
            make.right.equalTo(-5)
            make.bottom.equalTo(-20)
            make.height.equalTo(16)
        }
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {  _ in
            let explainView = BoBMineAssetsExplainView()
            explainView.bindData(quantityOfMoneyPOS: self.quantityOfMoneyPOS)
            explainView.tg_width.equal(293)
            explainView.tg_height.equal(280)
            GKCover.cover(from: self.currentVC?.view.window, contentView: explainView, style: .translucent, showStyle: .center, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
            
        }.disposed(by: rx.disposeBag)
        r.addGestureRecognizer(tap)
        return r
    }()
    lazy var leftTitleView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(.wrap)
        r.tg_height.equal(16)
        r.tg_centerX.equal(0)
        r.tg_space = 4
        r.tg_gravity = .vert.center
        r.tg_top.equal(20)
        r.addSubview(leftTitleLabel)
        r.addSubview(leftTitleIcon)
        return r
    }()
    lazy var leftTitleLabel: UILabel = {
        let r = UILabel()
        r.tg_width.equal(.wrap)
        r.tg_height.equal(.wrap)
        r.font = .regularFont(14)
        r.textColor = .black666
        r.text = "可用"
        r.textAlignment = .center
        return r
    }()
    lazy var leftTitleIcon: UIImageView = {
        let r = UIImageView(image: UIImage(named: "mine_assets_explain_icon"))
        r.tg_width.equal(16)
        r.tg_height.equal(16)
        return r
    }()
    lazy var leftLabel: UILabel = {
        let r = UILabel()
        r.font = .regularFont(16)
        r.textColor = .black333
        r.textAlignment = .center
        return r
    }()
    lazy var lineView1: UIView = {
        let r = UIView()
        r.backgroundColor = .init(hexString: "#EAEAEA")
        return r
    }()
    lazy var rightView: UIView = {
        let r = UIView()
        r.addSubview(rightTitleLabel)
        r.addSubview(rightLabel)
        rightTitleLabel.snp_makeConstraints { make in
            make.left.equalTo(5)
            make.right.equalTo(-5)
            make.top.equalTo(20)
            make.height.equalTo(16)
        }
        rightLabel.snp_makeConstraints { make in
            make.left.right.equalTo(rightTitleLabel)
            make.height.equalTo(16)
            make.bottom.equalTo(-20)
        }
        return r
    }()
    
    lazy var rightTitleLabel: UILabel = {
        let r = UILabel()
        r.font = .regularFont(14)
        r.textColor = .black666
        r.textAlignment = .center
        r.text = "冻结"
        return r
    }()
    lazy var rightLabel: UILabel = {
        let r = UILabel()
        r.font = .regularFont(16)
        r.textColor = .black333
        r.textAlignment = .center
        return r
    }()
    
    
}
