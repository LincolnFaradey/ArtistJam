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
        let size = CGSizeApplyAffineTransform(self.size, CGAffineTransformMakeScale(0.25, 0.25))
        
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        self.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    //  25mb - 2 cells
    func thumbnailWithSize(size: CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
        self.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}