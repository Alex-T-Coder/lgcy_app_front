//
//  Image+Extension.swift
//  lgcy
//
//  Created by Himanshu Joshi on 20/06/24.
//

import UIKit

extension UIImage {
    func resize(toWidth width: CGFloat) -> UIImage {
        let scale = width / self.size.width
        let height = self.size.height * scale
        let newSize = CGSize(width: width, height: height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? self
    }
}
