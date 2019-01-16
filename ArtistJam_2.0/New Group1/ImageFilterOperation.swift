//
//  ANImageFilterOperation.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 7/9/15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

import UIKit
import QuartzCore

class ImageFilterOperation: OperationWrapper {
    var outImage: UIImage?
    var image: UIImage?
    
    
    override func main() {
        print("Filtering started")
        guard let _ = image else {
            self.cancel()
            return
        }
        if isCancelled {
            return
        }
        self.outImage = monochromeImage()
        print("Filtering finished")
        finish()
    }
    
    func monochromeImage() -> UIImage {
        let img = CIImage(cgImage: self.image!.thumbnailWithSize(size: CGSize.init(width: 150, height: 150)).cgImage!)

        let filter = CIFilter(name: "CIPhotoEffectTonal")!
        
        filter.setValue(img, forKey: kCIInputImageKey)
        
        return imageWith(CIImage: filter.outputImage!)
    }

    typealias myCIImage = CIImage
    func imageWith(CIImage: myCIImage) -> UIImage {
        let rect = CIImage.extent
        
        let context = CIContext(options: nil)
        
        let imageRef = context.createCGImage(CIImage, from: rect)

        let image = UIImage(cgImage: imageRef!)
        
        return image
    }
    
}
