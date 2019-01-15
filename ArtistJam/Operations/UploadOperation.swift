//
//  File.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 7/22/15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

import UIKit

class UploadOperation: OperationWrapper {
    var uploadProgress: progressBlock?
    let imageData: Data
    let imageLink: String
    
    lazy var s3UploadRequest: AWSS3TransferManagerUploadRequest = {
        let request = AWSS3TransferManagerUploadRequest()

        request?.bucket = bucket()
        request?.uploadProgress = {[unowned self] (sent: Int64, total: Int64, expected: Int64) in
            let percent = Int8(Double(total) / Double(expected) * 100)
            self.uploadProgress!(percent)
        }
        
        request?.contentLength = self.imageData.count as NSNumber
        request?.body = saveData(data: self.imageData) as URL
        request?.key = self.imageLink
        request?.contentType = "image/png"
        
        return request!
    }()
    
    init(image: UIImage, link: String) {
        self.imageData = image.thumbnailWithSize(size: CGSize.init(width: 600, height: 600)).pngData()!
        self.imageLink = link
    }
    
    override func start() {
        guard !self.isCancelled else {
            self.cancel()
            return
        }
        
        uploadProgress = {(percents: Int8) in
            print("Accept: \(percents)")
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        AWSS3TransferUtility.default().uploadData(imageData, bucket: bucket(), key: imageLink, contentType: "image/png", expression: AWSS3TransferUtilityUploadExpression.init()) { (task, err) in
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if err != nil {
                self.cancel()
            }
            
            self.finish()
            
        }
    }
    
    override func cancel() {
        s3UploadRequest.cancel()
        super.cancel()
    }
    
    func fileKey(post: Post) -> String {
        return "\(String(describing: post.artist!.username))/\(correctFolderName(name: post.title!)!)/\(todayStringName()).png"
    }
}

func saveData(data: Data) -> URL {
    let path = NSTemporaryDirectory() + todayStringName()
    let url = URL(fileURLWithPath: path)
    
    try! data.write(to: url, options: Data.WritingOptions.atomicWrite)
    
    return url
}

let dateFormatter = DateFormatter()
func todayStringName() -> String {
    let today = Date()
    
    dateFormatter.dateFormat = "MM-dd-yyyy-hh:mm:ssa"
    return dateFormatter.string(from: today)
}
