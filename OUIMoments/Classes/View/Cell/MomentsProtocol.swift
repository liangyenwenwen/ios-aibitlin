import OUICore

enum MomentAction {
    // 点击头像
    case avatar
    // 点击title
    case title
    // 回复的标题
    case reply
    // 点击背景 是否是自己的评论
    case bg(Bool)
    // 评论
    case comment(String)
    // 草稿
    case commentDraft(String)
    //  删除
    case delete
    // 点赞/取消
    case thumbup
    //  删除某条评论
    case deleteComment
    // 权限：谁能看等
    case permisson
    // 新消息
    case newMessage
    // Preview pictures or videos.
    case preview(_ index: Int, _ senders: [UIView])
}

typealias MomentHandler = ((_ value: String?, _ action: MomentAction) -> Void)

// cell 两边距
let MomentPadding: CGFloat = 16
// Widget space
let MomentWidgetSpace: CGFloat = 8
// more picture space
let imageSpace = 4.0
// cell 两边距
let MomentAvatarSize: CGFloat = 44.w
// cell 内容左边距
let MomentContentLeftPadding = MomentPadding + MomentWidgetSpace + StandardUI.avatarWidth // 8: 头像与内容间距
// cell 宽度
let MomentContentWidth = kScreenWidth - 2 * MomentPadding - MomentContentLeftPadding
