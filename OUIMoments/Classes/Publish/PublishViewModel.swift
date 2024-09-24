
import Foundation

class PublishViewModel {
    
    var type: Int = 0 // 0 图文, 1 视频
    var text: String? // 发送的文本
    var metas: [MetaInfo] = []
    
    var permisson: Int = 0 // 0 公开, 1 私密 2 哪些人/群组可看 3 那些人/群组不能看
    var permissonFriends: [String] = []
    var permissonGroups: [String] = []
    var metionContacts: [String] = []
    
    // @param type: 0 图文, 1 视频
    // @permission: 0 公开, 1 私密 2 哪些人/群组可看 3 那些人/群组不能看
    func publishMoments(comletion: ((_ r: String?) -> Void)?) {
        
        OUIMoments.DefaultDataProvider().publishMoments(type: type,
                                  text: text,
                                  metas: metas.map {["thumb": $0.thumb, "original": $0.original]},
                                  permisson: permisson,
                                  permissonFriends: permissonFriends,
                                  permissonGroups: permissonGroups,
                                  metionContacts: metionContacts,
                                  completion: comletion)
    }
}
