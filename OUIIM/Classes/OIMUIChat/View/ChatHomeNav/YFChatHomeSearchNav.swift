//
//  YFChatHomeSearchNav.swift
//  OUIIM
//
//  Created by mac on 2024/10/9.
//

import Foundation
import OUICore

class YFChatHomeSearchNav: UIView {
    lazy var searchView: tableHeaderSearchView = {
        let  r = tableHeaderSearchView()
//        r.backgroundColor = .green
        return r
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        addSubview(searchView)
        searchView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(kStatusBarHeight)
            make.height.equalTo(52)
        }
//        backgroundColor = .red
        snp.makeConstraints { make in
            make.height.equalTo(kStatusBarHeight + 52)
        }
    }
    
}
