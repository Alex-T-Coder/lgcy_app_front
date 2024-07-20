//
//  Enum.swift
//  galleryDemo
//
//  Created by Ravi Jadav on 02/02/24.
//

import Foundation

enum EnumForShareList {
    
    case tagPeople
    case tagProduct
    case addlocation
    case addMusic
    case addfund
    case facebook
    case advanceSetting
    
    var name: String {
        switch self {
        case .tagPeople: return "Tag People"
        case .tagProduct: return "Tag Products"
        case .addlocation: return "Add Location"
        case .addMusic: return "Add Music"
        case .addfund: return "Add Fundraiser"
        case .facebook: return "Facebook"
        case .advanceSetting: return "Advanced Settings"
        }
    }
}

enum EnumForStyle {
    
    case normal
    case clarendon
    case gingham
    case moon
    case lark
    case reyes
    
    var styleName: String {
        switch self {
        case .normal: return "Normal"
        case .clarendon: return "Clarendon"
        case .gingham: return "Gingham"
        case .moon: return "Moon"
        case .lark: return "Lark"
        case .reyes: return "Reyes"
        }
    }
    
    var hexaColor: String {
        switch self {
        case .normal: return ""
        case .clarendon: return "#f1fcea"
        case .gingham: return "#F6807E"
        case .moon: return "#F6F1D5"
        case .lark: return "#b89b72"
        case .reyes: return "#DEC716"
        }
    }
}
