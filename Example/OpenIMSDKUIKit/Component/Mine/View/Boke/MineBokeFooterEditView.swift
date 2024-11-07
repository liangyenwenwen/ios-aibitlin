//
//  MineBokeFooterEditView.swift
//  MyCloudMusic
//
//  Created by mac on 2024/5/6.
//

import UIKit
import TangramKit
import RxSwift
import RxCocoa


import OUIIM
import OUICore
import ProgressHUD

class MineBokeFooterEditView: TGLinearLayout {

    var editBoke : ((myBlogShowBlogPOModel)->Void)!
    var showBokeOnHome : ((myBlogShowBlogPOModel,Bool)->Void)!
    var deleteBoke : ((myBlogShowBlogPOModel)->Void)!
    var reportBoke : ((myBlogShowBlogPOModel)->Void)!
    var topBlog : ((myBlogShowBlogPOModel)->Void)!
    var shareBlog: ((myBlogShowBlogPOModel)->Void)!
    var type: blogListVCType!
    var blogItem: myBlogShowBlogPOModel!
    
    var onHomeSwitch: UISwitch?
    
    init(type : blogListVCType = .meBlog) {
        super.init(frame: .zero, orientation: .vert)
        self.type = type
        innerInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        innerInit()
    }
    
    func update() {
        bokeCoveImage.show(blogItem.myBlogShowBlogPO.userBlogIcon)
        bokeTitle.text = blogItem.myBlogShowBlogPO.userBlogName
        
        onHomeSwitch?.isOn = YFFileDataUtil.isHaveThisBlog(.home, blogItem: blogItem)
    }
    
    func innerInit() {
        
        corner(MEDDLE_RADIUS)
        tg_width.equal(.fill)
        tg_height.equal(.wrap)
        tg_space = PADDING_OUTER
        tg_gravity = .horz.center
        tg_padding = UIEdgeInsets(top: 15, left: PADDING_MEDDLE, bottom: PADDING_MEDDLE, right: PADDING_MEDDLE)
        backgroundColor = .colorBackgroundAPP
        
        
        addSubview(topContainer)
        if type != .star {
            addSubview(centerContainer)
            addSubview(deleteBtn)
        } else {
            
            var deleteView = SuperSettingView.smallWithIcon(title: "删除博客".localized()) {[weak self] data in
                self?.deleteBoke(self!.blogItem)
                
            }
            deleteView.corner()
            addSubview(deleteView)
        }
       
        
    }

    lazy var topContainer: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(.fill)
//        r.tg_height.equal(.wrap)
        r.tg_height.equal(30)
        r.tg_space = PADDING_MEDDLE
        
        r.addSubview(bokeMessageContainer)
        bokeMessageContainer.addSubview(bokeCoveImage)
        bokeMessageContainer.addSubview(bokeTitle)
        
//        r.addSubview(cancleBtn)
        r.addSubview(cancleView)
        return r
    }()
    
    lazy var bokeMessageContainer: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_width.equal(.fill)
//        r.tg_height.equal(.wrap)
        r.tg_height.equal(30)
        r.tg_space = PADDING_MEDDLE
        r.clipsToBounds = true
        return r
    }()
    lazy var bokeCoveImage: UIImageView = {
        let r = UIImageView()
        r.clipsToBounds = true
        r.contentMode = .scaleAspectFill
        r.layer.cornerRadius = 4
        r.tg_width.equal(30)
        r.tg_height.equal(30)
        r.tg_centerY.equal(0)
        return r
    }()
    
    lazy var bokeTitle: UILabel = {
        let r = ViewFactoryUtil.normalLbael()
//        let r = UILabel()
        r.text = "标题".localized()
        r.textColor = .colorOnBackground
        r.font = .systemFont(ofSize: TEXT_LARGE)
//        r.tg_left.equal(30)
//        r.tg_centerY.equal(10)
        r.tg_height.equal(30)
//        r.tg_right.equal(100)
        return r
    }()
    
    lazy var cancleView: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_width.equal(50)
        r.tg_height.equal(30)
        r.tg_gravity = .horz.right
//        r.backgroundColor = .red
        r.addSubview(cancleBtn)
        let tap = UITapGestureRecognizer(target: self, action: #selector(gkcoverHide))
        r.isUserInteractionEnabled = true
        r.addGestureRecognizer(tap)
        return r
    }()
    
    @objc func gkcoverHide() {
        GKCover.hide()
    }
    
    lazy var cancleBtn: UIImageView = {
//        let r = ViewFactoryUtil.imageBtn(R.image.close_cirle_icon()!)
        let r = ViewFactoryUtil.defalutImgView(R.image.close_cirle_icon()!, 30)
//        r.rx.tap.subscribe(onNext: {
//            
//            GKCover.hide()
//        })
//        .disposed(by: rx.disposeBag)
        return r
    }()
    
    
    
    lazy var centerContainer: TGLinearLayout = {
        let r = TGLinearLayout(.vert)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_space = 1
        r.corner(MEDDLE_RADIUS)
        r.backgroundColor = .white
        
        
        
        if type == .meBlog {
            //我的好友
            var editView = SuperSettingView.smallWithIcon(title: "编辑".localized()) {[weak self] data in
                self?.editBoke(self!.blogItem)
            }
            r.addSubview(editView)
            r.addSubview(ViewFactoryUtil.smallDivider())
        } else {
            var addBoke = SuperSettingView.smallWithIcon(title: "添加到我的快捷博客".localized()) {[weak self] data in
                print("ADD")
            }
            r.addSubview(addBoke)
            r.addSubview(ViewFactoryUtil.smallDivider())
        }
        
        
        
        var showHomeView = SuperSettingView.create(title: "显示在我的个人主页".localized()) { data in
            
        } switchChanged: { [weak self] data in
            print("\(data.isOn)")
            self?.showBokeOnHome(self!.blogItem, data.isOn)
        }
        onHomeSwitch = showHomeView.superSwitch
        r.addSubview(showHomeView)
        showHomeView.superSwitch.isOn = true
        r.addSubview(ViewFactoryUtil.smallDivider())
        
        
        if type == .meBlog {
            
            var shareView = SuperSettingView.onlylTitle("博客置顶".localized(), click: { [weak self] data in
                print("博客置顶")
                self?.topBlog(self!.blogItem)
            })
            r.addSubview(shareView)
            r.addSubview(ViewFactoryUtil.smallDivider())
        }
        
        
        var shareView = SuperSettingView.onlylTitle("分享给好友".localized(), click: { [weak self] data in
            self!.shareBlog(self!.blogItem)
        })
        r.addSubview(shareView)
        

        
        return r
    }()
    
    lazy var deleteBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton()
        r.setTitle( type != .othersBlog ? "删除博客".localized() : "举报".localized(), for: .normal)
        r.setTitleColor(.black80, for: .normal)
//        r.addTarget(self, action: #selector(disagreeClick(_:)), for: .touchUpInside)
        r.rx.tap.subscribe(onNext: { [weak self] in
            if self?.type != .othersBlog {
                self?.deleteBoke(self!.blogItem)
            } else {
                self?.reportBoke(self!.blogItem)
            }
        })
        .disposed(by: rx.disposeBag)
        r.sizeToFit()
        return r
    }()
    
}
