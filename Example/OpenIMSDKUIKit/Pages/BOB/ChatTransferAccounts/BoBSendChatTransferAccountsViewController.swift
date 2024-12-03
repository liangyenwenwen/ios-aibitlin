//
//  BoBSendChatTransferAccountsViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/3.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import TangramKit
class BoBSendChatTransferAccountsViewController: BaseTitleController {
    var cionType = "C"
    var chooseCionTypeModel:CionTypeModel?
    var cionTypeArray:[CionTypeModel] = []
    override func initViews() {
        super.initViews()
        setBackGroundColor(.init(hexString: "#388CEF"))
        initScrollSafeArea()
        title = "转账"
        scrollViewContainer.tg_padding = UIEdgeInsets(top: PADDING_OUTER, left: PADDING_OUTER, bottom: PADDING_OUTER, right: PADDING_OUTER)
        scrollViewContainer.tg_space = 10
        superFooterContainerContainer.tg_bottom.equal(0)
        scrollViewContainer.addSubview(cionTypeView)
        scrollViewContainer.addSubview(bottomView)
        cionTypeView.snp_makeConstraints { make in
            make.top.equalTo(8)
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(106)
        }
        countView.snp_makeConstraints { make in
            make.left.right.equalTo(cionTypeView)
            make.top.equalTo(cionTypeView.snp_bottom).offset(12)
            make.height.equalTo(88)
        }
        bottomView.snp_makeConstraints { make in
            make.left.right.equalTo(cionTypeView)
            make.top.equalTo(countView.snp_bottom).offset(30)
            make.height.equalTo(102)
        }
    }
    func calculationMoney(){
//        self.countLabel.text = "0.00"
//        self.serviceChargeLabel.text = "手续费" + String(format: "%.2f",(chooseCionTypeModel?.zuiXiaoShouXuFei)!)  + (chooseCionTypeModel?.biZhong)!
//        if let doubleValue = Double(countTF.text ?? "0") {
//            if doubleValue > 0{
//                var count = 0.00
//                if (chooseCionTypeModel?.shouXuFei)!*doubleValue > (chooseCionTypeModel?.zuiXiaoShouXuFei)!{
//                    self.serviceChargeLabel.text = "手续费" + String(format: "%.2f",(chooseCionTypeModel?.shouXuFei)!*doubleValue)  + (chooseCionTypeModel?.biZhong)!
//                    count = doubleValue - (chooseCionTypeModel?.shouXuFei)!*doubleValue
//                }else{
//                    count = doubleValue - (chooseCionTypeModel?.zuiXiaoShouXuFei)!
//                }
//                if count > 0{
//                    self.countLabel.text = String(format: "%.2f",count)
//                }
//            }
//        }
    }
    lazy var cionTypeView: UIView = {
        let r = UIView()
        let v = UIView()
        v.backgroundColor = .white
        v.corner(8)
        v.addSubview(cionTypeImageView)
        v.addSubview(cionNameLabel)
        v.addSubview(walletType)
        let rightIcon = UIImageView(image: UIImage(named: "SuperChevronRight"))
        rightIcon.tintColor = .black80
        rightIcon.contentMode = .scaleAspectFit
        v.addSubview(rightIcon)
        r.addSubview(cionTypeTitleLabel)
        r.addSubview(v)
        r.addSubview(exchangeRateLabel)
        r.addSubview(totalMoneyLabel)
        cionTypeTitleLabel.snp_makeConstraints { make in
            make.left.top.right.equalTo(0)
            make.height.equalTo(38)
        }
        v.snp_makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(cionTypeTitleLabel.snp_bottom)
            make.height.equalTo(50)
        }
        cionTypeImageView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalTo(v)
            make.width.height.equalTo(26)
        }
        cionNameLabel.snp_makeConstraints { make in
            make.left.equalTo(cionTypeImageView.snp_right).offset(10)
            make.centerY.equalTo(cionTypeImageView.snp_centerY)
        }
        walletType.snp_makeConstraints { make in
            make.left.equalTo(cionNameLabel.snp_right).offset(7)
            make.centerY.equalTo(cionNameLabel)
            make.width.equalTo(62)
            make.height.equalTo(26)
        }
        rightIcon.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalTo(v)
            make.width.height.equalTo(15)
        }
        exchangeRateLabel.snp_makeConstraints { make in
            make.left.bottom.equalTo(0)
            make.width.equalTo(100)
            make.height.equalTo(18)
        }
        totalMoneyLabel.snp_makeConstraints { make in
            make.right.bottom.equalTo(0)
            make.left.equalTo(exchangeRateLabel.snp_right).offset(5)
            make.height.equalTo(18)
        }
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {  _ in
            self.view.endEditing(true)
            let chooseTypeView = BoBChooseCionTypeView()
            chooseTypeView.tg_width.equal(.fill)
            chooseTypeView.tg_height.equal(240)
            chooseTypeView.reloadListArray(array: self.cionTypeArray)
            chooseTypeView.chooseCionBlock = { [weak self] model,array in
                self?.chooseCionTypeModel = model
                self?.cionTypeArray = array
//                self?.refreshUI()
            }
            GKCover.cover(from: self.view.window, contentView: chooseTypeView, style: .translucent, showStyle: .bottom, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
        }
        r.addGestureRecognizer(tap)
       return r
    }()
    lazy var cionTypeTitleLabel: UILabel = {
        let r = UILabel()
        r.textColor = .black333
        r.font = .semiboldFont(16)
        r.text = "币种"
        return r
    }()
    lazy var cionTypeImageView: UIImageView = {
        let r = UIImageView(image: UIImage(named: "mine_home_cion_c_icon"))
        return r
    }()
    lazy var cionNameLabel: UILabel = {
        let r = UILabel()
        r.font = .mediumFont(16)
        r.text = cionType
        r.textColor = .black333
        return r
    }()
    lazy var walletType: UILabel = {
        let r = UILabel()
        r.textColor = .init(hexString: "#00AA3C")
        r.backgroundColor = .init(hexString: "#E5F6EB")
        r.corner(13)
        r.font = .regularFont(12)
        r.text = "T+0钱包"
        r.textAlignment = .center
        return r
    }()
    lazy var exchangeRateLabel: UILabel = {
        let r = UILabel()
        r.font = .regularFont(14)
        r.textColor = .black666
        return r
    }()
    lazy var totalMoneyLabel: UILabel = {
        let r = UILabel()
        r.font = .regularFont(14)
        r.textColor = .black666
        r.textAlignment = .right
        return r
    }()
    
    lazy var countView: UIView = {
        let r = UIView()
        let v = UILabel()
        v.textColor = .black333
        v.font = .semiboldFont(16)
        v.text = "转账数量"
        r.addSubview(v)
        v.snp_makeConstraints { make in
            make.left.top.right.equalTo(0)
            make.height.equalTo(38)
        }
        
        let bgView = UIView()
        bgView.backgroundColor = .white
        bgView.corner(8)
        r.addSubview(bgView)
        bgView.snp_makeConstraints { make in
            make.left.right.equalTo(r)
            make.bottom.equalTo(0)
            make.height.equalTo(50)
        }
        bgView.addSubview(countTF)
        countTF.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalTo(bgView)
            make.right.equalTo(-16)
        }
        return r
    }()
    lazy var countTF: QMUITextField = {
        let r = QMUITextField()
        r.font = .regularFont(16)
        r.tintColor = .black333
        r.keyboardType = .decimalPad
        r.setPlaceHolderTextColor(.black999)
        r.placeholder = "输入数量"
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
            self.calculationMoney()
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var choosePeopleView: UIView = {
        let r = UIView()
        let v = UILabel()
        v.textColor = .black333
        v.font = .semiboldFont(16)
        v.text = "转账给谁"
        r.addSubview(v)
        v.snp_makeConstraints { make in
            make.left.top.right.equalTo(0)
            make.height.equalTo(38)
        }
        
        let bgView = UIView()
        bgView.backgroundColor = .white
        bgView.corner(8)
        r.addSubview(bgView)
        bgView.snp_makeConstraints { make in
            make.left.right.equalTo(r)
            make.bottom.equalTo(0)
            make.height.equalTo(50)
        }
        bgView.addSubview(nameTF)
        let rightIcon = UIImageView(image: UIImage(named: "SuperChevronRight"))
        rightIcon.tintColor = .black80
        rightIcon.contentMode = .scaleAspectFit
        bgView.addSubview(rightIcon)
        rightIcon.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalTo(bgView)
            make.width.height.equalTo(15)
        }
        nameTF.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalTo(bgView)
            make.right.equalTo(rightIcon.snp_left).offset(-16)
        }
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {  _ in
            
        }.disposed(by: rx.disposeBag)
        bgView.addGestureRecognizer(tap)
        return r
    }()
    lazy var nameTF: QMUITextField = {
        let r = QMUITextField()
        r.font = .regularFont(16)
        r.tintColor = .black333
        r.setPlaceHolderTextColor(.black999)
        r.placeholder = "选择转账对象"
        r.isUserInteractionEnabled = false
        return r
    }()
    lazy var descView: UIView = {
        let r = UIView()
        let v = UILabel()
        v.textColor = .black333
        v.font = .semiboldFont(16)
        v.text = "转账说明"
        r.addSubview(v)
        v.snp_makeConstraints { make in
            make.left.top.right.equalTo(0)
            make.height.equalTo(38)
        }
        
        let bgView = UIView()
        bgView.backgroundColor = .white
        bgView.corner(8)
        r.addSubview(bgView)
        bgView.snp_makeConstraints { make in
            make.left.right.equalTo(r)
            make.bottom.equalTo(0)
            make.height.equalTo(50)
        }
        bgView.addSubview(descTF)
        let rightIcon = UIImageView(image: UIImage(named: "SuperChevronRight"))
        rightIcon.tintColor = .black80
        rightIcon.contentMode = .scaleAspectFit
        bgView.addSubview(rightIcon)
        rightIcon.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.centerY.equalTo(bgView)
            make.width.height.equalTo(15)
        }
        descTF.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalTo(bgView)
            make.right.equalTo(rightIcon.snp_left).offset(-16)
        }
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {  _ in
            
        }.disposed(by: rx.disposeBag)
        bgView.addGestureRecognizer(tap)
        return r
    }()
    lazy var descTF: QMUITextField = {
        let r = QMUITextField()
        r.font = .regularFont(16)
        r.tintColor = .black333
        r.setPlaceHolderTextColor(.black999)
        r.placeholder = "请输入转账说明"
        return r
    }()
    lazy var bottomView:UIView = {
        let r = UIView()
        r.addSubview(bottomView1)
        r.addSubview(totalLabel)
        r.addSubview(moneyLabel)
        totalLabel.snp_makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(bottomView1.snp_bottom).offset(9)
            make.height.equalTo(46)
        }
        moneyLabel.snp_makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(totalLabel.snp_bottom).offset(5)
            make.height.equalTo(16)
        }
        return r
    }()
    lazy var bottomView1: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(.wrap)
        r.tg_height.equal(26)
        r.tg_centerX.equal(0)
        r.tg_space = 9
        r.tg_gravity = .vert.center
        r.tg_top.equal(30)
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
    
}
