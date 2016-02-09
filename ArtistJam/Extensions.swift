//
//  Extensions.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 2/9/16.
//  Copyright © 2016 Andrei Nechaev. All rights reserved.
//

import UIKit



extension UIImage {
    func imageByCroppingTo(rect: CGRect) -> UIImage {
        let imgRef = CGImageCreateWithImageInRect(self.CGImage, rect)
        
        return UIImage(CGImage: imgRef!)
    }
}

extension UITableViewController {
    func addGradientBackground() {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.tableView.bounds
        gradient.colors = [UIColor.whiteColor().CGColor,
            UIColor(red:0.898,  green:0.886,  blue:0.886, alpha:1).CGColor]
        
        let aView = UIView(frame: self.tableView.frame)
        aView.layer.insertSublayer(gradient, atIndex: 0)
        self.tableView.backgroundView = aView
    }
}

//TODO: Create enums for interface colors
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

//extension NSCache {
//    subscript(key: AnyObject) -> AnyObject? {
//        get {
//            return objectForKey(key)
//        }
//        set {
//            if let value: AnyObject = newValue {
//                setObject(value, forKey: key)
//            } else {
//                removeObjectForKey(key)
//            }
//        }
//    }
//}

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
