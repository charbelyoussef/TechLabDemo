//
//  ViewController.swift
//  TechLabDemo
//
//  Created by Youssef on 9/27/21.
//

import UIKit
import Alamofire

class RequestManager: NSObject {
    
    var alamoFireManager: Alamofire.Session?
    
    static let sharedManager = RequestManager()
    
    fileprivate override init() {
        AF.sessionConfiguration.timeoutIntervalForRequest = 30
        AF.sessionConfiguration.timeoutIntervalForResource = 30
    }
    
    /**
     Send GET request.
     - parameter url     : URL string.
     - parameter success : Success handler callback.
     - parameter failure : Failure handler callback.
     */
    
    func get(url: String, headers: HTTPHeaders?, loading: Bool, success:@escaping (_ result: NSDictionary) -> (), failure:@escaping (_ result: Error) -> ()) {
        request(url: url, headers: headers, loading: loading, success: success, failure: failure)
    }
    
    /**
     Send HTTP request.
     - parameter method  : HTTP method. `"get"` by default.
     - parameter url     : URL string. `""` by default.
     - parameter params  : Request parameters Dictionary as [String:AnyObject]. `[:]` by default.
     - parameter success : Success handler callback.
     - parameter failure : Failure handler callback.
     */
    
    fileprivate func request(method: String = "get",
                             url: String = "",
                             params: [String:AnyObject] = [:],
                             headers: HTTPHeaders?,
                             raw:Bool = false,
                             loading: Bool,
                             success:@escaping (_ result: NSDictionary) -> (),
                             failure:@escaping (_ result: Error) -> ()) {
        
        var requestMethod: Alamofire.HTTPMethod
        
        switch method {
        case "post":
            requestMethod = .post
            break
        case "delete":
            requestMethod = .delete
        case "put":
            requestMethod = .put
        default:
            requestMethod = .get
            break
        }

        let encoding:ParameterEncoding = raw ? JSONEncoding.default : URLEncoding.default
                
        AF.request(url, method: requestMethod, parameters: params, encoding: encoding, headers: headers, interceptor: nil).responseJSON {
            (response:AFDataResponse<Any>) in
            switch(response.result) {
            case .success(let jsonResponse):
                
                
                if let responseArray = jsonResponse as? NSArray {
                    let jsonDict:NSDictionary = ["data" : responseArray]
                    success(jsonDict)
                }
                else if let response = jsonResponse as? NSDictionary {
                    success(response)
                }
                else {
                    let error = NSError(domain: "", code: 69, userInfo: [NSLocalizedDescriptionKey: Constants.Errors.PARSING_ERROR])
                    failure(error)
                    return
                }
                break
                
            case .failure(let error):
                if let err = error.asAFError {
                    if err.isResponseSerializationError {
                        let nserror = NSError(domain: "", code: 69, userInfo: [NSLocalizedDescriptionKey: "There was an error reading the data."])
                        failure(nserror)
                    }
                }
                else {
                    failure(error)
                }
                
                break
            }
        }
    }
    
}
