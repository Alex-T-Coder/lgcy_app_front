//
//  PlaceViewModel.swift
//  lgcy
//
//  Created by mac on 1/22/24.
//

import Foundation
import MapKit

class PlaceViewModel: BaseViewModel {
    @Published var places: [Place] = []
    
    func search(text: String , region: MKCoordinateRegion) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = text
        searchRequest.resultTypes = [.address,.pointOfInterest]
//        searchRequest.region = region
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown Error")")
                return
            }
            
            self.places = response.mapItems.map(Place.init)
            print("Places Count: \(self.places.count)")
            print("Places Count: \(response.mapItems)")
        }
    }
    
    func resetPlaces() {
        self.places = []
    }
}



