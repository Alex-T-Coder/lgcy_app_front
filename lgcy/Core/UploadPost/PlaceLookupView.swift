//
//  PlaceLookupView.swift
//  lgcy
//
//  Created by mac on 1/22/24.
//
        
import SwiftUI
import MapKit

struct PlaceLookupView: View {
    @EnvironmentObject var locationManager: LocationManager
    @StateObject var placeVM = PlaceViewModel()
    @Binding var returnedPlace: Place
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            List(placeVM.places) { place in
                HStack {
                    VStack(alignment: .leading) {
                        Text(place.name)
                            .font(.system(size: 15))
                        Text(place.address)
                            .font(.system(size: 12))
                    }
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    returnedPlace = place
                    dismiss()
                }
            }
            .listStyle(.plain)
            .searchable(text: $searchText)
            .onChange(of: searchText) { text in
                if text.isEmpty {
                    placeVM.resetPlaces()
                } else {
                    placeVM.search(text: text, region: locationManager.region)
                }
            }
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.black) // Set the text color to black

            )
            .navigationTitle("Select Location") // Clear the default title
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct PlaceLookupView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceLookupView(returnedPlace: .constant(Place(mapItem: MKMapItem())))
            .environmentObject(LocationManager())
    }
}
