//
//  BoBChooseBillView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/11/30.
//  Copyright © 2024 rentsoft. All rights reserved.
//
import MMBAlertsPickers
import OUICore
import ProgressHUD
import RxCocoa
import RxSwift
import TangramKit
import UIKit
class BoBChooseBillView: TGLinearLayout {
    var chooseConditionBlock:((_ selectTypeIndex:Int,_ timeStart:String,_ timeEnd:String)->())!
    var titleArray = [String]()
    var chooseType:Int = 0
    var timeStart:String = ""
    var timeEnd:String = ""
    var selectBtn = QMUIButton()
    init(titles:[String],selectTypeIndex:Int,timeStartStr:String,timeEndStr:String) {
        super.init(frame: .zero, orientation: .vert)
        titleArray = titles
        timeStart = timeStartStr
        timeEnd = timeEndStr
        chooseType = selectTypeIndex
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
        addSubview(timeView)
        addSubview(cancleBtn)
        addSubview(sureBtn)
        titleLbl.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
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
            make.top.equalTo(titleLbl.snp_bottom).offset(30)
            make.height.equalTo(170)
        }
        timeView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(typeView.snp_bottom).offset(20)
            make.height.equalTo(70)
        }
        cancleBtn.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(timeView.snp_bottom).offset(23)
            make.height.equalTo(46)
            make.width.equalTo((kScreenWidth-32-18)/2)
        }
        sureBtn.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.top.width.height.equalTo(cancleBtn)
        }
    }
    func chooseTime(type:Int){
        JNDatePickerView.show(onWindowOfView: self) { (pickerView: JNDatePickerView) in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if type == 0{
                if self.timeEnd.isEmpty{
                    pickerView.datePicker.maximumDate = Date()
                }else{
                    if let date = dateFormatter.date(from: self.timeEnd) {
                        pickerView.datePicker.maximumDate = date
                    } else {
                        pickerView.datePicker.maximumDate = Date()
                    }
                }
                pickerView.datePicker.minimumDate = Date(timeIntervalSince1970: 0)
            }else{
                pickerView.datePicker.maximumDate = Date()
                if self.timeStart.isEmpty{
                    pickerView.datePicker.minimumDate = Date(timeIntervalSince1970: 0)
                }else{
                    if let date = dateFormatter.date(from: self.timeStart) {
                        pickerView.datePicker.minimumDate = date
                    } else {
                        pickerView.datePicker.minimumDate = Date(timeIntervalSince1970: 0)
                    }
                }
            }
        } confirmAction: { [weak self] (selectedDate: Date) in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: selectedDate)
            if type == 0{
                self?.timeStartLabel.text = dateString
                self?.timeStart = dateString
            }else{
                self?.timeEndLabel.text = dateString
                self?.timeEnd = dateString
            }
            
        }
    }
    lazy var titleLbl: UILabel = {
        let r = ViewFactoryUtil.customTilteLabelFill("筛选".localized(), font: 18, textColor: .black333)
        r.font = .mediumFont(18)
        r.textColor = .black333
        r.textAlignment = .center
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
        r.addSubview(typeTitleLbl)
        typeTitleLbl.snp_makeConstraints { make in
            make.top.left.right.equalTo(0)
        }
        let width = (kScreenWidth-32-16)/3
        for (index,item) in titleArray.enumerated() {
            let btn = QMUIButton()
            btn.setTitle(item, for: .normal)
            btn.titleLabel?.font = .mediumFont(16)
            if chooseType == index{
                btn.border(.primaryColor,borderWidth: 1,cornerRadius: 4)
                btn.setTitleColor(.white, for: .normal)
                btn.backgroundColor = .primaryColor
                selectBtn = btn
            }else{
                btn.border(.init(hexString: "#EAEAEA"),borderWidth: 1,cornerRadius: 4)
                btn.setTitleColor(.black333, for: .normal)
                btn.backgroundColor = .white
            }
            btn.rx.tap.subscribe(onNext: { [self] in
                if self.chooseType != index{
                    self.selectBtn.border(.init(hexString: "#EAEAEA"),borderWidth: 1,cornerRadius: 4)
                    self.selectBtn.setTitleColor(.black333, for: .normal)
                    self.selectBtn.backgroundColor = .white
                    btn.border(.primaryColor,borderWidth: 1,cornerRadius: 4)
                    btn.setTitleColor(.white, for: .normal)
                    btn.backgroundColor = .primaryColor
                        self.selectBtn = btn
                    self.chooseType = index
                }
            }).disposed(by: rx.disposeBag)
            r.addSubview(btn)
            btn.snp_makeConstraints { make in
                make.left.equalTo((Int(width)+8)*(index%3))
                make.top.equalTo(typeTitleLbl.snp_bottom).offset(12+(40+8)*(index/3))
                make.width.equalTo(width)
                make.height.equalTo(40)
            }
        }
        return r
    }()
    lazy var typeTitleLbl: UILabel = {
        let r = ViewFactoryUtil.customTilteLabelFill("类型".localized(), font: 18, textColor: .black333)
        r.font = .mediumFont(18)
        r.textColor = .black333
        return r
    }()
    lazy var timeView: UIView = {
        let r = UIView()
        r.addSubview(timeTitleLbl)
        timeTitleLbl.snp_makeConstraints { make in
            make.top.left.right.equalTo(0)
        }
        let v = ViewFactoryUtil.customTilteLabelFill("至".localized(), font: 18, textColor: .black333)
        v.font = .regularFont(16)
        v.textAlignment = .center
        v.textColor = .black
        r.addSubview(v)
        r.addSubview(timeStartView)
        r.addSubview(timeEndView)
        timeStartView.snp_makeConstraints { make in
            make.left.equalTo(0)
            make.bottom.equalTo(r)
            make.height.equalTo(40)
            make.width.equalTo((kScreenWidth-32-60)/2)
        }
        v.snp_makeConstraints { make in
            make.left.equalTo(timeStartView.snp_right)
            make.top.bottom.equalTo(timeStartView)
            make.width.equalTo(60)
        }
        timeEndView.snp_makeConstraints { make in
            make.right.equalTo(0)
            make.top.width.height.equalTo(timeStartView)
        }
        return r
    }()
    lazy var timeTitleLbl: UILabel = {
        let r = ViewFactoryUtil.customTilteLabelFill("日期".localized(), font: 18, textColor: .black333)
        r.font = .mediumFont(18)
        r.textColor = .black333
        return r
    }()
    lazy var timeStartView: UIView = {
        let r = UIView()
        r.border(.init(hexString: "#EAEAEA"),borderWidth: 1,cornerRadius: 4)
        let icon = UIImageView(image: UIImage(named: "mine_bill_date_icon"))
        r.addSubview(icon)
        r.addSubview(timeStartLabel)
        icon.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.width.height.equalTo(18)
            make.centerY.equalTo(r)
        }
        timeStartLabel.snp_makeConstraints { make in
            make.left.equalTo(icon.snp_right).offset(8)
            make.centerY.equalTo(icon)
            make.right.equalTo(-16)
        }
        
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {  _ in
            self.chooseTime(type: 0)
        }.disposed(by: rx.disposeBag)
        r.addGestureRecognizer(tap)
        return r
    }()
    lazy var timeStartLabel: UILabel = {
        let r = ViewFactoryUtil.customTilteLabelFill("".localized(), font: 18, textColor: .black333)
        r.font = .regularFont(16)
        r.text = timeStart
        r.textColor = .black
        return r
    }()
    lazy var timeEndView: UIView = {
        let r = UIView()
        r.border(.init(hexString: "#EAEAEA"),borderWidth: 1,cornerRadius: 4)
        let icon = UIImageView(image: UIImage(named: "mine_bill_date_icon"))
        r.addSubview(icon)
        r.addSubview(timeEndLabel)
        icon.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.width.height.equalTo(18)
            make.centerY.equalTo(r)
        }
        timeEndLabel.snp_makeConstraints { make in
            make.left.equalTo(icon.snp_right).offset(8)
            make.centerY.equalTo(icon)
            make.right.equalTo(-16)
        }
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {  _ in
            self.chooseTime(type: 1)
        }.disposed(by: rx.disposeBag)
        r.addGestureRecognizer(tap)
        return r
    }()
    lazy var timeEndLabel: UILabel = {
        let r = ViewFactoryUtil.customTilteLabelFill("".localized(), font: 18, textColor: .black333)
        r.font = .regularFont(16)
        r.text = timeEnd
        r.textColor = .black
        return r
    }()
    lazy var cancleBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("取消")
        r.setTitleColor(.black666, for: .normal)
        r.titleLabel?.font = .mediumFont(16)
        r.border(.init(hexString: "#EAEAEA"),borderWidth: 1,cornerRadius: 23)
        r.rx.tap.subscribe(onNext: { [self] in
            GKCover.hide()
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
            if chooseConditionBlock != nil{
                chooseConditionBlock(chooseType,timeStart,timeEnd)
            }
            GKCover.hide()
        }).disposed(by: rx.disposeBag)
        return r
    }()
}



