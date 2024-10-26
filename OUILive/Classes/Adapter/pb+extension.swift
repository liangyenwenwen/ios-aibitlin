
import Foundation
import OUICore

enum MeetingStatus: String {
    case scheduled = "Scheduled"
    case inProgress = "In-Progress"
    case completed = "Completed"
}

extension MeetingInfoSetting {
    var creatorUserID: String { info.systemGenerated.creatorUserID }
    var creatorNickname: String { info.systemGenerated.creatorNickname }
    var meetingID: String { info.systemGenerated.meetingID }
    var meetingName: String { info.creatorDefinedMeeting.title }
    var scheduledTime: TimeInterval { TimeInterval(info.creatorDefinedMeeting.scheduledTime) }
    var duration: Int64  { info.creatorDefinedMeeting.meetingDuration }
    var endTime: TimeInterval { scheduledTime + Double(duration) }
    var status: MeetingStatus { MeetingStatus(rawValue: info.systemGenerated.status)! }
    var hostUserID: String { !info.creatorDefinedMeeting.hostUserID.isEmpty ? info.creatorDefinedMeeting.hostUserID : creatorUserID }
    
    var videoCanEnable: Bool {
        hosterIsSelf || setting.canParticipantsEnableCamera
    }
    
    var screenShareCanEnable: Bool {
        hosterIsSelf || setting.canParticipantsShareScreen
    }
    
    var audioCanEnable: Bool {
        hosterIsSelf || setting.canParticipantsUnmuteMicrophone
    }
    
    var enableVideoWhileJoining: Bool {
        hosterIsSelf || !setting.disableCameraOnJoin
    }
    
    var enableAudioWhileJoining: Bool {
        hosterIsSelf || !setting.disableMicrophoneOnJoin
    }
    
    var hosterIsSelf: Bool {
        hostUserID == IMController.shared.uid
    }
    
    var canInvite: Bool {
        var canInvite = true
        
//        if !self.hosterIsSelf {
//            canInvite = !(self.onlyHostInviteUser ?? false)
//        }
        
        return canInvite
    }
}
