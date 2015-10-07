//
//  ViewController.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 7/6/15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var operationQueue: NSOperationQueue {
            get {
                let queue = NSOperationQueue()
                queue.maxConcurrentOperationCount = 1
                return queue
            }
        }
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var horizontalCenterConstraint: NSLayoutConstraint!

    @IBOutlet weak var buttomTrailingConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeShown:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginButtonWasPressed(sender: UIButton) {
        self.performSegueWithIdentifier("loginToMain", sender: self)
        return
        sender.userInteractionEnabled = false
        let dictionary = [
            "username": loginTextField.text!,
            "password": passwordTextField.text!.MD5()
        ]
        NSUserDefaults.standardUserDefaults().setValue(dictionary["username"], forKey: "username")
        let authOperation = AuthOperation(json: dictionary, route: .SignIn)
        authOperation.completionBlock = {
            sender.userInteractionEnabled = true
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.performSegueWithIdentifier("loginToMain", sender: self)
            })
        }
        authOperation.cancelationBlock = {
            sender.userInteractionEnabled = true
        }
        
        operationQueue.addOperation(authOperation)
    }
    
    //MARK: - UIKeyboard notifications
    func keyboardWillBeShown(sender: NSNotification) {
        guard let userInfo = sender.userInfo as NSDictionary? else {
            return
        }

        if let rect = userInfo[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue {
            let kbSize = rect.height

            UIView.animateWithDuration(0.4, animations: { () -> Void in
                self.horizontalCenterConstraint.priority = UILayoutPriorityDefaultLow
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

