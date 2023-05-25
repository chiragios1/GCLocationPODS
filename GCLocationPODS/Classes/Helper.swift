//
//  Helper.swift
//  LocationTracking
//
//  Created by admin on 02/05/23.
//

import UIKit

class Helper {
   static func getCurrentTimeStampWOMiliseconds(dateToConvert: Date) -> Int {
        let objDateformat: DateFormatter = DateFormatter()
        objDateformat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let strTime: String = objDateformat.string(from: dateToConvert as Date)
        let objUTCDate: NSDate = objDateformat.date(from: strTime)! as NSDate
        let milliseconds: Int64 = Int64(objUTCDate.timeIntervalSince1970)
        //let strTimeStamp: String = "\(milliseconds)"
        return Int(milliseconds)
    }
   
   
}
extension UserDefaults {

   func save<T:Encodable>(customObject object: T, inKey key: String) {
       let encoder = JSONEncoder()
       if let encoded = try? encoder.encode(object) {
           self.set(encoded, forKey: key)
       }
   }

   func retrieve<T:Decodable>(object type:T.Type, fromKey key: String) -> T? {
       if let data = self.data(forKey: key) {
           let decoder = JSONDecoder()
           if let object = try? decoder.decode(type, from: data) {
               return object
           }else {
               print("Couldnt decode object")
               return nil
           }
       }else {
           print("Couldnt find key")
           return nil
       }
   }

}
class LocationwithtimestampUserDefault: Codable {
    public var applicationState: String?
    public var latitude: Double
    public var longitude: Double
    public var timestamp: Date?
    enum CodingKeys: String, CodingKey {
        case applicationState
        case latitude
        case longitude
        case timestamp
    }

    public init(applicationState: String, longitude: Double, latitude: Double, timestamp: Date) {
        self.applicationState = applicationState
        self.longitude = longitude
        self.latitude = latitude
        self.timestamp = timestamp
        
    }
  //Your stuffs
}
class LocationUpdateFailurUserDefault: Codable {
    public var customer_id: String?
     public var geo_hash: String?
    public var tstmp: Int16
    
    enum CodingKeys: String, CodingKey {
        case customer_id
        case geo_hash
        case tstmp
        
    }

    public init(_ customer_id: String, _ geo_hash: String, _ tstmp: Int16) {
        self.customer_id = customer_id
        self.geo_hash = geo_hash
        self.tstmp = tstmp
       
        
    }
  //Your stuffs
}

