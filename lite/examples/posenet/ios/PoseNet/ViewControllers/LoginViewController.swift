//
//  LoginViewController.swift
//  PoseNet
//
//  Created by Sean Harris on 19/04/2021.
//  Copyright © 2021 tensorflow. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var goToSignUpButton: UIButton!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func goToSignUpButtonTapped(_ sender: Any) {
      if #available(iOS 13.0, *) {
        let vc = storyboard?.instantiateViewController(identifier: "signup") as! SignUpViewController
        navigationController?.pushViewController(vc, animated: true)
      } else {
        return
      }
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
      if #available(iOS 13.0, *) {
        let vc = storyboard?.instantiateViewController(identifier: "record") as! ViewController
        navigationController?.pushViewController(vc, animated: true)
      } else {
        return
      }
    }
    
}
