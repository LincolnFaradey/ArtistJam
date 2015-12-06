//
//  ANImageFilterOperation.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 7/9/15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

import UIKit
import QuartzCore

class ImageFilterOperation: Operation {
    var outImage: UIImage?
    var image: UIImage?
    
    
    override func main() {
        print("Filtering started")
        guard let _ = image else {
            self.cancel()
            return
        }
        if cancelled {
            return
        }
        self.outImage = monochromeImage()
        print("Filtering finished")
        finish()
    }
    
    func monochromeImage() -> UIImage {
        let img = CIImage(CGImage: self.image!.thumbnailWithSize(CGSizeMake(150, 150)).CGImage!)

        let filter = CIFilter(name: "CIPhotoEffectTonal")!
        
        filter.setValue(img, forKey: kCIInputImageKey)
        
        return imageWith(filter.outputImage!)
    }

    typealias myCIImage = CIImage
    func imageWith(CIImage: myCIImage) -> UIImage {
        let rect = CIImage.extent
        
        let context = CIContext(options: nil)
        
        let imageRef = context.createCGImage(CIImage, fromRect: rect)

        let image = UIImage(CGImage: imageRef)
        
        return image
    }
    
}
