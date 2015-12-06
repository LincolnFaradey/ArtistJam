//
//  File.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 7/22/15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

import UIKit

class UploadOperation: Operation {
    var uploadProgress: progressBlock?
    let imageData: NSData
    let imageLink: String
    
    lazy var s3UploadRequest: AWSS3TransferManagerUploadRequest = {
        let request = AWSS3TransferManagerUploadRequest()

        request.bucket = BUCKET
        request.uploadProgress = {[unowned self] (sent: Int64, total: Int64, expected: Int64) in
            let percent = Int8(Double(total) / Double(expected) * 100)
            self.uploadProgress!(percent)
        }
        
        request.contentLength = self.imageData.length
        request.body = saveData(self.imageData)
        request.key = self.imageLink
        request.contentType = "image/png"
        
        return request
    }()
    
    init(image: UIImage, link: String) {
        self.imageData = UIImagePNGRepresentation(image.thumbnailWithSize(CGSizeMake(600, 600)))!
        self.imageLink = link
    }
    
    override func main() {
        
        guard !self.cancelled else {
            self.cancel()
            return
        }
        
        uploadProgress = {(percents: Int8) in
            print("Accept: \(percents)")
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        if let task = AWSS3TransferManager.defaultS3TransferManager().upload(s3UploadRequest) {
            task.continueWithSuccessBlock { [unowned self] (task: AWSTask!) -> AnyObject! in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                self.finish()
                return nil
            }
            
        }else {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }
    
    override func cancel() {
        s3UploadRequest.cancel()
        super.cancel()
    }
    
    func fileKey(post: Post) -> String {
        return "\(post.artist!.username)/\(correctFolderName(post.title!)!)/\(todayStringName()).png"
    }
}

func saveData(data: NSData) -> NSURL {
    let path = NSTemporaryDirectory() + todayStringName()
    data.writeToFile(path, atomically: false)
    
    return NSURL(fileURLWithPath: path)
}

let dateFormatter = NSDateFormatter()
func todayStringName() -> String {
    let today = NSDate()
    
    dateFormatter.dateFormat = "MM-dd-yyyy-hh:mm:ssa"
    return dateFormatter.stringFromDate(today)
}
