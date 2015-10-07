//
//  NewsLoaderOperation.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 7/13/15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

import UIKit

class NewsLoaderOperatrion: Operation {
    let coreDataStack = (UIApplication.sharedApplication().delegate as! AppDelegate).coreDataStack
    var task: NSURLSessionDataTask?
    let address = ADDRESS + "/feed/news/all"
    
    func addNews(json: NSDictionary) {
        
        let username = json["username"] as! String
        let title = json["title"] as! String
        let details = json["description"] as? String
        let imageLink = json["image_link"] as? String
        let liked = json["liked"] as? NSNumber
        let likes = json["likes"] as? NSNumber
        
        let news = findOrCreateNews(title, context: self.coreDataStack.context)
        let artist = findOrCreateArtist(username, context: self.coreDataStack.context)
        
        news.artist = artist
        news.title = title
        
        if news.details != details {
            news.details = details
        }
        
        if news.imageLink != imageLink {
            news.imageLink = imageLink
        }
        
        if news.likes != likes {
            news.likes = likes
        }
        
        if news.liked != liked {
            news.liked = liked
        }
        
        coreDataStack.saveContext()
    }
    
    override func main() {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let url = NSURL(string: address)
        task = NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            guard let data = data else {
                return
            }
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
                
                if let news = json["news"] as? Array<NSDictionary> {
                    print("JSON - \(json)")
                    for dictionary in news {
                        self.addNews(dictionary)
                    }
                }
                self.finish()
            } catch let error as NSError {
                print("Error occured with JSON serialization: \n \(error.userInfo)")
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

func findOrCreateNews(title: String, context: NSManagedObjectContext) -> News {
    let newsDescript = NSEntityDescription.entityForName("News", inManagedObjectContext: context)
    let fetchRequest = NSFetchRequest(entityName: "News")
    fetchRequest.predicate = NSPredicate(format: "title == %@", title)
    fetchRequest.fetchLimit = 1
    fetchRequest.entity = newsDescript
    
    let fetchResult = try! context.executeFetchRequest(fetchRequest)
    
    
    if fetchResult.count == 0 {
        let news = NSEntityDescription.insertNewObjectForEntityForName("News", inManagedObjectContext: context) as! News
        let images = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: context) as! Image
        news.imageData = images
        
        return news
    }
    
    return fetchResult.first as! News
}

func findOrCreateArtist(username: String, context: NSManagedObjectContext) -> Artist! {
    let artistEntity = NSEntityDescription.entityForName("Artist", inManagedObjectContext: context)
    let fetchRequest = NSFetchRequest(entityName: "Artist")
    fetchRequest.predicate = NSPredicate(format: "username == %@", username)
    fetchRequest.fetchLimit = 1
    fetchRequest.entity = artistEntity
    
    let fetchResult = try! context.executeFetchRequest(fetchRequest)
    
    if fetchResult.count == 0 {
        let artist: Artist!
        artist = NSEntityDescription.insertNewObjectForEntityForName("Artist", inManagedObjectContext: context) as! Artist
        artist.username = username
        artist.role = Role.Artist.rawValue
        return artist
    }
    
    return fetchResult.first as! Artist
}