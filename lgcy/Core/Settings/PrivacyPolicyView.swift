//
//  PrivacyPolicyView.swift
//  lgcy
//
//  Created by mac on 1/3/24.
//

import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .font(.system(size: 18))
                }
                .foregroundColor(.black)
                
                Spacer()
                
                Text("Privacy Policy & Terms")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    
                Spacer()
            }
            .padding()
            
            ScrollView {
                Text(readPrivacyPolicyContent())
                    .font(.custom("Times New Roman", size: 16))
                    .padding()
                    .padding(.vertical, -40)
            }
        }
        .navigationBarTitle("", displayMode: .inline)
    }

    // Function to read the content of the privacy policy file
    func readPrivacyPolicyContent() -> String {
        // Get the file path
        if let filePath = Bundle.main.path(forResource: "PrivacyPolicyText", ofType: "txt") {
            do {
                // Read the content of the file
                let content = try String(contentsOfFile: filePath)
                return content
            } catch {
                // Handle error if reading fails
                print("Error reading PrivacyPolicyText.txt: \(error)")
            }
        }
        return "Error: Privacy Policy not available."
    }
}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPolicyView()
    }
}
