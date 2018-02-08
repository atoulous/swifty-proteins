//
//  LoginViewController.swift
//  Swifty_Proteins
//
//  Created by Sloven GRACIET on 2/7/18.
//  Copyright © 2018 Sloven GRACIET. All rights reserved.
//

import UIKit
import LocalAuthentication

class LoginViewController: UIViewController {

    let authenticationContext = LAContext()
    var error:NSError?
    
    
    @IBOutlet weak var nonTouchIDLabel: UILabel!
    @IBOutlet weak var logbutton: UIButton!
    @IBAction func logButton(_ sender: UIButton) {
        
        
        authenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Only Duoquadra  are allowed",
            reply: { [unowned self] (success, error) -> Void in
                
                if( success ) {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "ProteinListSegue", sender: self)
                    }
                }else {
                    if let error = error {
                        let message = error.localizedDescription
                        self.showAlertViewAfterEvaluatingPolicyWithMessage(message: message)
                        
                    }
                    
                }
                
        })
        
    }
   
    
    func showAlertViewAfterEvaluatingPolicyWithMessage( message:String ){
        
        showAlertWithTitle(title: "Error", message: message)
    }
  
    func showAlertWithTitle( title:String, message:String ) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.view.backgroundColor = UIColor.red
        let okAction = UIAlertAction(title: "Ok ", style: .default, handler: nil)
        alertVC.addAction(okAction)
        DispatchQueue.main.async {
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.gray
        guard authenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            logbutton.isHidden = true
            DispatchQueue.main.async {
                self.nonTouchIDLabel.text = "logged in ..."
                sleep(2)
                self.performSegue(withIdentifier: "ProteinListSegue", sender: self)
            }
            return
        }

    
    }
    
  
   

}
