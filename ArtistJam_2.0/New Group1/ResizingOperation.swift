//
//  ResizingOperation.swift
//  ArtistJam
//
//  Created by Andrey on 02.09.15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

import ImageIO

extension UIImage {
    //  21 mb - 2 cells
    func thumbnail() -> UIImage {
        let size = self.size.applying(CGAffineTransform(scaleX: 0.25, y: 0.25))
        
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return scaledImage!
    }
    
    //  25mb - 2 cells
    func thumbnailWithSize(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
        self.draw(in: CGRect.init(x: 0, y: 0, width: size.width, height: size.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
}
