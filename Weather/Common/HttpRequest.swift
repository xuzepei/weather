

import UIKit

@objc protocol HttpRequestProtocol {
    @objc optional func willStartHttpRequest(_ token : Any)
    @objc optional func didFinishHttpRequest(_ token : Any)
    @objc optional func didFailHttpRequest(_ token : Any)
}

open class HttpRequest: NSObject{
    
    static let shared = HttpRequest()
    static let kHttpStatusCode = "http_status_code"
    
    var isRequesting = false
    var resultSelector : Selector? = nil
    var resultBlock: ((Dictionary<String, AnyObject>?) -> Void)? = nil
    var token : [String : Any]?
    var requestUrlString : String = ""
    var dataTask : URLSessionDataTask?
    var uploadTask : URLSessionUploadTask?
    weak var delegate : AnyObject?
    
    override init() {
        
    }
    
    init(delegate: AnyObject?) {
        self.delegate =  delegate
    }
    
    func get(_ urlString : String, resultBlock : @escaping ((Dictionary<String, AnyObject>?) -> Void), token : [String : Any]?) -> Bool {
        
        if urlString.count == 0 || self.isRequesting {
            return false
        }
        
        print("request-get:", urlString)
        
        self.resultBlock = resultBlock
        self.token = token
        self.requestUrlString = urlString
        
        let urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let request = NSMutableURLRequest()
        request.url = URL(string: urlString)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 20.0
        request.httpShouldHandleCookies = false
        request.httpMethod = "GET"
        request.setValue("*/*", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        self.isRequesting = true
        
        let session = URLSession.shared
        self.dataTask = session.dataTask(
            with: request as URLRequest, completionHandler: { (data : Data?, response : URLResponse?, error : Error?) in
                
                if let requestError = error {
                    
                    print("Http request error:", requestError.localizedDescription)
                    
                    //Analytics.logEvent("Http-Get", parameters: ["error": requestError.localizedDescription])
                }
                
                if let httpURLResponse = response as? HTTPURLResponse {
                    
                    print("HTTP status code:", httpURLResponse.statusCode)
                }
                
                var dict: Dictionary<String, AnyObject>? = nil
                
                if let receivedData = data {
                    
                    dict = Tool.parseToDictionary(jsonData: receivedData)
                    
                }
                
                self.dataTask = nil
                self.isRequesting = false
                
                DispatchQueue.main.async {
                    if let resultBlock = self.resultBlock {
                        resultBlock(dict)
                    }
                }
            })
        
        self.dataTask?.resume()
        
        return true
    }
    
    func post(_ urlString : String, resultBlock : @escaping ((Dictionary<String, AnyObject>?) -> Void), token : [String : Any]?, tag: String? = nil) -> Bool {
        
        if urlString.count == 0 || self.isRequesting {
            return false
        }
        
        print("request-post:", urlString)
        
        self.resultBlock = resultBlock
        self.token = token
        self.requestUrlString = urlString
        
        let urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let request = NSMutableURLRequest()
        request.url = URL(string: urlString)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 20.0
        request.httpShouldHandleCookies = false
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let dataString = self.token?["bodyString"] as? String {
            request.httpBody = dataString.data(using: .utf8)
        } else {
            if let bodyData = self.token?["bodyData"] as? Data {
                request.httpBody = bodyData
            }
        }
        
        self.isRequesting = true
        
        let session = URLSession.shared
        self.dataTask = session.dataTask(
            with: request as URLRequest, completionHandler: { (data : Data?, response : URLResponse?, error : Error?) in
                
                if let requestError = error {
                    
                    print("Http request error:", requestError.localizedDescription)
                    
                    //Analytics.logEvent("Http-Post", parameters: ["error": requestError.localizedDescription])
                }
                
                if let httpURLResponse = response as? HTTPURLResponse {
                    
                    print("HTTP status code:", httpURLResponse.statusCode)
                    
                    //self.httpStatusHandler(response: httpURLResponse, url: self.requestUrlString)
                }
                
                // Check for network-related errors
                if let error = error as NSError? {
                    if error.domain == NSURLErrorDomain {
                        print("####Network error: \(error.code)")
                    }
                }

                var dict: Dictionary<String, AnyObject>? = nil
                
                if let receivedData = data {
                    
                    //jsonString = String(data: receivedData, encoding: String.Encoding.utf8) ?? ""
                    if let tempDict = Tool.parseToDictionary(jsonData: receivedData) {
                        dict = tempDict
                    }
                    
                    if let tag = tag {
                        dict?["tag"] = tag as AnyObject
                    }
                    
                    debugPrint(dict ?? "")
                    
                }
                
                self.dataTask = nil
                self.isRequesting = false
                
                DispatchQueue.main.async {
                    if let resultBlock = self.resultBlock {
                        resultBlock(dict)
                    }
                }
            })
        
        self.dataTask?.resume()
        
        return true
    }

}
