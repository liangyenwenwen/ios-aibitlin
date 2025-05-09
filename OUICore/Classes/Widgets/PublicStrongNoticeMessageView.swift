//
//  PublicStrongNoticeMessageView.swift
//  OUICore
//
//  Created by mac on 2025/4/28.
//

import Foundation
import RxSwift
import OUICore
import Alamofire

class PublicStrongNoticeMessageView: UIView {
    var clickBtnBlock:((_ index:Int)->())!
    private let _disposeBag = DisposeBag()
    public override init(frame: CGRect) {
        super.init(frame: frame)
        innerInit()
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func innerInit() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5) // 半透明背景
        addSubview(contentView)
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(cancleBtn)
        contentView.addSubview(sureBtn)
        contentView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(44 + kStatusBarHeight)
            make.height.equalTo(180)
        }
        iconImageView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(16)
            make.width.height.equalTo(26)
        }
        titleLabel.snp_makeConstraints { make in
            make.top.equalTo(19)
            make.left.equalTo(iconImageView.snp_right).offset(5)
            make.right.equalTo(-16)
            make.height.equalTo(20)
        }
        contentLabel.snp_makeConstraints { make in
            make.top.equalTo(54)
            make.left.equalTo(16)
            make.right.equalTo(-16)
        }
        cancleBtn.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.bottom.equalTo(-16)
            make.width.equalTo((kScreenWidth-64-18)/2.0)
            make.height.equalTo(46)
        }
        sureBtn.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.top.width.height.equalTo(cancleBtn)
        }
    }
    func bindData(detail:PublicStrongNoticeMessage){
        iconImageView.setImage(url: URL(string: detail.detail?.icon ?? "")!, thumbURL: nil)
        titleLabel.text = detail.detail?.title
        contentLabel.text = detail.detail?.content
        showMask()
    }
    func showMask() {
        if let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? UIApplication.shared.windows.first{
            self.frame = keyWindow.bounds
            keyWindow.addSubview(self)
            // 动画显示遮罩
            alpha = 0
            UIView.animate(withDuration: 0.3) {
                self.alpha = 1
            }
        }else{
            clickBtnBlock(0)
        }
    }
    
    // 隐藏遮罩
    func hideMask() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }
    lazy var contentView: UIView = {
        let r = UIView()
        r.backgroundColor = .white
        r.layer.masksToBounds = true
        r.layer.cornerRadius = 12
        return r
    }()
    lazy var iconImageView: UIImageView = {
        let r = UIImageView()
        r.corner(radius: 4)
        return r
    }()
    lazy var titleLabel: UILabel = {
        let r = UILabel()
        r.font = UIFont(name: "PingFangSC-Semibold", size: 18)
        r.textColor = .init(hexString: "#333333")
        return r
    }()
    lazy var contentLabel: UILabel = {
        let r = UILabel()
        r.font = UIFont(name: "PingFangSC-Regular", size: 16)
        r.textColor = .init(hexString: "#333333")
        r.numberOfLines = 2
        return r
    }()
    lazy var cancleBtn: UIButton = {
        let r = UIButton()
        r.setTitle("稍后处理", for: .normal)
        r.setTitleColor(.init(hexString: "#666666"), for: .normal)
        r.titleLabel?.font = UIFont(name: "PingFangSC-Semibold", size: 16)
        r.layer.masksToBounds = true
        r.layer.cornerRadius = 23
        r.layer.borderWidth = 1
        r.layer.borderColor = UIColor.init(hexString: "#999999")?.cgColor
        r.rx.tap.subscribe(onNext: { [weak self] in
            self?.hideMask()
            self?.clickBtnBlock(0)
        }).disposed(by: _disposeBag)
        return r
    }()
    lazy var sureBtn: UIButton = {
        let r = UIButton()
        r.setTitle("立即处理", for: .normal)
        r.setTitleColor(.white, for: .normal)
        r.layer.masksToBounds = true
        r.layer.cornerRadius = 23
        r.backgroundColor = .init(hexString: "#388CEF")
        r.rx.tap.subscribe(onNext: { [weak self] in
            self?.hideMask()
            self?.clickBtnBlock(1)
        }).disposed(by: _disposeBag)
        return r
    }()
}
class PublicStrongNoticeMessage: Decodable {
    var externalUrl: String?
    var mixType:Int?
    var notificationName:String?
    var notificationType:Int?
    var text:String?
    var isRead:Bool?
    var msgID:String?
    var conversationID:String?
    var detail:PublicStrongNoticeMessageDetail?
    
}
class PublicStrongNoticeMessageDetail: Decodable {
    var type: Int?
    var icon:String?
    var title:String?
    var hash:String?
    var content:String?
    var date:String?
}
