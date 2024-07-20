//
//  lgcyTextFieldModifier.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI

struct lgcyTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.subheadline)
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal, 24)
        
    }
}
