//
//  OIMManager+Signaling.h
//  OpenIMSDK
//
//  Created by x on 2022/3/17.
//

#import "OIMManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface OIMManager (Signaling)

/**
 * Invite an individual to join an audio or video call.
 *
 * @param invitation
 * Invitation to join:
    {
        "inviteeUserIDList": ["userID"],  // Only one element
        "roomID": "", // Optional
        "timeout": 30, // Default 30s
        "mediaType": "video" / "audio" // Default "video"
    }
 * Invite certain individuals in a group to join an audio or video call.
    {
        "inviteeUserIDList": ["userID1", "userID2"],
        "groupID": "groupID", // Required
        "roomID": "", // Optional
        "timeout": 30, // Default 30s
        "mediaType": "video" / "audio" // Default "video"
    }
 * @param offlinePushInfo Offline push message
 */
- (OIMSignalingInfo *)signalingInvite:(OIMInvitationInfo *)invitation
                      offlinePushInfo:(OIMOfflinePushInfo * _Nullable)offlinePushInfo
                            onSuccess:(nullable OIMSignalingResultCallback)onSuccess
                            onFailure:(nullable OIMFailureCallback)onFailure;

/**
 * Invite certain individuals in a group to join an audio or video call - only different in parameter settings.
 */
- (OIMSignalingInfo *)signalingInviteInGroup:(OIMInvitationInfo *)invitation
                             offlinePushInfo:(OIMOfflinePushInfo * _Nullable)offlinePushInfo
                                   onSuccess:(nullable OIMSignalingResultCallback)onSuccess
                                   onFailure:(nullable OIMFailureCallback)onFailure;

/**
 * Accept an audio or video call invitation from someone.
 * opUserID: ID of the person performing the operation
 * invitation
    {
         "inviterUserID": "userID",
         "inviteeUserIDList": [
             "userID"
         ],
         "groupID": "groupID",
         "roomID": "roomID",
         "timeout": 1000,
         "mediaType": "video",
         "sessionType": x
     }
 */
- (void)signalingAccept:(OIMSignalingInfo *)invitation
              onSuccess:(nullable OIMSignalingResultCallback)onSuccess
              onFailure:(nullable OIMFailureCallback)onFailure;

/**
 * Reject an audio or video call invitation from someone.
 * opUserID: ID of the person performing the operation
 * invitation
    {
         "inviterUserID": "userID",
         "inviteeUserIDList": [
             "userID"
         ],
         "groupID": "groupID",
         "roomID": "roomID",
         "timeout": 1000,
         "mediaType": "video",
         "sessionType": x
     }
 */
- (void)signalingReject:(OIMSignalingInfo *)invitation
              onSuccess:(nullable OIMSuccessCallback)onSuccess
              onFailure:(nullable OIMFailureCallback)onFailure;

/**
 * Cancel an audio or video call invitation.
 * opUserID: ID of the person performing the operation
 * invitation
    {
         "inviterUserID": "userID",
         "inviteeUserIDList": [
             "userID"
         ],
         "groupID": "groupID",
         "roomID": "roomID",
         "timeout": 1000,
         "mediaType": "video",
         "sessionType": x
     }
 */
- (void)signalingCancel:(OIMSignalingInfo *)invitation
              onSuccess:(nullable OIMSuccessCallback)onSuccess
              onFailure:(nullable OIMFailureCallback)onFailure;

- (void)signalingHungUp:(OIMSignalingInfo *)invitation
              onSuccess:(nullable OIMSuccessCallback)onSuccess
              onFailure:(nullable OIMFailureCallback)onFailure;

/**
 * Retrieve room information for a specific group by group ID, including information about the members currently in the call.
 */
- (void)signalingGetRoomByGroupID:(NSString *)groupID
                        onSuccess:(nullable OIMSignalingParticipantChangeCallback)onSuccess
                        onFailure:(nullable OIMFailureCallback)onFailure;

/**
 * Retrieve a token based on the room ID.
 */
- (void)signalingGetTokenByRoomID:(NSString *)groupID
                        onSuccess:(nullable OIMSignalingResultCallback)onSuccess
                        onFailure:(nullable OIMFailureCallback)onFailure;

/**
 * Create a meeting.
 * @param meetingName: Meeting title
 * @param meetingHostUserID: ID of the meeting host
 * @param startTime: Start time (in seconds)
 * @param meetingDuration: Meeting duration (in seconds)
 * @param inviteeUserIDList: List of invited participants' IDs
 */
