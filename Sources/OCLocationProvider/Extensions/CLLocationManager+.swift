//
//  CLLocationManager.swift
//  
//
//  Created by Naoya on 2022/03/27.
//

import CoreLocation

extension CLLocationManager {
    public static var `default`: CLLocationManager {
        let manager = CLLocationManager()
        #if !os(watchOS)
        manager.pausesLocationUpdatesAutomatically = true
        #endif
        manager.allowsBackgroundLocationUpdates = true
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 10
         
        return manager
    }
}
