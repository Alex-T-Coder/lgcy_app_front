//
//  SmallBlackToggleStyle.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI

struct SmallBlackToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
                .font(.headline)
                .fontWeight(.regular)
                .foregroundColor(.black)
                .padding(.leading, 8)

            Spacer()

            Toggle("", isOn: configuration.$isOn)
                .labelsHidden()
                .frame(width: 20, height: 10)
                .scaleEffect(0.8)
                .toggleStyle(SwitchToggleStyle(tint: configuration.isOn ? .black : .gray))
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 4)
    }
}

