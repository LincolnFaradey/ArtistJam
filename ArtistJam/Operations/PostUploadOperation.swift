//
//  PostUploadOperation.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 7/22/15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

class PostUploadOperation: OperationWrapper {
    var post: Post!
    var task: URLSessionDataTask!
    
    init(post: Post) {
        self.post = post
    }
    
    override func main() {
        print("post upload began")
        let request: URLRequest?
        if post is Event {
            request = createPostEventRequestWith(route: .Stage("event/new"), json: eventJSONWithPost())
        } else {
            request = createPostEventRequestWith(route: .News("new"), json: newsJSONWithPost())
        }
        
        URLSession.shared.dataTask(with: request!) { (data: Data?, _: URLResponse?, error: Error?) in
            if error != nil {
                print("post upload error: \(String(describing: error?._userInfo))")
                self.cancel()
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!,
                                                            options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        let date = dateFormatter.string(from: event.date! as Date)
        
        let dictionary = [
            "title": event.title!,
            "username": event.artist!.username!,
            "description": event.details!,
            "image": event.imageLink!,
            "when": date,
            "lat": event.latitude!,
            "lon": event.longitude!
            ] as [String : Any]
        print("dict: \(dictionary)")
        return NSDictionary(dictionary: dictionary)
    }
    
    func createPostEventRequestWith(route: Route, json: NSDictionary) -> URLRequest? {
        let request = NSMutableURLRequest(url: route.url()!, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 60)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
            return request as URLRequest
        } catch let error {
            print("cannot serialize: \(String(describing: error._userInfo))")
            return nil
        }
    }
}
