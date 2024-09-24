//
//  UserMessageThridView.swift
//  MyCloudMusic
//
//  Created by mac on 2024/5/7.
//

import UIKit
import TangramKit
class UserMessageThridView: TGRelativeLayout {

    init() {
        super.init(frame: CGRect.zero)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews()  {
        tg_width.equal(.fill)
        tg_height.equal(.wrap)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(gotoLinke))
        addGestureRecognizer(tap)
    }

    func addThirdUI() {
        let r = Int.random(in: 4...4)
        let array = Array(repeating: "", count: r)
        let imageArr = ["facebook", "instagram", "tiktok", "youtube"]
        let dataArr = ["Facebook", "Instagram", "TikTok", "YouTube"]
        let width = (SCREEN_WIDTH - 36 * 2 - 12) / 2
        let height = 36
        
        for index  in array.indices {
            
            let r = UserMessageThridTypeView()
            r.tg_width.equal(width)
            r.tg_height.equal(height)
            
            let top = (index / 2) * 44
            r.tg_top.equal(top)
            r.bindData(title:dataArr[index], image:imageArr[index])
            if (index % 2 == 0) {
                r.tg_left.equal(0)
            } else {
                r.tg_right.equal(0)
            }
            
            addSubview(r)
        }
        
    }
    
    @objc func gotoLinke()  {
        let target = SuperWebController()
        target.uri = "https://www.baidu.com/"
        target.hidesBottomBarWhenPushed = true
        self.viewController()?.navigationController?.pushViewController(target, animated: true)
    }
}

//
//userContainer = TGRelativeLayout()
//userContainer.tg_width.equal(.fill)
//userContainer.tg_height.equal(.wrap)
//userContainer.tg_padding = UIEdgeInsets(top: PADDING_OUTER, left: PADDING_OUTER, bottom: PADDING_OUTER, right: PADDING_OUTER)
//class ItemTitleView: TGRelativeLayout {
//
//    init() {
//        super.init(frame: CGRect.zero)
//        initViews()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func initViews()  {
//        tg_width.equal(.fill)
//        tg_height.equal(.wrap)
//        
//        tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_OUTER, bottom: PADDING_MEDDLE, right: PADDING_OUTER)
//        
//        addSubview(titeView)
//        addSubview(moreIconView)
//    }
    
//    lazy var titeView: UILabel = {
//        let r = ViewFactoryUtil.normalLbael()
//        r.tg_centerY.equal(0)
//        r.font = .systemFont(ofSize: TEXT_LARGE2)
//        r.textColor = .colorOnSurface
//        
//        return r
//    }()
//    
//    lazy var moreIconView: UIImageView = {
//        let r = UIImageView()
//        r.tg_width.equal(15)
//        r.tg_height.equal(15)
//        r.image = R.image.superChevronRight()?.withTintColor()
//        r.tintColor = .black80
//        r.tg_centerY.equal(0)
//        r.tg_right.equal(0)
//        
//        r.contentMode = .scaleAspectFit
//        return r
//    }()
//    
//    
//}
