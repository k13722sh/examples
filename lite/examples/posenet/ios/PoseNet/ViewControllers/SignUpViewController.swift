//
//  SignUpViewController.swift
//  PoseNet
//
//  Created by Sean Harris on 19/04/2021.
//  Copyright © 2021 tensorflow. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var goToLoginPageButton: UIButton!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func goToLoginButtonTapped(_ sender: Any) {
      if #available(iOS 13.0, *) {
        let vc = storyboard?.instantiateViewController(identifier: "login") as! LoginViewController
        navigationController?.pushViewController(vc, animated: true)
      } else {
        return
      }
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
      if #available(iOS 13.0, *) {
        let vc = storyboard?.instantiateViewController(identifier: "record") as! ViewController
        navigationController?.pushViewController(vc, animated: true)
      } else {
        return
      }
    }
    
}
