//
//  MineDeleteCountAuthenticationVC.swift
//  MyCloudMusic
//
//  Created by mac on 2024/5/7.
//

import UIKit
import TangramKit
import RxSwift
import RxCocoa

class MineDeleteAcountAuthenticationVC: BaseTitleController {

    var vcType: MyStyle = .usePhone
    
    private var _areaCode = "+86"
    
    override func initViews() {
        super.initViews()
        setBackGroundColor(.colorBackgroundAPP)
        initLinearLayoutSafeArea()
    
        title = R.string.localizable.deleteAccount()
        
        container.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_OUTER, bottom: PADDING_MEDDLE, right: PADDING_OUTER)
        container.tg_space = PADDING_OUTER
        
        container.addSubview(sectionLbl)
        container.addSubview(topContentView)
        
        container.addSubview(nextBtn)
        
        refreshUI()
        bindData()
    }
    
    override func bindData() {
        Observable
            .combineLatest(useTypeView.textFieldView.rx.text.orEmpty, getCodeView.textFieldView.rx.text.orEmpty) {
                $0.count > 0 && $1.count > 0
            }
            .bind(to: nextBtn.rx.isEnabled)
            .disposed(by: rx.disposeBag)
    }
    
    func refreshUI() {
        switch vcType {
        case .usePhone:
            title = R.string.localizable.deleteAccount()
            sectionLbl.text = R.string.localizable.pleaseFillIn()
            useTypeView.changePhoneEmail(true)
            let tap = UITapGestureRecognizer(target: self, action: #selector(changePhoneArea))
            useTypeView.phoneCodeView.addGestureRecognizer(tap)
            nextBtn.setTitle(R.string.localizable.nextStep(), for: .normal)
        case .useEmail:
            title = R.string.localizable.deleteAccount()
            sectionLbl.text = R.string.localizable.pleaseFillIn()
            useTypeView.changePhoneEmail(false)
            nextBtn.setTitle(R.string.localizable.nextStep(), for: .normal)
        case .changePhone:
            title = R.string.localizable.phone()
            sectionLbl.text = R.string.localizable.pleaseFillIn()
            useTypeView.changePhoneEmail(true)
            let tap = UITapGestureRecognizer(target: self, action: #selector(changePhoneArea))
            useTypeView.phoneCodeView.addGestureRecognizer(tap)
            nextBtn.setTitle(R.string.localizable.nextStep(), for: .normal)
        case .changeEmail:
            title = R.string.localizable.email()
            sectionLbl.text = R.string.localizable.pleaseFillIn()
            useTypeView.changePhoneEmail(false)
            nextBtn.setTitle(R.string.localizable.nextStep(), for: .normal)
        case .forgetPwdbyPhone:
            title = "忘记密码".localized()
            sectionLbl.text = "请验证你的手机号".localized()
            useTypeView.changePhoneEmail(true)
            let tap = UITapGestureRecognizer(target: self, action: #selector(changePhoneArea))
            useTypeView.phoneCodeView.addGestureRecognizer(tap)
            nextBtn.setTitle(R.string.localizable.nextStep(), for: .normal)
        case .forgetPwdByEmail:
            title = "忘记密码".localized()
            sectionLbl.text = "请验证你的邮箱".localized()
            useTypeView.changePhoneEmail(false)
            nextBtn.setTitle(R.string.localizable.nextStep(), for: .normal)
        default :
            break
        }
    }
    
//    
//    func getTitle() -> String {
//        switch vcType {
//        case .usePhone, .useEmail:
//            return "删除账号"
//        case .changePhone:
//            return "修改手机号"
//        case .changeEmail:
//            return "修改手机号"
//        default :
//            return ""
//        }
//    }
//    
//    func getSectionTitle() -> String {
//        switch vcType {
//        case .usePhone:
//            return "请验证你的手机号"
//        case .useEmail:
//            return "请验证你的邮箱"
//        case .changePhone:
//            return "输入新的手机号"
//        case .changeEmail:
//            return "输入新的邮箱"
//        default :
//            return ""
//        }
//    }
    
    lazy var sectionLbl: UILabel = {
        let r = ViewFactoryUtil.sectionTilteLbael("请验证你的手机号")
        r.textColor = .black666
        r.font = .mediumFont(14)
        return r
    }()
 
    
    lazy var topContentView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_space = 1
        r.corner(MEDDLE_RADIUS)
        r.backgroundColor = .white
        
        r.addSubview(useTypeView)
        r.addSubview(ViewFactoryUtil.smallDivider())
        r.addSubview(getCodeView)
        
        return r
    }()
    
    lazy var useTypeView: SuperSettingView = {
        let r = SuperSettingView.createInputPhone("手机号", placeholder: "请输入手机号")
        r.phoneCodeLbl.font = UIFont(name: "PingFangSC-Medium", size: 16)
        r.isMediumFont()
        return r
    }()
    
    
    lazy var getCodeView: SuperSettingView = {
        let r = SuperSettingView.createInputAboutCode(R.string.localizable.code(), placeholder: R.string.localizable.pleaseFillIn())
        r.isMediumFont()
        return r
    }()
    
    lazy var nextBtn: QMUIButton = {
        let  r = ViewFactoryUtil.primaryHalfFilletButton()
        r.setTitle("下一步", for: .normal)
        r.addTarget(self, action: #selector(gotoNextVC), for: .touchUpInside)
        r.tg_top.equal(20)
        return r
    }()
    
    @objc func gotoNextVC()  {
        if vcType == .usePhone || vcType == .useEmail {
            let vc = MineDeleteAccountReasonVC()
            vc.vcType = vcType
            self.navigationController?.pushViewController(vc, animated: true)
        } else if vcType == .forgetPwdbyPhone || vcType == .forgetPwdByEmail {
            let vc = YFMineChangePasswordVC()
            vc.vcType = vcType
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            print("修改绑定")
        }
        
    }
    
    deinit {
        //保证定时器释放
        CountDownUtil.cancel()
        print(#file)
    }
    
}

extension MineDeleteAcountAuthenticationVC {
    
    @objc func changePhoneArea()  {
        let alert = UIAlertController(style: .actionSheet, title: "")
        alert.addLocalePicker(type: .phoneCode) {[weak self] info in
            // action with selected object
            guard let phoneCode = info?.phoneCode else {return}
            self?._areaCode = phoneCode
            self?.useTypeView.phoneCodeLbl.text = phoneCode
        }
        
        alert.addAction(title: "cancel".localized(), style: .cancel)
        self.present(alert, animated: true)
    }
    
    
}


