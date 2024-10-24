//
//  SuperSettingView.swift
//  设置Item
//
//  Created by smile on 2022/7/7.
//

import UIKit
import TangramKit
import OUICore

class SuperSettingView: TGLinearLayout {
    typealias ClickCallback = ((_ data:UIView)->Void)
    typealias SwitchChangedCallback = ((_ data:UISwitch)->Void)
    
    var click:ClickCallback?
    var switchChanged:SwitchChangedCallback?
    
    var tempPhone: String = ""
    var tempEmail: String = ""
    
    var isNeedExpendClickArea: Bool = true
    
    init() {
        super.init(frame: CGRect.zero, orientation: .horz)
        initViews()
        initListeners()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViews()
        initListeners()
    }
    
    func initViews() {
        tg_width.equal(.fill)
        tg_height.equal(51)
        tg_padding = UIEdgeInsets(top: 0, left: PADDING_OUTER, bottom: 0, right: PADDING_OUTER)
        tg_gravity = TGGravity.vert.center
        tg_space = PADDING_MEDDLE
        backgroundColor = .colorSurface
        
        addSubview(self.iconView)
        addSubview(phoneCodeView)
        addSubview(self.titleView)
        addSubview(self.textFieldView)
        addSubview(self.textView)
        addSubview(self.moreView)
        addSubview(contentLbl)
        addSubview(changeIcon)
        addSubview(self.codeBtn)
        addSubview(self.moreIconView)
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(expendClickAction))
//        isUserInteractionEnabled = true
//        addGestureRecognizer(tap)
        
    }
    
    func initListeners() {
        isUserInteractionEnabled = true
        
        //点击
        let tapGestureRecognizer=UITapGestureRecognizer(target: self, action: #selector(onTapClick(_:)))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func onTapClick(_ data:UITapGestureRecognizer) {
        if let r = click {
            r(data.qmui_targetView!)
        } else if isNeedExpendClickArea {
            self.textFieldView.becomeFirstResponder()
        }
    }
    
    /// 没有水平内边距
    func noHorizontalPadding() {
        tg_padding = UIEdgeInsets.zero
    }
    
    /// 小容器样式
    func small() {
        tg_padding = UIEdgeInsets(top: 0, left: PADDING_OUTER, bottom: 0, right: PADDING_OUTER)
        tg_height.equal(50)
    }
    
    @discardableResult
    func minStyle() -> SuperSettingView {
        tg_padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tg_height.equal(.wrap)
        
        titleView.font = UIFont.systemFont(ofSize: TEXT_MEDDLE)
        
        return self
    }
    
    func initSwitch() {
        insertSubview(superSwitch, at: 3)
        moreIconView.hide()
    }
    
    lazy var iconView: UIImageView = {
        let r = UIImageView()
        r.tg_width.equal(20)
        r.tg_height.equal(20)
        r.tintColor = .colorOnBackground
        r.hide()
        return r
    }()
    
    /// 手机号 前缀试图
    lazy var phoneCodeView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_gravity = .vert.center
        r.tg_width.equal(.fill)
        r.tg_height.equal(.fill)
        r.tg_space = PADDING_MEDDLE
        r.addSubview(phoneCodeLbl)
        r.addSubview(ViewFactoryUtil.defalutImgView(R.image.smallGrayBottomArrow()!, 10))
        r.addSubview(ViewFactoryUtil.vertLineView(20, .placeholder))
        r.hide()
        return r
    }()
    
    
    lazy var phoneCodeLbl: UILabel = {
        let result=UILabel()
        //fill:暂用剩下所有空间
        result.tg_width.equal(.wrap)
        result.tg_height.equal(.wrap)
        result.text = "+86"
        result.font = UIFont.systemFont(ofSize: TEXT_MEDDLE)
        result.tintColor = .colorOnBackground
        return result
    }()
    

    
    lazy var titleView: UILabel = {
        let result=UILabel()
        //fill:暂用剩下所有空间
        result.tg_width.equal(.fill)
        result.tg_height.equal(.wrap)
        result.font = .mediumFont(14)
        result.textColor = .black333
        return result
    }()
    
    lazy var moreView: UILabel = {
        let result=UILabel()
        result.tg_width.equal(.wrap)
        result.tg_height.equal(.wrap)
        result.font = UIFont.systemFont(ofSize: TEXT_SMALL)
        result.tintColor = .lightGray
        result.textColor = .lightGray
        return result
    }()
    
    lazy var textFieldView: QMUITextField = {
        let result=QMUITextField()
        result.tg_width.equal(.fill)
        result.tg_height.equal(.wrap)
        result.font = .mediumFont(14)
        result.tintColor = .colorOnBackground
        result.setPlaceHolderTextColor(.black999)
        result.hide()
        return result
    }()
    
    lazy var textView: QMUITextView = {
        let result = QMUITextView()
        result.tg_width.equal(.fill)
        result.tg_height.equal(.wrap)
//        result.tg_top.equal(10)
       
        result.hide()

        result.placeholder = "PleaseFillIn".localized()
        result.placeholderColor = .placeholderText

        result.font = .mediumFont(14)
        result.tintColor = .colorOnBackground
        
        return result
    }()
    
    lazy var moreIconView: UIImageView = {
        let result=ViewFactoryUtil.moreIconView()
        return result
    }()
    
    ///当前内容
    lazy var contentLbl: UILabel = {
        let r = ViewFactoryUtil.normalLbael()
        r.tg_width.equal(.fill)
        r.textAlignment = .right
        r.textColor = .lightGray
        r.hide()
        r.numberOfLines = 2
        return r
    }()
    
    lazy var superSwitch: UISwitch = {
        let r = UISwitch()
        r.tg_width.equal(.wrap)
        r.tg_height.equal(.wrap)
        
        //开关状态为开的时候左侧颜色
        r.onTintColor = .colorPrimary
        
        r.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        
        return r
    }()
    
    lazy var changeIcon: UIImageView = {
        let r = ViewFactoryUtil.cornerImgView(R.image.defaultAvatar()!, 40)
        r.hide()
        r.corner(20)
        r.addSubview(avatarImageView)
        r.contentMode = .scaleAspectFill
        return r
    }()
    
    lazy var avatarImageView: AvatarView = {
        let v = AvatarView()
        v.size = 40
        v.corner(20)
        v.border(.white)
        v.tg_top.equal(0)
        v.tg_left.equal(0)
        v.tg_width.equal(40)
        v.tg_height.equal(40)
        return v
    }()
    
    
    
    lazy var codeBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton()

        r.setTitle(" 获取验证码 ".localized(), for: .normal)
        r.setTitleColor(.primaryColor, for: .normal)
        r.hide()
        r.sizeToFit()
