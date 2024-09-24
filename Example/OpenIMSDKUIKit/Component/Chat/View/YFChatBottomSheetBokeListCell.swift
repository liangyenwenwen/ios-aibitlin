//
//  YFChatBottomSheetBokeListCell.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/5/18.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import UIKit
import TangramKit

class YFChatBottomSheetBokeListCell: BaseTableViewCell {
    
    
    override func initViews() {
        super.initViews()
        container.tg_padding = UIEdgeInsets(top: PADDING_MEDDLE, left: PADDING_OUTER, bottom: PADDING_MEDDLE, right: PADDING_OUTER)
        
        container.addSubview(bokeIcon)
        container.backgroundColor = .white
        container.addSubview(bokeTitle)
        container.tg_gravity = .vert.center
    }

    
    lazy var bokeIcon: UIImageView = {
        let r = ViewFactoryUtil.cornerImgView(R.image.defaultAvatar()!, 32)
        r.image = R.image.place_boke_icon()
        r.tg_centerY.equal(0)
        return r
    }()
    
    
    func bindData(item: blogDetailItem)  {
//        bokeIcon.show(item.icon)
        bokeIcon.sd_setImage(with: URL(string: item.userBlogIcon), placeholderImage: R.image.defaultAvatar())
        bokeTitle.text = item.userBlogName
    }

    
    
    lazy var bokeTitle: UILabel = {
        let r = ViewFactoryUtil.customBoldTilteLable("标题")
        return r
    }()
    


}
