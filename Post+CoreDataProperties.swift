//
//  Post+CoreDataProperties.swift
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

extension Post {

    @NSManaged var details: String?
    @NSManaged var imageLink: String?
    @NSManaged var title: String?
    @NSManaged var webID: NSNumber?
    @NSManaged var artist: Artist?
    @NSManaged var imageData: Image?

}
