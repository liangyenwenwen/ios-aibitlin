//
//  ChatServiceSystemMessgaeCell.swift
//  OUICore
//
//  Created by mac on 2025/4/29.
//

import Foundation
class ChatServiceSystemMessgaeCell: UITableViewCell {
    var moreMessageBlock:(()->Void)!
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        self.backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(bgView)
        bgView.addSubview(iconImageView)
        bgView.addSubview(titleNameLabel)
        bgView.addSubview(contentLabel)
        bgView.addSubview(timeLabel)
        bgView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.bottom.equalTo(0)
        }
        iconImageView.snp_makeConstraints { make in
            make.left.equalTo(14)
            make.top.equalTo(12)
            make.width.height.equalTo(26)
        }
        titleNameLabel.snp_makeConstraints { make in
            make.left.equalTo(iconImageView.snp_right).offset(5)
            make.right.equalTo(-14)
            make.centerY.equalTo(iconImageView.snp_centerY)
        }
        contentLabel.snp_makeConstraints { make in
            make.top.equalTo(iconImageView.snp_bottom).offset(10)
            make.left.equalTo(iconImageView)
            make.right.equalTo(titleNameLabel)
        }
        timeLabel.snp_makeConstraints { make in
            make.top.equalTo(contentLabel.snp_bottom).offset(10)
            make.left.right.equalTo(contentLabel)
            make.height.equalTo(20)
            make.bottom.equalTo(bgView.snp_bottom).offset(-12)
        }
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var bgView: UIView = {
        let r = UIView()
        r.backgroundColor = .white
        r.layer.cornerRadius = 12
        return r
    }()
    lazy var iconImageView: UIImageView = {
        let r = UIImageView()
        r.corner(radius: 4)
        return r
    }()
    
    lazy var titleNameLabel:  UILabel = {
        let r = UILabel()
        r.font = UIFont(name: "PingFangSC-Semibold", size: 16)
        r.textColor = .init(hexString: "#333333")
        r.numberOfLines = 1
        return r
    }()
    lazy var contentLabel:  UILabel = {
        let r = UILabel()
        r.font = UIFont(name: "PingFangSC-Medium", size: 14)
        r.textColor = .init(hexString: "#666666")
        r.numberOfLines = 0
        return r
    }()
    lazy var timeLabel:  UILabel = {
        let r = UILabel()
        r.font = UIFont(name: "PingFangSC-Regular", size: 11)
        r.textColor = .init(hexString: "#666666")
        return r
    }()
    
}

