import Alamofire

enum APIRoute {
    case getMeetings
    case quicklyMeeting
    case bookingMeeting
    case joinMeeting
    case getLiveToken
    case getMeeting
    case leaveMeeting
    case endMeeting
    case setPersonalSetting
    case updateMeetingSetting
    case operateAllStream

    
    var path: String {
        switch self {
        case .getMeetings:
            return "/rtc-meeting/get_meetings"
        case .quicklyMeeting:
            return "/rtc-meeting/create_immediate_meeting"
        case .bookingMeeting:
            return "/rtc-meeting/book_meeting"
        case .joinMeeting:
            return "/rtc-meeting/join_meeting"
        case .getLiveToken:
            return "/rtc-meeting/get_meeting_token"
        case .getMeeting:
            return "/rtc-meeting/get_meeting"
        case .leaveMeeting:
            return "/rtc-meeting/leave_meeting"
        case .endMeeting:
            return "/rtc-meeting/end_meeting"
        case .setPersonalSetting:
            return "/rtc-meeting/set_personal_setting"
        case .updateMeetingSetting:
            return "/rtc-meeting/update_meeting"
        case .operateAllStream:
            return "/rtc-meeting/operate_meeting_all_stream"
        }
    }
    
    var method: HTTPMethod {
        .post
    }
}
