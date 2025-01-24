//
//  BoBAppealResultViewController.swift
//  OpenIMSDKUIKit_Example
//
//  Created by mac on 2024/12/26.
//  Copyright © 2024 rentsoft. All rights reserved.
//

import Foundation
import TangramKit
import OUICore
import ZLPhotoBrowser
import OUICoreView

class BoBAppealResultViewController: BaseTitleController {
    var code:String = ""
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func initViews() {
        super.initViews()
        setBackGroundColor(.white)
        initScrollSafeArea()
        title = "申诉结果"
        scrollViewContainer.tg_padding = UIEdgeInsets(top: 0, left: PADDING_OUTER, bottom: 0, right: PADDING_OUTER)
        scrollViewContainer.addSubview(orderTitleView)
        scrollViewContainer.addSubview(buyAppealDetailView)
        scrollViewContainer.addSubview(sellAppealDetailView)
        loadData()
    }
    func loadData(){
        BoBBuyAndSellCionModel.QueryStatementDetailsRequest(code: code){[weak self] data in
            if data.statementDetailsBuyPO == nil{
                self?.buyAppealDetailView.hide()
            }else{
                self?.buyAppealDetailView.show()
                self?.buyAppealDetailView.bindData(buyOrSell:1,data: data.statementDetailsBuyPO)
            }
            if data.statementDetailsSellPO == nil{
                self?.sellAppealDetailView.hide()
            }else{
                self?.sellAppealDetailView.show()
                self?.sellAppealDetailView.bindData(buyOrSell:2,data: data.statementDetailsSellPO)
                if self?.buyAppealDetailView.isHidden == true{
                    self?.sellAppealDetailView.tg_top.equal(12)
                }
            }
        } completionHandler:{errCode,errMsg in
            SuperToast.show(title: String(errCode) + "：" + String(errCode).localized())
        }
            
    }
    func getAttribute(str:String) -> NSMutableAttributedString{
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: "receive_payment_copy_icon")
        attachment.bounds = CGRect(x: 0, y: -3.0, width: 16, height: 16)
        let str1 = str + " "
        let attributedString = NSMutableAttributedString(string: str1)
        let attachmentString = NSAttributedString(attachment: attachment)
        attributedString.insert(attachmentString, at: str1.length)
        return attributedString
    }
    lazy var orderTitleView: buyAndSellTitleView = {
        let r = buyAndSellTitleView()
        r.tg_top.equal(10)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(28)
        r.buyCountTitleLabel.text = "订单号"
        r.buyCounLabel.attributedText = getAttribute(str: code)
        r.buyCounLabel.font = .mediumFont(14)
        r.buyCounLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer()
        tap.rx.event.subscribe { [weak self] _ in
            UIPasteboard.general.string = self?.code ?? ""
            SuperToast.show(title: "复制成功".localized())
            self?.view.endEditing(true)
        }.disposed(by: rx.disposeBag)
        r.addGestureRecognizer(tap)
        return r
    }()
    lazy var buyAppealDetailView: BoBAppealResultView = {
        let r = BoBAppealResultView()
        r.tg_top.equal(12)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.hide()
        r.currentVC = self
        return r
    }()
    lazy var sellAppealDetailView: BoBAppealResultView = {
        let r = BoBAppealResultView()
        r.tg_top.equal(38)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        r.hide()
        r.currentVC = self
        return r
    }()
}

class BoBAppealResultView: TGLinearLayout {
    var imageArray:[String] = []
    var currentVC:UIViewController?
    init() {
        super.init(frame: .zero, orientation: .vert)
        innerInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        innerInit()
    }
    
    func innerInit() {
        tg_width.equal(.fill)
        tg_height.equal(.wrap)
        addSubview(appealDetailTitleLabel)
        addSubview(appealDetailContentLabel)
        addSubview(imageTitleLabel)
        addSubview(picView)
        addSubview(appealResultTitleLabel)
        addSubview(appealResultContentLabel)
    }
    func bindData(buyOrSell:Int,data:BoBMineOrderAppealDetail?){
        appealDetailTitleLabel.text = buyOrSell == 1 ? "买方申诉详情" : "卖方申诉详情"
        appealDetailContentLabel.text = data?.representationDetails
        imageArray = data?.screenshot!.components(separatedBy:",") ?? []
        let imageWidth = (UIScreen.main.bounds.width - 12 - 32) / 3
        for (i,item) in imageArray.enumerated()  {
            let imageView = UIImageView()
            imageView.border(.init(hexString: "#CCCCCC"),borderWidth: 1,cornerRadius: 8)
            let left = Int(i % 3) * Int(imageWidth + 8)
            let top = Int(i / 3) * Int(imageWidth + 8)
            imageView.tg_left.equal(left)
            imageView.tg_top.equal(top)
            imageView.tg_width.equal(imageWidth)
            imageView.tg_height.equal(imageWidth)
            imageView.sd_setImage(with: URL(string: item))
            imageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer()
            tap.rx.event.subscribe { [weak self] _ in
                self?.browserImages(i)
            }.disposed(by: rx.disposeBag)
            imageView.addGestureRecognizer(tap)
            picView.addSubview(imageView)
        }
        appealResultContentLabel.text = data?.resultPresentation
    }
    // 预览图片
    func browserImages(_ index: Int) {
        let sources = imageArray.map{ MediaResource(thumbUrl: URL(fileURLWithPath: $0), url: URL(fileURLWithPath: $0)) }
        let vc = MediaPreviewViewController(resources: sources, index: index, showIndicator: true)
        vc.isShowMore = false
        vc.showIn(controller: currentVC!, senders: [])
    }
    lazy var appealDetailTitleLabel: UILabel = {
        let r = UILabel()
        r.tg_top.equal(0)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(18)
        r.textColor = .black333
        r.font = .mediumFont(16)
        r.text = "买方申诉详情"
        return r
    }()
    lazy var appealDetailContentLabel: UILabel = {
        let r = UILabel()
        r.tg_top.equal(10)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(.wrap)
        r.textColor = .black999
        r.font = .regularFont(16)
        r.numberOfLines = 0
        return r
    }()
    lazy var imageTitleLabel: UILabel = {
        let r = UILabel()
        r.tg_top.equal(18)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(18)
        r.textColor = .black333
        r.font = .mediumFont(16)
        r.text = "相关截图"
        return r
    }()
    lazy var picView: TGRelativeLayout = {
        let r = TGRelativeLayout()
        r.tg_top.equal(10)
        r.tg_width.equal(.fill)
        r.tg_height.equal(.wrap)
        return r
    }()
    lazy var appealResultTitleLabel: UILabel = {
        let r = UILabel()
        r.tg_top.equal(18)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(18)
        r.textColor = .black333
        r.font = .mediumFont(16)
        r.text = "申诉结果"
        return r
    }()
    lazy var appealResultContentLabel: UILabel = {
        let r = UILabel()
        r.tg_top.equal(10)
        r.tg_left.equal(0)
        r.tg_right.equal(0)
        r.tg_height.equal(.wrap)
        r.textColor = .black999
        r.font = .regularFont(16)
        r.numberOfLines = 0
        return r
    }()
}
