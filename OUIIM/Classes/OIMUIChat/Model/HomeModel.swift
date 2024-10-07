//
//  HomeModel.swift
//  OUIIM
//
//  Created by mac on 2024/10/7.
//

import Foundation
import CommonCrypto

//
//class QueryUserInfo: UpdateUserInfoRequest {}
//
//class UpdateUserInfoRequest: Codable {
//    let userID: String?
//    let chatID: String?
//    let account: String?
//    let password: String?
//    let level: Int?
//    var faceURL: String?
//    var nickname: String?
//    let areaCode: String?
//    let phoneNumber: String?
//    let telephone: String?
//    let hireDate: String?
//    private var platform: Int? = 1
//    var birth: Int?
//    var gender: Int?
//    var email: String?
//    let englishName: String?
//    let forbidden: Int?
//    let allowAddFriend: Int?
//    let allowBeep: Int?
//    let allowVibration: Int?
//    let personalProfile: String?
//    
//    init(userID: String? = nil,
//         chatID: String? = nil,
//         phone: String? = nil,
//         password: String? = nil,
//         telephone: String? = nil,
//         areaCode: String? = nil,
//         faceURL: String? = nil,
//         nickname: String? = nil,
//         englishName: String? = nil,
//         birth: Int? = nil,
//         gender: Gender? = nil,
//         account: String? = nil,
//         level: Int? = nil,
//         email: String? = nil,
//         hireDate: String? = nil,
//         allowAddFriend: Int? = nil,
//         allowBeep: Int? = nil,
//         allowVibration: Int? = nil,
//         forbidden: Int? = nil,
//         personalProfile: String? = nil)
//    {
//        self.areaCode = areaCode
//        self.chatID = chatID
//        self.telephone = telephone
//        self.password = password?.md5()
//        self.phoneNumber = phone
//        self.faceURL = faceURL
//        self.nickname = nickname
//        self.englishName = englishName
//        self.birth = birth
//        self.gender = gender?.rawValue
//        self.email = email
//        self.account = account
//        self.level = level
//        self.userID = userID
//        self.hireDate = hireDate
//        self.allowAddFriend = allowAddFriend
//        self.allowBeep = allowBeep
//        self.allowVibration = allowVibration
//        self.forbidden = forbidden
//        self.personalProfile = personalProfile
//    }
//}
//
//public enum Gender: Int, Codable {
//    case undefine = 0
//    case male = 1
//    case female = 2
//    
//    public var description: String {
//        switch self {
//        case .male:
//            return "男".innerLocalized()
//        case .female:
//            return "女".innerLocalized()
//        case .undefine:
//            return "-".innerLocalized()
//        }
//    }
//}
//
//extension String {
//    
//    func md5() -> String {
//        let str = self.cString(using: String.Encoding.utf8)
//        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
//        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
//        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
//        CC_MD5(str!, strLen, result)
//        let hash = NSMutableString()
//        for i in 0 ..< digestLen {
//            hash.appendFormat("%02x", result[i])
//        }
//        result.deallocate()
//        return String(format: hash as String)
//    }
//
//}
