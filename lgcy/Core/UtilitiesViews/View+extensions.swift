//
//  View+extensions.swift
//  lgcy
//
//  Created by Adnan Majeed on 20/02/2024.
//

import Foundation
import SwiftUI

    //MARK: - View Extension
extension View {

    /**Hiding Keyboard from View*/
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }

    /**Apply Corer Radius at any specfic corner*/
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }

    func showToast(toastText: String, isShowing: Binding<Bool>) -> some View {
        self.modifier(ToastModifier(toastText: toastText, showToast: isShowing))
    }

    func showCopyToast(toastText: String, isShowing: Binding<Bool>) -> some View {
        self.modifier(CopyToastModifier(toastText: toastText, showToast: isShowing))
    }

}

    // make any modifier as conditional. it will pass the transform of the same view
    // based on the flag (bool input)
extension View {
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition { transform(self) } else { self }
    }
}
