//
//  BoBSendRedPacketViewController.swift
//  Alamofire
//
//  Created by mac on 2024/12/3.
//

import Foundation
import TangramKit
import OUICore
import RxSwift
import RxCocoa
import RxGesture
import OUIIM
import IQKeyboardManagerSwift


class BoBSendRedPacketViewController: BaseTitleController {
    var cionType = "C"
    var receiveUserId = ""
    var groupId = ""
    var groupMemberCount:Int  = 0
    var sendRedPacketAction:((_ redPacketJson:String)->())!
    var chooseCionTypeModel:CionTypeModel?
    var cionTypeArray:[CionTypeModel] = []
    var sendRedPacketType:Int = 0 //0是私聊红包，1是群红包
    var redPacketType:Int = 0 //0是拼手气红包，1是普通红包，2是专属红包
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        IQKeyboardManager.shared.enable = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = false
    }
    override func initViews() {
        super.initViews()
        setBackGroundColor(.colorBackgroundAPP)
        initScrollSafeArea()
        title = "红包"
        chooseCionTypeModel = CionTypeModel(icon: "", currency: cionType, quota: 0.00, handlingCharge: 0.00, minimumCommission: 0.00, cionType:"0", money:0.00, type: 0, isSelect: true,exchangeRate:1.00)
        scrollViewContainer.tg_padding = UIEdgeInsets(top: 0, left: PADDING_OUTER, bottom: PADDING_OUTER, right: PADDING_OUTER)
        sendRedPacketType = groupId.isEmpty ? 0 : 1
//        scrollViewContainer.tg_space = 12
        superFooterContainerContainer.tg_bottom.equal(0)
        if sendRedPacketType == 0{
            //私聊红包
            scrollViewContainer.addSubview(cionTypeView)
            scrollViewContainer.addSubview(redPacketDescView)
            scrollViewContainer.addSubview(bottomView)
            scrollViewContainer.addSubview(sureBtn)
            cionTypeView.tg_top.equal(8)
        }else{
            //群红包
            scrollViewContainer.addSubview(redPacketTypeBtn)
            scrollViewContainer.addSubview(cionTypeView)
            scrollViewContainer.addSubview(redPacketCountView)
            scrollViewContainer.addSubview(redpacketTotalView)
            scrollViewContainer.addSubview(redPacketDescView)
            scrollViewContainer.addSubview(bottomView)
            scrollViewContainer.addSubview(sureBtn)
            redPacketTypeTitleLabel.text = "发出总数量"
        }
        
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {  _ in
            self.view.endEditing(true)
        }.disposed(by: rx.disposeBag)
        scrollViewContainer.addGestureRecognizer(tap)
        bindBtnData()
        loadData()
    }
    private func bindBtnData() {
        Observable.combineLatest(redPacketNumberTF.rx.text.orEmpty, redPacketTotalTF.rx.text.orEmpty) {
            if self.sendRedPacketType == 0{
                //私聊红包
                $0.count > 0 && $1.count >= 0
            }else{
                if self.redPacketType == 2{
                    $0.count > 0 && $1.count > 0
                }else{
                    $0.count > 0 && $1.count >= 0
                }
            }
            
        }
        .bind(to: sureBtn.rx.isEnabled)
        .disposed(by:rx.disposeBag)
    }
    func loadData(){
            BoBRedPacketModel.TransferMoneyInnerSHomeRequest(){data in
                IMController.shared.isSetPayPassWord = data.secure ?? false
                IMController.shared.certificationLevel = data.certificationLevel ?? 0
                for item in data.expenditureHomePagePOS{
                    let model1 = CionTypeModel(icon: item.icon, currency: item.currency, quota: item.quota, handlingCharge: 0.00, minimumCommission: 0.00, cionType: "0", money: item.t0, type: 0, isSelect: true,exchangeRate:item.exchangeRate)
                let model2 = CionTypeModel(icon: item.icon, currency: item.currency, quota: item.quota, handlingCharge: 0.00, minimumCommission: 0.00, cionType: "1", money: item.t1, type: 1, isSelect: false,exchangeRate:item.exchangeRate)
                self.cionTypeArray.append(model1)
                self.cionTypeArray.append(model2)
            }
            if self.cionTypeArray.count > 0{
                self.chooseCionTypeModel = self.cionTypeArray[0]
                self.refreshUI()
            }
        } completionHandler: {errCode,errMsg in
            if errCode == -1{
                SuperToast.show(title: errMsg)
            }else{
                SuperToast.show(title: String(errCode) + "：" + String(errCode).localized())
            }
        }
    }
    func refreshUI(){
        cionNameLabel.text = chooseCionTypeModel?.currency
        if chooseCionTypeModel?.type == 0{
            self.walletType.text = "T+0钱包"
            self.walletType.textColor = .init(hexString: "#00AA3C")
            self.walletType.backgroundColor = .init(hexString: "#E5F6EB")
        }else{
            self.walletType.text = "T+1钱包"
            self.walletType.textColor = .init(hexString: "#FFA756")
            self.walletType.backgroundColor = .init(hexString: "#FFF7E5")
        }
        self.exchangeRateLabel.text = "汇率: " + String(format: "%.2f",(chooseCionTypeModel?.exchangeRate)!)
        
        let str = "可用余额 " + String(format: "%.2f ",(chooseCionTypeModel?.money)!) + (chooseCionTypeModel?.currency)!
        let attributedString = NSMutableAttributedString(string: str)
        attributedString.addAttribute(.foregroundColor, value: UIColor.primaryColor, range: NSRange(location: 5, length: str.length-6))
        self.totalMoneyLabel.attributedText = attributedString
        self.cionImageView.sd_setImage(with: URL(string: chooseCionTypeModel?.icon))
        self.cionLabel.text = chooseCionTypeModel?.currency
        self.calculationMoney()
    }
    func calculationMoney(){
        self.totalLabel.text = "0.00"
        self.moneyLabel.text = "≈￥0.00"
        if sendRedPacketType == 0{
            //私聊红包
            if let doubleValue = Double(redPacketNumberTF.text ?? "0") {
                if doubleValue > 0{
                    self.totalLabel.text = redPacketNumberTF.text
                    self.moneyLabel.text = String(format: "≈￥%.2f",(chooseCionTypeModel?.exchangeRate)!*doubleValue)
                }
            }
        }else{
            //群聊红包
            if self.redPacketType == 0{
                //拼手气红包
                if let doubleValue = Double(redPacketNumberTF.text ?? "0") {
                    if doubleValue > 0{
                        self.totalLabel.text = redPacketNumberTF.text
                        self.moneyLabel.text = String(format: "≈￥%.2f",(chooseCionTypeModel?.exchangeRate)!*doubleValue)
                    }
                }
            }else if self.redPacketType == 1{
                //普通红包
                if let doubleValue = Double(redPacketNumberTF.text ?? "0") {
                    if doubleValue > 0{
                        self.totalLabel.text = String(format: "%.2f",doubleValue*(Double(redPacketTF.text ?? "1") ?? 1))
                        self.moneyLabel.text = String(format: "≈￥%.2f",(chooseCionTypeModel?.exchangeRate)!*doubleValue*(Double(redPacketTF.text ?? "1") ?? 1))
                    }
                }
            }else{
                //专属红包
                if let doubleValue = Double(redPacketNumberTF.text ?? "0") {
                    if doubleValue > 0{
                        self.totalLabel.text = redPacketNumberTF.text
                        self.moneyLabel.text = String(format: "≈￥%.2f",(chooseCionTypeModel?.exchangeRate)!*doubleValue)
                    }
                }
            }
        }
    }
    lazy var redPacketTypeBtn: UIButton = {
        let r = UIButton()
        r.tg_top.equal(8)
        r.tg_left.equal(0)
        r.tg_height.equal(38)
        r.tg_width.equal(kScreenWidth-32)
        r.setImage(UIImage(named: "mine_red_packet_choose_type_icon"), for: .normal)
        r.setTitle("拼手气红包", for: .normal)
        r.titleLabel?.font = .mediumFont(16)
        r.setTitleColor(.primaryColor, for: .normal)
        r.contentHorizontalAlignment = .left
        r.semanticContentAttribute = .forceRightToLeft
        // 间距可能需要根据图片和文字大小调整
        let spacing: CGFloat = 6.0

        r.titleEdgeInsets = UIEdgeInsets(top: 0, left: -(r.imageView?.frame.width ?? 0), bottom: 0, right: r.imageView?.frame.width ?? 0)
        r.imageEdgeInsets = UIEdgeInsets(top: 0, left:spacing + (r.titleLabel?.frame.width ?? 0), bottom: 0, right: -(r.titleLabel?.frame.width ?? 0))
        r.rx.tap.subscribe(onNext: { [self] in
            self.view.endEditing(true)
            let redPacketTypeView = BoBRedPacketTypeView()
            redPacketTypeView.tg_width.equal(.fill)
            redPacketTypeView.tg_height.equal(245)
            redPacketTypeView.chooseRedPacketTypeBlock = { [weak self] typeTitle,typeIndex in
                if self!.redPacketType == typeIndex{
                    return
                }else{
                    self!.redPacketTypeBtn.setTitle(typeTitle, for: .normal)
                    self!.redPacketType = typeIndex
                    if typeIndex == 0{
                        //拼手气红包
                        self!.redPacketTypeTitleLabel.text = "发出总数量"
                        self!.redPacketNumberTF.text = ""
                        self!.redPacketCountView.show()
                        self!.redpacketTotalView.hide()
                        self!.redPacketTF.text = "1"
                        self!.redPacketTotalTF.text = ""
                    }else if typeIndex == 1{
                        //普通红包
                        self!.redPacketTypeTitleLabel.text = "单个发出数量"
                        self!.redPacketNumberTF.text = ""
                        self!.redPacketCountView.show()
                        self!.redpacketTotalView.hide()
                        self!.redPacketTF.text = "1"
                        self!.redPacketTotalTF.text = ""
                    }else{
                        //专属红包
                        self!.redPacketTypeTitleLabel.text = "发出数量"
                        self!.redPacketNumberTF.text = ""
                        self!.redPacketCountView.hide()
                        self!.redpacketTotalView.show()
                        self!.redPacketNumberTF.text = ""
                        self!.redPacketTotalTF.text = ""
                    }
                    self!.totalLabel.text = "0.00"
                    self!.moneyLabel.text = "≈￥0.00"
                }
            }
            GKCover.cover(from: self.view.window, contentView: redPacketTypeView, style: .translucent, showStyle: .bottom, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
        }).disposed(by: rx.disposeBag)
        return r
    }()
    
    lazy var cionTypeView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_top.equal(0)
        r.tg_left.equal(0)
        r.tg_height.equal(118)
        r.tg_width.equal(kScreenWidth-32)
        r.addSubview(redPacketTypeTitleLabel)
        let bgView = UIView()
        bgView.tg_top.equal(0)
        bgView.tg_left.equal(0)
        bgView.tg_width.equal(kScreenWidth-32)
        bgView.tg_height.equal(50)
        r.addSubview(bgView)
        let v = TGLinearLayout(.horz)
        v.backgroundColor = .white
        v.corner(8)
        bgView.addSubview(redPacketCountNmberView)
        bgView.addSubview(v)
        redPacketCountNmberView.snp_makeConstraints { make in
            make.top.equalTo(redPacketTypeTitleLabel.snp_bottom)
            make.left.equalTo(0)
            make.right.equalTo(v.snp_left).offset(-10)
            make.height.equalTo(50)
        }
        v.snp_makeConstraints { make in
            make.right.equalTo(0)
            make.top.bottom.equalTo(redPacketCountNmberView)
            make.width.equalTo(128)
        }
        v.addSubview(cionNameLabel)
        v.addSubview(walletType)
        let rightIcon = UIImageView(image: UIImage(named: "SuperChevronRight"))
        rightIcon.tintColor = .black80
        rightIcon.contentMode = .scaleAspectFit
        v.addSubview(rightIcon)
        r.addSubview(exchangeRateLabel)
        r.addSubview(totalMoneyLabel)
        rightIcon.snp_makeConstraints { make in
            make.centerY.equalTo(v)
            make.right.equalTo(-16)
            make.width.height.equalTo(15)
        }
        cionNameLabel.snp_makeConstraints { make in
            make.left.equalTo(10)
            make.centerY.equalTo(v)
        }
        walletType.snp_makeConstraints { make in
            make.left.equalTo(cionNameLabel.snp_right).offset(7)
            make.centerY.equalTo(cionNameLabel)
            make.width.equalTo(62)
            make.height.equalTo(26)
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
                self?.refreshUI()
            }
            GKCover.cover(from: self.view.window, contentView: chooseTypeView, style: .translucent, showStyle: .bottom, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
        }.disposed(by: rx.disposeBag)
        r.addGestureRecognizer(tap)
       return r
    }()
    lazy var redPacketTypeTitleLabel: UILabel = {
        let r = UILabel()
        r.tg_width.equal(kScreenWidth-32)
        r.tg_height.equal(38)
        r.tg_top.equal(0)
        r.tg_left.equal(0)
        r.textColor = .black333
        r.font = .semiboldFont(16)
        r.text = "发出数量"
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
        r.text = "汇率: 0.00"

        return r
    }()
    lazy var totalMoneyLabel: UILabel = {
        let r = UILabel()
        r.font = .regularFont(14)
        r.textColor = .black666
        r.textAlignment = .right
        let str = "可用余额 0.00 " + cionType
        let attributedString = NSMutableAttributedString(string: str)
        attributedString.addAttribute(.foregroundColor, value: UIColor.primaryColor, range: NSRange(location: 5, length: str.length-6))
        r.attributedText = attributedString
        return r
    }()
    
    lazy var redPacketCountView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_top.equal(12)
        r.tg_left.equal(0)
        r.tg_height.equal(88)
        r.tg_width.equal(kScreenWidth-32)
        let v = UILabel()
        v.tg_width.equal(kScreenWidth-32)
        v.tg_height.equal(38)
        v.tg_top.equal(0)
        v.tg_left.equal(0)
        v.textColor = .black333
        v.font = .semiboldFont(16)
        v.text = "红包个数"
        r.addSubview(v)
        let bgView = TGLinearLayout(.horz)
        bgView.tg_top.equal(0)
        bgView.tg_left.equal(0)
        bgView.tg_height.equal(50)
        bgView.tg_width.equal(kScreenWidth-32)
        bgView.tg_gravity = .horz.between
        bgView.backgroundColor = .white
        bgView.corner(8)
        r.addSubview(bgView)
        bgView.addSubview(reduceBtn)
        bgView.addSubview(redPacketTF)
        bgView.addSubview(addBtn)
        return r
    }()
    lazy var reduceBtn: QMUIButton = {
        let r =  ViewFactoryUtil.imageBtn(UIImage(named: "mine_red_packet_count_reduce_icon")!, 34)
        r.tg_left.equal(7)
        r.tg_width.equal(34)
        r.tg_height.equal(34)
        r.tg_centerY.equal(0)
        r.rx.tap.subscribe(onNext: { [self] in
            if redPacketTF.text == "1"{
                return
            }
            var count = Int(redPacketTF.text ?? "1")
            redPacketTF.text = String(format: "%d",(count ?? 1) - 1)
            self.calculationMoney()
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var addBtn: QMUIButton = {
        let r =  ViewFactoryUtil.imageBtn(UIImage(named: "mine_red_packet_count_add_icon")!, 34)
        r.tg_right.equal(7)
        r.tg_width.equal(34)
        r.tg_height.equal(34)
        r.tg_centerY.equal(0)
        r.rx.tap.subscribe(onNext: { [self] in
            var count = Int(redPacketTF.text ?? "1")
            if groupMemberCount <=  (count ?? 1){
                redPacketTF.text = String(format: "%d",groupMemberCount)
                SuperToast.show(title: "红包个数不可超过当前群聊人数")
            }else{
                redPacketTF.text = String(format: "%d",(count ?? 1) + 1)
            }
            self.calculationMoney()
        }).disposed(by: rx.disposeBag)
        return r
    }()
    
    lazy var redPacketTF: QMUITextField = {
        let r = QMUITextField()
        r.tg_height.equal(50)
        r.tg_width.equal(kScreenWidth-32-82-30)
        r.font = .regularFont(16)
        r.tintColor = .black333
        r.textAlignment = .center
        r.keyboardType = .asciiCapableNumberPad
        r.setPlaceHolderTextColor(.black999)
        r.placeholder = "输入个数"
        r.text = "1"
        r.rx.controlEvent(.editingDidEnd).subscribe(onNext: { [unowned self] in
            var count = Int(r.text ?? "1")
            if count == 0{
                r.text = "1"
            }else{
                if groupMemberCount <=  (count ?? 1){
                    r.text = String(format: "%d",groupMemberCount)
                    SuperToast.show(title: "红包个数不可超过当前群聊人数")
                }else{
                    r.text = String(format: "%d",count ?? 1)
                }
            }
            self.calculationMoney()
        }).disposed(by: rx.disposeBag)
//        r.rx.controlEvent(.editingChanged).subscribe(onNext: { [unowned self] in
//            var count = Int(r.text ?? "1")
//            if count == 0{
//                r.text = "1"
//            }else{
//                r.text = String(format: "%d",count ?? 1)
//            }
//            self.calculationMoney()
//        }).disposed(by: rx.disposeBag)
        return r
    }()
    
    lazy var redPacketCountNmberView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.backgroundColor = .white
        r.corner(8)
        r.addSubview(redPacketNumberTF)
        redPacketNumberTF.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.bottom.equalTo(r)
        }
        return r
    }()
    lazy var redPacketNumberTF: QMUITextField = {
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
    
    lazy var redpacketTotalView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.hide()
        r.tg_top.equal(12)
        r.tg_left.equal(0)
        r.tg_height.equal(88)
        r.tg_width.equal(kScreenWidth-32)
        r.addSubview(redpacketTotalLabel)
        let bgView = TGLinearLayout(.horz)
        bgView.tg_top.equal(0)
        bgView.tg_left.equal(0)
        bgView.tg_height.equal(50)
        bgView.tg_width.equal(kScreenWidth-32)
        bgView.tg_gravity = .horz.between
        bgView.backgroundColor = .white
        bgView.corner(8)
        r.addSubview(bgView)
        bgView.addSubview(redPacketTotalTF)
        bgView.addSubview(redPacketNextIcon)
        r.addSubview(choosePeopleBtn)
        choosePeopleBtn.snp_makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(38)
            make.height.equalTo(50)
        }
        return r
    }()
    lazy var choosePeopleBtn:UIButton = {
        let r = UIButton()
        r.backgroundColor = .clear
        r.rx.tap.subscribe(onNext: {
            let vc = MentionViewController(types: [.members], sourceID: self.groupId, allowsMultipleSelection: false)
            vc.selectedContact(hasSelected: []) { [self] _, infos in
                if let firstObj = infos.first{
                    self.receiveUserId = firstObj.ID ?? ""
                    self.redPacketTotalTF.text = firstObj.name
                }
                dismiss(animated: true)
            }
            let nav = UINavigationController(rootViewController: vc)
            self.present(nav, animated: true)
        })
        .disposed(by: rx.disposeBag)
        return r
    }()
    lazy var redpacketTotalLabel: UILabel = {
        let r = UILabel()
        r.tg_width.equal(kScreenWidth-32)
        r.tg_height.equal(38)
        r.tg_top.equal(0)
        r.tg_left.equal(0)
        r.textColor = .black333
        r.font = .semiboldFont(16)
        r.text = "发给谁"
        return r
    }()
    
    lazy var redPacketTotalTF: QMUITextField = {
        let r = QMUITextField()
        r.tg_height.equal(50)
        r.tg_top.equal(0)
        r.tg_left.equal(16)
        r.tg_width.equal(240)
        r.font = .regularFont(16)
        r.tintColor = .black333
        r.setPlaceHolderTextColor(.black999)
        r.placeholder = "选择发红包对象"
        r.isUserInteractionEnabled = false
        return r
    }()
    lazy var redPacketNextIcon: UIImageView = {
        let r = UIImageView(image: UIImage(named: "SuperChevronRight"))
        r.tg_right.equal(16)
        r.tg_centerY.equal(0)
        r.tg_width.equal(15)
        r.tg_height.equal(15)
        r.tintColor = .black80
        r.contentMode = .scaleAspectFit
        return r
    }()
    lazy var redPacketDescView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_top.equal(12)
        r.tg_left.equal(0)
        r.tg_height.equal(150)
        r.tg_width.equal(kScreenWidth-32)
        let v = UILabel()
        v.tg_width.equal(kScreenWidth-32)
        v.tg_height.equal(38)
        v.tg_top.equal(0)
        v.tg_left.equal(0)
        v.textColor = .black333
        v.font = .semiboldFont(16)
        v.text = "红包封面和说明"
        r.addSubview(v)
        let bgView1 = TGLinearLayout(.horz)
        bgView1.tg_top.equal(0)
        bgView1.tg_left.equal(0)
        bgView1.tg_height.equal(50)
        bgView1.tg_width.equal(kScreenWidth-32)
        bgView1.tg_gravity = .horz.between
        bgView1.backgroundColor = .white
        bgView1.corner(8)
        r.addSubview(bgView1)
        bgView1.addSubview(redPacketCoverLabel)
        let rightIcon = UIImageView(image: UIImage(named: "SuperChevronRight"))
        rightIcon.tg_right.equal(16)
        rightIcon.tg_centerY.equal(0)
        rightIcon.tg_width.equal(15)
        rightIcon.tg_height.equal(15)
        rightIcon.tintColor = .black80
        rightIcon.contentMode = .scaleAspectFit
        bgView1.addSubview(rightIcon)
