//
//  AlertPopUp.swift
//  lgcy
//
//  Created by Adnan Majeed on 20/02/2024.
//

import Foundation
import SwiftUI

struct AlertPopUp: View {

    @State var attentionPopUp = 0.0
    var title = ""
    var message = ""

    var body: some View {
        ZStack{

            VStack {

                VStack(spacing: 14) {
                        ///close popup button
                    HStack{

                        Text(title).foregroundColor(.black)
                            .font(Font.robotoBold(size: 16))

                        Spacer()

                        Image(systemName: "x.circle").foregroundColor(.black).font(Font.robotoBold(size: 16))
                            .onTapGesture {

                                withAnimation {
                                    attentionPopUp = -1000
                                }

                            }
                    }

                    Text(message).foregroundColor(.white).font(Font.robotoRegular(size: 14))

                }.padding(.horizontal, 22).padding(.bottom, 20).padding(.top, 60).background(Color.gray)
                    .clipShape(RoundedCorner(radius: 20, corners: [.bottomLeft, .bottomRight]))

                Spacer()

            }.background(Color.white.opacity(0.01))


        }.offset(y: attentionPopUp) .onTapGesture {
            withAnimation(.easeOut(duration: 0.8)) {
                attentionPopUp = -1000
            }
        }
    }
}

struct AlertPopUp_Previews: PreviewProvider {
    static var previews: some View {
        AlertPopUp()
    }
}

