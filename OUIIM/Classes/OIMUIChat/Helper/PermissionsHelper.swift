//
//  PermissionsHelper.swift
//  OUIIM
//
//  Created by mac on 2024/10/7.
//

import UIKit
import AVKit
import Photos
 
struct PermissionsHelper {
    
    static func cameraEnable() -> Bool {
        
        func cameraResult() {
            let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            
            if (authStatus == .authorized) {            // 已授权，可以打开相机
                saveCamera(value: "1")
            } else if (authStatus == .denied) {         // 已拒绝
                saveCamera(value: "0")
                let alertV = UIAlertView.init(title: "提示".localized(), message: "请去-> [设置 - 隐私 - 相机] 打开访问开关".localized(), delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "确定".localized())
                alertV.show()
            } else if (authStatus == .restricted) {     // 相机权限受限
                saveCamera(value: "0")
                let alertV = UIAlertView.init(title: "提示".localized(), message: "相机权限受限".localized(), delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "确定".localized())
                alertV.show()
            } else if (authStatus == .notDetermined) {  // 首次 使用
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (statusFirst) in
                    if statusFirst {
                        // 用户首次允许
                        saveCamera(value: "1")
                    } else {
                        // 用户首次拒绝
                        saveCamera(value: "0")
                    }
                })
            }
        }
        
        func saveCamera(value: String) {
            UserDefaults.standard.setValue(value, forKey: "cameraEnablebs")
        }
        
        cameraResult()
        
        let result = (UserDefaults.standard.value(forKey: "cameraEnablebs") as? String) == "1"
        return result
    }
    
    
    static func audioEnable() -> Bool {
        
        func audioResult() {
            let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
            
            if (authStatus == .authorized) {            // 已授权，可以使用摄像头
                saveAudio(value: "1")
            } else if (authStatus == .denied) {         // 已拒绝
                saveAudio(value: "0")
                let alertV = UIAlertView.init(title: "提示".localized(), message: "请去-> [设置 - 隐私 - 麦克风] 打开访问开关".localized(), delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "确定".localized())
                alertV.show()
            } else if (authStatus == .restricted) {     // 相机权限受限
                saveAudio(value: "0")
                let alertV = UIAlertView.init(title: "提示".localized(), message: "相机权限受限".localized(), delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "确定".localized())
                alertV.show()
            } else if (authStatus == .notDetermined) {  // 首次 使用
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (statusFirst) in
                    if statusFirst {
                        // 用户首次允许
                        saveAudio(value: "1")
                    } else {
                        // 用户首次拒绝
                        saveAudio(value: "0")
                    }
                })
            }
        }
        
        func saveAudio(value: String) {
            UserDefaults.standard.setValue(value, forKey: "audioEnablebs")
        }
        
        audioResult()
        
        let result = (UserDefaults.standard.value(forKey: "audioEnablebs") as? String) == "1"
        return result
    }
    
    
    static func photoEnable() -> Bool {
        
        func photoResult() {
            let status = PHPhotoLibrary.authorizationStatus()
            
            if (status == .authorized) {
                savePhoto(value: "1")
            } else if (status == .restricted || status == .denied) {
                let alertV = UIAlertView.init(title: "提示".localized(), message: "请去-> [设置 - 隐私 - 相册] 打开访问开关".localized(), delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "确定".localized())
                alertV.show()
                savePhoto(value: "0")
            } else if (status == .notDetermined) { // 首次使用
                PHPhotoLibrary.requestAuthorization({ (firstStatus) in
                    let isTrue = (firstStatus == .authorized)
                    if isTrue {
                        // 用户首次允许
                        savePhoto(value: "1")
                    } else {
                        // 用户首次拒绝
                        savePhoto(value: "0")
                    }
                })
            }
        }
        
        func savePhoto(value: String) {
            UserDefaults.standard.setValue(value, forKey: "photoEnablebs")
        }
        
        photoResult()
        
        let result = (UserDefaults.standard.object(forKey: "photoEnablebs") as? String) == "1"
        return result
    }
    
}
