//
//  ANStageTableViewCell.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 7/6/15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

import UIKit

protocol PostTableViewDelegate {
    func facebookButtonWasPressed(sender: UIButton, index: NSIndexPath)
    func twitterButtonWasPressed(sender: UIButton, index: NSIndexPath)
    func addButtonWasPressed(sender: UIButton, index: NSIndexPath)
    
    func likeButtonWasPressed(sender: UIButton, index: NSIndexPath)
}

class PostTableViewCell: UITableViewCell {

    var delegate: PostTableViewDelegate?

    var indexPath: NSIndexPath?
    
    var loading = false
    
    @IBOutlet weak var stageImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likesCounterLabel: UILabel!

    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        indexPath = nil
        super.prepareForReuse()
    }


//MARK: - Actions
    
    @IBAction func addButtonAction(sender: UIButton) {
        delegate?.addButtonWasPressed(sender, index: self.indexPath!)
    }
    
    @IBAction func twitterButtonAction(sender: UIButton) {
        delegate?.twitterButtonWasPressed(sender, index: self.indexPath!)
    }
    
    @IBAction func facebookButtonAction(sender: UIButton) {
        delegate?.facebookButtonWasPressed(sender, index: self.indexPath!)
    }

    @IBAction func likeButtonAction(sender: UIButton) {
        delegate?.likeButtonWasPressed(sender, index: self.indexPath!)
    }
}

extension PostTableViewCell {
    
    func loadImageFor(postEntity post: Post, atCoreDataStack stack: CoreDataStack) -> (loader: DownloadOperation, filter: ImageFilterOperation) {
        
        self.loading = true
        let loader = DownloadOperation(imageLink: post.imageLink!)

        let imageFilter = ImageFilterOperation()
        
        loader.completionBlock = {
            print("loaded")
            imageFilter.image = loader.downloadedImage!
        }
        

        imageFilter.completionBlock = {
            dispatch_async(dispatch_get_main_queue(), {
                post.imageData?.imageDataWith(loader.downloadedImage!)
                post.imageData?.thumbnailDataWith(imageFilter.outImage!)
                
                stack.saveContext()
                
                if let _ = post.imageData?.image() {
                    print("image exist")
                    self.loading = false
                }else {
                    print("no it doesn't")
                }
                
                self.stageImageView.image = post.imageData?.thumbnailImage()
                
            })
        }
        
        return (loader, imageFilter)
    }
    
}
