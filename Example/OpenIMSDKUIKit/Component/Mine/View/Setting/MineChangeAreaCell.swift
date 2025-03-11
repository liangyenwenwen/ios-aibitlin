//
//  MineChangeAreaCell.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2025/3/6.
//  Copyright © 2025 rentsoft. All rights reserved.
//

import Foundation
class MineChangeAreaCell: UITableViewCell {
    let titleLabel: UILabel = {
        let v = UILabel()
        v.font = UIFont.systemFont(ofSize: 17)
        v.textColor = DemoUI.color_0C1C33
        return v
    }()

    let selectImageView: UIImageView = UIImageView(image: UIImage(named: "mine_language_check"))
    let iconImageView: UIImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(DemoUI.margin_22)
            make.centerY.equalToSuperview()
            make.width.equalTo(20)
            make.height.equalTo(15)
        }
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp_right).offset(5)
            make.centerY.equalToSuperview()
        }

        contentView.addSubview(selectImageView)
        selectImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-DemoUI.margin_22)
            make.centerY.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
