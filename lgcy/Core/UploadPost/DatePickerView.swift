//
//  DatePickerView.swift
//  lgcy
//
//  Created by mac on 1/22/24.
//

import SwiftUI

struct DatePickerView: View {
    @State private var selectedDate = Date()
    @State private var isDatePickerPresented = false
    @State private var tapCount = 0

    var body: some View {
        NavigationView {
                VStack {
                                        
                    HStack {
                        Text(selectedDate, style: .date)
                            .font(.headline)
                            .fontWeight(.regular)
                            .foregroundColor(.black)
                            .padding(.leading)

                        Spacer()

                        Button {
                            isDatePickerPresented.toggle()
                        } label: {
                            Image(systemName: "calendar")
                                .resizable()
                                .frame(width: 23, height: 23)
                                .foregroundColor(.black)
                                .padding(.horizontal, 10)
                        }
                        .popover(isPresented: $isDatePickerPresented) {
                            VStack {
                                DatePicker(
                                    "",
                                    selection: $selectedDate,
                                    in: ...Date(),
                                    displayedComponents: [.date]
                                )
                                .datePickerStyle(.graphical)
                                .onTapGesture(count: 2) {
                                    // Handle double tap
                                    isDatePickerPresented.toggle()
                                }

                                Button("Done") {
                                    isDatePickerPresented.toggle()
                                }
                                .padding()
                                .foregroundColor(.black)
                            }
                            .accentColor(.black)
                            .padding()
                        }
                    }
                }
            }

            
        }
    }


struct DatePickerView_Previews: PreviewProvider {
    static var previews: some View {
        DatePickerView()
    }
}

