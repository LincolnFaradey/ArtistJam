//
//  Model.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 7/8/15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

import Foundation
import CoreLocation

enum Role: String {
    case Fan = "Fan"
    case Artist = "Artist"
}

struct User {
    let username: String?
    let role: Role
    
    init(json: NSDictionary) {
        username = json["username"] as? String
        if let number = json["role"] as? NSNumber {
            role = number.boolValue ? Role.Artist : Role.Fan
        }else {
            role = Role.Fan
        }
    }
    
    init(username: String, role: Role) {
        self.username = username
        self.role = role
    }
}

//protocol Post {
//    var owner: User! { get }
//    var title: String! { get }
//    var details: String! { get }
//    var imageLink: String! { get }
//    var localImageLink: String! { get }
//}
//
//struct Event: Post {
//    let owner: User!
//    let title: String!
//    let details: String!
//    var imageLink: String!
//    var localImageLink: String! {
//        get {
//            let pathComponents = imageLink?.componentsSeparatedByString("/").last
//            if let pathComponents = pathComponents {
//                return NSTemporaryDirectory().stringByAppendingFormat("/%@", pathComponents)
//            }else {
//                return nil
//            }
//        }
//    }
//    
//    let location: CLLocationCoordinate2D!
//    let date: String!
//    
//    init(json: NSDictionary, dateFormatter: NSDateFormatter) {
//        self.owner = User(username: json["username"] as! String, role: Role.Artist)
//        self.title = json["title"] as! String
//        self.details = json["description"] as! String
//        self.imageLink = json["image_link"] as! String
//        let latitude = json["lat"] as! NSNumber
//        let longitude = json["long"] as! NSNumber
//        self.location = CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue)
//        dateFormatter.dateFormat = "LL dd, yyyy HH:mm"
////        let tmpDate = dateFormatter.dateFromString(json["when"] as! String)
//        self.date = json["when"] as! String
////        dateFormatter.dateFormat = "LLLL dd, yyyy HH:mm"
////        self.date = dateFormatter.stringFromDate(tmpDate!)
//    }
//    
//    init(dictionary: Dictionary<String, AnyObject>) {
//        self.owner = User(username: dictionary["username"] as! String, role: Role.Artist)
//        self.title = dictionary["title"] as! String
//        self.details = dictionary["description"] as! String
//        self.imageLink = dictionary["image_link"] as? String
//        let latitude = dictionary["lat"] as! Double
//        let longitude = dictionary["lon"] as! Double
//        self.location = CLLocationCoordinate2DMake(latitude, longitude)
//        self.date = dictionary["date"] as! String
//    }
//}
//
//struct News: Post {
//    let id: Int?
//    let owner: User!
//    let title: String!
//    let details: String!
//    var imageLink: String!
//    var liked: Bool! {
//        willSet {
//            let url = newValue! ? NSURL(string: ADDRESS + "/news/like/" + String(id!)) : NSURL(string: ADDRESS + "/news/unlike/" + String(id!))
//            likes = newValue! ? likes + 1 : likes - 1
//            NSURLSession.sharedSession().dataTaskWithURL(url!)!.resume()
//        }
//    }
//    var likes: Int!
//    var date: String!
//    
//    var localImageLink: String! {
//        get {
//            let pathComponents = imageLink!.componentsSeparatedByString("/").last
//            if let pathComponents = pathComponents {
//                return NSTemporaryDirectory().stringByAppendingFormat("/%@", pathComponents)
//            }else {
//                return nil
//            }
//        }
//    }
//    
//    init(json: NSDictionary) {
//        self.owner = User(username: json["username"] as! String, role: Role.Artist)
//        self.title = json["title"] as! String
//        self.details = json["description"] as! String
//        self.imageLink = json["image_link"] as! String
//        self.liked = json["liked"]!.boolValue
//        self.likes = json["likes"] as! Int
//        
//        let idNum = json["id"] as! NSNumber
//        self.id = idNum.longValue
//    }
//    
//    mutating func revertLiked() {
//        self.liked = !self.liked!
//    }
//}