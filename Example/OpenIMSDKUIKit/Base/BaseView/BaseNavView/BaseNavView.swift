//
//  BaseNavView.swift
//  MyCloudMusic
//
//  Created by mac on 2024/4/28.
//

import UIKit
import TangramKit

class BaseNavView: TGRelativeLayout {

    init() {
        super.init(frame: CGRect.zero)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews()  {
        tg_width.equal(.fill)
        tg_height.equal(52)
        
        addSubview(leftContainer)
        
        addSubview(centerContainer)
        centerContainer.addSubview(titleView)
        
        addSubview(rightContainer)
    }
    
    private lazy var leftContainer: TGLinearLayout = {
        let r=TGLinearLayout(.horz)
        r.tg_gravity = TGGravity.vert.center
        r.tg_space = PADDING_SMALL
        r.tg_leading.equal(12)
        r.tg_trailing.equal(self.centerContainer.tg_leading).offset(PADDING_MEDDLE)
        r.tg_height.equal(.fill)
        return r
    }()
    
     lazy var rightContainer: TGLinearLayout = {
        let r=TGLinearLayout(.horz)
        r.tg_gravity = [TGGravity.vert.center,TGGravity.horz.right]
        r.tg_space = PADDING_SMALL
        r.tg_trailing.equal(12)
        r.tg_leading.equal(self.centerContainer.tg_trailing).offset(PADDING_MEDDLE)
        r.tg_height.equal(.fill)
        r.tg_space = PADDING_MEDDLE
        return r
    }()
    
    
    private lazy var centerContainer: TGLinearLayout = {
        let r = TGLinearLayout(.horz)
        r.tg_gravity = TGGravity.vert.center
        r.tg_leading.equal(12)
        r.tg_centerX.equal(0)
        r.tg_centerY.equal(0)
        r.tg_width.equal(.wrap)
        r.tg_height.equal(.fill)
        return r
    }()
    
    lazy var titleView: UILabel = {
        let r = UILabel()
        r.tg_width.equal(SCREEN_WIDTH - 150)
        r.tg_height.equal(.wrap)
        r.textAlignment = .center
        r.font = UIFont(name: "PingFangSC-Medium", size: 18)
        r.textColor = .black333
        r.numberOfLines = 1
        return r
    }()
}

// MARK: - 留给外面的接口
extension BaseNavView {
    
    @discardableResult
    func addLeftItem(_ data: UIView) -> BaseNavView {
        leftContainer.addSubview(data)
        return self
    }
    
    @discardableResult
    func addCenterItem(_ data: UIView) -> BaseNavView {
        titleView.hide()
        centerContainer.addSubview(data)
        return self
    }
    
    @discardableResult
    func addRighttItem(_ data: UIView) -> BaseNavView {
       
        rightContainer.addSubview(data)
        return self
    }
    
}
