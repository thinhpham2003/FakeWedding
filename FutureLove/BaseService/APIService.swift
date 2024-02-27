import UIKit
import Alamofire
import SwiftKeychainWrapper

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

    func requestTokenThinhGhepDoi(_ url: String,
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
                let headers: Dictionary = ["link1":link1, "link2": link2 , "Authorization":"Bearer " + token_login]
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

        request.timeoutInterval = 5000
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

        request.timeoutInterval = 500
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

    func UploadImagesToGenRieng(_ url: String,
                                ImageUpload: UIImage,
                                method: ApiMethod,
                                loading: Bool,
                                completion: @escaping ApiCompletion)
    {
        let form = MultipartForm(parts: [
            MultipartForm.Part(name: "src_img", data: ImageUpload.jpegData(compressionQuality: 1)!, filename: "src_img.jpeg", contentType: "image/jpeg"),
        ])

        var request = URLRequest(url: URL(string:url)!)
        request.httpMethod = "POST"
        request.setValue(form.contentType, forHTTPHeaderField: "Content-Type")
        var result:(message:String, data:Data?) = (message: "Fail", data: nil)

        URLSession.shared.uploadTask(with: request, from: form.bodyData){ (data, response, error) in

            if let error = error {
                // Error
            }
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
                if let resString = String(data: data, encoding: .utf8) {
                    completion(resString, error)
                }
                else {
                    completion(nil, error)
                }
            }
            // Do something after the upload task is complete

        }.resume()
    }



    func requestTokenFolderGhepDoi(_ url: String,
                                   linkNam: String,
                                   linkNu: String,
                                   param: ApiParam?,
                                   method: ApiMethod,
                                   loading: Bool,
                                   completion: @escaping ApiCompletion)
    {
        var request:URLRequest!

        // set method & param
        if method == .GET {
            if let token_login: String = KeychainWrapper.standard.string(forKey: "token_login"){
                let namString = linkNam.replacingOccurrences(of: "\"", with: "")
                let nuString = linkNu.replacingOccurrences(of: "\"", with: "")

                let headers: Dictionary = ["linknam":namString,"linknu":nuString ,"Authorization":"Bearer " + token_login]
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

        request.timeoutInterval = 1000
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


    func requestSwapVideoNhapVao(_ url: String,
                                 linkNam: String,
                                 linkNu: String,
                                 param: ApiParam?,
                                 method: ApiMethod,
                                 loading: Bool,
                                 completion: @escaping ApiCompletion)
    {
        var request:URLRequest!

        // set method & param
        if method == .GET {
            if let token_login: String = KeychainWrapper.standard.string(forKey: "token_login"){
                let namString = linkNam.replacingOccurrences(of: "\"", with: "")
                let nuString = linkNu.replacingOccurrences(of: "\"", with: "")

                let headers: Dictionary = ["Authorization":"Bearer " + token_login]
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

        request.timeoutInterval = 1000
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
    func requestSON(_ url: String,
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
            let headers: Dictionary = ["Link1":link1, "Link2": link2]

            if let paramString = param?.stringFromHttpParameters() {
                request = URLRequest(url: URL(string:"\(url)?\(paramString)")!)
            }
            else {
                request = URLRequest(url: URL(string:url)!)
            }
            request.allHTTPHeaderFields = headers


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

    func requestFreeHostSON(_ url: String,
                            param: [String: String],
                            method: ApiMethod,
                            loading: Bool,
                            completion: @escaping ApiCompletion)
    {
        var request:URLRequest!
        // set method & param
        if method == .GET {
            request = URLRequest(url: URL(string:url)!)
            request.timeoutInterval = 30
            request.httpMethod = method.rawValue
            let request = MultipartFormDataRequest(url: URL(string: url)!)
            for (key, value) in param {
                request.addTextField(named: key, value: value)
            }
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

        else if method == .POST {
            request = URLRequest(url: URL(string:url)!)
            request.timeoutInterval = 30
            request.httpMethod = method.rawValue
            let request = MultipartFormDataRequest(url: URL(string: url)!)
            for (key, value) in param {
                request.addTextField(named: key, value: value)
            }
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

    func LoginAPI(param:[String: String], closure: @escaping (_ response: LoginModel?, _ error: Error?) -> Void) {
        requestFreeHostSON("https://databaseswap.mangasocial.online/login" , param: param, method: .POST, loading: true) { (data, error) in
            if let data = data as? [String:Any]{
                var  returnData:LoginModel = LoginModel()
                returnData = returnData.initLoad(_A: data)
                closure(returnData,nil)
            }else{
                closure(nil,nil)
            }
        }
        closure(nil, nil)
    }

    func RegisterAccount(param:[String: String], closure: @escaping (_ response: RegisterModel?, _ error: Error?) -> Void) {
        requestFreeHostSON("https://databaseswap.mangasocial.online/register/user", param: param, method: .POST, loading: true) { (data, error) in
            if let data = data as? [String:Any]{
                var returnData: RegisterModel = RegisterModel()
                returnData = returnData.initLoad(data)
                closure(returnData,nil)
            }
        }
        closure(nil, nil)
    }

    func resetPassword(param:[String: String], closure: @escaping (_ response: ResetPasswordModel?, _ error: Error?) -> Void) {
        requestFreeHostSON("https://databaseswap.mangasocial.online/reset", param: param, method: .POST, loading: true) { (data, error) in
            if let data = data as? [String:Any]{
                var returnData: ResetPasswordModel = ResetPasswordModel()
                returnData = returnData.initLoad(data)
                closure(returnData,nil)
            }else{
                closure(nil,nil)
            }
        }
        closure(nil, nil)
    }

    func getIP(closure: @escaping (_ response: IPAddress?, _ error: Error?) -> Void) {
        requestJSON("https://ipinfo.io/json", param: nil, method: .GET, loading: true) { (data, error) in
            if let data2 = data as? [String:Any]{
                var returnData: IPAddress = IPAddress()
                returnData = returnData.initLoad(data2)
                closure(returnData,nil)
            }else{
                closure(nil,nil)
            }
        }
        closure(nil, nil)
    }
    func getAll_KeyAPI(closure: @escaping (_ response: [APIKeyIMGBB], _ error: Error?) -> Void) {
        requestJSON("https://raw.githubusercontent.com/sonnh7289/python3-download/main/key-ios.json" , param: nil, method: .GET, loading: true) { (data, error) in
            var listAPIkey:[APIKeyIMGBB] = [APIKeyIMGBB]()
            if let data2 = data as? [[String:Any]]{
                for item in data2{
                    var returnData: APIKeyIMGBB = APIKeyIMGBB()
                    returnData = returnData.initLoad(item)
                    listAPIkey.append(returnData)
                }
                closure(listAPIkey,nil)
            }else{
                closure([APIKeyIMGBB](),nil)
            }
        }
        closure([APIKeyIMGBB](), nil)
    }

    func listImageUploaded(type:String,idUser:String,closure: @escaping (_ response: [String], _ error: Error?) -> Void) {
        let linkUrl = "https://databaseswap.mangasocial.online/images/" + idUser + "?type=" + type
        requestJSON(linkUrl, param: nil, method: .GET, loading: true) { (data, error) in
            var listLinkImage : [String] = [String]()
            if let data = data as? [String:Any]{
                if type == "nam"{
                    if let data2 = data["image_links_nam"] as? [String]{
                        listLinkImage = data2
                        closure(listLinkImage,nil)
                    }else{
                        closure([String](),nil)
                    }
                }else if type == "nu"{
                    if let data2 = data["image_links_nu"] as? [String]{
                        listLinkImage = data2
                        closure(listLinkImage,nil)
                    }else{
                        closure([String](),nil)
                    }
                }else if type == "video"{
                    if let data2 = data["image_links_video"] as? [String]{
                        listLinkImage = data2
                        closure(listLinkImage,nil)
                    }else{
                        closure([String](),nil)
                    }
                }
            }else{
                closure([String](),nil)
            }
        }
    }

    func RemoveMyAccount(userID:String,password:String,closure: @escaping (_ response: String, _ error: Error?) -> Void) {
        let paramSend:[String: String] = ["password":password]
        let linkUrl = "https://databaseswap.mangasocial.online/deleteuser/" + userID
        requestRemoveAccount(linkUrl, param: paramSend, method: .POST, loading: true) { (data, error) in
            if let data2 = data as? [String:Any]{
                var messageSend = ""
                if let temp = data2["message"] as? String {messageSend = temp}
                closure(messageSend,nil)
            }else{
                if let data = data as? String{
                    closure(data,nil)
                }
                closure("ERROR NO Message",nil)
            }
        }
        // closure("Please Wait To Remove", nil)
    }

    func postTokenNotification(token:String,userID:String,deviceName:String,closure: @escaping (_ response: String, _ error: Error?) -> Void) {
        let paramSend:[String: String] = ["device_token":token,"id_user":userID,"device_name":deviceName]
        requestRemoveAccount("https://databaseswap.mangasocial.online/add/token", param: paramSend, method: .POST, loading: true) { (data, error) in
            if let data2 = data as? [String:Any]{
                var messageSend = ""
                if let temp = data2["message"] as? String {messageSend = temp}
                closure(messageSend,nil)
            }else{
                if let data = data as? String{
                    closure(data,nil)
                }
                closure("ERROR NO Message",nil)
            }
        }
    }
    // https://databaseswap.mangasocial.online/get/categories_wedding
    func listCategoriesAll(closure: @escaping (_ response: [CategoriesModel], _ error: Error?) -> Void) {
        requestJSON("https://databaseswap.mangasocial.online/get/categories_wedding", param: nil, method: .GET, loading: true) { (data, error) in
            var listCategories : [CategoriesModel] = [CategoriesModel]()
            if let data = data as? [String:Any]{
                if let listData = data["categories_all"] as? [[String:Any]]{
                    for item in listData{
                        var itemAdd:CategoriesModel = CategoriesModel()
                        itemAdd = itemAdd.initLoad(item)
                        listCategories.append(itemAdd)
                    }
                }
                closure(listCategories,nil)
            }else{
                closure([CategoriesModel](),nil)
            }
        }
    }

    // https://databaseswap.mangasocial.online/get/list_image_wedding/1?album=1
    func listImage1Categories(linkDetailCategories:String,closure: @escaping (_ response: [CategorieItemModel], _ error: Error?) -> Void) {
        requestJSON(linkDetailCategories, param: nil, method: .GET, loading: true) { (data, error) in
            var listCategories : [CategorieItemModel] = [CategorieItemModel]()
            if let data = data as? [String:Any]{
                if let listData = data["list_sukien_video"] as? [[String:Any]]{
                    for item in listData{
                        var itemAdd:CategorieItemModel = CategorieItemModel()
                        itemAdd = itemAdd.initLoad(item)
                        listCategories.append(itemAdd)
                    }
                }
                closure(listCategories,nil)
            }else{
                closure([CategorieItemModel](),nil)
            }
        }
    }

    func create50ImagesWedding(device_them_su_kien:String,ip_them_su_kien:String,id_user:String,link_img1:String, link_img2:String,list_folder:String,closure: @escaping (_ response: SukienSwap2Image?, _ error: Error?) -> Void) {
        let newString1 = link_img1.replacingOccurrences(of: "\"", with: "", options: .literal, range: nil)
        let StringNam = newString1.replacingOccurrences(of: "https://futurelove.online", with: "/var/www/build_futurelove")

        let newString2 = link_img2.replacingOccurrences(of: "\"", with: "", options: .literal, range: nil)
        let StringNu = newString2.replacingOccurrences(of: "https://futurelove.online", with: "/var/www/build_futurelove")
        /*  const response = await axios.get(https://thinkdiff.us/getdata/swap/listimage_wedding?device_them_su_kien=${userData.device_register}&ip_them_su_kien=${userData.ip_register}&id_user=${userData.id_user}&list_folder=weddingface${id}, {
         https://thinkdiff.us/getdata/swap/listimage_wedding?device_them_su_kien=123&ip_them_su_kien=123&id_user=234&list_folder=weddingface23
         https://thinkdiff.us/getdata/swap/listimage_wedding?device_them_su_kien=Simulator%20%28iPhone%2015%20Pro%29&ip_them_su_kien=27.67.189.28&id_user=236&list_folder=weddingface2)
         */
        if let devicePro = device_them_su_kien.urlEncoded{
            requestTokenThinhGhepDoi("https://thinkdiff.us/getdata/swap/listimage_wedding?device_them_su_kien=\(devicePro)&ip_them_su_kien=\(ip_them_su_kien)&id_user=\(id_user)&list_folder=\(list_folder)", "\(StringNam)", "\(StringNu)", param: nil, method: .GET, loading: true) { (data, error) in
                if let data = data as? [String:Any]{
                    var itemAdd:SukienSwap2Image = SukienSwap2Image()
                    itemAdd = itemAdd.initLoad(data)
                    closure( itemAdd, nil)

                }else{

                    closure( SukienSwap2Image(), nil)
                }
            }
        }
    }
    //https://databaseswap.mangasocial.online/get/list_2_image/id_image_swap_all?id_user=236
    func ListIMGUser(id_user:Int,closure: @escaping (_ response: [ListImageSwaped], _ error: Error?) -> Void) {
        let linkUrl = "https://databaseswap.mangasocial.online/get/list_2_image/id_image_swap_all?id_user=\(id_user)"
        requestJSON(linkUrl, param: nil, method: .GET, loading: true) { (data, error) in
            var listVideoReturn : [ListImageSwaped] = [ListImageSwaped]()
            if let data2 = data as? [[String:Any]]{
                for item in data2{
                    if let listVideo2 = item["list_sukien_video"] as? [[String:Any]]{
                        for item2 in listVideo2{
                            var itemvideoAdd: ListImageSwaped = ListImageSwaped()
                            itemvideoAdd = itemvideoAdd.initLoad(item2)
                            listVideoReturn.append(itemvideoAdd)
                        }
                    }
                    closure(listVideoReturn,nil)
                }
            }else{
                closure([ListImageSwaped](),nil)
            }
        }
    }
    /*
     var listVideoReturn : [BabyGenn] = [BabyGenn]()
     if let data2 = data as? [String:Any]{
     if let listTongToanBo =  data2["id_su_kien_swap_image"] as? [[String:Any]]{
     for item2 in listTongToanBo{
     var itemvideoAdd: BabyGenn = BabyGenn()
     itemvideoAdd = itemvideoAdd.initLoad(item2)
     listVideoReturn.append(itemvideoAdd)
     }
     closure(listVideoReturn,nil)
     }
     }else{
     closure([BabyGenn](),nil)
     }
     */
    func listTemplateVideoSwap(closure: @escaping (_ response: [VideoTemplate], _ error: Error?) -> Void) {
        let linkUrl = "https://databaseswap.mangasocial.online/get/list_video/all_video_wedding_template"
        requestJSON(linkUrl, param: nil, method: .GET, loading: true) { (data, error) in
            var listVideoReturn : [VideoTemplate] = [VideoTemplate]()
            if let data2 = data as? [String:Any]{
                if let listTongToanBo =  data2["list_sukien_video_wedding"] as? [[String:Any]]{
                    for item2 in listTongToanBo{
                        var itemvideoAdd: VideoTemplate = VideoTemplate()
                        itemvideoAdd = itemvideoAdd.initLoad(item2)
                        listVideoReturn.append(itemvideoAdd)
                    }
                    closure(listVideoReturn,nil)
                }
            }else{
                closure([VideoTemplate](),nil)
            }
        }
    }
    func listVideoSwapped(id_user: Int, closure: @escaping (_ response: [VideoSwapped], _ error: Error?) -> Void) {
        let linkUrl = "https://databaseswap.mangasocial.online/get/list_video_wedding/id_video_swap?id_user=\(id_user)"
        requestJSON(linkUrl, param: nil, method: .GET, loading: true) { (data, error) in
            var listVideoReturn : [VideoSwapped] = [VideoSwapped]()
            if let data2 = data as? [String:Any]{
                if let listTongToanBo =  data2["list_sukien_video"] as? [[String:Any]]{
                    for item2 in listTongToanBo{
                        var itemvideoAdd: VideoSwapped = VideoSwapped()
                        itemvideoAdd = itemvideoAdd.initLoad(item2)
                        listVideoReturn.append(itemvideoAdd)
                    }
                    closure(listVideoReturn,nil)
                }
            }else{
                closure([VideoSwapped](),nil)
            }
        }
    }


    //https://videoswap.mangasocial.online/getdata/genvideo/swap/imagevid/wedding?device_them_su_kien=${userData.device_register}&ip_them_su_kien=${userData.ip_register}&id_user=${userData.id_user}&src_img=${src_res_1}&src_vid_path=${id}
    func createVideoWedding(device_them_su_kien:String,id_video:String,ip_them_su_kien:String,id_user:String,link_img:String,closure: @escaping (_ response: SukienSwapVideo?, _ error: Error?) -> Void) {
        print("Link img: \(link_img)")
        let newString1 = link_img.replacingOccurrences(of: "\"", with: "", options: .literal, range: nil)
        let StringNam = newString1.replacingOccurrences(of: "https://futurelove.online", with: "/var/www/build_futurelove")

        if let devicePro = device_them_su_kien.urlEncoded{
            requestJSON("https://videoswap.mangasocial.online/getdata/genvideo/swap/imagevid/wedding?device_them_su_kien=\(devicePro)&ip_them_su_kien=\(ip_them_su_kien)&id_user=\(id_user)&src_img=\(StringNam)&src_vid_path=\(id_video)", param: nil, method: .GET, loading: true) { (data, error) in
                print("https://videoswap.mangasocial.online/getdata/genvideo/swap/imagevid/wedding?device_them_su_kien=\(devicePro)&ip_them_su_kien=\(ip_them_su_kien)&id_user=\(id_user)&src_img=\(StringNam)&src_vid_path=\(id_video)")
                if let data = data as? [String:Any]{
                    var itemAdd:SukienSwapVideo = SukienSwapVideo()
                    itemAdd = itemAdd.initLoad(data)
                    closure( itemAdd, nil)

                }else{

                    closure( SukienSwapVideo(), nil)
                }
            }
        }
    }


    func getProfile(user: Int, closure: @escaping (_ response: ProfileModel?, _ error: Error?) -> Void) {
        requestJSON("https://databaseswap.mangasocial.online/profile/\(user)", param: nil, method: .GET, loading: true) { (data, error) in
            if let data2 = data as? [String:Any]{
                var returnData: ProfileModel = ProfileModel()
                returnData = returnData.initLoad(data2)
                closure(returnData,nil)
            }else{
                closure(nil,nil)
            }
        }
        closure(nil, nil)
    }

}









