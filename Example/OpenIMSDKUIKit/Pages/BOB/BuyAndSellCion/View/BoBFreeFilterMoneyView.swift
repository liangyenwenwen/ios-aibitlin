//
//  BoBFreeFilterMoneyView.swift
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
class BoBFreeFilterMoneyView: TGLinearLayout {
    var chooseMoneyBlock:((_ chooseMoney:String)->())!
    var titleArray = [String]()
    var chooseMoney:String?
    var selectBtn = QMUIButton()
    init(titles:[String],defaultMoney:String) {
        super.init(frame: .zero, orientation: .vert)
        titleArray = titles
        chooseMoney = defaultMoney
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
        addSubview(countView)
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
        countView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(48)
            make.top.equalTo(titleLbl.snp_bottom).offset(18)
        }
        typeView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(countView.snp_bottom).offset(16)
            make.height.equalTo(136)
        }
        cancleBtn.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(typeView.snp_bottom).offset(18)
            make.height.equalTo(46)
            make.width.equalTo((kScreenWidth-32-18)/2)
        }
        sureBtn.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.top.width.height.equalTo(cancleBtn)
        }
    }
    lazy var titleLbl: UILabel = {
        let r = ViewFactoryUtil.customTilteLabelFill("确认购买", font: 18, textColor: .black333)
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
    lazy var countView: UIView = {
        let r = UIView()
        r.backgroundColor = .init(hexString: "#F5F5F5")
        r.corner(8)
        r.addSubview(countTF)
        r.addSubview(unitLabel)
        countTF.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(unitLabel.snp_left).offset(-15)
            make.centerY.equalTo(r)
        }
        unitLabel.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalTo(r)
            make.width.equalTo(40)
        }
        return r
    }()
    lazy var countTF: QMUITextField = {
        let r = QMUITextField()
        r.tg_height.equal(50)
        r.tg_top.equal(0)
        r.tg_left.equal(16)
        r.tg_width.equal(240)
        r.font = .regularFont(16)
        r.tintColor = .black333
        r.keyboardType = .decimalPad
        r.setPlaceHolderTextColor(.black999)
        r.placeholder = "请输入金额"
        r.text = chooseMoney
        r.rx.controlEvent(.editingChanged).subscribe(onNext: { [unowned self] in
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
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var unitLabel: UILabel = {
        let r = UILabel()
        r.text = "CNY"
        r.textColor = .black666
        r.font = .semiboldFont(16)
        r.textAlignment = .right
        return r
    }()
    lazy var typeView: UIView = {
        let r = UIView()
        let width = (kScreenWidth-32-24)/4
        for (index,item) in titleArray.enumerated() {
            let btn = QMUIButton()
            btn.setTitle("¥" + item, for: .normal)
            btn.titleLabel?.font = .semiboldFont(16)
            btn.border(.init(hexString: "#EAEAEA"),borderWidth: 1,cornerRadius: 6)
            btn.setTitleColor(.black666, for: .normal)
            btn.backgroundColor = .white
            btn.rx.tap.subscribe(onNext: { [self] in
                if self.selectBtn != btn{
                    if self.selectBtn != nil{
                        self.selectBtn.border(.init(hexString: "#EAEAEA"),borderWidth: 1,cornerRadius: 6)
                        self.selectBtn.setTitleColor(.black666, for: .normal)
                        self.selectBtn.backgroundColor = .white
                    }
                    btn.border(.primaryColor,borderWidth: 1,cornerRadius: 6)
                    btn.setTitleColor(.primaryColor, for: .normal)
                    btn.backgroundColor = .init(hexString: "#F3F8FF")
                    self.selectBtn = btn
                    self.chooseMoney = item
                    self.countTF.text = item
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
    lazy var cancleBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("重置")
        r.setTitleColor(.black666, for: .normal)
        r.titleLabel?.font = .mediumFont(16)
        r.border(.init(hexString: "#EAEAEA"),borderWidth: 1,cornerRadius: 23)
        r.rx.tap.subscribe(onNext: { [self] in
            if self.selectBtn != nil{
                self.selectBtn.border(.init(hexString: "#EAEAEA"),borderWidth: 1,cornerRadius: 6)
                self.selectBtn.setTitleColor(.black666, for: .normal)
                self.selectBtn.backgroundColor = .white
            }
            self.countTF.text = ""
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var sureBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("确认")
        r.setTitleColor(.white, for: .normal)
        r.titleLabel?.font = .mediumFont(16)
        r.backgroundColor = .primaryColor
        r.corner(23)
        r.rx.tap.subscribe(onNext: { [self] in
            if self.chooseMoneyBlock != nil{
                self.chooseMoneyBlock(self.countTF.text ?? "")
            }
            GKCover.hide()
        }).disposed(by: rx.disposeBag)
        return r
    }()
}
