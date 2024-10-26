import Alamofire
import OUICore

class APIManager {
    static let shared = APIManager()

    private init() {}

    private let baseURL = IMController.shared.sdkAPIAdrr

    // 使用 async/await 封装 Alamofire 请求
    func request(_ endpoint: String,
                               method: HTTPMethod = .post,
                               parameters: Parameters? = nil,
                               headers: HTTPHeaders? = nil) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            
            var h = headers ?? HTTPHeaders()
            h["token"] = IMController.shared.token
            h["operationID"] = String(Int(NSDate().timeIntervalSince1970))
            
            let url = "\(baseURL)\(endpoint)"
            
            Alamofire.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: h)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        do {
                            guard let result = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? [String: Any] else {
                                continuation.resume(throwing: ApiError(code: -1, message: "JSONSerialization throw an error"))
                                
                                return
                            }
                            
                            let data = result["data"] as? [String: Any]
                            let errMsg = result["errMsg"] as? String
                            let errDlt = result["errDlt"] as? String
                            let errCode = result["errCode"] as! Int
                            
                            if errCode == 0 {
                                if data != nil, let rData = try? JSONSerialization.data(withJSONObject: data, options: .fragmentsAllowed) {
                                    print("=====errCode == 0, data is truth")
                                    continuation.resume(returning: rData)
                                } else {
                                    print("=====errCode == 0, data is nil")
                                    continuation.resume(returning: Data())
                                }
                            } else {
                                print("=====errCode != 0 [errCode:\(errCode)]")
                                continuation.resume(throwing: ApiError(code: errCode, message: errMsg))
                            }
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }
}

struct ApiError: Error {
    var code: Int
    var message: String?
    var operationID: String?
}
