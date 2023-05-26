//
//  GCLocation.swift
//  LocationTracking
//
//  Created by admin on 02/05/23.
//

import Foundation
import CoreLocation
//import CoreData
import  Alamofire
import CocoaLumberjack
//import CocoaLumberjackSwift
import OSLog
import Darwin
import CommonCrypto
import CryptoKit
import os
import BackgroundTasks
import Reachability
import  UIKit
import SSZipArchive

public class GCLocation: NSObject {
   // var locationObject = [Locationwithtimestamp]()
  //  public lazy var cdsLocationWithTimestamp: CoreDataStack = .init(modelName: "LocationWithTimestamp")
    public  var locationManager:CLLocationManager?
    public var timer = Timer()
    public  let formatter = DateFormatter()
    //public let generatedUser = ((Bool) -> Void)?.self
   public var generatedUser : ((Bool) -> Void)?
    var reachability : Reachability?
    // Parse two times as strings
    public  let time1String = "13:30"
    public  let time2String = "14:45"
    public let strFullServerURL = ""
    enum ApplicationState {
        case active
        case inactive
        case background

       
        init() {
            switch UIApplication.shared.applicationState {
            case .active:
                self = .active
            case .inactive:
                self = .inactive
            case .background:
                self = .background
            @unknown default:
                fatalError()
            }
        }
        
        public func toString() -> String {
                switch self {
                case .active:
                    return "Active"
                case .inactive:
                    return "Inactive"
                case .background:
                    return "Background"
                }
            }
    }
    public  static let shared = GCLocation()
        
        private override init() {
            super.init()
            let consoleLogger = DDOSLogger.sharedInstance
            DDLog.add(consoleLogger)
            do
            {
                self.reachability =  try Reachability()
                try reachability!.startNotifier()
                NotificationCenter.default.addObserver( self, selector: #selector( self.reachabilityChanged ),name: Notification.Name.reachabilityChanged, object: reachability )
            }
            catch
            {
               print( "ERROR: Could not start reachability notifier." )
            }

        }
    public func configure(serverURL: String, ClientKey: String, ClientID: String){
        AlamoFireCommon.fullURL = serverURL
        UserDefaults.standard.set(ClientKey, forKey: "ClientKey")
        UserDefaults.standard.set(ClientID, forKey: "ClientID")
       
    }
    public func startTracking(){
        self.startLocation()
        let calendar = Calendar.current
        let now = Date()

        _ = calendar.startOfDay(for: now)
        let ninePmToday = calendar.date(bySettingHour: 21, minute: 0, second: 0, of: now)!
      //  let eightAmTomorrow = calendar.date(byAdding: .day, value: 1, to: midnightToday)!
        let eightAmToday = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: now)!

        if now >= ninePmToday || now < eightAmToday {
            timer = Timer.scheduledTimer(timeInterval: 3600.0, target: self, selector: #selector(startLocation), userInfo: nil, repeats: true)


        } else {
            timer = Timer.scheduledTimer(timeInterval:15.0, target: self, selector: #selector(startLocation), userInfo: nil, repeats: true)


        }
    }
    public func setUserId(UserID: String)  {
        UserDefaults.standard.set(UserID, forKey: "user_id")
        
    }
    
    public func createNewClient(clintName: String) {
        let dict = ["client_name" : clintName] as [String : Any]
        AlamoFireCommon.PostURL(url: "client", dict: dict) { responceData, success, error in
            if success
            {
                if let data = (responceData["Data"] as? [String: Any]) {
                    self.callAPIForGETclient(data["Id"] as! String)

                }
            }
            else {
                self.generatedUser!(false)

            }

        }
        
        
    }
    public func generateUser(){
        self.callAPIForCreateCustomerID(UserDefaults.standard.string(forKey: "ClientID")!)
    }
    public func GetLogFile(){
        let logFileLogger = DDFileLogger()
        print(logFileLogger.logFileManager.logsDirectory)
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Documents directory not found")
        }
        let zipPath = "\(documentsURL.path)/archive.zip"
        let zipURL = URL(fileURLWithPath: zipPath)
        let success = SSZipArchive.createZipFile(atPath: zipPath, withFilesAtPaths: logFileLogger.logFileManager.sortedLogFilePaths)

        if success {
            print("Archive created successfully")
            let activityVC = UIActivityViewController(activityItems: [zipURL], applicationActivities: nil)
            if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                // Find the relevant window
                if let viewController = windowScene.windows.first?.rootViewController {
                    // Present the activity view controller
                    viewController.present(activityVC, animated: true, completion: nil)
                }
            }
            // Present the activity view controller
           
        } else {
            print("Failed to create archive")
        }
        for path in logFileLogger.logFileManager.sortedLogFilePaths {
            do {
                let content = try String(contentsOfFile: path, encoding: .utf8)
                print(content)
            } catch let error as NSError {
                print("Error: \(error.localizedDescription)")
            }
            
           
            
        }
    }
    
// MARK -  OTHER METHODS
    ///// OTHER METHODS
    
