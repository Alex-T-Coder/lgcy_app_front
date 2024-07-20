//
//  CircularProfileImageView.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI
import NukeUI

struct CircularProfileImageView: View {
    @State var imagePath:String?
    var height:CGFloat = 40
    var width:CGFloat = 40
    var body: some View {
            LazyImage(url: URL(string: imagePath ?? "" )) { state in
                if let image = state.image {
                    image.resizable()
                } else if state.error != nil  {
                    Image("Cordus")
                        .resizable()
                } else {
                    ProgressView()
                }
            }
            .scaledToFill()
            .frame(width: width,height: height)
            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
    }
}

struct CircularProfileImageView_Previews: PreviewProvider {
    static var previews: some View {
        CircularProfileImageView()
    }
}
