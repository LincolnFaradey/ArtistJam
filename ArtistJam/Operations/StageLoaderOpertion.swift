//
//  ANStageLoaderOpertion.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 7/8/15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

import UIKit
import CoreData



class StageLoaderOpertion: Operation {
    private let url: NSURL
    private var task: NSURLSessionTask?
    
    enum Category: String {
        case Today = "today"
        case Coming = "coming"
        case New = "new"
        
        func predicate() -> NSPredicate {
            let today = NSDate()
            switch self {
            case .Today:
                return NSPredicate(format: "date < %@ and date > %@", today + 1.day, today - 1.day)
            case .Coming:
                return NSPredicate(format: "date >= %@", today + 1.day)
            case .New:
                return NSPredicate(value: true)
            }
        }
    }
    
    init(category: Category) {
        self.url = Route.Stage(category.rawValue).url()
    }
    
    override func main() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: {[unowned self] (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            guard let data = data else {
                self.cancel()
                return
            }
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
                print(json)
                for (_, v) in json {
                    if let events = v as? [NSDictionary] {
                        for dictionary in events {
                            print("JSON - \(dictionary)")
                            BackgroundDataWorker.sharedManager.save(dictionary, type: .Event)
                        }
                        BackgroundDataWorker.sharedManager.saveContext()
                    }
                }
                
            } catch let error as NSError {
                print("Error occured with JSON serialization:\n \(error.userInfo)")
            }
            self.finish()
        })
        
        task?.resume()
    }
    
    
    override func cancel() {
        task?.cancel()
        super.cancel()
    }
}
