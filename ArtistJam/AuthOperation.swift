//
//  ANAuthOperation.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 7/13/15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//


class AuthOperation: OperationWrapper {
    private let request: URLRequest
    
    private var task: URLSessionDataTask?
    private var jsonData: Data?
    
    init(json: NSDictionary, route: Route) {
        print("JSON Auth: \(json)")
        self.request = createAuthRequest(route: route, json: json)!
    }
    
    override func start() {
        self.task = URLSession.shared.dataTask(with: request, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            if error != nil {
                print(error!._userInfo!)
                self.cancel()
                return
            }
            
            let json: NSDictionary
            do {
                json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                
                let message = json["message"] as? String
                print("success \(json)")
                if message == "success" {
                    self.finish()
                } else {
                    self.cancel()
                }
            } catch let error as NSError {
                self.cancel()
                print("got an error: \(error.userInfo)")
            }
        })
        
        self.task?.resume()
    }
    
    override func cancel() {
        self.task?.cancel()
        super.cancel()
    }
    
}
