import UIKit


extension NSMutableData {
    func appendString(string: String) {
        let data = string.data(
            using: String.Encoding.utf8,
            allowLossyConversion: true)
        append(data!)
    }
}
extension String {
    var urlEncoded: String? {
        let allowedCharacterSet = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "~-_."))
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
    }
}

struct MultipartFormDataRequest {

    private let boundary: String = UUID().uuidString
    private var httpBody = NSMutableData()
    let url: URL
    var headers: Dictionary<String, String>?
    init(url: URL) {
        self.url = url
    }

    func addTextField(named name: String, value: String) {
        httpBody.append(textFormField(named: name, value: value))
    }

    func asURLRequest() -> URLRequest {
        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        if let headers = headers{
            request.allHTTPHeaderFields = headers
        }
        httpBody.appendString(string: "--\(boundary)--")
        request.httpBody = httpBody as Data
        return request
    }

    private func AddTextFormField(named name: String, value: UIImage) {
        var fieldString = Data()
        fieldString.append("--\(boundary)\r\n".data(using: .utf8)!)
        fieldString.append("Content-Disposition: form-data; name=\"\(name)\"\r\n".data(using: .utf8)!)
        fieldString.append("Content-Type: text/plain; charset=ISO-8859-1\r\n".data(using: .utf8)!)
        fieldString.append("Content-Transfer-Encoding: 8bit\r\n".data(using: .utf8)!)
        fieldString.append("\r\n".data(using: .utf8)!)
        fieldString.append(value.pngData()!)

    }

    private func textFormField(named name: String, value: String) -> String {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        fieldString += "Content-Type: text/plain; charset=ISO-8859-1\r\n"
        fieldString += "Content-Transfer-Encoding: 8bit\r\n"
        fieldString += "\r\n"
        fieldString += "\(value)\r\n"
        return fieldString
    }

    func addDataField(named name: String, data: Data, mimeType: String) {
        httpBody.append(dataFormField(named: name, data: data, mimeType: mimeType))
    }

    private func dataFormField(named name: String,
                               data: Data,
                               mimeType: String) -> Data {
        let fieldData = NSMutableData()

        fieldData.append("--\(boundary)\r\n")
        fieldData.append("Content-Disposition: form-data; name=\"\(name)\"\r\n")
        fieldData.append("Content-Type: \(mimeType)\r\n")
        fieldData.append("\r\n")
        fieldData.append(data)
        fieldData.append("\r\n")

        return fieldData as Data
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}



extension NSMutableData {
    func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}



typealias ApiCompletion = (_ data: Any?, _ error: Error?) -> ()

typealias ApiParam = [String: Any]

enum ApiMethod: String {
    case GET = "GET"
    case POST = "POST"
}
extension String {
    func addingPercentEncodingForURLQueryValue() -> String? {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    }
}

extension Dictionary {
    func stringFromHttpParameters() -> String {
        let parameterArray = self.map { (key, value) -> String in
            let percentEscapedKey = (key as! String).addingPercentEncodingForURLQueryValue()!
            if value is String {
                let percentEscapedValue = (value as! String).addingPercentEncodingForURLQueryValue()!
                return "\(percentEscapedKey)=\(percentEscapedValue)"
            }
            else {
                return "\(percentEscapedKey)=\(value)"
            }
        }
        return parameterArray.joined(separator: "&")
    }
}
extension URLSession {
    
    func dataTask(with request: MultipartFormDataRequest,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
    -> URLSessionDataTask {
        return dataTask(with: request.asURLRequest(), completionHandler: completionHandler)
    }
}
class APIService:NSObject {
    static let shared: APIService = APIService()
    