- (void)signalingCreateMeeting:(NSString *)meetingName
             meetingHostUserID:(NSString *)meetingHostUserID
                     startTime:(nullable NSNumber *)startTime
               meetingDuration:(nullable NSNumber *)meetingDuration
             inviteeUserIDList:(nullable NSArray *)inviteeUserIDList
                     onSuccess:(nullable OIMSignalingResultCallback)onSuccess
                     onFailure:(nullable OIMFailureCallback)onFailure;

/**
 * Join a meeting.
 * @param roomID: Meeting ID
 * @param name: Meeting title
 * @param participantNickname: Name to be displayed when joining the room
 */
- (void)signalingJoinMeeting:(NSString *)roomID
                        name:(nullable NSString *)name
         participantNickname:(nullable NSString *)participantNickname
                   onSuccess:(nullable OIMSignalingResultCallback)onSuccess
                   onFailure:(nullable OIMFailureCallback)onFailure;

/**
 * Meeting room administrator mutes or unmutes a specific participant's stream.
 * @param roomID: Meeting ID
 * @param userID: Target user's ID
 * @param streamType: video/audio
 * @param mute: YES to mute, NO to unmute
 * @param muteAll: Set both video and audio to mute/unmute
 */
- (void)signalingOperateStream:(NSString *)roomID
                        userID:(NSString *)userID
                    streamType:(NSString *)streamType
                          mute:(BOOL)mute
                       muteAll:(BOOL)muteAll
                     onSuccess:(nullable OIMSuccessCallback)onSuccess
                     onFailure:(nullable OIMFailureCallback)onFailure;

/**
 * Update meeting settings.
 * @param roomID: Meeting ID
 * @param params: Parameters for the update
 * ///  String meetingName,
 * ///  int startTime = 0,
 * ///  int endTime = 0,
 * ///  bool participantCanUnmuteSelf = true,
 * ///  bool participantCanEnableVideo = true,
 * ///  bool onlyHostInviteUser = true,
 * ///  bool onlyHostShareScreen = true,
 * ///  bool joinDisableMicrophone = true,
 * ///  bool joinDisableVideo = true,
 * ///  bool isMuteAllVideo = true,
 * ///  bool isMuteAllMicrophone = true,
 * ///  NSArray<String> addCanScreenUserIDList =  [],
 * ///  NSArray<String> reduceCanScreenUserIDList =  [],
 * ///  NSArray<String> addDisableMicrophoneUserIDList =
 * ///  NSArray<String> reduceDisableMicrophoneUserIDList =  [],
 * ///  NSArray<String> addDisableVideoUserIDList =  [],
 * ///  NSArray<String> reduceDisableVideoUserIDList =  [],
 * ///  NSArray<String> addPinedUserIDList = [],
 * ///  NSArray<String> reducePinedUserIDList =  [],
 * ///  NSArray<String> addBeWatchedUserIDList =  [],
 * ///  NSArray<String> reduceBeWatchedUserIDList =  [],
 */
- (void)signalingUpdateMeetingInfo:(NSString *)roomID
                           setting:(NSDictionary *)params
                         onSuccess:(nullable OIMSuccessCallback)onSuccess
                         onFailure:(nullable OIMFailureCallback)onFailure;

/**
 * Get information about all unfinished meetings.
 */
- (void)signalingGetMeetingsWithSuccess:(nullable OIMSignalingMeetingsInfoCallback)onSuccess
                                onFailure:(nullable OIMFailureCallback)onFailure;

/**
 * End a meeting.
 */
- (void)signalingCloseRoom:(NSString *)roomID
                        onSuccess:(nullable OIMSuccessCallback)onSuccess
                        onFailure:(nullable OIMFailureCallback)onFailure;

- (void)signalingSendCustomSignal:(NSString *)roomID
                       customInfo:(NSString *)customInfo
                        onSuccess:(nullable OIMSuccessCallback)onSuccess
                        onFailure:(nullable OIMFailureCallback)onFailure;

/**
 * Check for unfinished audio or video call invitations when the app starts.
 */
- (void)getSignalingInvitationInfoStartAppWithOnSuccess:(nullable OIMSignalingInvitationCallback)onSuccess
                                              onFailure:(nullable OIMFailureCallback)onFailure;
@end

NS_ASSUME_NONNULL_END
