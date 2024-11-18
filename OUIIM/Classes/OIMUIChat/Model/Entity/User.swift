
import DifferenceKit
import Foundation
import OUICore

struct User: Hashable {

    var id: String

    var name: String

    var faceURL: String?
    
    var type: ContactItemType = .user
}

extension User: Differentiable {
    public var differenceIdentifier: Int {
        id.hashValue
    }
    
    public func isContentEqual(to source: User) -> Bool {
        self == source
    }
}

extension User {
    func toSimplePublicUserInfo() -> PublicUserInfo {
        PublicUserInfo(userID: id, nickname: name, faceURL: faceURL)
    }
}
