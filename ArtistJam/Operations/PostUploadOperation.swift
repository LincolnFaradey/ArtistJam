//
//  PostUploadOperation.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 7/22/15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

class PostUploadOperation: Operation {
    var post: Post!
    var task: NSURLSessionDataTask!
    
    init(post: Post) {
        self.post = post
    }
    
    override func main() {
        print("post upload began")
        let request: NSURLRequest?
        if post is Event {
            request = createPostEventRequest(route: "stage/event/new", json: eventJSONWithPost())
        } else {
            request = createPostEventRequest(route: "feed/news/new", json: newsJSONWithPost())
        }
        
        task = NSURLSession.sharedSession().dataTaskWithRequest(request!) { (data: NSData?, _, error: NSError?) -> Void in
            if error != nil {
                print("post upload error: \(error?.userInfo)")
                self.cancel()
                return
            }
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!,
                    options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                
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
        }
        
        task.resume()
    }
    
    func newsJSONWithPost() -> NSDictionary {
        guard let username = post.artist?.username else {
            return [:]
        }
        
        let dictionary = [
            "title": post.title!,
            "username": username,
            "description": post.details!,
            "image": post.imageLink!
        ]
        
        return NSDictionary(dictionary: dictionary)
    }
    
    func eventJSONWithPost() -> NSDictionary {
        let event = post as! Event
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        let date = dateFormatter.stringFromDate(event.date!)
        
        let dictionary = [
            "title": event.title!,
            "username": event.artist!.username!,
            "description": event.details!,
            "image": event.imageLink!,
            "when": date,
            "lat": event.latitude!,
            "lon": event.longitude!
        ]
        print("dict: \(dictionary)")
        return NSDictionary(dictionary: dictionary)
    }
    
    func createPostEventRequest(route route: String, json: NSDictionary) -> NSURLRequest? {
        let loginURL = NSURL(string: ADDRESS + "/" + route)
        let request = NSMutableURLRequest(URL: loginURL!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 60)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions.PrettyPrinted)
            return request
        } catch let error as NSError {
            print("cannot serialize: \(error.userInfo)")
            return nil
        }
    }
}
