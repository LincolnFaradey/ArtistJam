//
//  BackgroundDataWorker.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 9/23/15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

enum PostType: String {
    case Event = "Event"
    case News = "News"
}

class BackgroundDataWorker {
    static let sharedManager = BackgroundDataWorker()
    
    let coreDataStack = (UIApplication.sharedApplication().delegate as! AppDelegate).coreDataStack
    let privateContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
    lazy var dateFormatter:NSDateFormatter = {
            let df = NSDateFormatter()
            df.dateFormat = "LL dd, yyyy HH:mm"
            return df
        }()
    
    private init() {
        self.privateContext.persistentStoreCoordinator = coreDataStack.psc
    }
    
    func save(json: NSDictionary, type: PostType) {
        let username = json["username"] as! String
        let title = json["title"] as! String
        let details = json["description"] as? String
        let imageLink = json["image_link"] as? String
        
        privateContext.performBlock {
            let artist = self.findOrCreateArtist(username)
            
            let post = (type == .Event) ?
                self.findOrCreatePostWith(title, type: .Event)
                : self.findOrCreatePostWith(title, type: .News)
            
            post.artist = artist
            post.details = details
            post.imageLink = imageLink
            
            if type == .Event {
                let event = post as! Event
                event.latitude = json["lat"] as? NSNumber
                event.longitude = json["long"] as? NSNumber
                event.date = self.dateFormatter.dateFromString(json["when"] as! String)
            }else {
                let news = post as! News
                news.likes = json["likes"] as? NSNumber
                news.liked = json["liked"] as? NSNumber
            }
            self.saveContext()
        }
    }
    
    func saveContext() {
        
        if privateContext.hasChanges {
            do {
                try privateContext.save()
            } catch let error as NSError {
                print("Could not save: \(error), \(error.userInfo)")
            }
        }
        
    }
    
    func findOrCreatePostWith(title: String, type: PostType) -> Post {
        let entityDescription = NSEntityDescription.entityForName(type.rawValue, inManagedObjectContext: privateContext)
        let fetchRequest = NSFetchRequest(entityName: type.rawValue)
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        fetchRequest.fetchLimit = 1
        fetchRequest.entity = entityDescription
        
        let fetchResult = try! privateContext.executeFetchRequest(fetchRequest)
        
        
        if fetchResult.count == 0 {
            let post = NSEntityDescription.insertNewObjectForEntityForName(type.rawValue, inManagedObjectContext: privateContext) as! Post
            let images = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: privateContext) as! Image
            post.imageData = images
            
            return post
        }
        
        return fetchResult.first as! Post
    }
    
    func findOrCreateArtist(username: String) -> Artist! {
        let artistEntity = NSEntityDescription.entityForName("Artist", inManagedObjectContext: privateContext)
        let fetchRequest = NSFetchRequest(entityName: "Artist")
        fetchRequest.predicate = NSPredicate(format: "username == %@", username)
        fetchRequest.fetchLimit = 1
        fetchRequest.entity = artistEntity
        
        let fetchResult = try! privateContext.executeFetchRequest(fetchRequest)
        
        if fetchResult.count == 0 {
            let artist: Artist!
            artist = NSEntityDescription.insertNewObjectForEntityForName("Artist", inManagedObjectContext: privateContext) as! Artist
            artist.username = username
            artist.role = Role.Artist.rawValue
            return artist
        }
        
        return fetchResult.first as! Artist
    }
}
