//
//  Place.swift
//  lgcy
//
//  Created by mac on 1/22/24.
//

import Foundation
import MapKit

struct Place: Identifiable, Equatable {
    let id = UUID().uuidString
    private var mapItem: MKMapItem
    
    init(mapItem: MKMapItem) {
        self.mapItem = mapItem
    }
    
    var name: String {
        self.mapItem.name ?? ""
    }
    
    var address: String {
        let placemark = self.mapItem.placemark
        let city = placemark.locality ?? ""
        let country = placemark.country ?? ""
        let landmark = placemark.name ?? ""

        if !landmark.isEmpty && landmark != city {
            return "\(landmark), \(country)"
        }

        if !city.isEmpty {
            return "\(city), \(country)"
        }

        return country
    }

    // Implement the Equatable conformance
    static func == (lhs: Place, rhs: Place) -> Bool {
        return lhs.id == rhs.id
    }
}
