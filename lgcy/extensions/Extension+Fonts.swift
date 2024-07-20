//
//  Extension+Fonts.swift
//  lgcy
//
//  Created by Suleman Ali on 20/02/2024.
//

import Foundation
import SwiftUI

extension Font {

        // MARK: AppFonts
    static func robotoBlack(size: CGFloat) -> Font {
        return Font.system(size: size,weight: .black)
    }

    static func robotoBold(size: CGFloat) -> Font {
        return Font.system(size: size,weight: .bold)
    }

    static func robotoMedium(size: CGFloat) -> Font {
        return Font.system(size: size,weight: .medium)
    }

    static func robotoRegular(size: CGFloat) -> Font {
        return Font.system(size: size,weight: .regular)
    }

}
