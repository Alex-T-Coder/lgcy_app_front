//
//  MediaPickerView.swift
//  lgcy
//
//  Created by mac on 1/22/24.
//

import SwiftUI
import Photos

struct MediaPickerView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isSquareOnSquareSelected = false
    @State private var selectedMediaIndices: [Int] = []

    // Sample media items (replace with your logic to fetch actual media)
    let mediaItems: [String] = ["photo1", "photo2", "photo3", "photo4", "photo5", "photo6", "photo7", "photo8", "photo9", "photo10", "photo11", "photo12", "photo13", "photo14", "photo15", "photo16", "photo17", "photo18", "photo19", "photo20"]

    var body: some View {
        VStack {
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.system(size: 20))
                    }
                    
                    Spacer()
                    
                    Text("New Post")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        // Handle Next button tap
                    }) {
                        Text("Next")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(Color.black)
            }
            
            // post image
            
            Image("Cordus")
                .resizable()
                .scaledToFill()
                .frame(height: 400)
                .clipShape(Rectangle())
                .padding(.top, -10)
                .padding(.bottom, -8)
            
            HStack {
                
                Text("Select")
                    .foregroundColor(.white)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .padding(.leading)
                
                Spacer()
                
                Button {
                    isSquareOnSquareSelected.toggle()
                } label: {
                    ZStack {
                        Circle()
                            .foregroundColor(isSquareOnSquareSelected ? .blue : .clear)
                            .frame(width: 33, height: 35)
                        
                        Image(systemName: "square.on.square")
                            .foregroundColor(.white)
                            .imageScale(isSquareOnSquareSelected ? .large : .large) // Adjust the image scale based on the selection
                            .padding(.trailing, 4)
                            .scaleEffect(isSquareOnSquareSelected ? 0.8 : 1.0) // Adjust the scale effect based on the selection
                    }
                }
                           Image(systemName: "camera")
                               .foregroundColor(.white)
                               .imageScale(.large)
                               .padding(.leading, 4)
                       }
                       .frame(height: 60) // Set the desired height
                       .background(Color.black) // Set the background color
                       .padding(.bottom, -20)


            ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(), count: 4), spacing: 1) {
                            ForEach(mediaItems, id: \.self) { mediaItem in
                                Image("Cordus")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: (UIScreen.main.bounds.width - 3) / 4, height: (UIScreen.main.bounds.width - 3) / 4)
                                    .clipped()
                                    .onTapGesture {
                                        if isSquareOnSquareSelected {
                                            if let index = mediaItems.firstIndex(of: mediaItem) {
                                                if selectedMediaIndices.count < 10 {
                                                    if let existingIndex = selectedMediaIndices.firstIndex(of: index) {
                                                        selectedMediaIndices.remove(at: existingIndex)
                                                    } else {
                                                        selectedMediaIndices.append(index)
                                                    }
                                                } else {
                                                    // If the maximum limit is reached, unselect the item if it's already selected
                                                    if selectedMediaIndices.contains(index) {
                                                        selectedMediaIndices.remove(at: selectedMediaIndices.firstIndex(of: index)!)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .overlay(
                                        ZStack {
                                            if isSquareOnSquareSelected,
                                               let index = mediaItems.firstIndex(of: mediaItem),
                                               let displayIndex = selectedMediaIndices.firstIndex(of: index) {
                                                Circle()
                                                    .foregroundColor(.blue)
                                                    .frame(width: 18, height: 18)
                                                    .overlay(
                                                        Text("\(displayIndex + 1)")
                                                            .foregroundColor(.white)
                                                            .font(.caption)
                                                    )
                                                    .offset(x: 30, y: -35)
                                            }
                                        }
                                    )
                            }
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                    }
                    .background(.black)
                }
        .onChange(of: isSquareOnSquareSelected) { newValue in
            // Immediate deselection when square on square is toggled off
            if !newValue {
                selectedMediaIndices.removeAll()
            }
        }
            }
        }

struct MediaPickerView_Previews: PreviewProvider {
    static var previews: some View {
                    MediaPickerView()
    }
}
