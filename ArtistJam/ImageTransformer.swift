//
//  ImageTransformer.swift
//  ArtistJam
//
//  Created by Andrey on 21.08.15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

import Foundation
import UIKit

class ImageTransformer : NSValueTransformer {
    
    override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return  true
    }
    
    override func reverseTransformedValue(value: AnyObject?) -> AnyObject? {
        if (value == nil) {
            return nil
        }
        
        return UIImage(data: value as! NSData)
    }
    
    override func transformedValue(value: AnyObject?) -> AnyObject? {
        guard let image = value as? UIImage else {
            return nil
        }
        
        return UIImagePNGRepresentation(image)
    }
    
}