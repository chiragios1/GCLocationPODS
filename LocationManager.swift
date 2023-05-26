//
//  LocationManager.swift
//  LocationTracking
//
//  Created by admin on 24/03/23.
//



import UIKit
import CoreLocation
import BackgroundTasks
import os
import CocoaLumberjack
final class LocationManager: NSObject {
    
    enum LocationErrors: String {
        case denied = "Locations are turned off. Please turn it on in Settings"
        case restricted = "Locations are restricted"
        case notDetermined = "Locations are not determined yet"
        case notFetched = "Unable to fetch location"
        case invalidLocation = "Invalid Location"
        case reverseGeocodingFailed = "Reverse Geocoding Failed"
        case unknown = "Some Unknown Error occurred"
    }
    
    typealias LocationClosure = ((_ location:CLLocation?,_ error: NSError?)->Void)
    private var locationCompletionHandler: LocationClosure?
    
    typealias ReverseGeoLocationClosure = ((_ location:CLLocation?, _ placemark:CLPlacemark?,_ error: NSError?)->Void)
    private var geoLocationCompletionHandler: ReverseGeoLocationClosure?
    
    private var locationManager:CLLocationManager?
    
    var locationAccuracy = kCLLocationAccuracyBest
    
    private var lastLocation:CLLocation?
    private var reverseGeocoding = false
   // let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Place API")
    //Singleton Instance
    static let shared: LocationManager = {
        let instance = LocationManager()
        // setup code
        return instance
    }()
    
    private override init() {}

    //MARK:- Destroy the LocationManager
    deinit {
        destroyLocationManager()
    }
    
    //MARK:- Private Methods
    private func setupLocationManager() {
        if locationManager != nil {
            if #available(iOS 14.0, *) {
                self.check(status: locationManager?.authorizationStatus)
            } else {
                self.check(status: CLLocationManager.authorizationStatus())
                // Fallback on earlier versions
            }
            return
        }
        //Setting of location manager
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = locationAccuracy
        locationManager?.allowsBackgroundLocationUpdates = true
        self.locationManager?.requestAlwaysAuthorization()
        

       // self.locationManager?.requestWhenInUseAuthorization()
        if #available(iOS 14.0, *) {
            self.check(status: locationManager?.authorizationStatus)
        } else {
            self.check(status: CLLocationManager.authorizationStatus())
        }
    }
    
     func destroyLocationManager() {
        locationManager?.delegate = nil
        locationManager = nil
        lastLocation = nil
    }
    
   
    
    @objc private func sendLocation() {
        guard let _ = lastLocation else {
            self.didStop(location: nil,error: NSError(
                domain: self.classForCoder.description(),
                code:Int(CLAuthorizationStatus.denied.rawValue),
                userInfo:
                [NSLocalizedDescriptionKey:LocationErrors.notFetched.rawValue,
                 NSLocalizedFailureReasonErrorKey:LocationErrors.notFetched.rawValue,
                 NSLocalizedRecoverySuggestionErrorKey:LocationErrors.notFetched.rawValue]))
            
            lastLocation = nil
            return
        }
        self.didComplete(location: lastLocation,error: nil)
        lastLocation = nil
    }
    
//MARK:- Public Methods
    
    /// Check if location is enabled on device or not
    ///
    /// - Parameter completionHandler: nil
    /// - Returns: Bool
    func isLocationEnabled() async ->  Bool {
        return CLLocationManager.locationServicesEnabled()
    }
     func isLocationPermissionGranted() -> Bool {
        guard CLLocationManager.locationServicesEnabled() else { return false }
        if #available(iOS 14.0, *) {
           
            return [.authorizedAlways, .authorizedWhenInUse].contains(locationManager?.authorizationStatus)
        } else {
            return [.authorizedAlways, .authorizedWhenInUse].contains(CLLocationManager.authorizationStatus())
            // Fallback on earlier versions
        }
    }
    /// Get current location
    ///
    /// - Parameter completionHandler: will return CLLocation object which is the current location of the user and NSError in case of error
    func getLocation(completionHandler:@escaping LocationClosure) {
        
        //Resetting last location
        lastLocation = nil
        
        self.locationCompletionHandler = completionHandler
        
        setupLocationManager()
    }
    
    
   

   
   
       
    //MARK:- Final closure/callback
     func didComplete(location: CLLocation?,error: NSError?) {
        
        locationCompletionHandler?(location,error)
       
    }
     func didStop(location: CLLocation?,error: NSError?) {
        locationManager?.stopUpdatingLocation()
        locationCompletionHandler?(location,error)
        locationManager?.delegate = nil
        locationManager = nil
    }
    private func didCompleteGeocoding(location:CLLocation?,placemark: CLPlacemark?,error: NSError?) {
        locationManager?.stopUpdatingLocation()
        geoLocationCompletionHandler?(location,placemark,error)
        locationManager?.delegate = nil
        locationManager = nil
        reverseGeocoding = false
    }
    
    private func check(status: CLAuthorizationStatus?) {
        guard let status = status else { return }
        switch status {
            
        case .authorizedWhenInUse,.authorizedAlways:
            self.locationManager?.startUpdatingLocation()
            self.locationManager?.startMonitoringSignificantLocationChanges()
            
        case .denied:
            let deniedError = NSError(
                domain: self.classForCoder.description(),
                code:Int(CLAuthorizationStatus.denied.rawValue),
                userInfo:
                [NSLocalizedDescriptionKey:LocationErrors.denied.rawValue,
                 NSLocalizedFailureReasonErrorKey:LocationErrors.denied.rawValue,
                 NSLocalizedRecoverySuggestionErrorKey:LocationErrors.denied.rawValue])
            didStop(location: nil,error: deniedError)
            
            
        case .restricted:
            didStop(location: nil,error: NSError(
                domain: self.classForCoder.description(),
                code:Int(CLAuthorizationStatus.restricted.rawValue),
                userInfo: nil))
            
            
        case .notDetermined:
            self.locationManager?.requestAlwaysAuthorization()
          //  self.locationManager?.requestWhenInUseAuthorization()
            
            
        @unknown default:
            didStop(location: nil,error: NSError(
                domain: self.classForCoder.description(),
                code:Int(CLAuthorizationStatus.denied.rawValue),
                userInfo:
                [NSLocalizedDescriptionKey:LocationErrors.unknown.rawValue,
                 NSLocalizedFailureReasonErrorKey:LocationErrors.unknown.rawValue,
                 NSLocalizedRecoverySuggestionErrorKey:LocationErrors.unknown.rawValue]))
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    //MARK:- CLLocationManager Delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
           lastLocation = locations.last
           if let location = locations.last {

               if location.horizontalAccuracy < 0 {
                   self.locationManager?.stopUpdatingLocation()
                   self.locationManager?.startUpdatingLocation()
                   return
               }
               self.sendLocation()
               self.locationManager?.stopUpdatingLocation()
           }
        
       }
       
       func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
           self.check(status: status)
       }
       
       func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
           print(error.localizedDescription)
           self.didStop(location: nil, error: error as NSError?)
       }
      
       
}
