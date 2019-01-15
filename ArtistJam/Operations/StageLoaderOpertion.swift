//
//  ANStageLoaderOpertion.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 7/8/15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

import UIKit
import CoreData

class StageLoaderOpertion: OperationWrapper {
    private let url: URL
    private var task: URLSessionTask?
    
    enum Category: String {
        case Today = "today"
        case Coming = "coming"
        case New = "new"
        
        func predicate() -> NSPredicate {
            let today = Date()
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
        self.url = Route.Stage(category.rawValue).url()!
    }
    
    override func main() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        task = URLSession.shared.dataTask(with: url, completionHandler: {[unowned self] (data: Data?, response: URLResponse?, error: Error?) -> Void in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            guard let data = data else {
                self.cancel()
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary
                print(json)
                for (_, v) in json {
                    if let events = v as? [NSDictionary] {
                        for dictionary in events {
                            print("JSON - \(dictionary)")
                            let _ = BackgroundDataWorker.sharedManager.save(json: dictionary, type: .Event)
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
