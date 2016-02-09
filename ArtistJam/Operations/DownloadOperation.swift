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
        request.bucket = bucket()
        request.key = self.imageLink
        request.downloadingFileURL = NSURL(fileURLWithPath: self.tmpImagePath)
        
        request.downloadProgress = { [unowned self] (sent: Int64, total: Int64, expected: Int64) in
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
            if percents % 10 == 0 {
                print("Accept: \(percents)")
            }
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        if cancelled {
            print("\(self.name) cancelled")
            return
        }
        
        let semaphore = dispatch_semaphore_create(0)
        
        if let task = AWSS3TransferManager.defaultS3TransferManager().download(s3Request) {

            task.continueWithBlock({ [unowned self] (task: AWSTask!) -> AnyObject! in
                defer {
                    dispatch_semaphore_signal(semaphore)
                }
                
                guard !self.cancelled else {
                    return nil;
                }
                if let imageData = NSData(contentsOfFile: self.tmpImagePath)
                    where task.exception == nil || task.error == nil
                {
                    self.downloadedImage = UIImage(data: imageData)
                    self.finish()
                    
                    return nil
                } else {
                    print("Task exception - \(task.exception)\nTask error - \(task.error)")
                    self.cancel()
                    
                    return nil;
                }
                
            })
        }
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }
    
    override func finish() {
        super.finish()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        removeTmpImage()
    }
    
    override func cancel() {
        super.cancel()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        s3Request.cancel()
        removeTmpImage()
        print("cancelled")
    }
    
    private func removeTmpImage() {
        do {
            if (NSFileManager.defaultManager().fileExistsAtPath(tmpImagePath)) {
                try NSFileManager.defaultManager().removeItemAtPath(tmpImagePath)
            }
        }catch let err as NSError {
            print("Couldn't remove a file: \(err.localizedDescription) info: \(err.userInfo)")
        }
    }
}
