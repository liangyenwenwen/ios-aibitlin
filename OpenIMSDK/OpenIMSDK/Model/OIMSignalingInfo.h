//
//  OIMSignalingInfo.h
//  OpenIMSDK
//
//  Created by x on 2022/3/17.
//

#import <Foundation/Foundation.h>
#import "OIMMessageInfo.h"
#import "OIMFullUserInfo.h"
#import "OIMDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface OIMInvitationInfo : NSObject

/**
 *  List of invitee UserIDs, with only one element in the case of a one-on-one chat.
 */
@property (nonatomic, copy) NSArray<NSString *> *inviteeUserIDList;

/**
 *  Room ID, must be unique.
 */
@property (nonatomic, copy) NSString *roomID;

/**
 *  Invitation timeout in seconds, default is 1000.
 */
@property (nonatomic, assign) NSInteger timeout;

/**
 *  Video or audio.
 */
@property (nonatomic, copy) NSString *mediaType;

/**
 *  1 for one-on-one chat, 2 for group chat.
 */
@property (nonatomic, assign) OIMConversationType sessionType;

@property (nonatomic, assign) OIMPlatform platformID;

/**
 *  Inviter's UserID.
 */
@property (nonatomic, copy) NSString *inviterUserID;

/**
 *  If it's a one-on-one chat, it's an empty string.
 */
@property (nonatomic, copy) NSString *groupID;

/**
 *  Initiation time.
 */
@property (nonatomic, assign) NSTimeInterval initiateTime;

- (BOOL)isVideo;

@end

@interface OIMInvitationResultInfo : NSObject

/**
 *  Token.
 */
@property (nonatomic, copy) NSString *token;

/**
 *  Room ID, must be unique and can be left unset.
 */
@property (nonatomic, copy) NSString *roomID;

/**
 *  Live streaming URL.
 */
@property (nonatomic, copy) NSString *liveURL;

/**
 * List of occupied lines.
 */
@property (nonatomic, copy) NSArray<NSString *> *busyLineUserIDList;

@end

@interface OIMSignalingInfo : NSObject

@property (nonatomic, copy) NSString *userID;

@property (nonatomic, strong) OIMInvitationInfo *invitation;

@property (nonatomic, strong) OIMOfflinePushInfo *offlinePushInfo;

@end

/// Participant Information
@interface OIMParticipantMetaData : NSObject

@property (nonatomic, strong) OIMGroupInfo *groupInfo;

@property (nonatomic, strong) OIMGroupMemberInfo *groupMemberInfo;

@property (nonatomic, strong) OIMPublicUserInfo *publicUserInfo;

@property (nonatomic, strong) OIMPublicUserInfo *userInfo;

@end

@interface OIMParticipantConnectedInfo : NSObject

@property (nonatomic, copy) NSString *groupID;

@property (nonatomic, strong) OIMInvitationInfo *invitation;

@property (nonatomic, copy) NSArray<OIMParticipantMetaData *> *metaData;

// --- Query Room ---
@property (nonatomic, copy) NSArray<OIMParticipantMetaData *> *participant;

@property (nonatomic, copy) NSString *token;

@property (nonatomic, copy) NSString *roomID;

@property (nonatomic, copy) NSString *liveURL;

@end

// Meeting-related
@interface OIMMeetingInfo : NSObject

@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *meetingName;
@property (nonatomic, copy) NSString *hostUserID;
@property (nonatomic, assign) NSTimeInterval createTime;
@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, assign) NSTimeInterval endTime;
@property (nonatomic, assign) BOOL participantCanEnableVideo;
@property (nonatomic, assign) BOOL onlyHostInviteUser;
@property (nonatomic, assign) BOOL joinDisableVideo;
@property (nonatomic, assign) BOOL participantCanUnmuteSelf;
@property (nonatomic, assign) BOOL isMuteAllMicrophone;
@property (nonatomic, copy) NSArray<NSString *> *inviteeUserIDList;
@end

@interface OIMMeetingInfoList : NSObject

@property (nonatomic, copy) NSArray<OIMMeetingInfo *> *meetingInfoList;
@end

@interface OIMMeetingStreamEvent : NSObject

@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *streamType;
@property (nonatomic, assign) BOOL mute;
@end

NS_ASSUME_NONNULL_END
