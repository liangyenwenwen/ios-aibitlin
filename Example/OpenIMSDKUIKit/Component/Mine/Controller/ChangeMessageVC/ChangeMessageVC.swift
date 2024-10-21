//
//  ChangeMessageVC.swift
//  MyCloudMusic
//
//  Created by mac on 2024/5/8.
//

import UIKit
import TangramKit
import RxSwift
import RxCocoa

enum ChangeMessageType {

//    case nickname = "名字"
//    case userID = "BitSwitch ID"
//    case userIntro = "个人简介"
//    case facebook = "Facebook 主页"
//    case instagram = "Instagram 主页"
//    case tiktok = "TikTok 主页"
//    case youtube = "YouTube 主页"
//    case markFriendname = "修改备注"
    case nickname
    case userID
    case userIntro
    case facebook
    case instagram
    case tiktok
    case youtube
    case markFriendname
}


class ChangeMessageVC: BaseTitleController {


    lazy var saveBtn:  QMUIButton = {
        let r = ViewFactoryUtil.linkButton()
//        r.setTitle(R.string.localizable.save(), for: .normal)
        r.setTitle("Save".localized(), for: .normal)
        r.setTitleColor(.colorPrimary, for: .normal)
        r.sizeToFit()
        return r
    }()
    
    private let _viewModel = MineViewModel()
    
    override func initViews() {
        
        super.initViews()
        setBackGroundColor(.colorBackgroundAPP)
        initLinearLayoutSafeArea()
        container.tg_padding = UIEdgeInsets(top: 0, left: PADDING_OUTER, bottom: 0, right: PADDING_OUTER)
        
        let topView = TGLinearLayout(.horz)
        topView.corner()
        topView.backgroundColor = .white
        topView.tg_width.equal(.fill)
        topView.tg_height.equal(110)
        topView.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_OUTER, bottom: PADDING_MEDDLE, right: PADDING_OUTER)
        container.addSubview(topView)
        
        topView.addSubview(editView)
        
        navView.addRighttItem(saveBtn)
        
        bindData()
    }
    
    
    lazy var editView: QMUITextView = {
        let r = ViewFactoryUtil.normalTextView()
//        r.placeholder = R.string.localizable.pleaseFillIn()
        r.placeholder = "PleaseFillIn".localized()
        r.font = .semiboldFont(16)
        return r
    }()
    
    
    override func bindData() {
        
        editView.rx.text.map{ $0!.count > 1}.bind(to: saveBtn.rx.isEnabled).disposed(by: rx.disposeBag)
    }
    
    
    var _changeType: ChangeMessageType?
    var changeType: ChangeMessageType? {
        get {
            return _changeType
        }
        set {
            
            let user = _viewModel.currentUserRelay.value
            
            switch newValue {
            case .nickname:
//                title = R.string.localizable.name()
                title = "Name".localized()
                editView.text = SuperStringUtil.getUserShowname(showname: user?.nickname ?? "")
            case .userID:
                title = "Aibitlin ID"
                editView.text = user?.chatID ?? (user?.userID ?? "")
            case .userIntro:
//                title = R.string.localizable.personalProfile()
                title = "PersonalProfile".localized()
                editView.text = user?.personalProfile
            case .facebook:
//                title = R.string.localizable.homePage("Facebook")
                title = "HomePage".localizedFormat("Facebook")
            case .instagram:
//                title = R.string.localizable.homePage("Instagram")
                title = "HomePage".localizedFormat("Instagram")
            case .tiktok:
//                title = R.string.localizable.homePage("TikTok")
                title = "HomePage".localizedFormat("TikTok")
            case .youtube:
//                title = R.string.localizable.homePage("YouTube") 
                title = "HomePage".localizedFormat("YouTube")
            case .markFriendname:
//                title = R.string.localizable.modifyRemarks()
                title = "ModifyRemarks".localized()
            default:
                break
            }
            
            _changeType = newValue
        }
    }
    
//    var changeType: ChangeMessageType? {
//        get {
//            return _changeType
//        }
//        set {
//
//            title = newValue?.rawValue
//            _changeType = newValue
//        }
//    }
//    

}
