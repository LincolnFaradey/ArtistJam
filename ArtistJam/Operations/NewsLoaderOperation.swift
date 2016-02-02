//
//  NewsLoaderOperation.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 7/13/15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

import UIKit

class NewsLoaderOperatrion: Operation {
    var task: NSURLSessionDataTask?
    
    override func main() {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        task = NSURLSession.sharedSession().dataTaskWithURL(Route.News("all").url(), completionHandler: { [unowned self] (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            guard let data = data else {
                return
            }
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
                let dataWorker = BackgroundDataWorker.sharedManager
                if let news = json["news"] as? [NSDictionary] {
                    print("JSON - \(json)")
                    for dictionary in news {
                        dataWorker.save(dictionary, type: .News)
                    }
                    dataWorker.saveContext()
                }
                self.finish()

                dataWorker.privateContext.reset()
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
