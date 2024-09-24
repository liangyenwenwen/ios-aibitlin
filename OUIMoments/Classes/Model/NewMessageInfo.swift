
import Foundation

enum NewMessageType: Int, Decodable {
    case favor = 1
    case mention = 2
    case comment = 3
}

public class NewMessageInfo: MomentsInfo {
    var type: NewMessageType = .favor
    
    private enum CodingKeys: String, CodingKey {
        case type
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(NewMessageType.self, forKey: .type)
        try super.init(from: decoder)
    }
}
