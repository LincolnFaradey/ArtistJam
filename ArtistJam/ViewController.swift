//
//  ViewController.swift
//  ArtistJam
//
//  Created by Andrei Nechaev on 7/6/15.
//  Copyright © 2015 Andrei Nechaev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var operationQueue: OperationQueue {
            get {
                let queue = OperationQueue()
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        
        NotificationCenter.default.addObserver(self, selector: Selector(("keyboardWillBeShown:")), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: Selector(("keyboardWillBeHidden:")), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginButtonWasPressed(sender: UIButton) {
        sender.isUserInteractionEnabled = false
        let dictionary = [
            "username": loginTextField.text!,
            "password": passwordTextField.text!.MD5()
        ]
        UserDefaults.standard.setValue(dictionary["username"], forKey: "username")
        let authOperation = AuthOperation(json: dictionary as NSDictionary, route: .SignIn)
        authOperation.completionBlock = {
            sender.isUserInteractionEnabled = true
            
            DispatchQueue.main.async { [unowned self] in
                self.performSegue(withIdentifier: "loginToMain", sender: self)
            }
        }
        
        authOperation.cancellationBlock = {
            print("Canceled")
            sender.isUserInteractionEnabled = true
        }
        
        operationQueue.addOperation(authOperation)
    }
    
    //MARK: - UIKeyboard notifications
    func keyboardWillBeShown(sender: NSNotification) {
        guard let userInfo = sender.userInfo as NSDictionary? else {
            return
        }

        if let rect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue {
            let kbSize = rect.height

            UIView.animate(withDuration: 0.3, animations: { [unowned self] in
                self.horizontalCenterConstraint.priority = UILayoutPriority.defaultLow
                self.buttomTrailingConstraint.constant = kbSize
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func keyboardWillBeHidden(sender: NSNotification) {
        UIView.animate(withDuration: 0.3, animations: { [unowned self] in
            self.horizontalCenterConstraint.priority = UILayoutPriority.defaultHigh
            self.view.layoutIfNeeded()
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

