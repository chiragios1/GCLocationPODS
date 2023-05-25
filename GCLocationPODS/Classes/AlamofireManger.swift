//
//  AlamofireManger.swift
//  LocationTracking
//
//  Created by admin on 05/04/23.
//

import Foundation

import Alamofire
import Reachability
import SystemConfiguration
import os
import CocoaLumberjack
//import CocoaLumberjackSwift
struct MYError : Error {
    let description : String
    let domain : String
    
    var localizedDescription: String {
        return NSLocalizedString(description, comment: "")
    }
    
}
class SingleTon: NSObject {
    static let sharedSingleTon = SingleTon()
    
    class func isInternetAvailable() -> Bool {
        var status: Bool
        let reachability =  try! Reachability()
        switch reachability.connection
        {
        case .none:
            debugPrint("Network unreachable")
            status = false
        case .wifi:
            debugPrint("Network reachable through WiFi")
            status = true
        case .cellular:
            status = true
            debugPrint("Network reachable through Cellular Data")
        case .unavailable:
            debugPrint("Network unreachable")
            status = false
        }
        return status
    }
}
enum AlertTitleMessage {
     static let INTERNET_ERROR = "You are browsing offline. Please check your internet connection!"
     static let ERROR = "Opps! Something went wrong."
    static let success = "Success"
    static let ok = "OK"
    static let gotIt = "Got It !"
    static let dismiss = "Dismiss"
    static let yes = "Yes"
    static let no = "No"
    static let cancel = "Cancel"
    static let save = "Save"
     static let logout = "Are you sure you want to Logout?"
}

public class AlamoFireCommon:  NSObject
{
    static var fullURL : String!
    static let shared = AlamoFireCommon()
        
        private override init() {
            super.init()
            
            let consoleLogger = DDOSLogger.sharedInstance
            DDLog.add(consoleLogger)
          
        }
    //MARK:- Alamofire
    //MARK:-POST Method
    public  class func PostURL(url: String, dict:Dictionary<String, Any>, completion: @escaping (_ responceData:Dictionary<String, Any>, _ success: Bool, _ error: Error) -> ())
    {
        if SingleTon.isInternetAvailable()
        {
          //  let fullUrl = "https://api-staging.green-convenience.com/v1/api/\(url)"
            let fullUrl = "\(fullURL ?? "")\(url)"
            var headers = HTTPHeaders()
            headers = ["Content-Type": "application/json", "key": UserDefaults.standard.string(forKey: "ClientKey") ?? ""]
           // fullUrl =  APIURL.BASEURL + url

       
            print("POST API: \(fullUrl)")
            print("PARAMETER: \(dict as NSDictionary)")
            //print("authentication-token: \(UserDefaultHelper.authToken ?? "")")
            
            //set Headers

           
            
            AF.request(fullUrl, method: .post, parameters: dict, encoding: JSONEncoding.prettyPrinted, headers: headers, interceptor: nil).responseJSON { (response) in
                switch response.result
                {
                case .success(_):
                    if response.value != nil
                    {
                        print(response.value!)
                        let data = response.value!
                       
                            completion(data as! [String:AnyObject],true,response.error ?? MYError(description: "", domain: ""))
                       // Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Place API").log("\(response.value as! NSDictionary)")
                        DDLogError("\(response.value as! NSDictionary)")

                    }
                    break
                case .failure(_):
                    print(response.error!)
                    let temp=NSDictionary.init(object: response.error?.localizedDescription ?? AlertTitleMessage.ERROR, forKey: "message" as NSCopying)
                    completion(temp as! Dictionary<String, Any>,false,response.error!)
                    Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Place API").log("\(temp )")
                    DDLogError("\(temp)")

                    break
                }
            }
        }
        else
        {
            let temp=NSDictionary.init(object: AlertTitleMessage.INTERNET_ERROR, forKey: "message" as NSCopying)
            completion(temp as! Dictionary<String, Any>,false,MYError(description: "", domain: ""))
        }
    }
    public   class func GetURL(url: String, dict:Dictionary<String, Any>, completion: @escaping (_ responceData:Dictionary<String, Any>, _ success: Bool, _ error: Error) -> ())
    {
        if SingleTon.isInternetAvailable()
        {
            //let fullUrl = "https://api-staging.green-convenience.com/v1/api/\(url)"
            let fullUrl = "\(fullURL ?? "")\(url)"
            var headers = HTTPHeaders()
            headers = ["Content-Type": "application/json", "key": UserDefaults.standard.string(forKey: "ClientKey") ?? ""]
           // fullUrl =  APIURL.BASEURL + url

       
            print("GET API: \(fullUrl)")
            print("PARAMETER: \(dict as NSDictionary)")
            //print("authentication-token: \(UserDefaultHelper.authToken ?? "")")
            
            //set Headers

           
            
            AF.request(fullUrl, method: .get, parameters: dict, encoding: URLEncoding.default, headers: headers, interceptor: nil).responseJSON { (response) in
                switch response.result
                {
                case .success(_):
                    if response.value != nil
                    {
                        print(response.value as! NSDictionary)
                        let data = response.value! as! NSDictionary
                       
                            completion(data as! [String:AnyObject],true,response.error ?? MYError(description: "", domain: ""))
                       // Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Place API").log("\(response.value as! NSDictionary)")
                     //   DDLogDebug("\(response.value as! NSDictionary)")

                    }
                    break
                case .failure(_):
                    print(response.error!)
                    let temp=NSDictionary.init(object: response.error?.localizedDescription ?? AlertTitleMessage.ERROR, forKey: "message" as NSCopying)
                    completion(temp as! Dictionary<String, Any>,false,response.error!)
                    Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Place API").log("\(temp )")
                //    DDLogError("\(temp)")

                    break
                }
            }
        }
        else
        {
            let temp=NSDictionary.init(object: AlertTitleMessage.INTERNET_ERROR, forKey: "message" as NSCopying)
            completion(temp as! Dictionary<String, Any>,false,MYError(description: "", domain: ""))
        }
    }
}
