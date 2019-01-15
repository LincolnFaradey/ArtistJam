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
        self.cgImage?.cropping(to: rect)
        let imgRef = self.cgImage?.cropping(to: rect)
        
        return UIImage(cgImage: imgRef!)
    }
}

extension UITableViewController {
    func addGradientBackground() {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.tableView.bounds
        gradient.colors = [UIColor.white.cgColor,
                           UIColor(red:0.898,  green:0.886,  blue:0.886, alpha:1).cgColor]
        
        let aView = UIView(frame: self.tableView.frame)
        aView.layer.insertSublayer(gradient, at: 0)
        self.tableView.backgroundView = aView
    }
}

//TODO: Create enums for interface colors
func grayStyleRoundedCorners(view: UIView, radius: Double) {
    view.clipsToBounds = true
    view.layer.borderColor = UIColor(red:0.392,  green:0.380,  blue:0.380, alpha:1).cgColor
    view.layer.borderWidth = 0.6
    view.layer.cornerRadius = CGFloat(radius)
}

func grayStyleRoundedCorners(views: [UIView], radius: Double) {
    for view in views {
        grayStyleRoundedCorners(view: view, radius: radius)
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

extension Data {
    
    private static let hexAlphabet = "0123456789abcdef".unicodeScalars.map { $0 }
    
    func hexString() -> String {
        return String(self.reduce(into: "".unicodeScalars, { (result, value) in
            result.append(Data.hexAlphabet[Int(value/16)])
            result.append(Data.hexAlphabet[Int(value%16)])
        }))
//        var string = String()
//        for i in UnsafeBufferPointer<UInt8>(start: UnsafeMutablePointer<UInt8>(other: bytes), count: length) {
//            string += Int(i).hexString()
//        }
//        return string
    }
    
    func MD5() -> Data {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)
        
        _ = self.withUnsafeBytes { (body: UnsafePointer<UInt8>) in
            CC_MD5(body, CC_LONG(self.count), &digest)
        }
    
        return Data(digest)
    }
    
    func SHA1() -> Data {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)
        
        _ = self.withUnsafeBytes { (body: UnsafePointer<UInt8>) in
            CC_SHA1(body, CC_LONG(self.count), &digest)
        }
        
        return Data(digest)
    }
}

extension String {
    func MD5() -> String {
        return self.data(using: .utf8)!.MD5().hexString()
    }
    
    func SHA1() -> String {
        return self.data(using: .utf8)!.SHA1().hexString()
    }
}

extension Int{
    var hour: (Int, NSCalendar.Unit) {
        return (self, NSCalendar.Unit.hour)
    }
    
    var day: (Int, NSCalendar.Unit) {
        return (self, NSCalendar.Unit.day)
    }
    
    var month: (Int, NSCalendar.Unit) {
        return (self, NSCalendar.Unit.month)
    }
    
    var year: (Int, NSCalendar.Unit) {
        return (self, NSCalendar.Unit.year)
    }
}
