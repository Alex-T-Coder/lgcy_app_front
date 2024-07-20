//
//  OldProfileView.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI

struct OldProfileView: View {
    
    private let gridItems: [GridItem] = [
        .init(.flexible(), spacing: 1),
        .init(.flexible(), spacing: 1),
        .init(.flexible(), spacing: 1)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView{
                //header
                VStack(spacing: 10){
                    // pic and stats
                    HStack{
                        Image("Cordus")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                        
                        Spacer()
                        
                        HStack(spacing: 8){
                            UserStatView(value: 3, title: "Posts")
                            
                            UserStatView(value: 12, title: "Followers")
                            
                            UserStatView(value: 34, title: "Following")
                            
                            
                        }
                    }
                    .padding(.horizontal)
                    
                    // name and bio
                    VStack(alignment: .leading, spacing: 4){
                        Text("Cordus Offcial")
                            .font(.footnote)
                            .fontWeight(.semibold)
                        
                        Text("Welcome to my story")
                            .font(.footnote)
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // action button
                    
                    NavigationLink {
                        EditProfileView()
                            .navigationBarBackButtonHidden()
                    } label: {
                        Text("Edit Profile")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(width: 360, height: 32)
                            .foregroundColor(.black)
                            .overlay(RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.gray, lineWidth: 1))
                    }
                    
                    Divider()
                }
                
                //post grid view
                
                LazyVGrid(columns: gridItems, spacing: 1){
                    ForEach(0 ... 30, id: \.self) { index in
                        Image("Cordus")
                            .resizable()
                            .scaledToFill()
                    }
                }
            }
            .navigationTitle("cordus.official")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SettingsView()
                            .navigationBarBackButtonHidden()
                        
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(.black)
                    }
                    
                }
            }
        }
    }
}
    
struct OldProfileView_Previews: PreviewProvider {
    static var previews: some View {
            OldProfileView()
    }
}
