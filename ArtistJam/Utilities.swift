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


func createAuthRequest(route route: Route, json: NSDictionary) -> NSURLRequest? {
    let urlComponents = NSURLComponents()
    urlComponents.scheme = Route.scheme()
    urlComponents.host = Route.host()
    urlComponents.path = route.path()
    
    var items: [NSURLQueryItem] = []

    for (key, value) in json {
        items.append(NSURLQueryItem(name: key as! String, value: String(value)))
    }
    urlComponents.queryItems = items
    print("Request url = \(urlComponents.URL!)")
    return NSURLRequest(URL: urlComponents.URL!)
}

func handleError(title: String, message: String, okAction: ((UIAlertAction)->Void)?) {
    let rootVC = UIApplication.sharedApplication().keyWindow?.rootViewController
    let errorController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
    
    let okAction = UIAlertAction(title: "Ok", style: .Default, handler: okAction)
    errorController.addAction(okAction)
    
    rootVC?.presentViewController(errorController, animated: true, completion: nil)
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

func + (date: NSDate, tuple: (value: Int, unit: NSCalendarUnit)) -> NSDate {
    return NSCalendar.currentCalendar().dateByAddingUnit(tuple.unit, value: tuple.value, toDate: date, options:.WrapComponents)!
}

func - (date: NSDate, tuple: (value: Int, unit: NSCalendarUnit)) -> NSDate {
    return NSCalendar.currentCalendar().dateByAddingUnit(tuple.unit, value: (-tuple.value), toDate: date, options:.WrapComponents)!
}