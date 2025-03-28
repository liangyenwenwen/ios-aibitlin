//
//  MineBokeListCell.swift
//  MyCloudMusic
//
//  Created by mac on 2024/5/6.
//

import UIKit
import TangramKit
class MineBokeListCell: BaseTableViewCell {
    
    var editBlock:(()->Void)!
    
    
    override func initViews() {
        super.initViews()
        container.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_OUTER, bottom: PADDING_MEDDLE, right: PADDING_OUTER)
        container.addSubview(topView)
        container.backgroundColor = .white
        
        container.addSubview(bokeMessageContainer)
        container.addSubview(moreView)
        container.tg_gravity = .vert.center
    }

    lazy var topView: TGRelativeLayout = {
        let r = TGRelativeLayout()
        r.addSubview(bokeIcon)
        r.tg_width.equal(66)
        r.tg_height.equal(66)
        
        r.tg_centerY.equal(0)
        r.corner()
        return r
    }()
    
    lazy var bokeIcon: UIImageView = {
        let r = ViewFactoryUtil.cornerImgView(R.image.defaultAvatar()!, 66)
        r.image = R.image.place_boke_icon()
        r.contentMode = .scaleAspectFill
        return r
    }()
    lazy var moreView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(50)
        r.tg_height.equal(50)
        r.tg_centerY.equal(-19)
        r.addSubview(moreImg)
        r.tg_gravity = .center
        let tap = UITapGestureRecognizer(target: self, action: #selector(moreDidClicked))
        r.isUserInteractionEnabled = true
        r.addGestureRecognizer(tap)
        return r
    }()
    lazy var moreImg: QMUIButton = {
        let r = ViewFactoryUtil.imageBtn(R.image.tabMoreSelected()!)
        r.isUserInteractionEnabled = false
        return r
    }()
    lazy var bokeMessageContainer: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_space = PADDING_OUTER
        r.clipsToBounds = true
        
        r.addSubview(bokeTitleAddStateView)
        r.addSubview(bokeContent)
        
        
        return r
    }()
    
    
    lazy var bokeTitleAddStateView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(.fill)
        r.tg_height.equal(19)
        r.tg_space = PADDING_MEDDLE
        r.addSubview(bokeTitle)
        r.tg_gravity = .vert.center
        return r
    }()
    
    
    lazy var bokeTitle: UILabel = {
        let r = ViewFactoryUtil.customBoldTilteLable("标题")
        r.tg_width.equal(.fill)
        r.numberOfLines = 1
        return r
    }()
    lazy var bokeContent: UILabel = {
        let r = ViewFactoryUtil.customTilteLabelFill(" ", font: TEXT_SMALL, textColor: .black666)
        r.numberOfLines = 1
        r.tg_width.equal(.fill)
        r.tg_right.equal(80)
        r.tg_height.equal(12)
        return r
    }()
    
    
    func bindData(_ item: myBlogShowBlogPOModel)  {
        bokeIcon.show(item.base?.info?.logo)
        bokeTitle.text = item.base?.info?.name
        bokeContent.text = item.base?.info?.mark
    }
    
    
    @objc func moreDidClicked() {
        editBlock()
    }
    
    func isClean() {
        moreImg.hide()
    }
}