    @objc  func startLocation() {
         LocationManager.shared.getLocation { [self] (location:CLLocation?, error:NSError?) in
             if let error = error {
                // self.alertMessage(message: error.localizedDescription, buttonText: "OK", completionHandler: nil)
                // DDLog.sharedInstance.logError("\(error.localizedDescription)")
                 DDLogError("\(error.localizedDescription)")
                 
                 return
             }
             guard let location = location else {
                // DDLog.sharedInstance().logError("Unable to fetch location")
                 DDLogError("Unable to fetch location")
            
                 
                 return
             }
            
             print("Latitude: \(location.coordinate.latitude), Longitude: \(location.coordinate.longitude)")
             
             
             let s = RelativeMap().hash(Lat: location.coordinate.latitude, Lon: location.coordinate.longitude, UserID: UserDefaults.standard.string(forKey: "user_id")!)

             
           
             callAPIForPlaceStore(geoHash: s)
             
             let newLocation = LocationwithtimestampUserDefault(applicationState:ApplicationState().toString() , longitude : location.coordinate.longitude, latitude: location.coordinate.latitude, timestamp: Date())
           

             //To save the object
             var aResult = UserDefaults.standard.retrieve(object: [LocationwithtimestampUserDefault].self, fromKey: "LocationwithtimestampUserDefault")
             aResult?.append(newLocation)
             
             UserDefaults.standard.save(customObject: aResult, inKey: "LocationwithtimestampUserDefault")
             
           
             
             
//             let managedContext = self.cdsLocationWithTimestamp.managedContext
//             let newLocation = Locationwithtimestamp(context: managedContext)
//             newLocation.longitude = location.coordinate.latitude
//             newLocation.latitude = location.coordinate.longitude
//             newLocation.timestamp = Date()
//             newLocation.applicationState  = ApplicationState().toString()
//
//             cdsLocationWithTimestamp.saveContext()
            
             
         }
     }
    @objc private func reachabilityChanged( notification: NSNotification )
      {
          guard let reachability = notification.object as? Reachability else
          {
              return
          }

          if reachability.connection != .unavailable
          {
              if reachability.connection == .wifi || reachability.connection == .cellular
              {
                  print("Reachable via WiFi or celluar")
//                  let managedContext = self.cdsLocationWithTimestamp.managedContext
//
//                  // Fetch all persons
//                  let fetchRequest = NSFetchRequest<LocationUpdateFailur>(entityName: "LocationUpdateFailur")
//
//                  do {
//                      let results = try managedContext.fetch(fetchRequest)
//                      if results.count > 0 {
//                          var resultsDict = [[String: Any]]()
//                          for result in results {
//
//                              resultsDict.append(result.toDict())
//                          }
//
//
//                          self.callAPIForPlaceStorForOffline(parameters: resultsDict)
//                      }
//
//
//                  } catch let error as NSError {
//                      print("Fetch error: \(error), \(error.userInfo)")
//                  }
                  
                  if let results = UserDefaults.standard.retrieve(object: [LocationUpdateFailurUserDefault].self, fromKey: "LocationUpdateFailurUserDefault"){
                      
                     
                          self.callAPIForPlaceStorForOffline(parameters: results  as! [[String: Any]])
                     
                          
                          
                      
                      }
                  }
                 
                  
                  
                  
                  print("Network not reachable")
                  
              }
              
          
         
      }
  //// WEB API public funcTIONs
    public func callAPIForPlaceStore(geoHash : String){
        
        let dict = ["positions" :[["customer_id" : UserDefaults.standard.string(forKey: "user_id")!,"geo_hash":geoHash, "tstmp" : Helper.getCurrentTimeStampWOMiliseconds(dateToConvert: Date()) ] as [String : Any]]] as [String : Any]
        
        AlamoFireCommon.PostURL(url: "position", dict: dict) { responceData, success, error in
            if success
            {
                var status = 0
                if let code = responceData["status"] as? Int
                {
                    status = code
                }
                if status == 200
                {
                    
                }
            } else {
                
                let aLocationUpdateFailur = LocationUpdateFailurUserDefault(((dict["positions"] as! [[String: Any]])[0]["customer_id"] as? String)!,((dict["positions"] as! [[String: Any]])[0]["geo_hash"] as? String)!, Int16(truncatingIfNeeded: (dict["positions"] as! [[String: Any]])[0]["tstmp"] as! Int) )
                
                
//                aLocationUpdateFailur.customer_id = (dict["positions"] as! [[String: Any]])[0]["customer_id"] as? String
//                aLocationUpdateFailur.geo_hash = (dict["positions"] as! [[String: Any]])[0]["geo_hash"] as? String
//                aLocationUpdateFailur.tstmp = Int16(truncatingIfNeeded: (dict["positions"] as! [[String: Any]])[0]["tstmp"] as! Int)

                //To save the object
                
                var aResult = UserDefaults.standard.retrieve(object: [LocationUpdateFailurUserDefault].self, fromKey: "LocationUpdateFailurUserDefault")
                aResult?.append(aLocationUpdateFailur)
                
                UserDefaults.standard.save(customObject: aResult, inKey: "LocationUpdateFailurUserDefault")

//                let managedContext =  self.cdsLocationWithTimestamp.managedContext
//
//                let newLocation = LocationUpdateFailur(context: managedContext)
//                newLocation.customer_id = (dict["positions"] as! [[String: Any]])[0]["customer_id"] as? String
//                newLocation.geo_hash = (dict["positions"] as! [[String: Any]])[0]["geo_hash"] as? String
//                newLocation.tstmp = Int16(truncatingIfNeeded: (dict["positions"] as! [[String: Any]])[0]["tstmp"] as! Int)
//                self.cdsLocationWithTimestamp.saveContext()
                
                
            }
        }
    }
    public func callAPIForPlaceStorForOffline(parameters : [[String: Any]]){
        
        let dict = ["positions" : parameters] as [String : Any]
        
        AlamoFireCommon.PostURL(url: "position", dict: dict) { responceData, success, error in
            if success
            {
                var status = 0
                if let code = responceData["StatusCode"] as? Int
                {
                    status = code
                }
                if status == 201
                {
//                    let managedContext = self.cdsLocationWithTimestamp.managedContext
//
//                    // Fetch all persons
//                    let fetchRequest = NSFetchRequest<LocationUpdateFailur>(entityName: "LocationUpdateFailur")
//                    fetchRequest.includesPropertyValues = true
//
//                    do {
//                        let results = try managedContext.fetch(fetchRequest)
//                        for result in results {
//                            managedContext.delete(result)
//                        }
//                        self.cdsLocationWithTimestamp.saveContext()
//
//
//                    } catch let error as NSError {
//                        print("Fetch error: \(error), \(error.userInfo)")
//                    }
                    
                    
                    UserDefaults.standard.removeObject(forKey: "LocationUpdateFailurUserDefault")
                }
            }
        }
    }
    public func callAPIForGETclient(_ clientID : String){
        AlamoFireCommon.GetURL(url: "client/\(clientID)", dict: [:]) { responceData, success, error in
            if success
            {
                if let data = (responceData["Data"] as? [String: Any]) {
                    if let Token = (data["token"] as? String) {
                        
                        UserDefaults.standard.set(Token, forKey: "token")
                        self.callAPIForCreateCustomerID(clientID)
                    }
                }
                
                else {
                    self.generatedUser!(false)
                    
                }
                
               
                
            }
        }
       

    }
    public func callAPIForCreateCustomerID(_ clientID : String){
        let dict = ["client_Id" : clientID] as [String : Any]
        AlamoFireCommon.PostURL(url: "customer", dict: dict) { responceData, success, error in
            if success
            {
                if let data = (responceData["Data"] as? [String: Any]) {
                    if let clientID = (data["Id"] as? String) {
                        self.callAPIForGetCustomer(clientID)
                    }
                    
                }
            }
            else {
                self.generatedUser!(false)
                
            }
        }
       

    }
    public func callAPIForGetCustomer(_ CustomerID : String){
        
        AlamoFireCommon.GetURL(url: "customer/\(CustomerID)", dict: [:]) { responceData, success, error in
            if success
            {
                if let data = (responceData["Data"] as? [String: Any]) {
                    if let customerID = (data["id"] as? String) {
                        UserDefaults.standard.set(customerID, forKey: "user_id")
                       
                            self.generatedUser!(true)
                            
                       
                    }
                }
                
            }
            else {
                self.generatedUser!(false)
                
            }
        }
       

    }
}

