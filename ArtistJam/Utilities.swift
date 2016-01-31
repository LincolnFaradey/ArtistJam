//
//  ANUtilities.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 7/6/15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

let ADDRESS = "https://www.artistjam.net/"

func createAuthRequest(route route: Route, json: NSDictionary) -> NSURLRequest? {
    print("Route: \(route.url())")
    let request = NSMutableURLRequest(URL: route.url(), cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 60)
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

func handleError(title: String, message: String, okAction: ((UIAlertAction)->Void)?) {
    let rootVC = UIApplication.sharedApplication().keyWindow?.rootViewController
    let errorController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
    
    let okAction = UIAlertAction(title: "Ok", style: .Default, handler: okAction)
    errorController.addAction(okAction)
    
    rootVC?.presentViewController(errorController, animated: true, completion: nil)
}



func imageByCropping(image: UIImage, rect: CGRect) -> UIImage {
    let imgRef = CGImageCreateWithImageInRect(image.CGImage, rect)

    return UIImage(CGImage: imgRef!)
}

func addGradientBackground(controller: UITableViewController) {
    let gradient: CAGradientLayer = CAGradientLayer()
    gradient.frame = controller.tableView.bounds
    gradient.colors = [UIColor.whiteColor().CGColor,
        UIColor(red:0.898,  green:0.886,  blue:0.886, alpha:1).CGColor]
    
    let aView = UIView(frame: controller.tableView.frame)
    aView.layer.insertSublayer(gradient, atIndex: 0)
    controller.tableView.backgroundView = aView
}

func grayStyleRoundedCorners(view: UIView, radius: Double) {
    view.clipsToBounds = true
    view.layer.borderColor = UIColor(red:0.392,  green:0.380,  blue:0.380, alpha:1).CGColor
    view.layer.borderWidth = 0.6
    view.layer.cornerRadius = CGFloat(radius)
}

func grayStyleRoundedCorners(views: [UIView], radius: Double) {
    for view in views {
        grayStyleRoundedCorners(view, radius: radius)
    }
}

func correctFolderName(name: String) -> String? {
    do {
        let regEx = try NSRegularExpression(pattern: "[^a-zA-Z0-9_]+", options: NSRegularExpressionOptions.CaseInsensitive)
        
        return regEx.stringByReplacingMatchesInString(name, options: NSMatchingOptions.WithTransparentBounds, range: NSMakeRange(0, name.characters.count), withTemplate: "_")
    } catch let error as NSError {
        print("Cannot create a folder name with error:\n \(error.userInfo)")
    }
    
    return nil
}

extension NSCache {
    subscript(key: AnyObject) -> AnyObject? {
        get {
            return objectForKey(key)
        }
        set {
            if let value: AnyObject = newValue {
                setObject(value, forKey: key)
            } else {
                removeObjectForKey(key)
            }
        }
    }
}

extension Int {
    func hexString() -> String {
        return String(format: "%02x", self)
    }
}

extension NSData {
    func hexString() -> String {
        var string = String()
        for i in UnsafeBufferPointer<UInt8>(start: UnsafeMutablePointer<UInt8>(bytes), count: length) {
            string += Int(i).hexString()
        }
        return string
        }

        func MD5() -> NSData {
            let result = NSMutableData(length: Int(CC_MD5_DIGEST_LENGTH))!
            CC_MD5(bytes, CC_LONG(length), UnsafeMutablePointer<UInt8>(result.mutableBytes))
            return NSData(data: result)
        }

        func SHA1() -> NSData {
            let result = NSMutableData(length: Int(CC_SHA1_DIGEST_LENGTH))!
            CC_SHA1(bytes, CC_LONG(length), UnsafeMutablePointer<UInt8>(result.mutableBytes))
            return NSData(data: result)
        }
}

extension String {
    func MD5() -> String {
        return (self as NSString).dataUsingEncoding(NSUTF8StringEncoding)!.MD5().hexString()
    }

    func SHA1() -> String {
        return (self as NSString).dataUsingEncoding(NSUTF8StringEncoding)!.SHA1().hexString()
    }
}

extension Int{
    var hour: (Int, NSCalendarUnit) {
        return (self, NSCalendarUnit.Hour)
    }
    
    var day: (Int, NSCalendarUnit) {
        return (self, NSCalendarUnit.Day)
    }
    
    var month: (Int, NSCalendarUnit) {
        return (self, NSCalendarUnit.Month)
    }
    
    var year: (Int, NSCalendarUnit) {
        return (self, NSCalendarUnit.Year)
    }
}

func + (date: NSDate, tuple: (value: Int, unit: NSCalendarUnit)) -> NSDate {
    return NSCalendar.currentCalendar().dateByAddingUnit(tuple.unit, value: tuple.value, toDate: date, options:.WrapComponents)!
}

func - (date: NSDate, tuple: (value: Int, unit: NSCalendarUnit)) -> NSDate {
    return NSCalendar.currentCalendar().dateByAddingUnit(tuple.unit, value: (-tuple.value), toDate: date, options:.WrapComponents)!
}