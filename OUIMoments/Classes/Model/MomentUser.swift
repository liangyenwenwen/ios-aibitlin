
import UIKit
import IGListDiffKit

class User: Codable {
    var userID: String = ""
    var nickname: String = ""
    var faceURL: String?
    
    init(userID: String, nickname: String, faceURL: String? = nil) {
        self.userID = userID
        self.nickname = nickname
        self.faceURL = faceURL
    }
}

extension User: ListDiffable {
    
    func diffIdentifier() -> NSObjectProtocol {
        return userID as NSObjectProtocol
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard self === object else { return true }
        guard let object = object as? User else { return false }
        return userID == object.userID
    }
}

extension User: Equatable {
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.isEqual(toDiffableObject: rhs)
    }
}

