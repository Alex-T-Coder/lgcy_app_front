//
//  TimelineModelContoller.swift
//  lgcy
//
//  Created by Vlad on 6.02.24.
//
import SwiftUI
import Foundation

class TimelineModelController: ObservableObject {
    @Published var images: [String : Image]
    @Published var selectedTimelineIndex: Int = 0
    
    init() {
        self.images = [:]
    }
}
