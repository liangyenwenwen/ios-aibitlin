
import DifferenceKit
import Foundation
import OUICore

struct User: Hashable {

    var id: String

    var name: String

    var faceURL: String?
}

extension User: Differentiable {}

extension User {
    func toSimpleFullUserInfo() -> FullUserInfo {
        FullUserInfo(userID: id, showName: name, faceURL: faceURL)
    }
}
