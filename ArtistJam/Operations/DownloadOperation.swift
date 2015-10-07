//
//  ANDownloadOperation.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 7/6/15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

import UIKit

class DownloadOperation: Operation {
    
    let imageLink: String
    var downloadedImage: UIImage?
    var progress: progressBlock?
    
    private lazy var tmpImagePath: String = {
            let sArr = self.imageLink.componentsSeparatedByString("/")
            let filePath = NSTemporaryDirectory() + sArr.last!
            return filePath
        }()
    
    lazy var s3Request: AWSS3TransferManagerDownloadRequest = {
        var request = AWSS3TransferManagerDownloadRequest()
        request.bucket = BUCKET
        request.key = self.imageLink
        request.downloadingFileURL = NSURL(fileURLWithPath: self.tmpImagePath)
        
        request.downloadProgress = {(sent: Int64, total: Int64, expected: Int64) in
            let percent = Int8(Double(total) / Double(expected) * 100)
            self.progress!(percent)
        }
        
        return request
        }()

    
    init(imageLink: String) {
        self.imageLink = imageLink
    }
    
    override func main() {
        progress = {(percents: Int8) in
            print("Accept: \(percents)")
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        if let task = AWSS3TransferManager.defaultS3TransferManager().download(s3Request) {
            task.continueWithSuccessBlock { (task: AWSTask!) -> AnyObject! in

                let imageData = NSData(contentsOfFile: self.tmpImagePath)!.copy() as! NSData

                self.downloadedImage = UIImage(data: imageData)
                self.finish()
                return nil
            }
        }
    }
    
    override func finish() {
        super.finish()
        removeTmpImage()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    override func cancel() {
        s3Request.cancel()
        removeTmpImage()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        super.cancel()
    }
    
    private func removeTmpImage() {
        do {
            try NSFileManager.defaultManager().removeItemAtPath(tmpImagePath)
        }catch let err as NSError {
            print("Couldn't remove a file: \(err.localizedDescription) info: \(err.userInfo)")
        }
    }
}
