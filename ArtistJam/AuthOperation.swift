//
//  ANAuthOperation.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 7/13/15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

let baseURL = NSURL(string: "https://www.artistjam.net/")!
enum Route {
    case SignIn
    case SignUp
    case Logout
    case Stage(String)
    case News(String)
    
    func url() -> NSURL {
        switch self {
        case .SignIn:
            return baseURL.URLByAppendingPathComponent("/auth/signin")
        case .SignUp:
            return baseURL.URLByAppendingPathComponent("/auth/signup")
        case .Logout:
            return baseURL.URLByAppendingPathComponent("/auth/logout")
        case .Stage(let category):
            return baseURL.URLByAppendingPathComponent("/stage/\(category)")
        case .News(let addr):
            return baseURL.URLByAppendingPathComponent("/feed/news/\(addr)")
        }
    }
}

class AuthOperation: Operation {
    private let request: NSURLRequest
    
    private var task: NSURLSessionDataTask?
    private var jsonData: NSData?
    
    init(json: NSDictionary, route: Route) {
        print("JSON Auth: \(json)")
        self.request = createAuthRequest(route: route, json: json)!
    }
    
    override func main() {
        self.task = NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if error != nil {
                print(error?.userInfo)
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
        self.task?.cancel()
        super.cancel()
    }
    
}
