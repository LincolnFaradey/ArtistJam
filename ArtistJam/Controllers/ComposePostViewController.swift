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
    let operationQueue = OperationQueue()
    let activityIndicator = UIActivityIndicatorView()
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var dataPicker: UIDatePicker!
    @IBOutlet weak var toolbarConstraint: NSLayoutConstraint!
    
    lazy var imagePicker: UIImagePickerController = {
        let ip = UIImagePickerController()
        ip.sourceType = .photoLibrary
        ip.allowsEditing = true
        ip.setEditing(true, animated: true)
        ip.delegate = self
        
        return ip
    }()
    
    var locationCoordinates: CLLocationCoordinate2D?
    var image: UIImage?
    
    var strDate: String?
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LL dd, yyyy HH:mm"
        
        return dateFormatter
    }()
    
    var AWSUploadOperation: UploadOperation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataPicker.minimumDate = Date()
        
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
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
    
    //MARK: - IBActions
    @IBAction func setDescription(sender: UIBarButtonItem) {
        descriptionTextView.becomeFirstResponder()
    }
    
    @IBAction func setDate(sender: UIBarButtonItem) {
        let _ = resignFirstResponder()
        UIView.animate(withDuration: 0.3) {
            self.toolbarConstraint.constant = self.dataPicker.frame.height
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func datePickerChanged(sender: UIDatePicker) {
        strDate = dateFormatter.string(from: sender.date)
    }
    
    @IBAction func setLocation(sender: UIBarButtonItem) {
        performSegue(withIdentifier: "createToMapSegue", sender: self)
    }
    
    @IBAction func setPhoto(sender: UIBarButtonItem) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    func isReadyToPost() -> Bool {
        if titleTextField.text!.count < 4 {
            handleError(title: "Error", message: "Length of the title cannot be less than 4 characters", okAction: nil)
        } else if descriptionTextView.text!.count < 4 {
            handleError(title: "Error", message: "Length of the description cannot be less than 4 characters", okAction: nil)
        } else if image == nil {
            handleError(title: "Error", message: "You didn't add an image to your post", okAction: nil)
        } else if strDate == nil {
            handleError(title: "Error", message: "You didn't add a date to your post", okAction: nil)
        } else if locationCoordinates == nil {
            handleError(title: "Error", message: "You didn't add a location to your post", okAction: nil)
        } else {
            return true
        }
        
        return false
    }
    
    func addEvent() -> Post {
        let username = UserDefaults.standard.value(forKey: "username") as! String

        let eventDic: [String: AnyObject] = [
            "username": username as AnyObject,
            "title": titleTextField.text! as AnyObject,
            "description": descriptionTextView.text! as AnyObject,
            "image_link": fileLink() as AnyObject,
            "when": strDate! as AnyObject,
            "lat": locationCoordinates!.latitude as AnyObject,
            "lon": locationCoordinates!.longitude as AnyObject
        ]
        
        let event = BackgroundDataWorker.sharedManager.save(json: eventDic as NSDictionary, type: .Event) as! Event
        event.imageData?.imageDataWith(image: self.image)
        BackgroundDataWorker.sharedManager.saveContext()
        
        return event
    }
    
    @IBAction func postEvent(sender: UIBarButtonItem) {
        if !isReadyToPost() {
            return
        }
        
        activityIndicator.startAnimating()
        self.view.isUserInteractionEnabled = false
        let event = addEvent()
        print("id: \(event.objectID)")
        
        AWSUploadOperation = UploadOperation(image: self.image!, link: fileLink())
        let postUpload = PostUploadOperation(post: event)
        postUpload.addDependency(AWSUploadOperation!)
        
        AWSUploadOperation?.completionBlock = {
            print("AWS Success")
        }
        
        postUpload.completionBlock = {
            print("Upload success")
            DispatchQueue.main.async {[unowned self] in
                self.activityIndicator.stopAnimating()
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        postUpload.cancellationBlock = {
            print("cancelled")
            self.view.isUserInteractionEnabled = false
        }
        
        operationQueue.addOperation(AWSUploadOperation!)
        operationQueue.addOperation(postUpload)
    }
    
    func fileLink() -> String {
        let ownerName = UserDefaults.standard.value(forKey: "username") as! String
        
        return "\(ownerName)/\(correctFolderName(name: titleTextField.text!)!)/\(correctFolderName(name: strDate!)!).png"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createToMapSegue" {
            let vc = segue.destination as! MapViewController
            vc.delegate = self
        }
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
    
    //MARK: - MapViewControllerDelegate
    func controller(controller: MapViewController, didAcceptCoordinate coordinates: CLLocationCoordinate2D) {
        locationCoordinates = coordinates
        print("Coordinates \(String(describing: locationCoordinates))")
    }
}
