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


func createAuthRequest(route: Route, json: NSDictionary) -> URLRequest? {
    let urlComponents = NSURLComponents()
    urlComponents.scheme = Route.scheme()
    urlComponents.host = Route.host()
    urlComponents.path = route.path()
    
    var items: [NSURLQueryItem] = []

    for (key, value) in json {
        items.append(NSURLQueryItem(name: key as! String, value: (value as! String)))
    }
    urlComponents.queryItems = items as [URLQueryItem]
    print("Request url = \(urlComponents.url!)")
    return NSURLRequest(url: urlComponents.url!) as URLRequest
}

func handleError(title: String, message: String, okAction: ((UIAlertAction)->Void)?) {
    let rootVC = UIApplication.shared.keyWindow?.rootViewController
    let errorController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    
    let okAction = UIAlertAction(title: "Ok", style: .default, handler: okAction)
    errorController.addAction(okAction)
    
    rootVC?.present(errorController, animated: true, completion: nil)
}


func correctFolderName(name: String) -> String? {
    do {
        let regEx = try NSRegularExpression(pattern: "[^a-zA-Z0-9_]+", options: NSRegularExpression.Options.caseInsensitive)
        
        return regEx.stringByReplacingMatches(in: name, options: NSRegularExpression.MatchingOptions.withTransparentBounds, range: NSMakeRange(0, name.count), withTemplate: "_")
    } catch let error as NSError {
        print("Cannot create a folder name with error:\n \(error.userInfo)")
    }
    
    return nil
}

func + (date: Date, tuple: (value: Int, unit: Calendar.Component)) -> Date {
    return Calendar.current.date(byAdding: tuple.unit, value: tuple.value, to: date, wrappingComponents: false)!
}

func - (date: Date, tuple: (value: Int, unit: Calendar.Component)) -> Date {
    return Calendar.current.date(byAdding: tuple.unit, value: (-tuple.value), to: date, wrappingComponents: false)!
}
