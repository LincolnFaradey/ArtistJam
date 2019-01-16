//
//  ANRegestrationViewController.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 7/13/15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

import UIKit

class RegestrationViewController: UIViewController {
    var operationQueue: OperationQueue {
        get {
            let queue = OperationQueue()
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
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.questionView.alpha = 0.0
        self.authView.alpha = 0.0
        self.navigationController?.isNavigationBarHidden = false
        NotificationCenter.default.addObserver(self, selector:Selector(("keyboardWillBeShown:")), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:Selector(("keyboardWillBeHidden:")), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.4) { () -> Void in
            self.questionView.alpha = 1.0
            self.authView.alpha = 0.0
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func loginButtonWasPressed(sender: UIButton) {
        sender.isUserInteractionEnabled = false
        let dictionary = [
            "role": self.selectedIndex == 0 ? "fan" : "artist",
            "username": self.loginTextField.text!,
            "email": self.emailTextField.text!,
            "password": self.passwordTextField!.text!.MD5()
        ]
        let authOperation = AuthOperation(json: dictionary as NSDictionary, route: Route.SignUp)
        authOperation.completionBlock = {
            sender.isUserInteractionEnabled = true
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
        authOperation.cancellationBlock = {
            sender.isUserInteractionEnabled = true
        }
        
        self.operationQueue.addOperation(authOperation)
    }
    
    @IBAction func roleChooseButtonWasPressed(sender: UIButton) {
        self.selectedIndex = sender.tag
        UIView.animate(withDuration: 0.4) { () -> Void in
            self.questionView.alpha = 0.0
            self.authView.alpha = 1.0
        }
    }
    
    func keyboardWillBeShown(sender: NSNotification) {
        guard let userInfo = sender.userInfo as NSDictionary? else {
            return
        }
        if let rect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue {
            let kbSize = rect.height
            
            UIView.animate(withDuration: 0.4, animations: { () -> Void in
                self.horizontalCenterConstraint.priority = UILayoutPriority(rawValue: 1)
                self.buttomTrailingConstraint.constant = kbSize
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func keyboardWillBeHidden(sender: NSNotification) {
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.horizontalCenterConstraint.priority = UILayoutPriority.defaultHigh
            self.view.layoutIfNeeded()
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
