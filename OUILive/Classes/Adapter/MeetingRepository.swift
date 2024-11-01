import Foundation
import SwiftProtobuf
import ProgressHUD
import OUICore

enum CreateMeetingType: Int {
  case quick
  case booking
  case join
}

class MeetingRepository {
    func getMeetings(userID: String) async -> [MeetingInfoSetting] {
        do {
            let params: [String : Any] = [
                "userID": userID,
                "status": [MeetingStatus.scheduled.rawValue, MeetingStatus.inProgress.rawValue]
            ]
            
            let data = try await APIManager.shared.request(APIRoute.getMeetings.path, parameters: params)
            guard let dataMap = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any] else { return [] }
            let meetingDetails = dataMap["meetingDetails"]
            let rData = try JSONSerialization.data(withJSONObject: meetingDetails, options: .fragmentsAllowed)
            
            guard let temp = try? MeetingInfoSetting.array(fromJSONUTF8Data: rData) else { return [] }
            
            return temp
        } catch {
            catchError(error: error)
            return []
        }
    }
    
    func getLiveKitToken(meetingID: String, userID: String) async -> LiveKit? {
        let params = ["meetingID": meetingID, "userID": userID]
        
        return await request(APIRoute.getLiveToken.path, params: params)
    }
    
    
    func getMeetingInfo(meetingID: String, userID: String) async -> MeetingInfoSetting? {
        let params = ["meetingID": meetingID, "userID": userID]
        
        do {
            let data = try await APIManager.shared.request(APIRoute.getMeeting.path, parameters: params)
            guard let dataMap = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any] else { return nil }
            let meetingDetails = dataMap["meetingDetail"]
            let rData = try JSONSerialization.data(withJSONObject: meetingDetails, options: .fragmentsAllowed)
            let result = try MeetingInfoSetting(jsonUTF8Data: rData)
            
            return result
        } catch {
            catchError(error: error)
            return nil
        }
    }
    
    func createMeeting(type: CreateMeetingType, creatorUserID: String, creatorDefinedMeetingInfo: CreatorDefinedMeetingInfo, setting: MeetingSetting? = nil, repeatInfo: MeetingRepeatInfo? = nil) async -> (cert: LiveKit?, info: MeetingInfoSetting) {
        
        var params: [String: Any] = ["creatorUserID": creatorUserID]
        
        var jsonEncodingOptions = JSONEncodingOptions()
        jsonEncodingOptions.alwaysPrintInt64sAsNumbers = true
        
        if let data = try? creatorDefinedMeetingInfo.jsonUTF8Data(options: jsonEncodingOptions), let creatorParam = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any] {
            params["creatorDefinedMeetingInfo"] = creatorParam
        }
        
        if setting == nil {
            var s = MeetingSetting()
            s.canParticipantsEnableCamera = true
            s.canParticipantsUnmuteMicrophone = true
            s.canParticipantsShareScreen = true
            s.disableMicrophoneOnJoin = false
            s.disableCameraOnJoin = false
            s.canParticipantJoinMeetingEarly = true
            s.lockMeeting = false
            s.audioEncouragement = true
            s.videoMirroring = true
            
            if let data = try? s.jsonUTF8Data(), var settingParam = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any] {
                settingParam["disableMicrophoneOnJoin"] = s.disableMicrophoneOnJoin
                settingParam["disableCameraOnJoin"] = s.disableCameraOnJoin
                settingParam["lockMeeting"] = s.lockMeeting

                params["setting"] = settingParam
            }
        } else {
            if let data = try? setting!.jsonUTF8Data(), let settingParam = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any] {
                params["setting"] = settingParam
            }
        }
        
        if type == .quick {
            guard let result: CreateImmediateMeetingResp = await request(APIRoute.quicklyMeeting.path, params: params) else { return (cert: nil, info: MeetingInfoSetting()) }
            
            return (cert: result.liveKit, info: result.detail)
        } else if type == .booking {
            guard let result: BookMeetingResp = await request(APIRoute.bookingMeeting.path, params: params) else { return (cert: nil, info: MeetingInfoSetting()) }
            
            return (cert: nil, info: result.detail)
        } else {
            guard let result: LiveKit = await request(APIRoute.joinMeeting.path, params: params) else { return (cert: nil, info: MeetingInfoSetting()) }
            
            return (cert: result, info: MeetingInfoSetting())
        }
    }
    
    func joinMeeting(meetingID: String, userID: String) async -> LiveKit? {
        let params = ["userID": userID, "meetingID": meetingID]
        
        do {
            let data = try await APIManager.shared.request(APIRoute.joinMeeting.path, parameters: params)
            guard let dataMap = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any] else { return nil }
            
            let meetingDetails = dataMap["liveKit"]
            let rData = try JSONSerialization.data(withJSONObject: meetingDetails, options: .fragmentsAllowed)
            let result = try LiveKit(jsonUTF8Data: rData)
            
            return result
        } catch {
            catchError(error: error)
            return nil
        }
    }
    
    func leaveMeeting(meetingID: String, userID: String) async -> Bool {
        let params = ["meetingID": meetingID, "userID": userID]
        
        let result = await request(APIRoute.leaveMeeting.path, params: params)
        
        return result
    }
    
    func endMeeting(meetingID: String, userID: String, endType: MeetingEndType = .endType) async -> Bool {
        let params: [String : Any] = ["meetingID": meetingID, "userID": userID, "endType": endType.rawValue]
        
        let result = await request(APIRoute.endMeeting.path, params: params)
        
        return result
    }
    
    func setPersonalSetting(meetingID: String, userID: String, setting: PersonalMeetingSetting) async -> Bool {
        var params: [String: Any] = ["meetingID": meetingID, "userID": userID]
        
        if let data = try? setting.jsonUTF8Data(), let settingParam = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any] {
            params = params.merging(settingParam, uniquingKeysWith: { (current, _) in current })
        }
        
        let result = await request(APIRoute.setPersonalSetting.path, params: params)
        
        return result
    }
    
    func updateMeetingSetting(req: UpdateMeetingRequest) async -> Bool {
        var jsonEncodingOptions = JSONEncodingOptions()
        jsonEncodingOptions.alwaysPrintInt64sAsNumbers = true
        
        guard let data = try? req.jsonUTF8Data(options: jsonEncodingOptions), let params = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any] else { return false }
        
        
        let result = await request(APIRoute.updateMeetingSetting.path, params: params)
        
        return result
    }
    
    func operateAllStream(meetingID: String, operatorUserID: String, cameraOnEntry: Bool?, microphoneOnEntry: Bool?) async -> Bool {
        var params: [String: Any] = ["meetingID": meetingID, "operatorUserID": operatorUserID]
        if let cameraOnEntry = cameraOnEntry {
            params["cameraOnEntry"] = cameraOnEntry
        }
        if let microphoneOnEntry = microphoneOnEntry {
            params["microphoneOnEntry"] = microphoneOnEntry
        }
        
        let result = await request(APIRoute.operateAllStream.path, params: params)
        
        return result
    }
    
    func request<T: SwiftProtobuf.Message>(_ endpoint: String, params: [String: Any]) async -> T? {
        do {
            let data = try await APIManager.shared.request(endpoint, parameters: params)
                        
            guard let temp = try? T(jsonUTF8Data: data) else { return nil }
            
            return temp
        } catch (let e) {
            catchError(error: e)
            
            return nil
        }
    }
    
    func request(_ endpoint: String, params: [String: Any]) async -> Bool {
        do {
            let data = try await APIManager.shared.request(endpoint, parameters: params)
            
            return data != nil
        } catch {
            catchError(error: error)
            
            return false
        }
    }
    
    func catchError(error: Error) {
        var errorStr = error.localizedDescription
        
        if let err = error as? ApiError {
            print("API catch error: \(err.message)")
            errorStr = err.message ?? String(err.code)
        }
//        ProgressHUD.error(errorStr)dcxv
//        if let handler = OIMApi.showTipHandle {
//            handler(errorStr, { res in
//               
//            })
//        }
        DispatchQueue.main.async {
            if let handler = OIMApi.showTipHandle {
                handler(errorStr, { res in
                })
            }
        }
    }
}