//        r.addTarget(self, action: #selector(sendClick(_:)), for: .touchUpInside)
        return r
    }()
    
    
//    deinit {
//        print(#file)
//    }

}

//MARK: - 触发方法
extension SuperSettingView {
    
    @objc func switchChanged(_ sender:UISwitch) {
        if let r = switchChanged {
            r(sender)
        }
    }
    
    @objc func sendClick(_ sender:QMUIButton) {
        sendCode()
    }
    
    func sendCode() {
        startCountDown()
    }
    
    /// 开始倒计时
    func startCountDown() {
        CountDownUtil.countDown(60) { result in
            
            if result == 0 {
                self.codeBtn.setTitle("Resend".localized(), for: .normal)
                self.codeBtn.isEnabled = true
            } else {
                self.codeBtn.setTitle("ResendCount".localizedFormat(result), for: .normal)
            }
            
            self.codeBtn.sizeToFit()
        }
        
        //禁用按钮
        self.codeBtn.isEnabled = false
    }
    
    /// 切换手机邮箱
    func changePhoneEmail(_ isPhone: Bool) {
        if(isPhone) {
            phoneCodeView.show()
            titleView.hide()

            textFieldView.placeholder = "Phone".localized()
            tempEmail = textFieldView.text!
            textFieldView.text = tempPhone
            textFieldView.keyboardType = .numberPad
            textFieldView.clearButtonMode = .always
            
            needLimitLength(length: PHONE_MAX_LENGTH)
            
        } else {
            phoneCodeView.hide()
            titleView.show()

            titleView.text = "email".localized()
            textFieldView.placeholder = "PleaseFillIn".localized()
            tempPhone = textFieldView.text!
            textFieldView.text = tempEmail
            textFieldView.keyboardType = .emailAddress
        }
    }
    
    /// titleView  name: "PingFangSC-Medium", size: 16
    func isMediumFont(_ size: CGFloat = 16)  {
        titleView.font = UIFont(name: "PingFangSC-Medium", size: size)
    }
    
    
    
    func isCode() {
        needLimitLength(length: CODE_MAX_LENGTH)
    }
    
    func isPwd() {
        textFieldView.isSecureTextEntry = true
        textFieldView.keyboardType = .asciiCapable
        needLimitLength(length: PASSWORD_MAX_LENGTH)
    }
    
