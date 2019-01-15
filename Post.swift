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
    
    @NSManaged var name: String
    
    @NSManaged var about: String?
    
    @NSManaged var imageURL: String?
    
    // MARK: - Decodable
    required convenience init(from decoder: Decoder) throws {
        guard let codingUserInfoKeyManagedObjectContext = decoder.userInfo[CodingUserInfoKey],
            let managedObjectContext = decoder.userInfo[codingUserInfoKeyManagedObjectContext] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "User", in: managedObjectContext) else {
                fatalError("Failed to decode User")
        }
        
        self.init(entity: entity, insertInto: managedObjectContext)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)!
        self.username = try container.decodeIfPresent(String.self, forKey: .username)!
        self.name = try container.decodeIfPresent(String.self, forKey: .name)!
        self.about = try container.decodeIfPresent(String.self, forKey: .about)!
        self.imageLink = try container.decodeIfPresent(String.self, forKey: .about)!
    }
    
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(avatarUrl, forKey: .avatarUrl)
        try container.encode(username, forKey: .username)
        try container.encode(role, forKey: .role)
    }
}
