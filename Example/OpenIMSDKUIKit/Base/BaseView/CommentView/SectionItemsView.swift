//
//  SectionItemsView.swift
//  MyCloudMusic
//
//  Created by mac on 2024/4/29.
//

import UIKit
import TangramKit

/// 最多10个元素
class SectionItemsView: TGLinearLayout {

    var bokeClick:((blogDetailItem, Bool)->Void)?
    var commendbokeClick:((blogDetailItem, Bool, Int)->Void)?
    
    init() {
        super.init(frame: .zero, orientation: .vert)
        innerInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        innerInit()
    }
    
    func innerInit() {
        
        corner(MEDDLE_RADIUS)
        tg_width.equal(.fill)
        tg_height.equal(.wrap)
        
        addSubview(topContainer)
        addSubview(bottomContainer)
        
        topContainer.hide()
        bottomContainer.hide()
    }
    
    ///绑定blog数据
    func updateNet(data:Array<Any>)  {
        if data.count == 0 {
            topContainer.hide()
            bottomContainer.hide()
        } else if data.count < 6 {
            topContainer.show()
            bottomContainer.hide()
            for index in topContainer.subviews.indices {
                let item = topContainer.subviews[index] as! SectionItemView
                if index < data.count {
                    item.show()
                    item.bindDataNet(data[index] as! blogDetailItem)
                } else {
                    item.hide()
                }
            }
        } else {
            topContainer.show()
            bottomContainer.show()
            for index in topContainer.subviews.indices {
                let item = topContainer.subviews[index] as! SectionItemView
                item.bindDataNet(data[index] as! blogDetailItem)
                item.show()
            }
            
            for index in bottomContainer.subviews.indices {
                let item = bottomContainer.subviews[index] as! SectionItemView
                if index + 5 < data.count {
                    item.show()
                    
                    if data.count > 9 && index == 4 {
                        item.bindDataNet(data[index + 5] as! blogDetailItem, true)
                    } else {
                        item.bindDataNet(data[index + 5] as! blogDetailItem)
                    }
                    
                } else {
                    item.hide()
                }
            }

        }
    }
    
    ///更新我的推荐博客
    func updateRecommendData() {
        let moreBoke = blogDetailItem(id: -1, sign: 0, userBlogUrl: "", userBlogIntro: "", userBlogName: "", userBlogCreatIp: "", userBlogCreatAffiliatingArea: "", userBlogOrder: 0, userId: "", isDelete: 0, creationTime: "", userBlogIcon: "", changeTime: "")
        
        let data = YFFileDataUtil.readDataToFile(false)
        
        topContainer.show()
        bottomContainer.hide()
        for index in topContainer.subviews.indices {
            let item = topContainer.subviews[index] as! SectionItemView
            item.index = index
            if index < data.count {
                item.show()
                item.bindDataNet(data[index])
            } else {
                item.hide()
            }
        }
        
        if data.count < 3 {
            
            for index in data.count...2 {
                let item = topContainer.subviews[index] as! SectionItemView
                item.index = data.count
                item.show()
                item.bindDataNet(moreBoke, true, isRecommend: true)
            }
            
        }
        
    }
    
    
    
    
//    func update(data:Array<Any>)  {
//        if data.count == 0 {
//            topContainer.hide()
//            bottomContainer.hide()
//        } else if data.count < 6 {
//            topContainer.show()
//            bottomContainer.hide()
//            for index in topContainer.subviews.indices {
//                let item = topContainer.subviews[index] as! SectionItemView
//                if index < data.count {
//                    item.show()
//                    item.bindData(data[index] as! BokeItemStruct)
//                } else {
//                    item.hide()
//                }
//            }
//        } else {
//            topContainer.show()
//            bottomContainer.show()
//            for index in topContainer.subviews.indices {
//                let item = topContainer.subviews[index] as! SectionItemView
//                item.bindData(data[index] as! BokeItemStruct)
//                item.show()
//            }
//            
//            for index in bottomContainer.subviews.indices {
//                let item = bottomContainer.subviews[index] as! SectionItemView
//                if index + 5 < data.count {
//                    item.show()
//                    
//                    if data.count > 9 && index == 4 {
//                        let item = bottomContainer.subviews[4] as! SectionItemView
//                        item.bindData(TestDataUtil.moreBokeItemStruct)
//                    } else {
//                        item.bindData(data[index + 5] as! BokeItemStruct)
//                    }
//                    
//                } else {
//                    item.hide()
//                }
//            }
//
//        }
//    }
    
    
    lazy var topContainer: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_space = PADDING_OUTER
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_padding = UIEdgeInsets(top: 0, left: PADDING_OUTER, bottom: PADDING_MEDDLE, right: PADDING_OUTER)
        