    func isUserName() {
        needLimitLength(length: USERNAME_MAX_LENGTH)
    }
    
    /// 限制输入长度
    func needLimitLength(length: Int) {
        textFieldView.rx.text
            .orEmpty
            .map{$0.count > length ? String($0.prefix(length)) : $0 }
            .bind(to: textFieldView.rx.text)
            .disposed(by: rx.disposeBag)
    }
    
    /// 限制输入长度
    func needLimitLengthAboutTextView(length: Int) {
        textView.rx.text
            .orEmpty
            .map{$0.count > length ? String($0.prefix(length)) : $0 }
            .bind(to: textFieldView.rx.text)
            .disposed(by: rx.disposeBag)
    }
    
    
    var inputText: String? {
        return textFieldView.text
    }
    
    func isReport() {
        textFieldView.isUserInteractionEnabled = false
        textFieldView.placeholder = "ReasonForReporting".localized()
        moreIconView.show()
    }
}


//MARK: - 快捷创建控件
extension SuperSettingView{

    static func smallWithIcon(icon:UIImage?=nil,title:String,click:@escaping ClickCallback,switchChanged:SwitchChangedCallback?=nil) -> SuperSettingView {
        let r = SuperSettingView()
        
        //小容器
        r.small()
        
        if let icon = icon {
            r.iconView.show()
            r.iconView.image = icon
        }
        
        r.titleView.text = title
        
        r.click = click
        r.switchChanged = switchChanged
        
        if let _ = switchChanged {
            r.initSwitch()
        }
        
        return r
    }
    
    static func smallWithIcon(title:String,click: ((_ data:UIView)->Void)?=nil) -> SuperSettingView {
        let result = SuperSettingView()
        result.tg_height.equal(.wrap)
        result.tg_padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        result.iconView.hide()
        result.moreIconView.hide()
        
        result.titleView.font = UIFont.systemFont(ofSize: TEXT_MEDDLE)
        
        result.titleView.text = title
        
        result.click = click
        
        return result
    }
    
    ///图标，标题，开关效果（图片实现的）
    static func radioWithIcon(icon:UIImage,title:String,click:@escaping ((_ data:UIView)->Void)) -> SuperSettingView {
        let result = SuperSettingView()
//        result.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_OUTER, bottom: PADDING_MEDDLE, right: PADDING_OUTER)
        
        result.iconView.show()
        result.iconView.tg_width.equal(30)
        result.iconView.tg_height.equal(30)
        
        result.moreIconView.show()
        result.moreIconView.tg_width.equal(20)
        result.moreIconView.tg_height.equal(20)
        
        result.iconView.image = icon
        result.titleView.text = title
        
        result.moreIconView.image = R.image.check()
        
        result.click = click
        
        return result
    }
    
    ///标题  开关
    static func create(title:String,click:@escaping ClickCallback,switchChanged:SwitchChangedCallback?=nil) -> SuperSettingView {
        let r = SuperSettingView()
    
        r.titleView.text = title
        
        r.click = click
        r.switchChanged = switchChanged
        
        if let _ = switchChanged {
            r.initSwitch()
        }
        
        return r
    }
    
    
    /// icon 标题 开关 
    static func create(icon:UIImage,title:String,  ishaveMore: Bool = true, click:@escaping ((_ data:UIView)->Void),switchChanged:((_ data:UISwitch)->Void)?=nil) -> SuperSettingView {
        let result = SuperSettingView()
//        result.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_OUTER, bottom: PADDING_MEDDLE, right: PADDING_OUTER)
        
        result.iconView.show()
        result.iconView.image = icon.withTintColor()
        result.titleView.text = title
        
        result.click = click
        result.switchChanged=switchChanged
        
        if let _ = switchChanged {
            result.initSwitch()
        }
        
        if(!ishaveMore) {
            result.moreIconView.hide()
        }
        
        return result;
    }
    
