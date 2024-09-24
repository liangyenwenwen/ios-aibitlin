//
//  YFTitleAddUnderlineChooseView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/5/9.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import UIKit
import TangramKit

class YFTitleAddUnderlineChooseView: TGLinearLayout {

    var viewClick:(()->Void)!
    
    init() {
        super.init(frame: CGRect.zero, orientation: .vert)
        initViews()
        initListeners()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViews()
        initListeners()
    }

    func initViews()  {
        addSubview(titleLbl)
        addSubview(underlineView)
    }
    
    func initListeners() {
        isUserInteractionEnabled = true
        
        //点击
        let tapGestureRecognizer=UITapGestureRecognizer(target: self, action: #selector(onTapClick(_:)))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func onTapClick(_ data:UITapGestureRecognizer) {
        print(#file, #function)
        if let r = viewClick {
            r()
        }
    }
    
    lazy var titleLbl: UILabel = {
        let r = UILabel()
        r.tg_width.equal(.fill)
        r.tg_height.equal(.fill)
        r.textAlignment = .center
        r.font = .boldSystemFont(ofSize: TEXT_LARGE3)
        r.textColor = .colorOnBackground
        r.text = "text"
        
        return r
    }()
    
    lazy var underlineView: UIView = {
        let r = UIView()
        r.tg_width.equal(.fill)
        r.tg_height.equal(1)
        r.backgroundColor = .colorOnBackground
        return r
    }()
    
    func setData(_ title: String, _ isChoose : Bool = false)  {
        titleLbl.text = title
        refresUI(isChoose)
    }
    
    func refresUI(_ isChoose: Bool) {
        titleLbl.textColor = isChoose ? .colorOnBackground : .placeholder
        underlineView.backgroundColor  = isChoose ? .colorOnBackground : .clear
        let height = isChoose ? 2 : 1
        underlineView.tg_height.equal(height)
    }
    
}
