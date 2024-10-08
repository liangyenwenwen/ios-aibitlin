//
//  YFCallRecordsListCell.swift
//  OUIIM
//
//  Created by mac on 2024/10/8.
//

import Foundation
import OUICalling
import OUILive
import Kingfisher

class YFCallRecordsListCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var leftIconImg: UIImageView = {
        let r = UIImageView()
        r.clipsToBounds = true
        r.layer.cornerRadius = 28
        return r
    }()
    
    lazy var titleLbl: UILabel = {
        let r = UILabel()
        r.text = "username"
        r.textColor = .init(hexString: "#333333")
        r.font = UIFont(name: "PingFangSC-Semibold", size: 16)
        r.textAlignment = .left
        return r
    }()
    
    lazy var recordTypeImg: UIImageView = {
        let r = UIImageView()
        r.image = .init(named: "call_log_auido")
        return r
    }()
    
    lazy var stateLbl: UILabel = {
        let r = UILabel()
        r.text = "cancle"
        r.textColor = .init(hexString: "#666666")
        r.font = UIFont(name: "PingFangSC-Regular", size: 14)
        return r
    }()
    
    lazy var timeLbl: UILabel = {
        let r = UILabel()
        r.text = "00:00"
        r.textColor = .init(hexString: "#666666")
        r.font = UIFont(name: "PingFangSC-Regular", size: 14)
        r.textAlignment = .right
        return r
    }()
    
    func initUI() {
        contentView.addSubview(leftIconImg)
        contentView.addSubview(titleLbl)
        contentView.addSubview(recordTypeImg)
        contentView.addSubview(stateLbl)
        contentView.addSubview(timeLbl)
        
        leftIconImg.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.width.height.equalTo(56)
            make.centerY.equalToSuperview()
        }
        
        titleLbl.snp.makeConstraints { make in
            make.left.equalTo(leftIconImg.snp_right).offset(13)
            make.top.equalTo(leftIconImg.snp_top).offset(4)
            make.height.equalTo(22)
        }
        
        recordTypeImg.snp.makeConstraints { make in
            make.left.equalTo(titleLbl)
            make.bottom.equalTo(leftIconImg.snp_bottom).offset(-8)
            make.width.height.equalTo(12)
        }
        
        stateLbl.snp.makeConstraints { make in
            make.left.equalTo(recordTypeImg.snp_right).offset(8)
            make.centerY.equalTo(recordTypeImg)
        }
        
        timeLbl.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-30)
            make.centerY.equalTo(titleLbl)
            make.left.equalTo(titleLbl.snp_right).offset(20)
        }
        
    }
    
    func update(model: CallRecord) {
//        cell.titleLabel.text = model.nickname
//        cell.subtitleLabel.text = "[\(model.typeStr())] \(model.formatDateStr())"
//        cell.avatarImageView.setAvatar(url: model.faceURL, text: model.nickname, onTap: nil)
//        cell.trainingLabel.text = model.durationStr()
//        
//        if !model.success {
//            cell.titleLabel.textColor = .red
//            cell.subtitleLabel.textColor = .red
//            cell.trainingLabel.textColor = .red
//            cell.trainingLabel.text = model.inOrOutStr()
//        }
//        leftIconImg.setImage(with: model.faceURL, placeHolder: "DefaultAvatar", original: false)
        
        titleLbl.text = model.nickname
        leftIconImg.setImageAbout(string: model.faceURL, placeHolder: "DefaultAvatar")
        timeLbl.text = model.formatDateStr()
        
        stateLbl.text =  model.success ?  model.durationStr() : model.inOrOutStr()
        titleLbl.textColor = model.success ? .init(hexString: "#333333") :  .init(hexString: "#FF3939")
        recordTypeImg.image = model.type == "audio"  ? .init(named: "call_log_auido") : .init(named: "call_log_video")
    }
    
    func update(model: MeetingInfo) {
        
//        cell.titleLabel.text = model.meetingName
//        cell.subtitleLabel.text = "\(Date.timeString(timeInterval: model.startTime * 1000)) - \(Date.timeString(timeInterval: model.endTime * 1000))"
//        cell.avatarImageView.setAvatar(url: nil, text: nil, placeHolder: "live_room_record_icon")
//        let now = Date().timeIntervalSince1970
//        if now > model.endTime {
//            cell.trainingLabel.text =  "[已结束]"
//        } else if now < model.startTime {
//            cell.trainingLabel.text =  "[未开始]"
//        } else {
//            cell.trainingLabel.text =  "[已开始]"
//        }
//        
//        cell.titleLabel.textColor = .red
//        cell.subtitleLabel.textColor = .red
//        cell.trainingLabel.textColor = .red
        
        
    }
    
    
}
