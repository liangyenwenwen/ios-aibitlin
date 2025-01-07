//
//  NotificationService.swift
//  NotificationService
//
//  Created by mac on 2025/1/6.
//  Copyright © 2025 rentsoft. All rights reserved.
//

import UserNotifications
import UIKit

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

//    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
//        self.contentHandler = contentHandler
//        print("处理通知")
//        if let bestAttemptContent = bestAttemptContent {
//                   // 假设头像的URL地址，实际中你需要根据用户等相关信息从服务器获取正确的URL
//                   let avatarURLString = "http://192.168.7.16:10002/object/6150535698/image_2025-01-03-25-04.445.png"
//                   guard let avatarURL = URL(string: avatarURLString) else {
//                       contentHandler(bestAttemptContent)
//                       return
//                   }
//                   let session = URLSession(configuration:.default)
//                   let task = session.downloadTask(with: avatarURL) { [weak self] (location, response, error) in
//                       guard let self = self else { return }
//                       if let error = error {
//                           print("下载头像出错: \(error)")
//                           self.contentHandler!(bestAttemptContent)
//                           return
//                       }
//                       guard let location = location else {
//                           self.contentHandler!(bestAttemptContent)
//                           return
//                       }
//                       let avatarFileName = "userAvatar"
//                       let fileManager = FileManager.default
//                       let destinationURL = fileManager.temporaryDirectory.appendingPathComponent(avatarFileName)
//                       do {
//                           try fileManager.moveItem(at: location, to: destinationURL)
//                           if let avatarURL = Bundle.main.url(forResource: avatarFileName, withExtension: nil) {
//                               let attachmentIdentifier = "avatarAttachment"
//                               do {
//                                   let attachment = try UNNotificationAttachment(identifier: attachmentIdentifier, url: avatarURL, options: nil)
//                                   bestAttemptContent.attachments = [attachment]
//                               } catch {
//                                   print("添加头像附件出错: \(error)")
//                               }
//                           }
//                           self.contentHandler!(bestAttemptContent)
//                       } catch {
//                           print("移动文件出错: \(error)")
//                           self.contentHandler!(bestAttemptContent)
//                       }
//                   }
//                   task.resume()
//               }
//        }
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            if let userInfo = request.content.userInfo as? [String: Any],
               let clientID = userInfo["clientMsgID"] as? String,
               !clientID.isEmpty == true
            {
                let key = "key"
                UserDefaults.standard.set(request.identifier, forKey: key)
                bestAttemptContent.title = "\(bestAttemptContent.title)"
                bestAttemptContent.sound = UNNotificationSound(named: .init(rawValue: "call.caf"))
            }
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
extension UNNotificationAttachment {
    static func create(image: UIImage, fileIdentifier: String = "fine-image", options: [NSObject : AnyObject]? = nil) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let tempDir = fileManager.temporaryDirectory.appendingPathComponent(ProcessInfo.processInfo.globallyUniqueString)
        do {
            try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true, attributes: nil)
            let fileURL = tempDir.appendingPathComponent(fileIdentifier).appendingPathExtension("png")
            if let pngData = image.pngData() {
                try pngData.write(to: fileURL)
                let attachment = try UNNotificationAttachment(identifier: fileIdentifier, url: fileURL, options: options)
                return attachment
            }
        } catch {
            // 错误处理
            print(error.localizedDescription)
        }
        return nil
    }
}
