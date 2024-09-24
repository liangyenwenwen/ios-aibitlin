//
//  TableViewCell.swift
//  MyCloudMusic
//
//  Created by mac on 2024/5/7.
//

import UIKit
import TangramKit

enum BottomBtnStyle {
    case normol
    case sendMessage
    case attention
    case sendMessageAndAttention
}

class BottomBtnView: TGLinearLayout {
    
    init() {
        super.init(frame: CGRect.zero, orientation: .horz)
        initViews()

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViews()
    }
    
    func initViews() {
        tg_width.equal(.fill)
        tg_height.equal(55)
        tg_padding = UIEdgeInsets(top: 0, left: PADDING_OUTER, bottom: 0, right: PADDING_OUTER)
        tg_gravity = TGGravity.vert.center
        tg_space = PADDING_MEDDLE
//        backgroundColor = .colorSurface
    }
    
    func setStyle(_ style: BottomBtnStyle)  {
        switch style {
        case .normol:
            initNormalUI()
        case .sendMessage:
            initSendMessagelUI()
        case .attention:
            initAttentionUI()
        case .sendMessageAndAttention:
            initSendMessageAndAttentionlUI()
        default:
            break;
        }
    }
    
    func initNormalUI() {
        addSubview(centerBtn)
    }
    
    
    func initSendMessagelUI() {
        centerBtn.show()
        leftBtn.hide()
        rightBtn.hide()
        
        addSubview(centerBtn)
        centerBtn .setTitle(R.string.localizable.sendMessage(), for: .normal)
    }
    
    func initAttentionUI() {
        centerBtn.show()
        leftBtn.hide()
        rightBtn.hide()
        
        addSubview(centerBtn)
        centerBtn.setTitle(R.string.localizable.follow(), for: .normal)
    }
    
    func initSendMessageAndAttentionlUI() {
        centerBtn.hide()
        leftBtn.show()
        rightBtn.show()
        
        addSubview(leftBtn)
        leftBtn.setTitle(R.string.localizable.follow(), for: .normal)
        
        addSubview(rightBtn)
        rightBtn.setTitle(R.string.localizable.sendMessage(), for: .normal)
    }

    lazy var centerBtn: QMUIButton = {
        let r = ViewFactoryUtil.primaryHalfFilletButton()
        r.setTitle("确认", for: .normal)
        return r
    }()
    
    
    lazy var leftBtn: QMUIButton = {
        let r = ViewFactoryUtil.primaryHalfFilletButton()
        r.setTitle("确认", for: .normal)
        return r
    }()
    
    
    lazy var rightBtn: QMUIButton = {
        let r = ViewFactoryUtil.primaryHalfFilletButton()
        r.setBackgroundColor(color: .colorBackgroundAPP, forState: .normal)
        r.setTitleColor(.black70, for: .normal)
        r.setTitle("取消", for: .normal)
        return r
    }()
    
    
    
}