    private func convertToJson(_ byData: Data) -> Any? {
        do {
            return try JSONSerialization.jsonObject(with: byData, options: [])
        } catch {
            //            self.debug("convert to json error: \(error)")
        }
        return nil
    }
    func requestJSON(_ url: String,
                     param: ApiParam?,
                     method: ApiMethod,
                     loading: Bool,
                     completion: @escaping ApiCompletion)
    {
        var request:URLRequest!
        
        // set method & param
        if method == .GET {
            if let paramString = param?.stringFromHttpParameters() {
                request = URLRequest(url: URL(string:"\(url)?\(paramString)")!)
            }
            else {
                request = URLRequest(url: URL(string:url)!)
            }
        }
        else if method == .POST {
            request = URLRequest(url: URL(string:url)!)
            
            // content-type
            let headers: Dictionary = ["Content-Type": "application/json"]
            request.allHTTPHeaderFields = headers
            
            do {
                if let p = param {
                    request.httpBody = try JSONSerialization.data(withJSONObject: p, options: .prettyPrinted)
                }
            } catch { }
        }
        
        request.timeoutInterval = 30
        request.httpMethod = method.rawValue
        
        //
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                
                // check for fundamental networking error
                guard let data = data, error == nil else {
                    completion(nil, error)
                    return
                }
                
                // check for http errors
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200, let res = response {
                }
                
                if let resJson = self.convertToJson(data) {
                    completion(resJson, nil)
                }
                else if let resString = String(data: data, encoding: .utf8) {
                    completion(resString, error)
                }
                else {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    func requestRemoveAccount(_ url: String,
                              param:  [String: String],
                              method: ApiMethod,
                              loading: Bool,
                              completion: @escaping ApiCompletion)
    {
        // set method & param
        if method == .POST {
            if let token_login: String = KeychainWrapper.standard.string(forKey: "token_login"){
                let headers: Dictionary = [ "Authorization":"Bearer " + token_login]
                var request = MultipartFormDataRequest(url: URL(string: url)!)
                for (key, value) in param {
                    request.addTextField(named: key, value: value)
                }
                request.headers = headers
                var result:(message:String, data:Data?) = (message: "Fail", data: nil)
                URLSession.shared.dataTask(with: request, completionHandler: {data,response,error in
                    result.data = data
                    DispatchQueue.main.async {
                        // check for fundamental networking error
                        guard let data = data, error == nil else {
                            completion(nil, error)
                            return
                        }
                        // check for http errors
                        if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200, let res = response {
                        }
                        if let resJson = self.convertToJson(data) {
                            completion(resJson, nil)
                        }
                        else if let resString = String(data: data, encoding: .utf8) {
                            completion(resString, error)
                        }
                        else {
                            completion(nil, error)
                        }
                    }
                }).resume()
                
            }
        }
    }
    
    func requestTokenGhepDoi(_ url: String,
                             _ link1: String,
                             _ link2: String,
                             param: ApiParam?,
                             method: ApiMethod,
                             loading: Bool,
                             completion: @escaping ApiCompletion)
    {
        var request:URLRequest!
        
        // set method & param
        if method == .GET {
            if let token_login: String = KeychainWrapper.standard.string(forKey: "token_login"){
                let headers: Dictionary = ["Link1":link1, "Link2": link2 , "Authorization":"Bearer " + token_login]
                if let paramString = param?.stringFromHttpParameters() {
                    if let linkPro = "\(url)?\(paramString)".urlEncoded{
                        request = URLRequest(url: (URL(string:linkPro )!))
                    }
                }
                else {
                    if let linkPro = "\(url)".urlEncoded{
                        request = URLRequest(url: (URL(string:"\(url)" )!))
                    }
                }
                request.allHTTPHeaderFields = headers
            }
        }
        else if method == .POST {
            request = URLRequest(url: URL(string:url)!)
            
            // content-type
            let headers: Dictionary = ["Link-detail":"https://www.mngdoom.com/"]
            request.allHTTPHeaderFields = headers
            
            do {
                if let p = param {
                    request.httpBody = try JSONSerialization.data(withJSONObject: p, options: .prettyPrinted)
                }
            } catch { }
        }
        
    }
}








