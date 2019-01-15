//
//  ANDownloadOperation.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 7/6/15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

import UIKit

class DownloadOperation: OperationWrapper {
    
    let imageLink: String
    var downloadedImage: UIImage?
    var progress: progressBlock?
    
    private lazy var tmpImagePath: String = {
        let sArr = self.imageLink.components(separatedBy: "/")
            let filePath = NSTemporaryDirectory() + sArr.last!
            return filePath
        }()
    
    lazy var s3Request: AWSS3TransferManagerDownloadRequest = {
        var request = AWSS3TransferManagerDownloadRequest()
        request?.bucket = bucket()
        request?.key = self.imageLink
        request?.downloadingFileURL = URL(fileURLWithPath: self.tmpImagePath)
        
        request?.downloadProgress = { [unowned self] (sent: Int64, total: Int64, expected: Int64) in
            let percent = Int8(Double(total) / Double(expected) * 100)
            self.progress!(percent)
        }
        
        return request!
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
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if isCancelled {
            print("\(String(describing: self.name)) cancelled")
            return
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        if let task = AWSS3TransferUtility.default().download(to: s3Request.downloadingFileURL, key: self.imageLink, expression: imageLink) {

            task.continueWithBlock({ [unowned self] (task: AWSTask!) -> AnyObject? in
                defer {
                    dispatch_semaphore_signal(semaphore)
                }
                
                guard !self.cancelled else {
                    return nil;
                }
                if let imageData = NSData(contentsOfFile: self.tmpImagePath), task.exception == nil || task.error == nil
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
        let _ = DispatchSemaphore(value: 0).wait(timeout: DispatchTime.distantFuture)
    }
    
    override func finish() {
        super.finish()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        removeTmpImage()
    }
    
    override func cancel() {
        super.cancel()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        s3Request.cancel()
        removeTmpImage()
        print("cancelled")
    }
    
    private func removeTmpImage() {
        do {
            if (FileManager.default.fileExists(atPath: tmpImagePath)) {
                try FileManager.default.removeItem(atPath: tmpImagePath)
            }
        }catch let err as NSError {
            print("Couldn't remove a file: \(err.localizedDescription) info: \(err.userInfo)")
        }
    }
}
