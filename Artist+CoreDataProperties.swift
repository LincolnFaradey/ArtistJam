//
//  Artist+CoreDataProperties.swift
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

extension Artist {

    @NSManaged var avatar: NSData?
    @NSManaged var details: String?
    @NSManaged var followers: NSNumber?
    @NSManaged var role: String?
    @NSManaged var username: String?
    @NSManaged var post: NSSet?

}
