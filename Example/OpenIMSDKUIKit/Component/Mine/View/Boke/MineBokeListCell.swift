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
        
//        container.addSubview(chooseImg)
//        container.addSubview(bokeIcon)
        container.addSubview(topView)
        container.backgroundColor = .white
        
        container.addSubview(bokeMessageContainer)
//        bokeMessageContainer.backgroundColor = .red
        
        container.addSubview(moreView)
        
        container.tg_gravity = .vert.center
        
//        moreImg.backgroundColor = .red
//        moreImg.snp.makeConstraints { make in
//            make.centerY.equalTo(bokeTitle.snp_centerY)
//        }
        
//        contentView.addSubview(moreClickView)
//        moreClickView.snp.makeConstraints { make in
//            make.top.left.equalTo(moreImg).offset(-5)
//            make.right.bottom.equalTo(moreImg).offset(5)
//        }
    }

    lazy var topView: TGRelativeLayout = {
        let r = TGRelativeLayout()
        r.addSubview(bokeIcon)
        r.addSubview(blogStateLbl)
        r.tg_width.equal(66)
        r.tg_height.equal(66)
        
        r.tg_centerY.equal(0)
        
        blogStateLbl.tg_bottom.equal(0)
        blogStateLbl.tg_left.equal(0)
        blogStateLbl.tg_right.equal(0)
        blogStateLbl.tg_height.equal(16)
        
        r.corner()
        return r
    }()
    
    lazy var bokeIcon: UIImageView = {
        let r = ViewFactoryUtil.cornerImgView(R.image.defaultAvatar()!, 66)
        r.image = R.image.place_boke_icon()
        r.contentMode = .scaleAspectFill
        return r
    }()

    
    lazy var blogStateLbl: UILabel = {
        let r = ViewFactoryUtil.customTilteLabelFill("state", font: TEXT_SMALL)
        r.textAlignment = .center
        r.textColor = .white
        r.backgroundColor = .black.withAlphaComponent(0.3)
        r.hide()
        return r
    }()
    
    lazy var chooseImg: QMUIButton = {
        let r = ViewFactoryUtil.imageBtn(R.image.moreVerticalDot()!)
        r.tg_centerY.equal(0)
        return r
    }()
    
    lazy var moreView: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(50)
        r.tg_height.equal(50)
        r.tg_centerY.equal(-19)
//        r.backgroundColor = .red
        r.addSubview(moreImg)
        r.tg_gravity = .center
        let tap = UITapGestureRecognizer(target: self, action: #selector(moreDidClicked))
        r.isUserInteractionEnabled = true
        r.addGestureRecognizer(tap)
//        r.addTarget(self, action: #selector(moreDidClicked), for: .touchUpInside)
        return r
    }()
    
    
    
    lazy var moreImg: QMUIButton = {
        let r = ViewFactoryUtil.imageBtn(R.image.tabMoreSelected()!)
//        r.tg_centerY.equal(-19)
        r.isUserInteractionEnabled = false
//        r.backgroundColor = .green
//        r.tg_centerY.equal(<#T##origin: Int##Int#>)
//        r.centerYAnchor.constraint(equalTo: bokeTitle.centerYAnchor)
//        r.addTarget(self, action: #selector(moreDidClicked), for: .touchUpInside)
        return r
    }()
    
    lazy var moreClickView: UIView = {
        let r = UIView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(moreDidClicked))
        r.addGestureRecognizer(tap)
        r.backgroundColor = .red.withAlphaComponent(0.3)
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
        r.addSubview(blogStateImg)
        r.addSubview(bokeTitle)
        
//        r.addSubview(moreImg)
        
//        r.backgroundColor = .red
//        r.addSubview(stateLbl)
//        r.addSubview(ViewFactoryUtil.primaryHalfFilletButton())
        r.tg_gravity = .vert.center
        return r
    }()
    
    
    lazy var bokeTitle: UILabel = {
        let r = ViewFactoryUtil.customBoldTilteLable("标题")
        r.tg_width.equal(.fill)
        r.numberOfLines = 1
        return r
    }()
    
    lazy var stateLbl: QMUILabel = {
        let r = QMUILabel()
        r.text = "处理中"
        r.font = .systemFont(ofSize: 12)
        r.tg_width.equal(.wrap)
        r.tg_height.equal(.wrap)
//        r.border(.red)
        r.contentEdgeInsets = UIEdgeInsets(horizontal: 5, vertical: 2)
        r.hide()
        return r
    }()
    
    lazy var blogStateImg: UIImageView = {
        let r = ViewFactoryUtil.defalutImgView(R.image.blog_state_1()!, 14)
        return r
    }()
    
    lazy var bokeContent: UILabel = {
        let r = ViewFactoryUtil.customTilteLabelFill("博客内容博客内容博客内容博客内容博客内容博客内容博客内容博客内容博客内容博客内容", font: TEXT_SMALL, textColor: .black666)
        r.numberOfLines = 1
        r.tg_width.equal(.fill)
        r.tg_right.equal(80)
        r.tg_height.equal(12)
        return r
    }()
    
    
    func bindData(_ item: blogDetailItem)  {
        bokeIcon.show(item.userBlogIcon)
        bokeTitle.text = item.userBlogName
        bokeContent.text = item.userBlogIntro
        
        switch item.state {
        case .normal:
            blogStateLbl.hide()
            stateLbl.hide()
            blogStateImg.hide()
            break
        case .wait:
            blogStateLbl.hide()
            stateLbl.show()
            blogStateImg.show()
            blogStateLbl.text = "处理中".localized()
            stateLbl.text = "处理中".localized()
            stateLbl.textColor = .orange
            stateLbl.border(.orange, cornerRadius: 2)
            blogStateImg.image = R.image.blog_state_1()!
        case .refuse:
            blogStateLbl.hide()
            stateLbl.show()
            blogStateImg.show()
            blogStateLbl.text = "拒绝".localized()
            stateLbl.text = "拒绝".localized()
            stateLbl.textColor = .red
            stateLbl.border(.red, cornerRadius: 2)
            blogStateImg.image = R.image.blog_state_3()!
        case .limit:
            blogStateLbl.hide()
            stateLbl.show()
            blogStateImg.show()
            blogStateLbl.text = "受限制".localized()
            stateLbl.text = "受限制".localized()
            stateLbl.textColor = .red
            stateLbl.border(.red, cornerRadius: 2)
            blogStateImg.image = R.image.blog_state_2()!
        }
    }
    
    
    @objc func moreDidClicked() {
        editBlock()
    }
    
    func isClean() {
        moreImg.hide()
    }
}
