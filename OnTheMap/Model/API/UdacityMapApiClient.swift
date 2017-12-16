//
//  UdacityMapApiClient.swift
//  OnTheMap
//
//  Created by Sebastian on 09.12.17.
//  Copyright © 2017 IdrilsBlog. All rights reserved.
//

import UIKit

class UdacityMapApiClient {
    // MARK: Properties
    
    // shared URL session
    var session = URLSession.shared

    let urlScheme = "https"
    let apiHost = "parse.udacity.com"
    let apiPath = "/parse/classes/StudentLocation"
    
    let headers = ["Accept": "application/json",
                   "Content-Type": "application/json",
                   "X-Parse-Application-Id": "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr",
                   "X-Parse-REST-API-Key": "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
                    ]
    
    
    func getStudentsLocations(completionHander: @escaping (_ result: [StudentInformation]?, _ error: NSError?) -> Void) {
        let request = buildRequest(HTTPmethod: "GET", urlParameters: ["limit": "100", "order": "-updatedAt"], pathExtension: nil, headers: headers, body: nil)
        
        _ = execRequest(request) { (result, error) in
            guard error == nil else {
                completionHander(nil, error)
                return
            }
            
            guard let students = result!["results"] as? [[String: AnyObject]] else {
                print("Can't find [students] in response")
                completionHander(nil, NSError(domain: "execRequest", code: 1, userInfo: [NSLocalizedDescriptionKey : "Can't find [students] in response"]))
                return
            }
            
            var studentsArray: [StudentInformation] = []
            for student in students {
                studentsArray.append(StudentInformation(dictionary: student))
            }
            
            completionHander(studentsArray, nil)
            
            
        }
    }
    
    func getStudentLocation(uniqueKey: String, completionHander: @escaping (_ result: StudentInformation?, _ error: NSError?) -> Void ) {
        
        
        let request = buildRequest(HTTPmethod: "GET",  urlParameters: ["where": "{\"uniqueKey\":\"\(uniqueKey)\"}"], pathExtension: nil, headers: headers, body: nil)
        
        _ = execRequest(request) { (result, error) in
            guard error == nil else {
                completionHander(nil, error)
                return
            }
            
            guard let student = result!["results"] as? [[String: AnyObject]] else {
                print("Can't find [student] in response")
                completionHander(nil, NSError(domain: "execRequest", code: 1, userInfo: [NSLocalizedDescriptionKey : "Can't find [student] in response"]))
                return
            }
            
            if let student = student.first {
                completionHander(StudentInformation(dictionary: student), nil)
            } else {
                completionHander(nil, NSError(domain: "execRequest", code: 1, userInfo: [NSLocalizedDescriptionKey : "Couldn't get Student out of result"]))
            }
            
        }
    }
    
    func addStudent(student: StudentInformation, completionHander:  @escaping (_ result: String?, _ error: NSError?) -> Void ) {
        
        let bodyString = createStudentBody(student)
        let request = buildRequest(HTTPmethod: "POST", urlParameters: [:], pathExtension: nil, headers: headers, body: bodyString)
        
        
        _ = execRequest(request) {(result, error) in
            guard error == nil else {
                completionHander(nil, error)
                return
            }
            
            guard let objectID = result!["objectId"] as? String else {
                print("Can't find [objectID] in response")
                completionHander(nil, NSError(domain: "execRequest", code: 1, userInfo: [NSLocalizedDescriptionKey : "Can't find [objectID] in response"]))
                return
            }
            
            completionHander(objectID, nil)
            
            
        }
        
    }
    
    func updateStudent(student: StudentInformation, completionHander:  @escaping (_ result: String?, _ error: NSError?) -> Void ) {
        
        let bodyString = createStudentBody(student)
        // add objectID to path Extension
        let request = buildRequest(HTTPmethod: "PUT", urlParameters: [:], pathExtension: "/\(student.objectId)", headers: headers, body: bodyString)
        
        _ = execRequest(request) {(result, error) in
            guard error == nil else {
                completionHander(nil, error)
                return
            }
            
            completionHander(nil, nil)
            
            
        }
        
    }
    
    
    // MARK: Reqeust handling
    
    private func buildRequest(HTTPmethod: String = "GET", urlParameters: [String:String], pathExtension: String?, headers: [String:String]?, body: String?) -> NSMutableURLRequest {
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
    
    private func execRequest(_ request: NSMutableURLRequest, complectionHandler: @escaping (_ result: AnyObject?, _ error: NSError?)-> Void) -> URLSessionDataTask {
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                complectionHandler(nil, NSError(domain: "execRequest", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!.localizedDescription)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode
                if statusCode! >= 400 && statusCode! <= 499 {
                    sendError("Your request returned a status code \(statusCode!) please check your Username or Password.")
                } else {
                    sendError("Your request returned a status code other than 2xx!")
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: complectionHandler)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
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
    
    private func createStudentBody(_ student: StudentInformation) -> String {
        let body = ["uniqueKey": student.uniqueKey,
                    "firstName": student.firstName,
                    "lastName": student.lastName,
                    "mapString": student.mapString,
                    "mediaURL": student.link?.absoluteString,
                    "latitude": student.location.coordinate.latitude,
                    "longitude": student.location.coordinate.longitude
            ] as [String : Any]
        
        let bodyData = try! JSONSerialization.data(withJSONObject: body, options: [])
        return String(data: bodyData, encoding: String.Encoding.utf8)!
    }

}
