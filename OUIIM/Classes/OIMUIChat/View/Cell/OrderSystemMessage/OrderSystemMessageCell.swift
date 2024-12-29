//
//  OrderSystemMessageCell.swift
//  OUIIM
//
//  Created by mac on 2024/12/23.
//

import Foundation
class OrderSystemMessageCell: UITableViewCell {
    var moreMessageBlock:(()->Void)!
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        self.backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(topCornerView)
        contentView.addSubview(timeBottomCornerView)
        contentView.addSubview(bgView)
        bgView.addSubview(titleNameLabel)
        bgView.addSubview(orderNumberLabel)
        bgView.addSubview(timeLabel)
        bgView.addSubview(lineView)
        bgView.addSubview(bottomView)
        topCornerView.snp_makeConstraints { make in
            make.left.right.top.equalTo(bgView)
            make.height.equalTo(24)
        }
        bgView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.bottom.equalTo(0)
        }
        timeBottomCornerView.snp_makeConstraints { make in
            make.left.right.bottom.equalTo(bgView)
            make.height.equalTo(24)
        }
        titleNameLabel.snp_makeConstraints { make in
            make.left.equalTo(14)
            make.right.equalTo(-14)
            make.top.equalTo(12)
            make.width.height.equalTo(20)
        }
        orderNumberLabel.snp_makeConstraints { make in
            make.top.equalTo(titleNameLabel.snp_bottom).offset(8)
            make.left.right.equalTo(titleNameLabel)
            make.height.equalTo(20)
        }
        timeLabel.snp_makeConstraints { make in
            make.top.equalTo(orderNumberLabel.snp_bottom).offset(10)
            make.left.right.equalTo(titleNameLabel)
            make.height.equalTo(20)
        }
        lineView.snp_makeConstraints { make in
            make.top.equalTo(timeLabel.snp_bottom).offset(10)
            make.left.right.equalTo(titleNameLabel)
            make.height.equalTo(1)
        }
        bottomView.snp_makeConstraints { make in
            make.top.equalTo(lineView.snp_bottom)
            make.left.right.equalTo(0)
            make.height.equalTo(40)
        }
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func moreMessage() {
        if self.moreMessageBlock != nil{
            self.moreMessageBlock()
        }
    }
    lazy var topCornerView: UIView = {
        let r = UIView()
        r.backgroundColor = .white
        r.isHidden = true
        return r
    }()
    lazy var bgView: UIView = {
        let r = UIView()
        r.backgroundColor = .white
        r.layer.cornerRadius = 12
        return r
    }()
    
    lazy var titleNameLabel:  UILabel = {
        let r = UILabel()
        r.font = UIFont(name: "PingFangSC-Semibold", size: 16)
        r.textColor = .init(hexString: "#333333")
        return r
    }()
    lazy var timeBottomCornerView: UIView = {
        let r = UIView()
        r.backgroundColor = .white
        r.isHidden = true
        return r
    }()
    lazy var orderNumberLabel:  UILabel = {
        let r = UILabel()
        r.font = UIFont(name: "PingFangSC-Semibold", size: 14)
        r.textColor = .init(hexString: "#666666")
        return r
    }()
    lazy var timeLabel:  UILabel = {
        let r = UILabel()
        r.font = UIFont(name: "PingFangSC-Regular", size: 12)
        r.textColor = .init(hexString: "#666666")
        return r
    }()
    lazy var lineView: UIView = {
        let r = UIView()
        r.backgroundColor = .init(hexString: "#F5F5F5")
        return r
    }()
    lazy var bottomView: UIView = {
        let r = UIView()
        r.addSubview(unReadNumberLabel)
        r.addSubview(messageCountTitleLabel)
        r.addSubview(icon)
        unReadNumberLabel.snp_makeConstraints { make in
            make.left.equalTo(14)
            make.centerY.equalTo(r)
            make.width.height.equalTo(16)
        }
        messageCountTitleLabel.snp_makeConstraints { make in
            make.left.equalTo(34)
//            make.left.equalTo(14)
            make.centerY.equalTo(r)
            make.right.equalTo(icon.snp_left).offset(-16)
        }
        icon.snp_makeConstraints { make in
            make.right.equalTo(-14)
            make.centerY.equalTo(r)
            make.width.height.equalTo(16)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(moreMessage))
        r.addGestureRecognizer(tap)
        return r
    }()
    lazy var unReadNumberLabel: UILabel = {
        let r = UILabel()
        r.backgroundColor = .init(hexString: "#FD5344")
        r.textColor = .white
        r.font = UIFont(name: "PingFangSC-Regular", size: 11)
        r.layer.masksToBounds = true
        r.layer.cornerRadius = 8
        r.textAlignment = .center
        return r
    }()
    lazy var messageCountTitleLabel: UILabel = {
        let r = UILabel()
        r.textColor = .init(hexString: "#666666")
        r.font = UIFont(name: "PingFangSC-Medium", size: 14)
        return r
    }()
    lazy var icon: UIImageView = {
        let r = UIImageView()
        return r
    }()
    
}

