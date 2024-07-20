//
//  AppActivityIndicator.swift
//  lgcy
//
//  Created by Adnan Majeed on 20/02/2024.
//

import Foundation
import SwiftUI
struct AppActivityIndicator: View {
    @Binding var showActivityIndicator: Bool
    @State var offset: CGFloat = 15
    @State var scale: CGFloat = 1.0
    @State var rotation: Double = 0.0

    var body: some View {
        if showActivityIndicator {
            ZStack {

                Color.black.opacity(0.2).edgesIgnoringSafeArea(.all)

                VStack{
                    ZStack {
                        ForEach(0..<8) { i in

                            Color.gray.frame(width: 5, height: 10)
                                .offset(y: offset).scaleEffect(scale)
                                .rotationEffect(.degrees(360 / 8) * Double(i) + .degrees(rotation))
                        }
                    }.frame(width: 32, height: 32)

                }.background(Color.white).cornerRadius(50)

            }.onAppear {
                offset += 0.4
                scale = 0.5
                withAnimation(Animation.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
        }
    }
}

struct AppActivityIndicator_Previews: PreviewProvider {
    static var previews: some View {
        AppActivityIndicator(showActivityIndicator: .constant(true))
    }
}