        for index in 0..<5 {
            let itemView  = SectionItemView()
            r.addSubview(itemView)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(itemClick(_:)))
            itemView.addGestureRecognizer(tap)
        }
        return r
    }()
    
    lazy var bottomContainer: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_space = PADDING_OUTER
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.tg_padding = UIEdgeInsets(top: 0, left: PADDING_OUTER, bottom: PADDING_OUTER, right: PADDING_MEDDLE)
        
        for index in 0..<5 {
            let itemView  = SectionItemView()
            r.addSubview(itemView)
            let tap = UITapGestureRecognizer(target: self, action: #selector(itemClick(_:)))
            itemView.addGestureRecognizer(tap)
        }
        return r
    }()
    

    @objc func itemClick(_ sender: UITapGestureRecognizer) {
        var r = sender.view as! SectionItemView
        
        if bokeClick != nil {
            bokeClick!(r.item, r.isMore)
        }
       
        if commendbokeClick != nil {
            commendbokeClick!(r.item, r.isMore, r.index)
        }
       
    }
    
    
}



class SectionItemView: TGLinearLayout {
    
    let itemWidth = (SCREEN_WIDTH - PADDING_OUTER * 8) / 5.0
    var item: blogDetailItem!
    var isMore: Bool = false
    var isRecommend: Bool = false
    var index: Int = 0
    
    init() {
        super.init(frame: .zero, orientation: .vert)
        innerInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        innerInit()
    }
    
    func innerInit() {
        
        tg_width.equal(itemWidth)
        tg_height.equal(itemWidth * 1.6)
        
        addSubview(topView)
        addSubview(titleLbl)
    }
    
    lazy var topView: TGRelativeLayout = {
        let r = TGRelativeLayout()
        r.addSubview(topImg)
        r.addSubview(blogStateLbl)
        r.tg_width.equal(itemWidth)
        r.tg_height.equal(itemWidth)
        r.tg_top.equal(8)
        
        blogStateLbl.tg_bottom.equal(0)
        blogStateLbl.tg_left.equal(0)
        blogStateLbl.tg_right.equal(0)
        blogStateLbl.tg_height.equal(16)
        
        r.corner()
        return r
    }()
    
    
    lazy var topImg : UIImageView = {
        let r =  ViewFactoryUtil.cornerImgView(R.image.place_boke_icon()!)
        r.tg_width.equal(itemWidth)
        r.tg_height.equal(itemWidth)
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
    
    
    lazy var titleLbl: UILabel = {
        let r = ViewFactoryUtil.normalLbael()
        r.textAlignment = .center
        r.tg_width.equal(.fill)
        r.tg_height.equal(.fill)
        r.tg_top.equal(8)
        return r
    }()
    
    func bindData(_ bokeItem: BokeItemStruct) {
        
        if bokeItem == TestDataUtil.moreBokeItemStruct {
            topImg.image = R.image.boke_more_icon()
        } else {
            topImg.show(bokeItem.icon)
        }
        
        switch bokeItem.state {
        case .normal:
            blogStateLbl.hide()
            break
        case .wait:
            blogStateLbl.show()
            blogStateLbl.text = "处理中".localized()
        case .refuse:
            blogStateLbl.show()
            blogStateLbl.text = "拒绝".localized()
        case .limit:
            blogStateLbl.show()
            blogStateLbl.text = "受限制".localized()
        }
        
        titleLbl.text = bokeItem.title
    }
    
    func bindDataNet(_ bokeItem: blogDetailItem, _ ismore: Bool = false, isRecommend: Bool = false) {

        switch bokeItem.state {
        case .normal:
            blogStateLbl.hide()
            break
        case .wait:
            blogStateLbl.show()
            blogStateLbl.text = "处理中".localized()
        case .refuse:
            blogStateLbl.show()
            blogStateLbl.text = "拒绝".localized()
        case .limit:
            blogStateLbl.show()
            blogStateLbl.text = "受限制".localized()
        }
        
        titleLbl.text = bokeItem.userBlogName
        print(bokeItem.userBlogIcon)
        topImg.show(bokeItem.userBlogIcon)
        

        if ismore {
            topImg.image = R.image.boke_more_icon()
        }
        
        if isRecommend {
            topImg.image = R.image.add_recommend_blog_icon()!
            titleLbl.text = ""
        }
        
        isMore = ismore
        
        item = bokeItem
    }
    
}
