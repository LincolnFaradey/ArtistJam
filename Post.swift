//
//  Post.swift
//  ArtistJam
//
//  Created by Andrey on 01.09.15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

import Foundation
import CoreData

class Post: NSManagedObject, Codable {
    
//    let id = json["id"] as? NSNumber
//    let username = json["username"] as! String
//    let title = json["title"] as! String
//    let details = json["description"] as? String
//    let imageLink = json["image_link"] as? String
    
//    @NSManaged var details: String?
//    @NSManaged var imageLink: String?
//    @NSManaged var title: String?
//    @NSManaged var webID: NSNumber?
//    @NSManaged var artist: Artist?
//    @NSManaged var imageData: Image?
    
    enum CodingKeys: String, CodingKey {
        case details = "description"
        case imageLink
        case title
        case id
        case username
        
    }
    
    @NSManaged var id: String
    
    @NSManaged var username: String
    
    @NSManaged var about: String?
    
    // MARK: - Decodable
    required convenience init(from decoder: Decoder) throws {
        guard let infoKey = CodingUserInfoKey.init(rawValue: "Post") else {
            fatalError("No CodingUserInfoKey 'Post' found")
        }
        guard let codingUserInfoKeyManagedObjectContext = decoder.userInfo[infoKey],
            let managedObjectContext = codingUserInfoKeyManagedObjectContext as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Post", in: managedObjectContext) else {
                fatalError("Failed to decode Post")
        }
        
        self.init(entity: entity, insertInto: managedObjectContext)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)!
        self.username = try container.decodeIfPresent(String.self, forKey: .username)!
        self.title = try container.decodeIfPresent(String.self, forKey: .title)!
        self.details = try container.decodeIfPresent(String.self, forKey: .details)!
        self.imageLink = try container.decodeIfPresent(String.self, forKey: .imageLink)!
    }
    
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(username, forKey: .username)
        try container.encode(details, forKey: .details)
        try container.encode(title, forKey: .title)
        try container.encode(imageLink, forKey: .imageLink)
    }
}
