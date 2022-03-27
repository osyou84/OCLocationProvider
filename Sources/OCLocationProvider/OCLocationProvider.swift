//
//  OCLocationProvider.swift
//  OCLocationProvider
//
//  Created by Naoya on 2021/11/14.
//

import CoreLocation
import Combine

public final class OCLocationProvider: NSObject {
    public let authorizationPublisher: PassthroughSubject<CLAuthorizationStatus, Never> = .init()
    public let locationPublisher: PassthroughSubject<CLLocationCoordinate2D, Never> = .init()
    
    private let locationManager: CLLocationManager
    private var currentLocation: CLLocationCoordinate2D?
    
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
    
    public func getCurrentLocation() -> CLLocationCoordinate2D? {
        return locationManager.location?.coordinate
    }
    
    public func getDistance(targetLatitude: Double, targetLongitude: Double) -> Double {
        guard let currentLocation = currentLocation else { return .zero }
        
        let currentLa   = currentLocation.latitude * Double.pi / 180
        let currentLo   = currentLocation.longitude * Double.pi / 180
        let targetLa    = targetLatitude * Double.pi / 180
        let targetLo    = targetLongitude * Double.pi / 180

        let radLatDiff = currentLa - targetLa
        let radLonDiff = currentLo - targetLo
        let radLatAve = (currentLa + targetLa) / 2.0

        let a = 6377397.155
        let b = 6356078.963

        let e2 = (a * a - b * b) / (a * a)
        let a1e2 = a * (1 - e2)

        let sinLat = sin(radLatAve)
        let w2 = 1.0 - e2 * (sinLat * sinLat)

        let m = a1e2 / (sqrt(w2) * w2)
        let n = a / sqrt(w2)

        let t1 = m * radLatDiff
        let t2 = n * cos(radLatAve) * radLonDiff
        let distance = sqrt((t1 * t1) + (t2 * t2))

        return distance / 1000
    }
}

extension OCLocationProvider: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let data = locations.last else { return }
        
        currentLocation = data.coordinate
        locationPublisher.send(data.coordinate)
    }

    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationPublisher.send(manager.authorizationStatus)
    }
}
