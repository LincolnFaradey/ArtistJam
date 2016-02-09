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
    let privateContext: NSManagedObjectContext
    lazy var dateFormatter:NSDateFormatter = {
            let df = NSDateFormatter()
            df.dateFormat = "LL dd, yyyy HH:mm"
            return df
        }()
    
    private init() {
//        privateContext = coreDataStack.context
        privateContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        self.privateContext.parentContext = coreDataStack.context
    }
    
    func save(json: NSDictionary, type: PostType) -> Post? {
        let id = json["id"] as? NSNumber
        let username = json["username"] as! String
        let title = json["title"] as! String
        let details = json["description"] as? String
        let imageLink = json["image_link"] as? String
        
        var newPost: Post?
        privateContext.performBlockAndWait { [unowned self] in
            let artist = self.findOrCreateArtist(username)
            
            newPost = (type == .Event) ? self.findOrCreatePostWith(title, type: .Event)
                                        : self.findOrCreatePostWith(title, type: .News)
            
            guard let post = newPost else {
                print("Couldn't create post")
                return
            }
            
            post.webID = id
            post.artist = artist
            post.details = details
            post.imageLink = imageLink
            
            
            if type == .Event {
                let event = post as! Event
                event.latitude = json["lat"] as? NSNumber ?? 0
                event.longitude = json["long"] as? NSNumber ?? 0
                event.date = self.dateFormatter.dateFromString(json["when"] as! String)
            }else {
                let news = post as! News
                news.likes = json["likes"] as? NSNumber ?? 0
                news.liked = json["liked"] as? NSNumber ?? 0
            }
        }
        
        return newPost
    }
    
    func update(post: Post, value: AnyObject, keyPath: String) {
        post.setValue(value, forKeyPath: keyPath)
        self.saveContext()
    }
    
    func saveContext() {
        
        if privateContext.hasChanges {
            print("private context has changes")
            do {
                try privateContext.save()
                NSNotificationCenter.defaultCenter()
                    .postNotificationName(NSManagedObjectContextObjectsDidChangeNotification,
                        object: nil)
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
            let image = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: privateContext) as! Image
            
            post.title = title
            post.imageData = image
            
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
