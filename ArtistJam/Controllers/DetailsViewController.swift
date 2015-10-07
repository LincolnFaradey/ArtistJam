//
//  DetailsViewController.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 9/9/15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

class DetailsViewController: UIViewController {


    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    var post: Post!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = self.post.title
        self.imageView.image = self.post.imageData?.image()
        self.textView.text = self.post.details
    }
}
