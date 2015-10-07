//
//  ANAuthOperation.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 7/13/15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

enum Route: String {
    case SignIn = "signin"
    case SignUp = "signup"
}

typealias CancelationBlock = ()->()

class AuthOperation: Operation {
    var cancelationBlock = CancelationBlock?()
    
    private var json: NSDictionary
    private let route: String
    
    private var task: NSURLSessionDataTask?
    private var jsonData: NSData?
    
    init(json: NSDictionary, route: Route) {
        self.json = json

        self.route = route.rawValue
    }
    
    override func main() {
        guard let request = createAuthRequest(route: route, json: json) else {
            cancel()
            return
        }
        self.task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if error != nil {
                self.cancel()
                return
            }
            
            let json: NSDictionary
            do {
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                
                let message = json["message"] as? String
                print("success \(json)")
                if message == "success" {

                    self.finish()
                }else {
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
        if let block = cancelationBlock {
            block()
        }
        
        self.task?.cancel()
        super.cancel()
    }
    
}
