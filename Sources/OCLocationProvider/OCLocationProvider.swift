//
//  OCLocationProvider.swift
//  OCLocationProvider
//
//  Created by Naoya on 2021/11/14.
//

import CoreLocation
import Combine

public final class OCLocationProvider: NSObject {
    private let locationManager: CLLocationManager
    
    public let authorizationPublisher: PassthroughSubject<CLAuthorizationStatus, Never> = .init()
    public let locationPublisher: PassthroughSubject<CLLocationCoordinate2D, Never> = .init()
    
    public init(locationManager: CLLocationManager = .default) {
        self.locationManager = locationManager
        
        super.init()
        
        self.locationManager.delegate = self
    }
    
    public func getAuthorizationStatus() -> CLAuthorizationStatus {
        return locationManager.authorizationStatus
    }
    
    public func requestWhenInUseAuthorization() {
        guard locationManager.authorizationStatus == .notDetermined else {
            return
        }

        locationManager.requestWhenInUseAuthorization()
    }

    public func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    public func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}

extension OCLocationProvider: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let data = locations.last else { return }
        locationPublisher.send(data.coordinate)
    }

    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationPublisher.send(manager.authorizationStatus)
    }
}
