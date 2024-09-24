//
//  UserTagView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/8/30.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import UIKit
import TangramKit
class UserTagView: TGLinearLayout {


    init() {
        super.init(frame: .zero, orientation: .horz)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initViews()
    }
    
    func initViews()  {
        tg_width.equal(.wrap)
        tg_height.equal(.wrap)
//        backgroundColor = .white
        tg_space = PADDING_SMALL
        let tap = UITapGestureRecognizer(target: self, action: #selector(gotoLinke))
        addGestureRecognizer(tap)
    }

    func addThirdUI() {
        let r = Int.random(in: 3...3)
        let array = Array(repeating: "", count: r)
        let imageArr = ["tag_vip", "tag_blog", "tag_company", "youtube"]
        let dataArr = ["VIP2", "博客".innerLocalized(), "企业".innerLocalized(), "YouTube"]
        
        let height = 12
        for index  in array.indices {
            
            let r = UserTagTypeView()
            print(index, index.hashValue)
            r.tagType = userTagType(rawValue: index) ?? .company
            r.updateUI()
            r.tg_width.equal(.wrap)
            r.tg_height.equal(height)
            
//            let top = (index / 2) * 44
            r.tg_top.equal(0)
//            r.bindData(title:dataArr[index], image:imageArr[index])
//            if (index % 2 == 0) {
//                r.tg_left.equal(0)
//            } else {
//                r.tg_right.equal(0)
//            }
            
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

