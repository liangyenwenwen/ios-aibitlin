import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
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
            let localAvatarPath = "OpenIM/userFace/"
            if FileManager.default.fileExists(atPath: localAvatarPath) {
                displayLocalAvatar(bestAttemptContent, localAvatarPath: localAvatarPath)
            } else {
                // 假设头像的URL地址，实际中需根据用户等相关信息从服务器获取正确的URL
                let avatarURLString = userInfo["face_url"] as? String,
                guard let avatarURL = URL(string: avatarURLString) else {
                    contentHandler(bestAttemptContent)
                    return
                }
                downloadAvatar(avatarURL, bestAttemptContent: bestAttemptContent)
            }
//            contentHandler(bestAttemptContent)
        }
    }
    // 显示本地头像的方法
        func displayLocalAvatar(_ bestAttemptContent: UNNotificationContent, localAvatarPath: String) {
            if let avatarURL = URL(fileURLWithPath: localAvatarPath) {
                let attachmentIdentifier = "avatarAttachment"
                do {
                    let attachment = try UNNotificationAttachment(identifier: attachmentIdentifier, url: avatarURL, options: [UNNotificationAttachmentOptionsTypeHintKey: kUTTypePNG])
                    bestAttemptContent.attachments = [attachment]
                    contentHandler(bestAttemptContent)
                } catch {
                    print("添加本地头像附件出错: \(error)")
                    contentHandler(bestAttemptContent)
                }
            }
        }
    // 下载头像的方法
        func downloadAvatar(_ avatarURL: URL, bestAttemptContent: UNNotificationContent) {
            let session = URLSession(configuration:.default)
            let task = session.downloadTask(with: avatarURL) { [weak self] (location, response, error) in
                guard let self = self else { return }
                if let error = error {
                    print("下载头像出错: \(error)")
                    self.contentHandler(bestAttemptContent)
                    return
                }
                guard let location = location else {
                    self.contentHandler(bestAttemptContent)
                    return
                }
                let fileManager = FileManager.default
                let avatarFileName = "user_avatar.png"
                let destinationURL = fileManager.temporaryDirectory.appendingPathComponent(avatarFileName)
                do {
                    try fileManager.moveItem(at: location, to: destinationURL)
                    if let avatarURL = URL(fileURLWithPath: destinationURL.path) {
                        let attachmentIdentifier = "avatarAttachment"
                        do {
                            let attachment = try UNNotificationAttachment(identifier: attachmentIdentifier, url: avatarURL, options: [UNNotificationAttachmentOptionsTypeHintKey: kUTTypePNG])
                            bestAttemptContent.attachments = [attachment]
                        } catch {
                            print("添加下载头像附件出错: \(error)")
                        }
                    }
                    self.contentHandler(bestAttemptContent)
                } catch {
                    print("移动文件出错: \(error)")
                    self.contentHandler(bestAttemptContent)
                }
            }
            task.resume()
        }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
