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
    let itemwidth = (UIScreen.main.bounds.width - 100) / 4
    var bottomHeight = 0
    
    public func setItems(_ items : [MenuItem]) {
        actionItems = items;
        
        
        addScrollView()
        
        for i in items.indices {
            let itemView: ItemView? = ItemView()
            itemView!.setData(item: items[i])
            scrollView!.addSubview(itemView!)
            let leading = 10 + i % 4 * (Int(itemwidth) + 20)
            let top = i / 4 * (Int(itemwidth) + 30)
            itemView!.snp.makeConstraints { make in
                make.leading.equalTo(leading)
                make.width.equalTo(itemwidth)
                make.height.equalTo(itemwidth + 28)
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

        let heightRow = (items.count - 1) / 4  + 1
        
        let height = Int(itemwidth + 30) * heightRow + 70
        let width = Int(frame_width)
        scrollView!.contentSize = CGSize(width: width, height: height - 60)
        
        let bottomHeight = height > 400 ? 400 : height
        self.bottomHeight = bottomHeight
        
        bottomView.snp.updateConstraints { make in
            make.height.equalTo(bottomHeight)
        }
        bottomShow(show: true)
    }
    
    lazy var bottomView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.clipsToBounds =  true
        return v
    }()
    
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
        v.backgroundColor = .black;
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
            make.height.equalTo(0)
        }
        bottomView.layer.cornerRadius = 10
        bottomView.layer.maskedCorners  = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
   
        bottomView.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.height.equalTo(5)
            make.top.equalToSuperview().offset(18)
            make.centerX.equalToSuperview()
        }
        
        bottomView.addSubview(tipsLbl)
        tipsLbl.snp.makeConstraints { make in
            make.centerY.equalTo(lineView)
            make.trailing.equalTo(-20)
        }
        
        
        
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
        scrollView!.snp.makeConstraints { make in
            make.top.equalTo(40)
            make.leading.bottom.trailing.equalToSuperview()
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
            v.font = .systemFont(ofSize: 14)
            v.textColor = .colorOnBackground
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
            let itemwidth = (UIScreen.main.bounds.width - 100) / 4
            iconImageView.snp.makeConstraints { make in
                make.top.equalTo(5)
                make.width.height.equalTo(itemwidth)
                make.centerX.equalToSuperview()
            }
            
            titleLabel.snp.makeConstraints { make in
                make.top.equalTo(iconImageView.snp.bottom).offset(5)
                make.centerX.equalToSuperview()
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


