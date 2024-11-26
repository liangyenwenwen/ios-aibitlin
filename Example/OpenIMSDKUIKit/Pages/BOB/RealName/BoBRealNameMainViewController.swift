//
//  BoBRealNameMainViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/11/20.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import OUICore
class BoBRealNameMainViewController:UIViewController{
    var certificationLevel:Int = 0
    var scrollView: UIScrollView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "实名认证"
        scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.addSubview(topImageView)
        scrollView.addSubview(primaryView)
        scrollView.addSubview(advancedView)
        view.addSubview(primaryBtn)
        view.addSubview(advancedBtn)
        scrollView.snp_makeConstraints { make in
            make.left.equalTo(0)
            make.width.equalTo(kScreenWidth)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(primaryBtn.snp_top).offset(-20)
        }
        topImageView.snp_makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(0)
            make.height.equalTo(96)
        }
        primaryBtn.snp_makeConstraints { make in
            make.left.right.height.equalTo(advancedBtn)
            make.bottom.equalTo(advancedBtn.snp_top).offset(-10)
        }
        advancedBtn.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(48)
            make.bottom.equalTo(view.snp_bottomMargin)
        }
        showBottomView()
        getRealNameData()
    }
    lazy var topImageView: UIImageView = {
        let r = UIImageView()
        r.image = UIImage(named: "real_name_top_icon")
        r.contentMode = .scaleAspectFill
        r.addSubview(tipLabel)
        tipLabel.snp_makeConstraints { make in
            make.left.equalTo(34)
            make.centerY.equalTo(r.snp_centerY)
            make.right.equalTo(-140)
        }
        return r
    }()
    lazy var tipLabel: UILabel = {
        let r = UILabel()
        r.font = UIFont(name: "PingFangSC-Semibold", size: 20)
        r.textColor = .white
        r.text = "开启身份认证"
        r.numberOfLines = 2
        return r
    }()
    lazy var primaryView: BoBMainRealNameTopView = {
        let r = BoBMainRealNameTopView()
        r.realNameType = 0
        r.hide()
        return r
    }()
    lazy var advancedView: BoBMainRealNameTopView = {
        let r = BoBMainRealNameTopView()
        r.realNameType = 1
        r.hide()
        return r
    }()
    lazy var primaryBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("去初级认证".localized())
        r.setTitleColor(.white, for: .normal)
        r.corner(24)
        r.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 16)
        r.backgroundColor = .primaryColor
        r.hide()
        r.rx.tap.subscribe(onNext: { [self] in
            let vc = BoBPrimaryRealNameViewController()
            vc.certificationLevel = self.certificationLevel
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: rx.disposeBag)
        return r
    }()
    lazy var advancedBtn: QMUIButton = {
        let r = ViewFactoryUtil.linkButton("去高级认证".localized())
        r.setTitleColor(.primaryColor, for: .normal)
        r.border(.primaryColor,borderWidth: 2,cornerRadius: 24)
        r.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 16)
        r.hide()
        r.rx.tap.subscribe(onNext: { [self] in
            let vc = BoBPrimaryRealNameViewController()
            vc.certificationLevel = 1
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: rx.disposeBag)
        return r
    }()
}
extension BoBRealNameMainViewController{
    func getRealNameData(){
        
        BoBRealNameModel.QueryRealNameInfo(userId: IMController.shared.uid) { [weak self] data in
            self?.primaryView.bindData(model: data)
            self?.primaryView.show()
            let height1 = CGFloat(78+30*(data.cjmmbRealNameAuthenticationPOS.count+2+data.cjtbRealNameAuthenticationPOS.count))
//            let height1 = CGFloat(50+30*(data.cjmmbRealNameAuthenticationPOS.count+1)+1+14+30*(data.cjtbRealNameAuthenticationPOS.count+1)+1+12)
            self?.primaryView.snp_makeConstraints({ make in
                make.left.equalTo(16)
                make.right.equalTo(-40)
                make.top.equalTo(self!.topImageView.snp_bottom).offset(20)
                make.height.equalTo(height1)
            })
            self?.advancedView.bindData(model: data)
            self?.advancedView.show()
//            height2 = 50+30*(data.gjmmbRealNameAuthenticationPOS.count+1)+1+14+30*(data.gjtbRealNameAuthenticationPOS.count+1)+1+16+42+16
            let count = data.cjmmbRealNameAuthenticationPOS.count+2+data.cjtbRealNameAuthenticationPOS.count
            let height2 = CGFloat(140+30*count)
            self?.advancedView.snp_makeConstraints({ make in
                make.left.right.equalTo(self!.primaryView)
                make.top.equalTo(self!.primaryView.snp_bottom).offset(16)
                make.height.equalTo(height2)
            })
            self?.scrollView.contentSize = CGSize(width: kScreenWidth, height: height1+height2+16)
            self?.certificationLevel = data.certificationLevel
            self?.showBottomView()
        } completionHandler: {errCode, errMsg in
            
        }
    }
    func showBottomView(){
        if self.certificationLevel == 0{
            //未认证
            self.primaryBtn.show()
            self.advancedBtn.show()
            self.advancedBtn.backgroundColor = .white
            self.advancedBtn.setTitleColor(.primaryColor, for: .normal)
            self.advancedBtn.layer.borderWidth = 2
//            scrollView.snp_updateConstraints { make in
//                make.bottom.equalTo(primaryBtn.snp_top).offset(-20)
//            }
        }else if self.certificationLevel == 1{
            //初级认证
            self.primaryBtn.hide()
            self.advancedBtn.show()
            self.advancedBtn.backgroundColor = .primaryColor
            self.advancedBtn.setTitleColor(.white, for: .normal)
            self.advancedBtn.layer.borderWidth = 0
//            scrollView.snp_updateConstraints { make in
//                make.bottom.equalTo(advancedBtn.snp_top).offset(-20)
//            }
        }else{
           //高级认证
            self.primaryBtn.hide()
            self.advancedBtn.hide()
//            scrollView.snp_updateConstraints { make in
//                make.bottom.equalTo(advancedBtn.snp_bottom)
//            }
        }
    }
}
