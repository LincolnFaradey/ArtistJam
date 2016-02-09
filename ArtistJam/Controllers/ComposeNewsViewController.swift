//
//  ComposeNewsViewController.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 9/16/15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

class ComposeNewsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let coreDataStack = CoreDataStack()
    let operationQueue = NSOperationQueue()
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var toolbarConstraint: NSLayoutConstraint!
    
    lazy var imagePicker: UIImagePickerController = {
        let ip = UIImagePickerController()
        ip.sourceType = .PhotoLibrary
        ip.allowsEditing = true
        ip.setEditing(true, animated: true)
        ip.delegate = self
        
        return ip
        }()
    
    lazy var strDate: String = {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy-HH:mm"
            let str = dateFormatter.stringFromDate(NSDate())
            return str
        }()
    
    var image: UIImage?
    
//    var AWSUploadOperation: UploadOperation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        resignFirstResponder()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    //MARK: - IBActions
    @IBAction func setDescription(sender: UIBarButtonItem) {
        descriptionTextView.becomeFirstResponder()
    }
    
    @IBAction func setPhoto(sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    func isReadyToPost() -> Bool {
        if titleTextField.text!.characters.count < 4 {
            handleError("Error", message: "Length of the title cannot be less then 4 characters", okAction: nil)
        } else if descriptionTextView.text!.characters.count < 4 {
            handleError("Error", message: "Length of the description cannot be less then 4 characters", okAction: nil)
        } else if image == nil {
            handleError("Error", message: "You didn't add an image to your post", okAction: nil)
        } else {
            return true
        }
        
        return false
    }
    
    func addNews() -> Post {
        let username = NSUserDefaults.standardUserDefaults().valueForKey("username") as! String
        let title = titleTextField.text
        let details = descriptionTextView.text
        let imageLink = fileLink()

        let postDic = [
            "username": username,
            "title": title,
            "description": details,
            "image_link": imageLink
        ]
        
        let news = BackgroundDataWorker.sharedManager.save(postDic, type: .News) as! News
        news.imageData?.imageDataWith(self.image!)
//        news.imageData?.thumbnailDataWith(self.image!)
        BackgroundDataWorker.sharedManager.saveContext()
        return news
    }
    
    @IBAction func postNews(sender: UIBarButtonItem) {
        if !isReadyToPost() {
            return
        }
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        self.view.userInteractionEnabled = false
        let news = addNews()
        
        let AWSUploadOperation = UploadOperation(image: self.image!, link: fileLink())
        let postUpload = PostUploadOperation(post: news)
        postUpload.addDependency(AWSUploadOperation)
        
        AWSUploadOperation.completionBlock = {
            print("AWS Success")
        }
        
        postUpload.completionBlock = {
            print("Upload success")
            dispatch_async(dispatch_get_main_queue(), { [unowned self] in
                activityIndicator.stopAnimating()
                self.navigationController?.popToRootViewControllerAnimated(true)
            })
        }
        
        operationQueue.addOperation(AWSUploadOperation)
        operationQueue.addOperation(postUpload)
    }
    
    func fileLink() -> String {
        let ownerName = NSUserDefaults.standardUserDefaults().valueForKey("username") as! String
        
        return "\(ownerName)/\(correctFolderName(titleTextField.text!)!)/\(correctFolderName(strDate)!).png"
    }
    
    
    //MARK: - UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let img = editingInfo![UIImagePickerControllerOriginalImage] as! UIImage
        let rect = (editingInfo![UIImagePickerControllerCropRect] as! NSValue).CGRectValue()
        
        self.image = img.imageByCroppingTo(rect)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //MARK: Keyboard and touches
    func keyboardWillShow(sender: NSNotification) {
        guard let userInfo = sender.userInfo as NSDictionary? else {
            return
        }
        
        if let rect = userInfo[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue {
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                self.toolbarConstraint.constant = rect.height
                self.view.layoutIfNeeded()
            })
        }
        
    }
    
    func keyboardWillHide(sender: NSNotification) {
        UIView.animateWithDuration(0.3) { _ in
            self.toolbarConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        resignFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        self.descriptionTextView.resignFirstResponder()
        self.titleTextField.resignFirstResponder()
        return true
    }
    
}

