//
//  TabMoreView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/4/18.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit

class TabMoreView: UIView {
    
    //数据源
    var actionItems:[MenuItem] = []
    var itemArr:[ItemView?]? = []


    private var disposeBag = DisposeBag()
    let frame_width = UIScreen.main.bounds.width
    let itemwidth = (UIScreen.main.bounds.width - 32) / 4
    var bottomHeight = 0
    
    public func setItems(_ items : [MenuItem]) {
        actionItems = items;
        
        if scrollView == nil {
            addScrollView()
        }
        
//        let centerBgView = UIView()
//        centerBgView.backgroundColor = .init(hexString: "#f5f5f5")
//        centerBgView.corner(6)
//        scrollView?.addSubview(centerBgView)
//        scrollView?.backgroundColor = .red
//        centerBgView.snp.makeConstraints { make in
//            make.leading.equalTo(16)
//            make.width.equalTo(frame_width - 32)
//            make.top.equalTo(0)
//            make.bottom.equalTo(-20)
//        }
        
        for i in items.indices {
            let itemView: ItemView? = ItemView()
            itemView!.setData(item: items[i])
            scrollView?.addSubview(itemView!)
            let leading = i % 4 * (Int(itemwidth))
            let top = 8 + 16 + i / 4 * (90)
            itemView!.snp.makeConstraints { make in
                make.leading.equalTo(leading)
                make.width.equalTo(itemwidth)
//                make.height.equalTo(itemwidth + 28)
                make.top.equalTo(top)
            }
            
            let tapItem = UITapGestureRecognizer()
            tapItem.rx.event.subscribe {  _ in
                print(i)
                items[i].action()
            }.disposed(by: disposeBag)
            itemView!.addGestureRecognizer(tapItem)
            
            if itemArr == nil {
                itemArr = [ItemView]()
                itemArr!.append(itemView)

            } else {
                itemArr!.append(itemView)

            }

            
        }

//        let heightRow = (items.count - 1) / 4  + 1
        
        let height = 196
        let width = Int(frame_width - 32)
        scrollView!.contentSize = CGSize(width: width, height: height)
        
//        let bottomHeight = height > 400 ? 400 : height
//        self.bottomHeight = bottomHeight
        self.bottomHeight = 252
        
        bottomView.snp.updateConstraints { make in
            make.height.equalTo(252)
        }
        bottomShow(show: true)
    }
    
    lazy var bottomView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.clipsToBounds =  true
        return v
    }()
    
//    lazy var centerBgView: UIView = {
//        let r = UIView()
//        r.backgroundColor = .init(hexString: "#F5F5F5")
//        r.corner(8)
//        return r
//    }()
    
    lazy var tipsLbl : UILabel = {
        let v = UILabel()
        v.text = R.string.localizable.toolbox()
        v.textColor = .gray
        v.font = UIFont.systemFont(ofSize: 14)
        return v
    }()
    
//    lazy var scrollView: UIScrollView = {
//        let v = UIScrollView()
//        v.showsVerticalScrollIndicator = false
//        return v
//    }()
    
    var scrollView: UIScrollView?
    
    lazy var lineView: UIView = {
        let v = UIView()
        v.backgroundColor = .init(hexString: "#CCCCCC");
        v.layer.cornerRadius = 2
        return v;
    }()
    
    lazy var bottomLineView: UIView = {
        let v = UIView()
        v.backgroundColor = .gray.withAlphaComponent(0.2);
        return v;
    }()
    
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        backgroundColor = .black.withAlphaComponent(0.0)
        
        
        addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.snp.bottom)
            make.height.equalTo(252)
        }
        bottomView.layer.cornerRadius = 10
        bottomView.layer.maskedCorners  = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
   
        bottomView.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.width.equalTo(50)
            make.height.equalTo(4)
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
        }
        
//        bottomView.addSubview(tipsLbl)
//        tipsLbl.snp.makeConstraints { make in
//            make.centerY.equalTo(lineView)
//            make.trailing.equalTo(-20)
//        }
        
        
        
        bottomView.addSubview(bottomLineView)
        bottomLineView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        addScrollView()
        
    }
    
    func addScrollView() {
        scrollView = UIScrollView()
        bottomView.addSubview(scrollView!)
        scrollView?.showsVerticalScrollIndicator = false
//        scrollView?.addSubview(centerBgView)
        scrollView?.backgroundColor = .init(hexString: "#f5f5f5")
        scrollView?.corner(8)
        scrollView!.snp.makeConstraints { make in
            make.top.equalTo(36)
            make.leading.equalTo(16)
            make.trailing.equalTo(-16)
//            make.bottom.trailing.equalToSuperview()
            make.height.equalTo(196)
        }
    }
    
    
    //点击bottom区域外 消失
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        let view = bottomView
        let point = touch.location(in: self)
        let tPoint = view.convert(point, from: self)
        if view.point(inside: tPoint, with: event) {return}
        bottomShow(show: false)
    }
    
    
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public struct MenuItem {
        let title: String
        let icon: UIImage?
        let action: () -> Void
        public init(title: String, icon: UIImage?, action: @escaping () -> Void) {
            self.title = title
            self.icon = icon
            self.action = action
        }
    }
    
    
    class ItemView: UIView {
        
        private var itemData:MenuItem = MenuItem(title: "标题", icon: nil) {
            
        }
        
        deinit {
            print("释放 \(itemData.title)")
        }
        let iconImageView: UIImageView = {
            let v = UIImageView()
            return v
        }()

        let titleLabel: UILabel = {
            let v = UILabel()
            v.font = .regularFont(14)
            v.textColor = .init(hexString: "#333333")
            return v
        }()
        
        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override init(frame: CGRect) {
            
            super.init(frame: frame)
            addSubview(iconImageView)
            addSubview(titleLabel)
            
//            backgroundColor = .green
//            let itemwidth = (UIScreen.main.bounds.width - 100) / 4
            iconImageView.snp.makeConstraints { make in
                make.top.equalTo(0)
                make.width.height.equalTo(30)
                make.centerX.equalToSuperview()
            }
            
            titleLabel.snp.makeConstraints { make in
                make.top.equalTo(iconImageView.snp.bottom).offset(14)
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview()
            }
            
        }
        
        func setData(item :MenuItem) {
            itemData = item
            iconImageView.image = item.icon
            titleLabel.text = item.title
        }
        
    }

    
    func bottomShow(show:Bool, _ duration: CGFloat = 0.3) {
        
        self.layoutIfNeeded()
        UIView.animate(withDuration: duration) {
            
            self.bottomView.snp.updateConstraints { make in
                make.top.equalTo(self.snp.bottom).offset( show ? -self.bottomHeight : 0)
            }
            self.backgroundColor = .black.withAlphaComponent(show ? 0.3 : 0)
            self.layoutIfNeeded()
        } completion: { [self] _ in
            if !show  {

                disposeBag = DisposeBag()
                
                
                if(scrollView != nil) {
                    scrollView?.removeFromSuperview()
                }
                
                scrollView = nil
                itemArr = nil
                self.backgroundColor = .black.withAlphaComponent(show ? 0.3 : 0)
                self.removeFromSuperview()
            }
        }

    }
}


