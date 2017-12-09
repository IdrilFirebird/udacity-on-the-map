//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Sebastian on 03.12.17.
//  Copyright © 2017 IdrilsBlog. All rights reserved.
//

import UIKit

class UdacityClient: NSObject {

    // MARK: Properties
    
    // shared session
    var session = URLSession.shared
//    let baseURL = "https://www.udacity.com/api/"
    let urlScheme = "https"
    let apiHost = "www.udacity.com"
    let apiPath = "/api"
    
    let headers = ["Accept": "application/json", "Content-Type": "application/json"]
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    
//  Maybe implement that as singolton with class methods?
//    class func sharedInstance() -> UdacityClient {
//        struct Singleton {
//            static var sharedInstance = UdacityClient()
//        }
//        return Singleton.sharedInstance
//    }

    
    func createUserSession(username: String, password: String, completionHander: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        let bodyString = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
        
        let request = buildRequest(HTTPmethod: "POST", pathExtension: "/session", urlParameters: [:], headers: headers, body: bodyString)
        
        execRequest(request) { (result, error) in
            guard error == nil else {
                completionHander(nil, error)
                return
            }
            
            guard let account = result!["account"] as? [String : AnyObject], let userId = account["key"] as? String else {
                print("Can't find [account][key] in response")
                completionHander(nil, NSError(domain: "execRequest", code: 1, userInfo: [NSLocalizedDescriptionKey : "Can't find [account][key] in response"]))
                return
            }
            
            guard let session = result!["session"] as? [String : AnyObject], let sessionId = session["id"] as? String else {
                print("Can't find [session][id] in response")
                completionHander(nil, NSError(domain: "execRequest", code: 1, userInfo: [NSLocalizedDescriptionKey : "Can't find [session][id] in response"]))
                return
            }
            
            let result = ["userID": userId, "sessionID": sessionId] as AnyObject?
            
            completionHander(result, nil)
            
        }
    }
    
    func destroySession(completionHander: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        
         let request = buildRequest(HTTPmethod: "DELETE", pathExtension: "/session", urlParameters: [:], headers: headers, body: nil)
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        
        if let cookie = xsrfCookie {
            request.setValue(cookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        execRequest(request) { (result, error) in
            guard error == nil else {
                completionHander(nil, error)
                return
            }
            
            guard let session = result!["session"] as? [String : AnyObject], let sessionId = session["id"] as? String else {
                print("Can't find [session][id] in response")
                completionHander(nil, NSError(domain: "execRequest", code: 1, userInfo: [NSLocalizedDescriptionKey : "Can't find [session][id] in response"]))
                return
            }

            let result = ["userID": nil, "sessionID": sessionId] as AnyObject?
            
            completionHander(result, nil)
            
        }
    }
    
    func getUserInfo(userId: String, completionHander: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        let request = buildRequest(HTTPmethod: "GET", pathExtension: "/users/\(userId)", urlParameters: [:], headers: headers, body: nil)
        
        execRequest(request) { (result, error) in
            guard error == nil else {
                completionHander(nil, error)
                return
            }
            
            guard let userData = result!["user"] as? [String : AnyObject] else {
                print("Can't find [user] in response")
                completionHander(nil, NSError(domain: "execRequest", code: 1, userInfo: [NSLocalizedDescriptionKey : "Can't find [user] in response"]))
                return
            }
            guard let firstName = userData["first_name"] as? String, let lastName = userData["last_name"] as? String else {
                print("Can't find [user]['first_name'] or [user]['last_name'] in response")
                completionHander(nil, NSError(domain: "execRequest", code: 1, userInfo: [NSLocalizedDescriptionKey : "Can't find [user]['first_name'] or [user]['last_name'] in response"]))
                return
            }
            
            let result = ["firstName": firstName, "lastName": lastName, "userID": userId] as AnyObject?
            
            completionHander(result, nil)
            
        }
        
    }
    
    
    // MARK: Reqeust handling
    
    func buildRequest(HTTPmethod: String, pathExtension: String?, urlParameters: [String:String], headers: [String:String]?, body: String?) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(url: apiURLFromParameters(baseURL_: urlParameters, withPathExtension: pathExtension))
        request.httpMethod = HTTPmethod
        if let headers = headers {
            for (header, value) in headers {
                request.addValue(value, forHTTPHeaderField: header)
            }
            
        }
        
        if let body = body {
            request.httpBody = body.data(using: String.Encoding.utf8)
        }

        return request
    }
    
    func execRequest(_ request: NSMutableURLRequest, complectionHandler: @escaping (_ result: AnyObject?, _ error: NSError?)-> Void) -> URLSessionDataTask {
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                complectionHandler(nil, NSError(domain: "execRequest", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            //Udacity Api data shift
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range) /* subset response data! */
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: complectionHandler)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    
    private func apiURLFromParameters(baseURL_ parameters: [String:String], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = urlScheme
        components.host = apiHost
        components.path = apiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }

    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
}
