//
//  ANRegestrationViewController.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 7/13/15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

import UIKit

class RegestrationViewController: UIViewController {
    var operationQueue: NSOperationQueue {
        get {
            let queue = NSOperationQueue()
            queue.maxConcurrentOperationCount = 1
            return queue
        }
    }
    
    @IBOutlet weak var authView: UIView!
    @IBOutlet weak var questionView: UIView!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var horizontalCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttomTrailingConstraint: NSLayoutConstraint!
    
    var selectedIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
    }
    
    override func viewWillAppear(animated: Bool) {
        self.questionView.alpha = 0.0
        self.authView.alpha = 0.0
        self.navigationController?.navigationBarHidden = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillBeShown:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animateWithDuration(0.4) { () -> Void in
            self.questionView.alpha = 1.0
            self.authView.alpha = 0.0
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func loginButtonWasPressed(sender: UIButton) {
        sender.userInteractionEnabled = false
        let dictionary = [
            "role": self.selectedIndex == 0 ? "fan" : "artist",
            "username": self.loginTextField.text!,
            "email": self.emailTextField.text!,
            "password": self.passwordTextField!.text!.MD5()
        ]
        let authOperation = AuthOperation(json: dictionary, route: Route.SignUp)
        authOperation.completionBlock = {
            sender.userInteractionEnabled = true
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.navigationController?.popViewControllerAnimated(true)
            })
        }
        authOperation.cancellationBlock = {
            sender.userInteractionEnabled = true
        }
        
        self.operationQueue.addOperation(authOperation)
    }
    
    @IBAction func roleChooseButtonWasPressed(sender: UIButton) {
        self.selectedIndex = sender.tag
        UIView.animateWithDuration(0.4) { () -> Void in
            self.questionView.alpha = 0.0
            self.authView.alpha = 1.0
        }
    }
    
    func keyboardWillBeShown(sender: NSNotification) {
        guard let userInfo = sender.userInfo as NSDictionary? else {
            return
        }
        if let rect = userInfo[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue {
            let kbSize = rect.height
            
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                self.horizontalCenterConstraint.priority = 1
                self.buttomTrailingConstraint.constant = kbSize
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func keyboardWillBeHidden(sender: NSNotification) {
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.horizontalCenterConstraint.priority = UILayoutPriorityDefaultHigh
            self.view.layoutIfNeeded()
        })
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }

}
