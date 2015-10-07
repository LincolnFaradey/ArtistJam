//
//  ANStageLoaderOpertion.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 7/8/15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

import UIKit
import CoreData

enum Category: String {
    case Today = "today"
    case Coming = "coming"
    case New = "new"
}

class StageLoaderOpertion: Operation {
    
    private let category: Category
    private var task: NSURLSessionTask?
//    let dateFormatter = NSDateFormatter()
//    let coreDataStack = (UIApplication.sharedApplication().delegate as! AppDelegate).coreDataStack
    
    private let address = "https://www.artistjam.net/stage/"
    
    init(category: Category) {
        self.category = category
    }
    
//    func checkArtist(username: String) -> Artist? {
//        let artistEntity = NSEntityDescription.entityForName("Artist", inManagedObjectContext: self.coreDataStack.context)
//        let fetchRequest = NSFetchRequest(entityName: "Artist")
//        fetchRequest.predicate = NSPredicate(format: "username == %@", username)
//        fetchRequest.fetchLimit = 1
//        fetchRequest.entity = artistEntity
//        
//        let fetchResult = try! coreDataStack.context.executeFetchRequest(fetchRequest)
//        
//        if fetchResult.count == 0 {
//            return nil
//        }
//        
//        return fetchResult.first as? Artist
//    }
//    
//    func addEvent(json: NSDictionary, dateFormatter: NSDateFormatter){
//        
//        let eventEntity = NSEntityDescription.entityForName("Event", inManagedObjectContext: self.coreDataStack.context)
//        let fetchRequest = NSFetchRequest(entityName: "Event")
//        fetchRequest.predicate = NSPredicate(format: "title == %@", json["title"] as! String)
//        fetchRequest.fetchLimit = 1
//        fetchRequest.entity = eventEntity
//        
//        let fetchResult = try! coreDataStack.context.executeFetchRequest(fetchRequest)
//        
//        let event: Event!
//        
//        if fetchResult.count == 0 {
//            event = NSEntityDescription.insertNewObjectForEntityForName("Event", inManagedObjectContext: self.coreDataStack.context) as! Event
//            
//            let artist: Artist!
//            if let user = checkArtist(json["username"] as! String) {
//                artist = user
//            } else {
//                artist = NSEntityDescription.insertNewObjectForEntityForName("Artist", inManagedObjectContext: self.coreDataStack.context) as! Artist
//                artist.username = json["username"] as? String
//                artist.role = Role.Artist.rawValue
//            }
//            
//            event.artist = artist
//        } else {
//            event = fetchResult.first as! Event
//        }
//        
//        event.webID = json["id"] as? NSNumber
//        event.title = json["title"] as? String
//        event.details = json["description"] as? String
//        event.imageLink = json["image_link"] as? String
//        event.latitude = json["lat"] as? NSNumber
//        event.longitude = json["long"] as? NSNumber
//
//        dateFormatter.dateFormat = "LL dd, yyyy HH:mm"
//        event.date = dateFormatter.dateFromString(json["when"] as! String)
//        
//        self.coreDataStack.saveContext()
//    }
    
    override func main() {
//        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let url = NSURL(string: address + category.rawValue.lowercaseString)
        task = NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            guard let data = data else {
                return
            }
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
                
                print("JSON - \(json)")
                
                if let events = json[self.category.rawValue] as? [NSDictionary] {
//                    dispatch_async(dispatch_get_main_queue(), {
                        for dictionary in events {
                            BackgroundDataWorker.sharedManager.save(dictionary, type: PostType.Event)
//                            self.addEvent(dictionary , dateFormatter: self.dateFormatter)
                        }
                        self.finish()
//                    })
                }
            } catch let error as NSError {
                print("Error occured with JSON serialization:\n \(error.userInfo)")
                self.finish()
            }
        })
        
        task?.resume()
    }
    
    
    override func cancel() {
        task?.cancel()
        super.cancel()
    }
}
