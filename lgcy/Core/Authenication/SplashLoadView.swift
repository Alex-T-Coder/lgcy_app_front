//
//  SplashLoadView.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI

struct SplashLoadView: View {


    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            Image("lgcyblack")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
        }
    }
}

struct SplashLoadView_Previews: PreviewProvider {
    static var previews: some View {
        SplashLoadView()
    }
}
