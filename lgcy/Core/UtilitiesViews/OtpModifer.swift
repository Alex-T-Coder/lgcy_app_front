//
//  OtpModifer.swift
//  lgcy
//
//  Created by Adnan Majeed on 26/02/2024.
//

import Foundation
import Combine
import SwiftUI

struct OtpModifer: ViewModifier {

    @Binding var pin : String

    var textLimt = 1

    func limitText(_ upper : Int) {
        if pin.count > upper {
            self.pin = String(pin.prefix(upper))
        }
    }


        //MARK -> BODY
    func body(content: Content) -> some View {
        content
            .multilineTextAlignment(.center)
            .keyboardType(.numberPad)
            .onReceive(Just(pin)) {_ in limitText(textLimt)}
            .frame(width: 45, height: 45)
            .background(Color.white.cornerRadius(5))
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.black, lineWidth: 3)
            )
    }
}
