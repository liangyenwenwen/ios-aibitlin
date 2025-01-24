//
//  BoBReceiveRedPacketAlertView.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/6.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import MMBAlertsPickers
import OUICore
import ProgressHUD
import RxCocoa
import RxSwift
import TangramKit
import UIKit
class BoBReceiveRedPacketAlertView: TGLinearLayout {
    var receiveRedPacketSuccess:((_ receiveRedPacketData:String)->())!
    var redPacketMessageStatus:RedPacketMessageStatus?
    var groupId:String? = ""
    var isReceiveing:Bool = false
    init() {
        super.init(frame: .zero, orientation: .vert)
        innerInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        innerInit()
    }
    
    func innerInit() {
        corner(MEDDLE_RADIUS)
        tg_width.equal(.fill)
        tg_height.equal(.wrap)
        tg_gravity = .horz.center
        tg_padding = UIEdgeInsets(top: 0, left: PADDING_OUTER, bottom: 0, right: PADDING_OUTER)
        addSubview(bgImageView)
        addSubview(closeBtn)
    }
    func bindData(redPacketInfo:RedPacketMessageStatus){
        redPacketMessageStatus = redPacketInfo
        let status = Int(redPacketInfo.localEx ?? "0")
        if status == 0{
            contentLabel.text = redPacketInfo.data?.instructions
        }else if status == 2{
            //已过期
            receieBtn.setTitle("", for: .normal)
            receieBtn.isUserInteractionEnabled = false
            contentLabel.text = "该红包已过期，已自动退还给对方"
        }else if status == 3{
            //已领完
            receieBtn.setTitle("", for: .normal)
            receieBtn.isUserInteractionEnabled = false
            contentLabel.text = "该红包已领完"
        }
    }
    lazy var bgImageView: UIImageView = {
       let r = UIImageView(image: UIImage(named: "mine_red_packet_recieve_bg_icon"))
        r.tg_width.equal(kScreenWidth-40)
        r.tg_height.equal(518)
        r.isUserInteractionEnabled = true
        r.addSubview(receieBtn)
        r.addSubview(contentLabel)
        receieBtn.snp_makeConstraints { make in
            make.width.height.equalTo(96)
            make.top.equalTo(172)
            make.centerX.equalTo(r)
        }
        contentLabel.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.bottom.equalTo(-44.5)
            make.height.equalTo(76)
        }
        return r
    }()
    func rotateImageView() {
            // 定义旋转动画
        UIView.animate(withDuration: 1,delay: 0,options: .curveLinear, animations: {
                self.receieBtn.transform = self.receieBtn.transform.rotated(by:.pi)
            }) { (completed) in
                if self.isReceiveing{
                    self.rotateImageView()
                }
            }
        }
    lazy var receieBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("拆")
        r.setTitleColor(.init(hexString: "#DD3333"), for: .normal)
        r.backgroundColor = .init(hexString: "#FFDA71")
        r.corner(48)
        r.titleLabel?.font = .semiboldFont(52)
        r.titleLabel?.sizeToFit()
        r.rx.tap.subscribe(onNext: {[self] in
            let redPacketTRype = self.redPacketMessageStatus?.data?.redPacketType
            var param : [String: Any]
            if redPacketTRype == 0 || redPacketTRype == 3{
                param = ["code":redPacketMessageStatus?.data?.code ?? ""]
            }else{
                param = ["groupId":redPacketMessageStatus?.data?.groupId ?? "","code":redPacketMessageStatus?.data?.code ?? ""]
            }
            rotateImageView()
            isReceiveing = true
            receieBtn.isUserInteractionEnabled = false
            BoBRedPacketModel.ReceiveChatRedPacketsRequest(type: redPacketMessageStatus?.data?.redPacketType, param:param){errCode,errMsg in
                // 0是未领取，1是已领取，2，已过期，3是已领完
                if errCode == 620000{
                    self.isReceiveing = false
                    if self.receiveRedPacketSuccess != nil{
                        self.receiveRedPacketSuccess("1")
                    }
                }else{
                    self.isReceiveing = false
                    self.receieBtn.isUserInteractionEnabled = true
                    if errCode == 620027{
                        //已过期
                        if self.receiveRedPacketSuccess != nil{
                            self.receiveRedPacketSuccess("2")
                        }
                    }else if errCode == 620028{
                        //已领取
                        if self.receiveRedPacketSuccess != nil{
                            self.receiveRedPacketSuccess("1")
                        }
                    }else if errCode == 620029{
                        //已领完
                        if self.receiveRedPacketSuccess != nil{
                            self.receiveRedPacketSuccess("3")
                        }
                    }
                    SuperToast.show(title: String(errCode) + "：" + String(errCode).localized())
                }
                
                
                
                
                
            }
        })
        .disposed(by: rx.disposeBag)
        return r
    }()
    lazy var contentLabel: UILabel = {
       let r = UILabel()
        r.font = .semiboldFont(16)
        r.textColor = .init(hexString: "#FFDA71")
        r.textAlignment = .center
        return r
    }()
    
       
    lazy var closeBtn: QMUIButton = {
        let r = ViewFactoryUtil.imageBtn(UIImage(named: "mine_red_packet_recieve_close_icon")!)
        r.tg_top.equal(23)
        r.tg_width.equal(44)
        r.tg_height.equal(44)
        r.setTitleColor(.black333, for: .normal)
        r.titleLabel?.font = .mediumFont(16)
        r.rx.tap.subscribe(onNext: {
            GKCover.hide()
        })
        .disposed(by: rx.disposeBag)
        return r
    }()
}



