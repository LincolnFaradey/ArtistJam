//
//  ComposePostViewController.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 7/21/15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

import UIKit
import CoreLocation

class ComposePostViewController: UIViewController, MapViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let coreDataStack = CoreDataStack()
    let operationQueue = NSOperationQueue()
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var dataPicker: UIDatePicker!
    @IBOutlet weak var toolbarConstraint: NSLayoutConstraint!
    
    lazy var imagePicker: UIImagePickerController = {
        let ip = UIImagePickerController()
        ip.sourceType = .PhotoLibrary
        ip.allowsEditing = true
        ip.setEditing(true, animated: true)
        ip.delegate = self
        
        return ip
    }()
    
    var locationCoordinates: CLLocationCoordinate2D?
    var image: UIImage?
    
    var strDate: String?
    lazy var dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        
        return dateFormatter
    }()
    
    var AWSUploadOperation: UploadOperation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataPicker.minimumDate = NSDate()
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
    
    //MARK: - IBActions
    @IBAction func setDescription(sender: UIBarButtonItem) {
        descriptionTextView.becomeFirstResponder()
    }
    
    @IBAction func setDate(sender: UIBarButtonItem) {
        resignFirstResponder()
        UIView.animateWithDuration(0.3) { _ in
            self.toolbarConstraint.constant = self.dataPicker.frame.height
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func datePickerChanged(sender: UIDatePicker) {
        strDate = dateFormatter.stringFromDate(sender.date)
    }
    
    @IBAction func setLocation(sender: UIBarButtonItem) {
        performSegueWithIdentifier("createToMapSegue", sender: self)
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
        } else if strDate == nil {
            handleError("Error", message: "You didn't add a date to your post", okAction: nil)
        } else if locationCoordinates == nil {
            handleError("Error", message: "You didn't add a location to your post", okAction: nil)
        } else {
            return true
        }
        
        return false
    }
    
    func addEvent() -> Post {
        let event = NSEntityDescription.insertNewObjectForEntityForName("Event", inManagedObjectContext: coreDataStack.context) as! Event
        let artist = NSEntityDescription.insertNewObjectForEntityForName("Artist", inManagedObjectContext: self.coreDataStack.context) as! Artist
        
        artist.username = NSUserDefaults.standardUserDefaults().valueForKey("username") as? String
        artist.role = Role.Artist.rawValue
        
        event.artist = artist
        event.title = titleTextField.text
        event.details = descriptionTextView.text
        event.date = dateFormatter.dateFromString(strDate!)
        event.imageLink = fileLink()
        event.imageData?.imageDataWith(self.image!)
        event.latitude = locationCoordinates!.latitude
        event.longitude = locationCoordinates!.longitude
        self.coreDataStack.saveContext()
        
        return event
    }
    
    @IBAction func postEvent(sender: UIBarButtonItem) {
        if !isReadyToPost() {
            return
        }
        
        let event = addEvent()
        print("id: \(event.objectID)")
        
        AWSUploadOperation = UploadOperation(data: UIImagePNGRepresentation(self.image!)!, link: fileLink())
        let postUpload = PostUploadOperation(post: event)
        postUpload.addDependency(AWSUploadOperation!)
        
        AWSUploadOperation?.completionBlock = {
            print("AWS Success")
        }
        
        postUpload.completionBlock = {
            print("Upload success")
            dispatch_async(dispatch_get_main_queue(), {
                self.navigationController?.popToRootViewControllerAnimated(true)
                self.coreDataStack.saveContext()
            })
        }
        
        operationQueue.addOperation(AWSUploadOperation!)
        operationQueue.addOperation(postUpload)
    }
    
    func fileLink() -> String {
        let ownerName = NSUserDefaults.standardUserDefaults().valueForKey("username") as! String
        
        return "\(ownerName)/\(correctFolderName(titleTextField.text!)!)/\(correctFolderName(strDate!)!).png"
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "createToMapSegue" {
            let vc = segue.destinationViewController as! MapViewController
            vc.delegate = self
        }
    }
    
    //MARK: - UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let img = editingInfo![UIImagePickerControllerOriginalImage] as! UIImage
        let rect = (editingInfo![UIImagePickerControllerCropRect] as! NSValue).CGRectValue()
        
        self.image = imageByCropping(img, rect: rect)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - MapViewControllerDelegate
    func controller(controller: MapViewController, didAcceptCoordinate coordinates: CLLocationCoordinate2D) {
        locationCoordinates = coordinates
        print("Coordinates \(locationCoordinates)")
    }
}
