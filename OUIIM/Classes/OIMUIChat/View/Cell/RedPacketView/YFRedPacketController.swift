//
//  YFRedPacketController.swift
//  Alamofire
//
//  Created by mac on 2024/12/4.
//

import Foundation
final class YFRedPacketController {
        
    var redPacketStatus: Int?

    var instructions: String?

    weak var delegate: ReloadDelegate?
    
    var longPress: ((_ sourceView: UIView, _ point: CGPoint) -> Void)?

    var source: redPacketMessageSource

    private let messageId: String
    
    private let bubbleController: BubbleController
    
    
    
    weak var view: YFRedPacketView? {
        didSet {
            view?.reloadData()
        }
    }
    init(source: redPacketMessageSource, messageID: String, bubbleController: BubbleController) {
        self.source = source
        self.messageId = messageID
        self.bubbleController = bubbleController
        configData()
    }
    private func configData() {
        self.instructions = source.instructions
        self.redPacketStatus = Int(source.localEx ?? "0")
    }
    
    func action() {
        var customsource =  CustomMessageSource(data: getCustomRedPacketData(source))
        customsource.localEx = source.localEx
        delegate?.didTapContent(with: messageId, data: .custom(customsource))
    }
    func getCustomRedPacketData(_ source: redPacketMessageSource) -> String {
        let parm = ["customType": 10800, "data":["sendUserId": source.sendUserId,
                                                 "sendUserFaceURL":source.sendUserFaceURL,
                                                 "sendUserName":source.sendUserName,
                                                 "receiverId": source.receiverId,
                                                 "receiverName":source.receiverName,
                                                 "code": source.code,
                                                 "redPacketType":source.redPacketType,
                                                 "instructions":source.instructions],
                    "localEx":source.localEx]  as [String : Any]
        
        do {
            let datastr = String.init(data: try JSONSerialization.data(withJSONObject: parm), encoding: .utf8)
            return datastr!
        } catch {
            return ""
        }
        
    }
}