//        let tap = UITapGestureRecognizer()
//        tap.rx.event.subscribe {  _ in
//    
//        }.disposed(by: rx.disposeBag)
//        bgView1.addGestureRecognizer(tap)
        
        let bgView2 = TGLinearLayout(.horz)
        bgView2.tg_top.equal(12)
        bgView2.tg_left.equal(0)
        bgView2.tg_height.equal(50)
        bgView2.tg_width.equal(kScreenWidth-32)
        bgView2.backgroundColor = .white
        bgView2.corner(8)
        r.addSubview(bgView2)
        bgView2.addSubview(descTF)
        return r
    }()
    lazy var redPacketCoverLabel: UILabel = {
        let r = UILabel()
        r.tg_width.equal(kScreenWidth-32-32-15-15)
        r.tg_height.equal(38)
        r.tg_centerY.equal(0)
        r.tg_left.equal(16)
        r.textColor = .black999
        r.font = .regularFont(16)
        r.text = "默认"
        return r
    }()
    
    lazy var descTF: QMUITextField = {
        let r = QMUITextField()
        r.tg_top.equal(0)
        r.tg_left.equal(16)
        r.tg_height.equal(50)
        r.tg_width.equal(kScreenWidth-32-32)
        r.font = .regularFont(16)
        r.tintColor = .black333
        r.maximumTextLength = 20
        r.setPlaceHolderTextColor(.black999)
        r.placeholder = "恭喜发财，大吉大利"
        return r
    }()
    lazy var bottomView:TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_top.equal(30)
        r.tg_left.equal(0)
        r.tg_height.equal(102)
        r.tg_width.equal(kScreenWidth-32)
        r.addSubview(bottomView1)
        r.addSubview(totalLabel)
        r.addSubview(moneyLabel)
        return r
    }()
    lazy var bottomView1: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(.wrap)
        r.tg_height.equal(26)
        r.tg_centerX.equal(0)
        r.tg_space = 9
        r.tg_gravity = .vert.center
        r.tg_top.equal(0)
        r.addSubview(cionImageView)
        r.addSubview(cionLabel)
        return r
    }()
    lazy var cionImageView: UIImageView = {
        let r = UIImageView(image: UIImage(named: "mine_home_cion_c_icon"))
        r.tg_width.equal(26)
        r.tg_height.equal(26)
        return r
    }()
    lazy var cionLabel: UILabel = {
        let r = UILabel()
        r.tg_width.equal(.wrap)
        r.tg_height.equal(.wrap)
        r.textColor = .black333
        r.text = cionType
        r.font = .mediumFont(16)
        return r
    }()
    lazy var totalLabel: UILabel = {
        let r = UILabel()
        r.tg_top.equal(9)
        r.tg_height.equal(46)
        r.tg_width.equal(kScreenWidth-32)
        r.tg_centerX.equal(0)
        r.textAlignment = .center
        r.textColor = .black333
        r.font = .regularFont(46)
        r.text = "0.00"
        return r
    }()
    lazy var moneyLabel: UILabel = {
        let r = UILabel()
        r.tg_top.equal(5)
        r.tg_height.equal(16)
        r.tg_width.equal(kScreenWidth-32)
        r.tg_centerX.equal(0)
        r.textAlignment = .center
        r.textColor = .primaryColor
        r.font = .regularFont(16)
        r.text = "≈￥0.00"
        return r
    }()
    lazy var sureBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("塞钱进红包".localized())
        r.tg_width.equal(kScreenWidth-32)
        r.tg_height.equal(56)
        r.tg_top.equal(30)
        r.tg_centerX.equal(0)
        r.setTitleColor(.white, for: .normal)
        r.corner(28)
        r.titleLabel?.font = .semiboldFont(16)
        r.backgroundColor = .init(hexString: "#F25151")
        r.rx.tap.subscribe(onNext: { [self] in
            
            if IMController.shared.certificationLevel == 0 {
                let alert = UIAlertController(title: "提示", message: "请先进行实名认证".innerLocalized(), preferredStyle: .alert)
                // 创建UIAlertAction，用于处理用户的选择
                let cancleAction = UIAlertAction(title: "取消", style: .default) { _ in
                }
                let okAction = UIAlertAction(title: "去认证", style: .default) { _ in
                    let vc =  BoBRealNameMainViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                // 将action添加到alertController上
                alert.addAction(cancleAction)
                alert.addAction(okAction)
                // 弹出alert
                self.present(alert, animated: true, completion: nil)
            }else{
                if IMController.shared.isSetPayPassWord {
                    if self.redPacketType == 0{
                        if let totalMoney = Double(redPacketNumberTF.text ?? "0") {
                           if let number = Double(self.redPacketTF.text ?? "1"){
                               if totalMoney < number*0.01{
                                   SuperToast.show(title: "红包总数量至少" + String(format: "%.2f", number*0.01))
                                  return
                               }
                            }
                            
                        }
                    }
                    
                    let passWordView = BoBPayPassWordView()
                    passWordView.tg_width.equal(.fill)
                    passWordView.tg_height.equal(210)
                    passWordView.payBtnClickBlock = { [weak self] passWord in
                        var type = 0
                        var param : [String: Any]
                        var instructions = "恭喜发财，大吉大利"
                        if self?.descTF.text?.isEmpty == false{
                            instructions = self?.descTF.text ?? ""
                        }
                        let timestamp = String(Int(Date().timeIntervalSince1970 * 1000))
                        var pwd = (IMController.shared.payPassWordSonKey + passWord).md5
                        if self?.sendRedPacketType == 0{
                            //私聊红包
                            type = 0
                            let amount = self?.redPacketNumberTF.text ?? "0.00"
                            let funderWallet = self?.chooseCionTypeModel?.cionType ?? ""
                            let receiverId = self?.receiveUserId ?? ""
                            let currency = self?.chooseCionTypeModel?.currency ?? ""
                            
                            let sign = (amount + funderWallet + instructions + "1" + receiverId + currency + timestamp + pwd).md5
                            param = ["amount":amount,"funderWallet":funderWallet,"instructions":instructions,"redEnvelopeCover":"1","receiverId":receiverId,"currency":currency,"timestamp":timestamp,"sign":sign]
                        }else{
                            if self?.redPacketType == 0{
                                //群拼手气红包
                                type = 1
                                let number = self?.redPacketTF.text ?? "1"
                                let totalQuantity = self?.redPacketNumberTF.text ?? "0.00"
                                let funderWallet = self?.chooseCionTypeModel?.cionType ?? ""
                                let groupId = self?.groupId ?? ""
                                let currency = self?.chooseCionTypeModel?.currency ?? ""
                                let sign = (number + totalQuantity + instructions + "1" + funderWallet + currency + groupId + timestamp + pwd).md5
                                param = ["number":number,"totalQuantity":totalQuantity,"instructions":instructions,"redEnvelopeCover":"1","funderWallet":funderWallet,"currency":currency,"groupId":groupId,"timestamp":timestamp,"sign":sign]
                            }else if self?.redPacketType == 1{
                                //群普通红包
                                type = 2
                                let number = self?.redPacketTF.text ?? "1"
                                let individualQuantity = self?.redPacketNumberTF.text ?? "0.00"
                                let funderWallet = self?.chooseCionTypeModel?.cionType ?? ""
                                let currency = self?.chooseCionTypeModel?.currency ?? ""
                                let groupId = self?.groupId ?? ""
                                let sign = (number + individualQuantity + instructions + "1" + funderWallet + currency + groupId + timestamp + pwd).md5
                                param = ["number":number,"individualQuantity":individualQuantity,"instructions":instructions,"redEnvelopeCover":"1","funderWallet":funderWallet,"currency":currency,"groupId":groupId,"timestamp":timestamp,"sign":sign]
                            }else{
                                //群专属红包
                                type = 3
                                
                                let amount = self?.redPacketNumberTF.text ?? "0.00"
                                let funderWallet = self?.chooseCionTypeModel?.cionType ?? ""
                                let receiverId = self?.receiveUserId ?? ""
                                let currency = self?.chooseCionTypeModel?.currency ?? ""
                                
                                let sign = (amount + funderWallet + instructions + "1" + receiverId + currency + timestamp + pwd).md5
                                param = ["amount":amount,"funderWallet":funderWallet,"instructions":instructions,"redEnvelopeCover":"1","receiverId":receiverId,"currency":currency,"timestamp":timestamp,"sign":sign]
                            }
                        }
                        self?.sendRedPacket(type: type, param: param)
                    }

                    GKCover.cover(from: self.view.window, contentView: passWordView, style: .translucent, showStyle: .center, showAnimStyle: .bottom, hideAnimStyle: .bottom, notClick: false)
                    
                }else{
                    let alert = UIAlertController(title: "提示", message: "为了您的财产安全，请设置安全密码".innerLocalized(), preferredStyle: .alert)
                    // 创建UIAlertAction，用于处理用户的选择
                    let cancleAction = UIAlertAction(title: "取消", style: .default) { _ in
                    }
                    let okAction = UIAlertAction(title: "去设置", style: .default) { _ in
                        let vc = BoBChangePayPassWordViewController()
                        vc.passWordType = 0
                        self.navigationController?.pushViewController(vc,animated: true)
                    }
                    // 将action添加到alertController上
                    alert.addAction(cancleAction)
                    alert.addAction(okAction)
                    // 弹出alert
                    self.present(alert, animated: true, completion: nil)
                }
                
            }
        }).disposed(by: rx.disposeBag)
        return r
    }()
    
    func sendRedPacket(type:Int,param:[String : Any]){
        BoBRedPacketModel.SendRedPacketRequest(type:type,param:param){[weak self] redPacketData in
            SuperToast.show(title:"发送成功")
            if self?.sendRedPacketAction != nil{
                let sendUserId = redPacketData.funderId ?? ""
                let sendUserFaceURL = redPacketData.funderImg ?? ""
                let sendUserName = redPacketData.funderNickName ?? ""
                let receiverId = redPacketData.receiverId ?? ""
                let receiverName = redPacketData.receiverNickName ?? ""
                let code = redPacketData.code ?? ""
                let redPacketType = redPacketData.redPacketType ?? 0
                let instructions = redPacketData.instructions ?? "恭喜发财，大吉大利"

                let param = ["sendUserId": sendUserId,
                              "sendUserFaceURL":sendUserFaceURL ,
                              "sendUserName":sendUserName ,
                              "receiverId":receiverId,
                              "receiverName":receiverName,
                              "code":code,
                              "redPacketType":redPacketType,
                              "instructions":instructions,
                              "groupId": self?.groupId ?? ""
                              ]
                if let jsonData = try? JSONSerialization.data(withJSONObject: param, options: []) {
                    // 尝试将Data转换成字符串
                    if let jsonString = String(data: jsonData, encoding: .utf8) {
                        self?.sendRedPacketAction(jsonString)
                    }
                }
            }

            self?.navigationController?.popViewController(animated: true)
        }completionHandler:{errCode,errMsg in
            if errCode == -1{
                SuperToast.show(title: errMsg)
            }else{
                SuperToast.show(title: String(errCode) + "：" + String(errCode).localized())
            }
        }
    }
    
}
