//
//  BoBShowVoucherView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/25.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
class BoBShowVoucherView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        innerInit()
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func innerInit() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5) // 半透明背景
        addSubview(voucherImageView)
        addSubview(closeBtn)
        voucherImageView.snp_makeConstraints { make in
            make.width.equalTo(300)
            make.height.equalTo(649)
            make.centerX.equalTo(0)
            make.centerY.equalTo(-32)
        }
        closeBtn.snp_makeConstraints { make in
            make.centerX.equalTo(0)
            make.top.equalTo(voucherImageView.snp_bottom).offset(20)
            make.width.height.equalTo(44)
        }
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe { [weak self] _ in
            self?.hideMask()
        }.disposed(by: rx.disposeBag)
        addGestureRecognizer(tap)
    }
    // 自定义弹框视图
    func showMask(view: UIView) {
        self.frame = view.bounds
        view.addSubview(self)
        // 动画显示遮罩
        alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
    }
    
    // 隐藏遮罩
    func hideMask() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }
    lazy var voucherImageView: UIImageView = {
        let r = UIImageView()
        r.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe { [weak self] _ in
        }.disposed(by: rx.disposeBag)
        r.addGestureRecognizer(tap)
        return r
    }()
    lazy var closeBtn: QMUIButton = {
        let r = QMUIButton()
        r.setImage(UIImage(named: "order_detail_show_voucher_close_icon"), for: .normal)
        r.rx.tap.subscribe(onNext: { [weak self] in
            self?.hideMask()
        }).disposed(by: rx.disposeBag)
        return r
    }()
}
