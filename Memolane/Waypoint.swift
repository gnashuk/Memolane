//
//  Waypoint.swift
//  Prototype
//
//  Created by Oleg Gnashuk on 1/26/16.
//  Copyright © 2016 Oleg Gnashuk. All rights reserved.
//

import MapKit

class Waypoint: NSObject, MKAnnotation {
    var latitude: Double!
    var longitude: Double!
    var title: String!
    var subtitle: String!
    var imageURL: String!
    
//    init(latitude: Double, longitude: Double, title: String, subtitle: String) {
//        self.latitude = latitude
//        self.longitude = longitude
//        self.title = title
//        self.subtitle = subtitle
//    }
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
    }
}