    /// 标题和输入文本TF
    static func createInput(_ title:String,placeholder:String? = "请输入".localized(), _ min: CGFloat = 80,click: ClickCallback? = nil) -> SuperSettingView {
        let result = SuperSettingView()
//        result.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_OUTER, bottom: PADDING_MEDDLE, right: PADDING_OUTER)
        
        //最小宽度
        result.titleView.tg_width.equal(.wrap).min(min)
        result.titleView.text = title
        
        result.textFieldView.show()
        result.textFieldView.placeholder = placeholder
        
        if let _  = click {
            result.click = click
        }
        
        result.moreIconView.hide()
        
        return result;
    }
    

    
    static func createInputPhone(_ title:String,placeholder:String?=nil, _ min: CGFloat = 80) -> SuperSettingView {
        let result = SuperSettingView()
//        result.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_OUTER, bottom: PADDING_MEDDLE, right: PADDING_OUTER)
        
        //最小宽度
        result.titleView.hide()
        
        result.phoneCodeView.show()
        result.phoneCodeView.tg_width.equal(.wrap).min(min)
        result.titleView.tg_width.equal(.wrap).min(min)
        
        result.textFieldView.show()
        result.textFieldView.placeholder = placeholder
    
        
        result.moreIconView.hide()
        
        return result;
    }
    
    
    /// 标题和输入文本TF  获取验证码Code
    static func createInputAboutCode(_ title:String,placeholder:String = "PleaseFillIn".localized()) -> SuperSettingView {
        let result = SuperSettingView()
//        result.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_OUTER, bottom: PADDING_MEDDLE, right: PADDING_OUTER)
        
        //最小宽度
        result.titleView.tg_width.equal(.wrap).min(80)
        result.titleView.text = title
        
        result.textFieldView.show()
        result.textFieldView.placeholder = placeholder
    
        result.textFieldView.keyboardType = .numberPad
        result.moreIconView.hide()
        result.codeBtn.show()
        return result;
    }
    
    
    /// 标题和输入文本TextView
    static func createInputTextView(_ title:String,placeholder:String?=nil, min: CGFloat = 80) -> SuperSettingView {
        let result = SuperSettingView()
//        result.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_OUTER, bottom: PADDING_MEDDLE, right: PADDING_OUTER)
        
        //最小宽度
        result.titleView.tg_width.equal(.wrap).min(min)
        result.titleView.text = title
        
        result.textView.show()
        result.textView.placeholder = placeholder
    
        
        result.moreIconView.hide()
        
        return result;
    }
    
    ///只有标题 
    static func onlylTitle(_ title:String,click: ((_ data:UIView)->Void)?=nil) -> SuperSettingView {
        let result = SuperSettingView()
//        result.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_OUTER, bottom: PADDING_MEDDLE, right: PADDING_OUTER)
        
        //最小宽度
        result.titleView.tg_width.equal(.wrap).min(80)
        result.titleView.text = title

        result.moreIconView.hide()
        result.click = click
        
        return result;
    }
    
    ///标题   修改头像  箭头
    static func createSetIcon(_ title:String,click: ((_ data:UIView)->Void)?=nil) -> SuperSettingView {
        let result = SuperSettingView()
//        result.tg_padding = UIEdgeInsets(top: PADDING_SMALL, left: PADDING_OUTER, bottom: PADDING_SMALL, right: PADDING_OUTER)
        
        //最小宽度
        result.titleView.tg_width.equal(.wrap).min(80)
        result.titleView.text = title

        result.changeIcon.show()
        result.moreIconView.show()
        result.titleView.tg_width.equal(.fill)
        
        result.click = click
        
        return result;
    }

    ///  标题  内容 箭头
    static func createSetTitleAddContentView(_ title:String, _ content: String, click: ((_ data:UIView)->Void)?=nil) -> SuperSettingView {
        let result = SuperSettingView()
//        result.tg_padding = UIEdgeInsets(top: PADDING_SMALL, left: PADDING_OUTER, bottom: PADDING_SMALL, right: PADDING_OUTER)
        
        //最小宽度
        result.titleView.tg_width.equal(.wrap).min(80)
        result.titleView.text = title

        result.contentLbl.show()
        result.contentLbl.text = content
        result.moreIconView.show()
        
        result.click = click
        
        return result;
    }
    
    
    ///  标题   箭头
    static func createNoromalView(_ title:String, click: ((_ data:UIView)->Void)?=nil) -> SuperSettingView {
        let result = SuperSettingView()
//        result.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_OUTER, bottom: PADDING_MEDDLE, right: PADDING_OUTER)
        
        //最小宽度
        result.titleView.tg_width.equal(.wrap).min(80)
        result.titleView.tg_width.equal(.fill)
        result.titleView.text = title

        result.moreIconView.show()
        
        result.click = click
        return result;
    }
    
    func loginUI() {
        tg_height.equal(46)
        backgroundColor = .colorBackgroundAPP
        corner(23)
    }
    
    
   @objc func expendClickAction() {
       
       if isNeedExpendClickArea {
           if self.textFieldView.isShow() {
               self.textFieldView.becomeFirstResponder()
           }
       }
    }
    
    
}
