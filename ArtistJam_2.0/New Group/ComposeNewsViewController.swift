//
//  ComposeNewsViewController.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 9/16/15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

class ComposeNewsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let coreDataStack = CoreDataStack()
    let operationQueue = OperationQueue()
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var toolbarConstraint: NSLayoutConstraint!
    
    lazy var imagePicker: UIImagePickerController = {
        let ip = UIImagePickerController()
        ip.sourceType = .photoLibrary
        ip.allowsEditing = true
        ip.setEditing(true, animated: true)
        ip.delegate = self
        
        return ip
        }()
    
    lazy var strDate: String = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy-HH:mm"
        let str = dateFormatter.string(from: Date())
            return str
        }()
    
    var image: UIImage?
    
//    var AWSUploadOperation: UploadOperation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: Selector(("keyboardWillShow:")), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: Selector(("keyboardWillHide:")), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let _ = resignFirstResponder()
        NotificationCenter.default.removeObserver(self)
    }
    
    
    //MARK: - IBActions
    @IBAction func setDescription(sender: UIBarButtonItem) {
        descriptionTextView.becomeFirstResponder()
    }
    
    @IBAction func setPhoto(sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    func isReadyToPost() -> Bool {
        if titleTextField.text!.count < 4 {
            handleError(title: "Error", message: "Length of the title cannot be less then 4 characters", okAction: nil)
        } else if descriptionTextView.text!.count < 4 {
            handleError(title: "Error", message: "Length of the description cannot be less then 4 characters", okAction: nil)
        } else if image == nil {
            handleError(title: "Error", message: "You didn't add an image to your post", okAction: nil)
        } else {
            return true
        }
        
        return false
    }
    
    func addNews() -> Post {
        let username = UserDefaults.standard.value(forKey: "username") as! String
        let title = titleTextField.text
        let details = descriptionTextView.text
        let imageLink = fileLink()

        let postDic = [
            "username": username,
            "title": title,
            "description": details,
            "image_link": imageLink
        ]
        
        let news = BackgroundDataWorker.sharedManager.save(json: postDic as NSDictionary, type: .News) as! News
        news.imageData?.imageDataWith(image: self.image!)
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
        self.view.isUserInteractionEnabled = false
        let news = addNews()
        
        let AWSUploadOperation = UploadOperation(image: self.image!, link: fileLink())
        let postUpload = PostUploadOperation(post: news)
        postUpload.addDependency(AWSUploadOperation)
        
        AWSUploadOperation.completionBlock = {
            print("AWS Success")
        }
        
        postUpload.completionBlock = {
            print("Upload success")
            DispatchQueue.main.async { [unowned self] in
                activityIndicator.stopAnimating()
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        
        operationQueue.addOperation(AWSUploadOperation)
        operationQueue.addOperation(postUpload)
    }
    
    func fileLink() -> String {
        let ownerName = UserDefaults.standard.value(forKey: "username") as! String
        
        return "\(ownerName)/\(correctFolderName(name: titleTextField.text!)!)/\(correctFolderName(name: strDate)!).png"
    }
    
    
    //MARK: - UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let img = editingInfo![UIImagePickerController.InfoKey.originalImage.rawValue] as! UIImage
        let rect = (editingInfo![UIImagePickerController.InfoKey.cropRect.rawValue] as! NSValue).cgRectValue
        
        self.image = img.imageByCroppingTo(rect: rect)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: Keyboard and touches
    func keyboardWillShow(sender: NSNotification) {
        guard let userInfo = sender.userInfo as NSDictionary? else {
            return
        }
        
        if let rect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue {
            UIView.animate(withDuration: 0.4, animations: { () -> Void in
                self.toolbarConstraint.constant = rect.height
                self.view.layoutIfNeeded()
            })
        }
        
    }
    
    func keyboardWillHide(sender: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.toolbarConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let _ = resignFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        self.descriptionTextView.resignFirstResponder()
        self.titleTextField.resignFirstResponder()
        return true
    }
    
}

