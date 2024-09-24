//
//  Constant.swift
//  MyCloudMusic
//
//  Created by mac on 2024/4/24.
//

import Foundation


class Constant {
    static let ANONYMOUS = "anonymous"
    
    /// 列表Cell复用字符串
    static let CELL = "CELL"

    static let CLICK_EVENT = "CLICK_EVENT"
    static let EVENT_MUSIC_LIST_CHANGED = "EVENT_MUSIC_LIST_CHANGED"
    static let EVENT_SONG_CLICK = "EVENT_SONG_CLICK"
    static let EVENT_LOGIN_CLICK = "EVENT_LOGIN_CLICK"
    static let EVENT_BANNER_CLICK = "EVENT_BANNER_CLICK"
    static let EVENT_SELECT_LOCATION = "EVENT_SELECT_LOCATION"
    static let EVENT_ADDRESS_CHANGED = "EVENT_ADDRESS_CHANGED"
    static let EVENT_PAY_SUCCESS = "EVENT_PAY_SUCCESS"
    static let EVENT_ALIPAY_PAY_SUCCESS = "EVENT_ALIPAY_PAY_SUCCESS"
    static let EVENT_WECHAT_PAY_SUCCESS = "EVENT_WECHAT_PAY_SUCCESS"
    static let EVENT_NOTIFICATION_CLICK = "EVENT_NOTIFICATION_CLICK"
    static let EVENT_USER_SELECTED = "EVENT_USER_SELECTED"
    
    static let DATA = "DATA"
}

/// 类型枚举，所有类型都定义到这里，方便统一管理，当然也可以按模块，界面拆分
enum MyStyle:Int {
    case none = -1
    case usePhone
    case useEmail
    case useFeedback
    case useReport
    case isLogin
    case isRegister
    case changePhone
    case changeEmail
    case reportUser
    case reportBlog
    case forgetPwdbyPhone
    case forgetPwdByEmail
    case bokeVisitorStranger
    case bokeVisitorFriend
    case newAttentionFriend
}

/// 间歇
/// 0.5
let PADDING_MIN:CGFloat = 0.5
////5
let PADDING_SMALL:CGFloat = 5
///10
let PADDING_MEDDLE:CGFloat = 10
///16
let PADDING_OUTER:CGFloat = 16
///24
let PADDING_LARGE2:CGFloat = 24

/// 文本尺寸
/// 8
let TEXT_TAG:CGFloat = 8
/// 12
let TEXT_SMALL:CGFloat = 12
/// 14
let TEXT_MEDDLE:CGFloat = 14
///16
let TEXT_LARGE:CGFloat = 16
///17
let TEXT_LARGE2:CGFloat = 17
///18
let TEXT_LARGE3:CGFloat = 18
///24
let TEXT_LARGE4:CGFloat = 24
///30
let TEXT_PRICE:CGFloat = 30

/// 按钮尺寸
let BUTTON_SMALL:CGFloat = 30
let BUTTON_MEDDLE:CGFloat = 42
let BUTTON_LARGE:CGFloat = 55
let BUTTON_WIDTH_MEDDLE:CGFloat = 150

/// 圆角尺寸
let SMALL_RADIUS:CGFloat = 5
let MEDDLE_RADIUS:CGFloat = 10
let BUTTON_SMALL_RADIUS:CGFloat = 15
let BUTTON_MEDDLE_RADIUS:CGFloat = 21

let SCREEN_WIDTH:CGFloat = UIScreen.main.bounds.width

let VALUE_NO = -1
let VALUE0 = 0
let VALUE10 = 10
let VALUE12 = 12

/// 输入框尺寸
let INPUT_SMALL = 30
let INPUT_MEDDLE = 40

/**
 * android
 */
let PLATFORM_ANDROID = 0

/**
 * ios
 */
let PLATFORM_IOS = 10

/**
 * web
 */
let PLATFORM_WEB = 20

/**
 * wap
 */
let PLATFORM_WAP = 30

/**
 * 支付宝
 */
let ALIPAY = 10

/**
 * 微信
 */
let WECHAT = 20

/**
 * 花呗分期
 */
let HUABEI_STAGE = 30

/**
 * 待支付
 */
let WAIT_PAY = 0

/**
 * 订单关闭
 */
let CLOSE = 10

/**
 * 待发货
 */
let WAIT_SHIPPED = 500

/**
 * 待收货
 */
let WAIT_RECEIVED = 510

/**
 * 待评价
 */
let WAIT_COMMENT = 520

/**
 * 完成
 */
let COMPLETE = 530

/// 支付宝支付回调
/// 不能和其他应用有重复
/// 用于支付宝客户端回调我们应用
let ALIPAY_CALLBACK_SCHEME = "ixueacourse"

let ON_MESSAGE = "ON_MESSAGE"
let ON_MESSAGE_COUNT_CHANGED = "ON_MESSAGE_COUNT_CHANGED"

//通知中的动作
let EXTRA = "extra"

let ACTION_PUSH_CLICK = "ACTION_PUSH_CLICK"

