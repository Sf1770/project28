//
//  ViewController.swift
//  project28
//
//  Created by Sabrina Fletcher on 6/22/18.
//  Copyright © 2018 Sabrina Fletcher. All rights reserved.
//

import LocalAuthentication
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var secret: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        title = "Nothing to see here"
        
    }

    @objc func adjustForKeyboard(notification: Notification){
        let userInfo = notification.userInfo!
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide{
            secret.contentInset = UIEdgeInsets.zero
        } else{
            secret.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        secret.scrollIndicatorInsets = secret.contentInset
        
        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
    }
    
    @IBAction func authenticateTapped(_ sender: UIButton) {
        //unlockSecretMessage()
        let context = LAContext()
        var error: NSError?
        
        #if targetEnvironment(simulator)
        //runs this code if it is a simulator running the program
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
                if true{
                    //hack for simulator in order to eliminate the need for biometrics
                    self.unlockSecretMessage()
                }
            }
        #else
        //runs code if real device is connected
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
            let reason = "To view the secrets you've locked inside"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [unowned self] (success, authenticationError) in
                DispatchQueue.main.async {
                    if success {
                        self.unlockSecretMessage()
                    } else{
                        let ac = UIAlertController(title: "Authentication failed", message: "You could not be verified; please try again.", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "Ok", style: .default))
                        self.present(ac, animated: true)
                    }
                }
            }
        } else{
            //no biometry
            let ac = UIAlertController(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default))
            self.present(ac, animated: true)
        }
    #endif
    }
    
    func unlockSecretMessage() {
        secret.isHidden = false
        title = "Secret stuff!"
        
        if let text = KeychainWrapper.standard.string(forKey: "SecretMessage"){
            secret.text = text
        }
    }
    
    @objc func saveSecretMessage(){
        if !secret.isHidden {
            //saves secret in keychain
            _ = KeychainWrapper.standard.set(secret.text, forKey: "SecretMessage")
            secret.resignFirstResponder()
            secret.isHidden = true
            title = "Nothing to see here"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

