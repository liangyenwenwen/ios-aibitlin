//
//  QuickWindowView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2025/5/7.
//  Copyright © 2025 rentsoft. All rights reserved.
//

import UIKit

class QuickWindowView: UIView {
    lazy var titleLabel: UILabel = {
        let r = UILabel()
        r.textColor = .black333
        r.font = .mediumFont(14)
        return r
    }()
    lazy var countLabel: UILabel = {
        let r = UILabel()
        r.textColor = .black999
        r.font = .regularFont(12)
        r.textAlignment = .right
        return r
    }()
    lazy var iconImageView: UIImageView = {
        let r = UIImageView()
        r.image = R.image.superChevronRight()?.withTintColor()
        r.tintColor = .black999
        return r
    }()
    // 初始化按钮
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(titleLabel)
        addSubview(countLabel)
        addSubview(iconImageView)
        titleLabel.snp_makeConstraints { make in
            make.left.equalTo(8)
            make.centerY.equalToSuperview()
            make.right.equalTo(countLabel.snp_left).offset(-3)
        }
        countLabel.snp_makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.equalTo(15)
            make.right.equalTo(iconImageView.snp_left).offset(-4)
        }
        iconImageView.snp_makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-8)
            make.width.equalTo(4)
            make.height.equalTo(8)
        }
        setupDragGesture()
    }
    
    private func setupDragGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        self.addGestureRecognizer(panGesture)
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let button = gesture.view else { return }
        
        // 在拖动过程中放大按钮1.5倍
        if gesture.state == .began || gesture.state == .changed {
            button.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }
        
        // 改为使用 superview，而不是 view
        let translation = gesture.translation(in: button.superview)
        let newX = button.center.x + translation.x
        let newY = button.center.y + translation.y
        gesture.setTranslation(.zero, in: button.superview)
        
        // 获取父视图信息
        guard let superview = button.superview else { return }
        let screenWidth = superview.bounds.width
        let screenHeight = superview.bounds.height

        let buttonWidth = button.frame.width
        let buttonHeight = button.frame.height

        // 安全区域高度
        let safeAreaTop = superview.safeAreaInsets.top
        let safeAreaBottom = superview.safeAreaInsets.bottom

        // 限制拖动区域（上下限）
        let topLimit = safeAreaTop + 44 // 导航栏下方
        let bottomLimit = screenHeight - safeAreaBottom - buttonHeight - getTabBarHeight() // 标签栏上方

        // 限制边界
        let limitedY = min(max(newY, topLimit + buttonHeight / 2), bottomLimit + buttonHeight / 2)
        let limitedX = min(max(newX, buttonWidth / 2), screenWidth - buttonWidth / 2)

        button.center = CGPoint(x: limitedX, y: limitedY)

        if gesture.state == .ended {
            // 吸附到左侧或右侧
            let finalX: CGFloat = button.center.x < screenWidth / 2
            ? buttonWidth / 2 + 10
            : screenWidth - buttonWidth / 2 - 10
            
            // 弹簧动画
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                button.transform = CGAffineTransform.identity // 恢复原大小
                button.center.x = finalX
            })
        }
        
        
    }
}
