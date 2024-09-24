import Foundation
import OUICore

class RevokedMessageStorage {
    static var shared = RevokedMessageStorage()
    
    init() {
//        for (i, item) in messages.enumerated() {
//            let value = item.value
//            
//            if value.createTime - NSDate().timeIntervalSince1970 * 1000 > 24 * 60 * 60 * 1000 {
//                messages.removeValue(forKey: item.key)
//            }
//        }
    }
        
    private var messages: [String: MessageInfo] = [:]
    
    static func append(messageID: String, value: MessageInfo) {
        let JSONEncoder = JSONEncoder()
        if let fromJSON = try? JSONEncoder.encode(value) {
            let JSONDecoder = JSONDecoder()
            let toObj = try? JSONDecoder.decode(MessageInfo.self, from: fromJSON)
            
            Self.shared.messages[messageID] = toObj
        }
    }
    
    static func remove(messageID: String) {
        Self.shared.messages.removeValue(forKey: messageID)
    }
    
    static func message(messageID: String) -> MessageInfo? {
        Self.shared.messages[messageID]
    }
    
    static func isExsit(messageID: String) -> Bool {
        Self.shared.messages[messageID] != nil
    }
    
    static func messageValue(messageID: String) -> (contentType: MessageContentType, text: String, quoteText: String?)? {
        let msg = message(messageID: messageID)
        
        if msg?.contentType == .text {
            return (.text, msg?.textElem?.content ?? "", nil)
        } else if msg?.contentType == .quote {
            let quote = msg?.quoteElem
            let text = quote?.text ?? ""
            
            return (.quote, text, nil)
        } else if msg?.contentType == .at {
            let at = msg?.atTextElem
            let text = at?.text ?? ""
            
            return (.at, text, nil)
        }
        
        return nil
    }
}
