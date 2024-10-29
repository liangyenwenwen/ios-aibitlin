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
import OUICore

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
        r.contentMode = .scaleAspectFill
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
    
    lazy var videoView: rightBtnView = {
        let r = rightBtnView()
//        r.isHidden = true
        r.centerImg.image = .init(named: "call_log_video_btn")
        return r
    }()
    
    lazy var audioView: rightBtnView = {
        let r = rightBtnView()
//        r.isHidden = true
        r.centerImg.image = .init(named: "call_log_auido_btn")
        return r
    }()
    
    
    lazy var unReadView: UIView = {
        let r = UIView()
        r.backgroundColor = .init(hexString: "#FD5344")
        r.clipsToBounds = true
        r.layer.cornerRadius = 4
        return r
    }()
    
    
    
    
    func initUI() {
        contentView.addSubview(leftIconImg)
        contentView.addSubview(titleLbl)
        contentView.addSubview(recordTypeImg)
        contentView.addSubview(stateLbl)
        contentView.addSubview(timeLbl)
        contentView.addSubview(unReadView)
        
        contentView.addSubview(audioView)
        contentView.addSubview(videoView)
        
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
        
        unReadView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(8)
            make.right.equalTo(-12)
        }
        
        videoView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(12)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(52)
        }
        
        audioView.snp.makeConstraints { make in
            make.right.equalTo(videoView.snp_left)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(52)
        }
        
        
        
    }
    
    
    
    
    func update(model: CallRecord, indexRow: Int, currentRow: Int) {
        
        titleLbl.text = SuperStringUtil.getUserState(showname: model.nickname ?? "").n
        leftIconImg.setImageAbout(string: model.faceURL, placeHolder: "DefaultAvatar")
        timeLbl.text =   MessageHelper.convertList(timestamp_ms: model.date)
        
        stateLbl.text =  model.success ? model.inOrOutStr() + model.durationStr() : model.inOrOutStr()
        titleLbl.textColor = model.success ? .init(hexString: "#333333") :  .init(hexString: "#FF3939")
        recordTypeImg.image = model.type == "audio"  ? .init(named: "call_log_auido") : .init(named: "call_log_video")
        
        if indexRow == currentRow {
            backgroundColor = .init(hexString: "#f0f7ff")
            timeLbl.isHidden = true
            videoView.isHidden = false
            audioView.isHidden = false
            unReadView.isHidden = true
        } else {
            backgroundColor = .white
            timeLbl.isHidden = false
            videoView.isHidden = true
            audioView.isHidden = true
            
            unReadView.isHidden = !model.isUnRead
        }
    }
    
//    func update(model: MeetingInfo) {
        
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
        
        
//    }
    
    
    class rightBtnView: UIView {
        
        var didClickBlock:(() -> Void)?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            initUI()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        lazy var centerImg: UIImageView = {
            let r = UIImageView()
            r.image = .init(named: "call_log_video_btn")
            return r
        }()
        
        func initUI() {
            addSubview(centerImg)
            
            centerImg.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.height.equalTo(36)
            }
            let tap = UITapGestureRecognizer(target: self, action: #selector(didClickAction))
            addGestureRecognizer(tap)
        }
        
        @objc func didClickAction() {
            
            if didClickBlock != nil {
                self.didClickBlock!()
            }
        }

    }
    
    
    
}
