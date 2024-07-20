//
//  ToastView.swift
//  lgcy
//
//  Created by Suleman Ali on 20/02/2024.
//

import Foundation
import SwiftUI
struct ToastView: View {

    let toastText: String
    @Binding var showToast: Bool

    var body: some View {
        VStack {
            Text(toastText)
                .font(Font.robotoRegular(size: 14))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
        }.padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.red)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .inset(by: 0.5)
                    .stroke(Color.red, lineWidth: 1))
            .padding(.horizontal, 20)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.showToast = false
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.showToast = false
                }
            }
    }
}

struct ToastModifier: ViewModifier {
    let toastText: String
    @Binding var showToast: Bool

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content

            if showToast {
                ToastView(toastText: toastText, showToast: $showToast)
                    .transition(.move(edge: .top))
                    .animation(.easeInOut(duration: 0.3))
            }
        }
    }
}

struct ToastView_Previews: PreviewProvider {
    static var previews: some View {
        ToastView(toastText: "Please fill in all fields", showToast: .constant(true))
    }
}
struct CopyToastView: View {

    let toastText: String
    @Binding var showToast: Bool

    var body: some View {
        VStack {
            Text(toastText)
                .font(Font.robotoRegular(size: 14))
                .foregroundColor(.gray)
                .frame(alignment: .center)
        }.padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.blue)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .inset(by: 0.5)
                    .stroke(Color.gray, lineWidth: 1))
            .padding(.horizontal, 20)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.showToast = false
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.showToast = false
                }
            }
    }
}

struct CopyToastModifier: ViewModifier {
    let toastText: String
    @Binding var showToast: Bool

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content

            if showToast {
                CopyToastView(toastText: toastText, showToast: $showToast)
                    .transition(.move(edge: .top))
                    .animation(.easeInOut(duration: 0.3))
            }
        }
    }
}
