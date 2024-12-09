//
//  YFTransferAccountsController.swift
//  Alamofire
//
//  Created by mac on 2024/12/4.
//

final class YFTransferAccountsController {
     
    var currency: String?
    
    var money: Double?
    
    var transferAccountsStatus: Int?

    var instructions: String?

    weak var delegate: ReloadDelegate?
    
    var longPress: ((_ sourceView: UIView, _ point: CGPoint) -> Void)?

    var source: transferAccountsMessageSource
    
    private let messageId: String
    
    private let bubbleController: BubbleController
    
    
    
    weak var view: YFTransferAccountsView? {
        didSet {
            view?.reloadData()
        }
    }
    init(source: transferAccountsMessageSource, messageID: String, bubbleController: BubbleController) {
        self.source = source
        self.messageId = messageID
        self.bubbleController = bubbleController
        configData()
    }
    private func configData() {
        self.instructions = source.instructions
        self.transferAccountsStatus = Int(source.localEx ?? "0")
        self.money = source.money
        self.currency = source.currency
    }
    
    func action() {
        var customsource =  CustomMessageSource(data: getCustomTransferAccountsData(source))
        customsource.localEx = source.localEx
        delegate?.didTapContent(with: messageId, data: .custom(customsource))
    }
    func getCustomTransferAccountsData(_ source: transferAccountsMessageSource) -> String {
        let parm = ["customType": 10801, "data":["sendUserId": source.sendUserId,
                                                 "sendUserName":source.sendUserName,
                                                 "receiverId": source.receiverId,
                                                 "receiverName":source.receiverName,
                                                 "code": source.code,
                                                 "instructions":source.instructions,
                                                 "currency":source.currency,
                                                 "money":source.money],
                    "localEx":source.localEx]  as [String : Any]
        
        do {
            let datastr = String.init(data: try JSONSerialization.data(withJSONObject: parm), encoding: .utf8)
            return datastr!
        } catch {
            return ""
        }
        
    }
}
