//
//  NewsLoaderOperation.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 7/13/15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

import UIKit

class NewsLoaderOperatrion: OperationWrapper {
    var task: URLSessionDataTask?
    
    override func main() {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        task = URLSession.shared.dataTask(with: Route.News("all").url()!, completionHandler: { [unowned self] (data: Data?, response: URLResponse?, error: Error?) -> Void in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            guard let data = data else {
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let news = try decoder.decode([News].self, from: data)
                let dataWorker = BackgroundDataWorker.sharedManager
                for n in news {
                    let _ = dataWorker.save(post: n, type: .News)
                }
                dataWorker.saveContext()
//                let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [Dictionary<String, Any>]
//                let dataWorker = BackgroundDataWorker.sharedManager
//
//                if let news = json?["news"] {
//                    print("JSON - \(String(describing: json))")
//                    for dictionary in news {
//                        dataWorker.save(dictionary, type: .News)
//                    }
//                    dataWorker.saveContext()
//                }
                self.finish()

                dataWorker.privateContext.reset()
            } catch let error {
                print("Error occured with JSON serialization: \n \(String(describing: error._userInfo))")
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
