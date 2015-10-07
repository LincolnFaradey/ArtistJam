//
//  Image+CoreDataProperties.swift
//  ArtistJam
//
//  Created by Andrey on 01.09.15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Image {

    @NSManaged var imageData: NSData?
    @NSManaged var thumbnailData: NSData?
    @NSManaged var post: Post?

    
    func image() -> UIImage? {
        guard let data = self.imageData else {
            return nil
        }
        
        return UIImage(data: data)
    }
    
    func imageDataWith(image: UIImage) {
        self.imageData = UIImagePNGRepresentation(image)
    }
    
    func thumbnailImage() -> UIImage? {
        guard let data = self.thumbnailData else {
            return nil
        }
        return UIImage(data: data)
    }
    
    func thumbnailDataWith(image: UIImage) {
        self.thumbnailData = UIImagePNGRepresentation(image)
    }
}
