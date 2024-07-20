//
//  TabItem.swift
//  lgcy
//
//  Created by Adnan Majeed on 01/03/2024.
//

import Foundation
import SwiftUI
struct TabItem: View {
    let imageName: String?
    let text: String?
    let index: Int
    @Binding var selectedTab: Int
    let namespace: Namespace.ID
    var body: some View {
        Button(action: {
            selectedTab = index
        }) {

            VStack {
                if let imageName = imageName {
                    Image(systemName: imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .fontWeight(selectedTab == index ? .bold : .regular)
                        .frame(width: 15, height: 15)
                        .foregroundColor(.black)
                        .padding(.vertical, 5)

                }
                else if let text = text {
                    Text(text)
                        .font(.subheadline)
                        .fontWeight(selectedTab == index ? .bold : .regular)
                        .foregroundColor(.black)
                        .padding(.vertical, 5)
                }

                if selectedTab == index {
                    Color.black
                        .frame(height: 1)
                        .matchedGeometryEffect(id: "underline",
                                               in: namespace,
                                               properties: .frame)
                } else {
                    Color.clear.frame(height: 1)
                }
            }
            .animation(.spring(), value: self.selectedTab)

        }
    }
}
