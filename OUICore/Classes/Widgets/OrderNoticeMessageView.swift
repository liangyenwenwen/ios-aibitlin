//
//  OrderNoticeMessageView.swift
//  Alamofire
//
//  Created by mac on 2024/12/29.
//

import Foundation
import RxSwift
import OUICore
import Alamofire

class OrderNoticeMessageView: UIView {
    var clickBtnBlock:((_ index:Int)->())!
    private let _disposeBag = DisposeBag()
    var countdownTime:Int = 0
    private var timer: DispatchSourceTimer?
    var currentShowMessage:orderMessageNoticDetail?
    public override init(frame: CGRect) {
        super.init(frame: frame)
        innerInit()
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func innerInit() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5) // 半透明背景
        addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(timeTitleLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(cancleBtn)
        contentView.addSubview(sureBtn)
        contentView.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(44 + kStatusBarHeight)
            make.height.equalTo(180)
        }
        titleLabel.snp_makeConstraints { make in
            make.top.equalTo(19)
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(20)
        }
        timeTitleLabel.snp_makeConstraints { make in
            make.top.equalTo(54)
            make.left.equalTo(16)
            make.height.equalTo(22)
        }
        timeLabel.snp_makeConstraints { make in
            make.centerY.equalTo(timeTitleLabel)
            make.left.equalTo(timeTitleLabel.snp_right).offset(4)
        }
        cancleBtn.snp_makeConstraints { make in
            make.left.equalTo(16)
            make.bottom.equalTo(-16)
            make.width.equalTo((kScreenWidth-64-18)/2.0)
            make.height.equalTo(46)
        }
        sureBtn.snp_makeConstraints { make in
            make.right.equalTo(-16)
            make.top.width.height.equalTo(cancleBtn)
        }
    }
    func loadData(){
        let API_BOB_URL = "https://web.pk-im.com"
//        let API_BOB_URL = "http://192.168.7.128:18729"
        let OrderDetails = "/wallet/userOrderDetails/orderDetails"//订单详情
        let code = currentShowMessage?.detail?.code as! String
        let param = ["code": code] as [String : Any]
        var url = API_BOB_URL + OrderDetails + "?"
        for (key, value) in param {
            url += "&\(key)=\(value)"
        }
        let httpHeaders : HTTPHeaders = [
            "token":IMController.shared.chatToken,
            "X-Forwarded-For":IMController.shared.publicIP,
            "Authorization":"eyJ1c2VySW5mbyI6InVzZXJCbG9nWWFuWmhlbmdUb2tlbiJ9",
            "Content-Type":"application/json",
            "operationID":String(Int(Date().timeIntervalSince1970)),
        ]
        Alamofire.request(url, method: .post, parameters: param,encoding: JSONEncoding.default, headers: httpHeaders).responseJSON { dataRequest in
            
            if let data = dataRequest.data {
                let strData = String.init(data: data, encoding: String.Encoding.utf8)
                print(strData!)
                if let res = JsonTool.fromJson(strData!, toClass: OrderDetailResponse.self) {

                    if res.code == 620000  {
                        self.refreshUI(data: res.data)
                    } else {
                       print("请求失败")
                        self.clickBtnBlock(0)
                    }
                } else {
                    print("请求失败")
                    self.clickBtnBlock(0)
                }
            } else {
                print("请求失败")
                self.clickBtnBlock(0)
            }
        }
    }
    func refreshUI(data:OrderDetailModel){
        if data.countdownTime ?? 0 > 0 && data.orderStatus == currentShowMessage?.detail?.orderStatus{
            self.countdownTime = data.countdownTime ?? 0
            self.startTimer()
            self.showMask()
        }else{
            self.clickBtnBlock(0)
        }
    }
    func convertSecondsToMinuteSecondFormat(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let remainingSeconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    func startTimer() {
        // 创建一个基于全局并发队列的定时器源
        timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        // 设置定时器触发间隔为1秒
        timer?.schedule(deadline:.now(), repeating:.seconds(1))
        // 设置定时器触发时执行的闭包
        timer?.setEventHandler {[weak self] in
            if self?.countdownTime == 0{
                self?.stopTimer()
                self?.clickBtnBlock(0)
            }else{
                DispatchQueue.main.async {
                    self?.countdownTime = (self?.countdownTime ?? 0)-1
                    self?.timeLabel.text = self?.convertSecondsToMinuteSecondFormat(self?.countdownTime ?? 0)
                }
            }
        }
        // 启动定时器
        timer?.resume()
    }
    func stopTimer() {
        if timer != nil{
            timer?.cancel()
            timer = nil
        }
    }
    static func netWithUrl(_ data: String ,_ paramters:[String: Any]) -> String {
        var string = data + "?"
        for (key, value) in paramters {
            string += "&\(key)=\(value)"
        }
        return string
    }
    func bindData(detail:orderMessageNoticDetail){
        currentShowMessage = detail
        titleLabel.text = currentShowMessage?.detail?.remindersDetails
        loadData()
    }
    func showMask() {
        if let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) ?? UIApplication.shared.windows.first{
            self.frame = keyWindow.bounds
            keyWindow.addSubview(self)
            // 动画显示遮罩
            alpha = 0
            UIView.animate(withDuration: 0.3) {
                self.alpha = 1
            }
        }else{
            stopTimer()
            clickBtnBlock(0)
        }
    }
    
    // 隐藏遮罩
    func hideMask() {
        stopTimer()
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }
    lazy var contentView: UIView = {
        let r = UIView()
        r.backgroundColor = .white
        r.layer.masksToBounds = true
        r.layer.cornerRadius = 12
        return r
    }()
    lazy var titleLabel: UILabel = {
        let r = UILabel()
        r.font = UIFont(name: "PingFangSC-Semibold", size: 18)
        r.textColor = .init(hexString: "#333333")
        return r
    }()
    lazy var timeTitleLabel: UILabel = {
        let r = UILabel()
        r.font = UIFont(name: "PingFangSC-Regular", size: 16)
        r.textColor = .init(hexString: "#333333")
        r.text = "剩余时间"
        return r
    }()
    lazy var timeLabel: UILabel = {
        let r = UILabel()
        r.font = UIFont(name: "PingFangSC-Semibold", size: 16)
        r.textColor = .init(hexString: "#F32525")
        r.text = "14:59"
        return r
    }()
    lazy var cancleBtn: UIButton = {
        let r = UIButton()
        r.setTitle("稍后处理", for: .normal)
        r.setTitleColor(.init(hexString: "#666666"), for: .normal)
        r.titleLabel?.font = UIFont(name: "PingFangSC-Semibold", size: 16)
        r.layer.masksToBounds = true
        r.layer.cornerRadius = 23
        r.layer.borderWidth = 1
        r.layer.borderColor = UIColor.init(hexString: "#999999")?.cgColor
        r.rx.tap.subscribe(onNext: { [weak self] in
            self?.hideMask()
            self?.clickBtnBlock(0)
        }).disposed(by: _disposeBag)
        return r
    }()
    lazy var sureBtn: UIButton = {
        let r = UIButton()
        r.setTitle("立即处理", for: .normal)
        r.setTitleColor(.white, for: .normal)
        r.layer.masksToBounds = true
        r.layer.cornerRadius = 23
        r.backgroundColor = .init(hexString: "#388CEF")
        r.rx.tap.subscribe(onNext: { [weak self] in
            self?.hideMask()
            self?.clickBtnBlock(1)
        }).disposed(by: _disposeBag)
        return r
    }()
}
class orderMessageNoticDetail: Decodable {
    var externalUrl: String?
    var mixType:Int?
    var notificationName:String?
    var notificationType:Int?
    var text:String?
    var isRead:Bool?
    var msgID:String?
    var detail:orderMessageNoticContentDetail?
}
class orderMessageNoticContentDetail: Decodable {
    var reminders:Bool?//是否是强提醒,true强提醒
    var code: String?
    var remindersDetails:String?
    var orderStatus:Int?
    var time:String?
    var type:Int?
}
class OrderDetailResponse: Decodable {
    var data: OrderDetailModel
    var flag: Bool = false
    var code: Int = 620000
    var message: String? = nil
    var count: Int? = 0
}
class OrderDetailModel: Decodable {
    var orderStatus:Int? //1:等待用户付款 2:等待商家确认 3:已完成 4:用户取消 5:商家取消 6:等待商家付款 7:等待用户确认 8:等待卖家接单 9:等待买家接单 10:已超时
    var countdownTime:Int?//d倒计时时间
}
