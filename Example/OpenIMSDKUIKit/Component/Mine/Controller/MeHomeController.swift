//
//  MeHomeController.swift
//  MyCloudMusic
//
//  Created by mac on 2024/4/29.
//

import OUICore
import OUIIM
import TangramKit
import UIKit
import RxCocoa
import NSObject_Rx

#if ENABLE_MOMENTS
import OUIMoments
#endif

class MeHomeController: BaseLogicController {
    private let _viewModel = MineViewModel()
    var mineWalletData:MineWalletMoneyData?
    var vipTitle = UILabel()
    var userShowId: String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        _viewModel.queryUserInfo()
        loadUserWallet()
        updatelanguage()
        
    }
    
    override func initViews() {
        super.initViews()
        initLinearLayoutSafeArea()
        container.tg_padding = UIEdgeInsets(top: PADDING_OUTER, left: 20, bottom: PADDING_OUTER, right: 0)
        container.tg_space = 12
        addTopUserMessage()
        bindData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    func loadUserWallet(){
        guard let userID = AccountViewModel.userID else { return }
        
        AccountViewModel.queryUserWalletInfo(userId: userID,
                                             valueHandler: { [weak self] (data :MineWalletMoneyData) in
            self?.mineWalletData = data
            self?.updateMineWalletView()
            self?.walletView.stopRote()
        }, completionHandler: {(errCode, errMsg) in
            self.walletView.stopRote()
        })
    }
    override func bindData() {
        
        _viewModel.currentUserRelay.subscribe(onNext: { [weak self] (user: QueryUserInfo?) in
            guard let self, user != nil else { return }
            
            updateHeaderView()
            
        }).disposed(by: rx.disposeBag)
    }

    func updatelanguage() {
//
//        let  codeTitle = sectionCodeView.viewWithTag(20001) as! UILabel
//        codeTitle.text = "我的二维码".localized()
//
//        let  monentsTitle = sectionMomentsView.viewWithTag(20001) as! UILabel
//        monentsTitle.text = "我的动态".localized()
//
//        let  myBlogTitle = sectionMyBlogView.viewWithTag(20001) as! UILabel
//        myBlogTitle.text = "我的博客".localized()
//
//        let  starBlogTitle = sectionStarBlogView.viewWithTag(20001) as! UILabel
//        starBlogTitle.text = "我收藏的博客".localized()
        
    }
    
    func updateHeaderView() {
        let user = _viewModel.currentUserRelay.value
        let userState = SuperStringUtil.getUserState(showname: user?.nickname ?? "")
        
        avatarImageView.setAvatar(url: user?.faceURL, text: userState.n)
        username.text = userState.n
        userShowId = user?.chatID ?? (user?.userID ?? "")
        idLabel.text = "ID: " + userShowId
    }
    func updateMineWalletView(){
        realNameStatusView.show()
        if mineWalletData?.certificationLevel == 0 {
            //未实名认证
            realNameStatusView.backgroundColor = .init(hexString: "#FFA756")
            realNameStatusIcon.image = UIImage(named: "real_name_unAuthentication_icon")
            realNameStatusLabel.text = "未认证"
        } else if mineWalletData?.certificationLevel == 1{
            //初级实名认证
            realNameStatusView.backgroundColor = .init(hexString: "#3ACC9B")
            realNameStatusIcon.image = UIImage(named: "real_name_authentication_icon")
            realNameStatusLabel.text = "初级认证"

        }else{
            //高级实名认证
            realNameStatusView.backgroundColor = .init(hexString: "#1E85FE")
            realNameStatusIcon.image = UIImage(named: "real_name_authentication_icon")
            realNameStatusLabel.text = "高级认证"
        }
        walletView.bindData(walletMoneyData: mineWalletData!)
    }
    
    func addTopUserMessage() {
        let userView = TGLinearLayout(.horz)
        userView.tg_gravity = .vert.center
        userView.corner(MEDDLE_RADIUS)
        userView.tg_width.equal(.fill)
        userView.tg_height.equal(.wrap)
        userView.tg_padding = UIEdgeInsets(top: PADDING_OUTER, left: 0, bottom: PADDING_OUTER, right: 0)
        userView.tg_space = 12
        container.addSubview(userView)
        
        userView.addSubview(avatarImgBg)
        avatarImgBg.addSubview(avatarImageView)
        
        let userMessageView = TGLinearLayout(.vert)
        userMessageView.tg_width.equal(.fill)
        userMessageView.tg_height.equal(.wrap)
        userView.addSubview(userMessageView)
        
        userMessageView.addSubview(username)
        userMessageView.addSubview(idView)
        userView.addSubview(realNameStatusView)
        
        container.addSubview(buyCoinView)
        container.addSubview(paymentView)
        container.addSubview(transferAccountsView)
        container.addSubview(billView)
        container.addSubview(walletView)
        container.addSubview(settingView)
        buyCoinView.snp_makeConstraints { make in
            make.top.equalTo(userView.snp_bottom).offset(0)
            make.left.equalTo(0)
            make.height.equalTo(90)
            make.width.equalTo(kScreenWidth/4.0)
        }
        paymentView.snp_makeConstraints { make in
            make.top.width.height.equalTo(buyCoinView)
            make.left.equalTo(buyCoinView.snp_right)
        }
        transferAccountsView.snp_makeConstraints { make in
            make.top.width.height.equalTo(buyCoinView)
            make.left.equalTo(paymentView.snp_right)
        }
        billView.snp_makeConstraints { make in
            make.top.width.height.equalTo(buyCoinView)
            make.left.equalTo(transferAccountsView.snp_right)
        }
        walletView.snp_makeConstraints { make in
            make.top.equalTo(billView.snp_bottom).offset(25)
            make.left.right.equalTo(0)
            make.height.equalTo(62)
        }
        settingView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(walletView.snp_bottom).offset(13)
            make.height.equalTo(105)
        }

    }

    lazy var userIcon: UIImageView = {
        let r = ViewFactoryUtil.circleImgView(R.image.defaultAvatar()!, 64)
        return r
    }()
    
    lazy var avatarImgBg: UIView = {
        let r = UIView()
        r.tg_width.equal(64)
        r.tg_height.equal(64)
        return r
    }()
    
    lazy var avatarImageView: AvatarView = {
        let v = AvatarView()
        v.size = 64
        v.border(.white)
        v.corner(32)
        return v
    }()
    
    lazy var username: UILabel = {
        let r = UILabel()
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.textColor = .black333
        r.font = UIFont(name: "PingFangSC-Medium", size: 22)
        return r
    }()
    lazy var idView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.addSubview(idLabel)
        let copyImg = ViewFactoryUtil.defalutImgView(R.image.copy_icon()!, 16)
        copyImg.tg_centerY.equal(0)
        copyImg.tg_left.equal(3)
        r.addSubview(copyImg)
        let tap = UITapGestureRecognizer(target: self, action: #selector(copyUserID))
        r.addGestureRecognizer(tap)
        return r
    }()
    lazy var idLabel : UILabel = {
        let r = UILabel()
        r.tg_height.equal(.wrap)
        r.tg_centerY.equal(0)
        r.tg_width.equal(.wrap)
        r.font = UIFont(name: "PingFangSC-Semibold", size: 12)
        r.textColor = .black999
        return r
    }()
    lazy var realNameStatusView: UIView = {
        let r = UIView()
        r.tg_height.equal(19)
        r.tg_centerY.equal(0)
        r.tg_right.equal(-10)
        r.tg_width.equal(75+10)
        r.corner(9.5)
        r.addSubview(realNameStatusIcon)
        r.addSubview(realNameStatusLabel)
        realNameStatusIcon.snp_makeConstraints { make in
            make.centerY.equalTo(r)
            make.left.equalTo(4)
            make.width.height.equalTo(13)
        }
        realNameStatusLabel.snp_makeConstraints { make in
            make.centerY.equalTo(realNameStatusIcon)
            make.left.equalTo(realNameStatusIcon.snp_right).offset(4)
            make.right.equalTo(-4)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(gotoRealNameVC))
        r.addGestureRecognizer(tap)
        return r
    }()
    lazy var realNameStatusIcon: UIImageView = {
        let r = UIImageView()
        return r
    }()
    lazy var realNameStatusLabel: UILabel = {
        let r = UILabel()
        r.font = UIFont(name: "PingFangSC-Regular", size: 12)
        r.textColor = .white
        return r
    }()
    lazy var buyCoinView:ButtonItem = {
        let r = ButtonItem()
        r.bindData(title: "买卖币", icon: UIImage(named: "mine_home_buy_coin_icon")!)
        r.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {  _ in
            SuperToast.show(title: "开发中")
        }
        r.addGestureRecognizer(tap)
        return r
    }()
    lazy var paymentView:ButtonItem = {
        let r = ButtonItem()
        r.bindData(title: "收款", icon: UIImage(named: "mine_home_payment_icon")!)
        r.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {  _ in
            self.gotoControllerFromRoot(BoBReceivePaymentViewController.self)
        }
        r.addGestureRecognizer(tap)
        return r
    }()
    lazy var transferAccountsView:ButtonItem = {
        let r = ButtonItem()
        r.bindData(title: "转账", icon: UIImage(named: "mine_home_transfer_accounts_icon")!)
        r.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {  _ in
            self.gotoControllerFromRoot(BoBTransferAccountsViewController.self)
        }
        r.addGestureRecognizer(tap)
        return r
    }()
    lazy var walletView: MineHomeWalletView = {
        let r = MineHomeWalletView()
        r.refreshBlock = {
            self.loadUserWallet()
        }
        return r
    }()
    lazy var billView:ButtonItem = {
        let r = ButtonItem()
        r.bindData(title: "账单", icon: UIImage(named: "mine_home_bill_icon")!)
        r.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe {  _ in
            SuperToast.show(title: "开发中")
        }
        r.addGestureRecognizer(tap)
        return r
    }()
    lazy var settingView: UIView = {
        let r = UIView()
        r.corner(8)
        r.backgroundColor = .white
        let t = TGLinearLayout(.vert)
        t.tg_width.equal(.fill)
        t.tg_height.equal(.wrap)
        t.tg_space = 1
        t.addSubview(paymentMethodView)
        t.addSubview(ViewFactoryUtil.smallDivider())
        t.addSubview(settingCenterView)
        r.addSubview(t)
        return r
    }()
    
    lazy var paymentMethodView: SuperSettingView = {
        let r = SuperSettingView.create(icon: UIImage(named: "mine_home_payment_method_icon")!, title: "支付方式",isChangeIconColor:false, click: { [weak self] data in
            let vc = BoBPaymentMethodListViewController()
            vc.certificationLevel = self?.mineWalletData?.certificationLevel ?? 0
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
        })
        r.isMediumFont()
        return r
    }()
    
    lazy var settingCenterView: SuperSettingView = {
        let r = SuperSettingView.create(icon: UIImage(named: "mine_home_setting_icon")!, title: "设置中心",isChangeIconColor:false, click: { [weak self] data in
            self?.gotoControllerFromRoot(MineSettingVC.self)
        })
        r.isMediumFont()
        return r
    }()

    
    
    
}

class ButtonItem: UIView{
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            addSubview(iconImageView)
            addSubview(titleLabel)
            
            iconImageView.snp.makeConstraints { make in
                make.top.equalTo(19)
                make.width.height.equalTo(30)
                make.centerX.equalToSuperview()
            }
            
            titleLabel.snp.makeConstraints { make in
                make.top.equalTo(iconImageView.snp_bottom).offset(11)
                make.left.equalTo(8)
                make.right.equalTo(-8)
            }
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        let iconImageView: UIImageView = {
            let v = UIImageView()
            return v
        }()

        let titleLabel: UILabel = {
            let v = UILabel()
            v.font =  UIFont(name: "PingFangSC-Medium", size: 14)
            v.textColor = .black333
            v.textAlignment = .center
            return v
        }()
        
    func bindData(title:String,icon:UIImage) {
            iconImageView.image = icon
            titleLabel.text = title
        }
    }

extension MeHomeController {
   
    @objc func gotoRealNameVC() {
        let vc = BoBRealNameMainViewController()
        vc.certificationLevel = mineWalletData?.certificationLevel ?? 0
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func copyUserID() {
        UIPasteboard.general.string = userShowId
        
        SuperToast.show(title: "复制成功".localized())
    }
}
