//
//  FormViewController.swift
//  PoseNet
//
//  Created by Sean Harris on 22/04/2021.
//  Copyright © 2021 tensorflow. All rights reserved.
//

import FirebaseFirestore
import UIKit

class FormViewController: UIViewController {

    @IBOutlet weak var setUserButton: UIButton!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var practiceTextField: UITextField!
    @IBOutlet weak var injuryPicker: UIPickerView!
    
    var pickerText = "Right Shoulder"
    
    private let injuries = ["Right Shoulder", "Left Shoulder"]

    override func viewDidLoad() {
        super.viewDidLoad()
        injuryPicker.dataSource = self
        injuryPicker.delegate = self
    }
    
    @IBAction func didTapSetUserButton(_ sender: Any) {
        // Instantiate a user variable using the fields provided
        user = User(firstName: firstNameTextField.text!, surname: surnameTextField.text!, practice: practiceTextField.text!, injury: pickerText)
        // Establish the database connection
        let database = Firestore.firestore()
        // Create a reference to the document where the user's progress report should be stored
        let docRef = database.collection("/\(user.practice)/Database/Users/\(user.firstName) \(user.surname)/Injuries").document("\(user.injury)")
        
        // Check if the user already has previous progress, if not create the required document
        docRef.getDocument { (document, error) in
           if let document = document, document.exists {
             // Do nothing the user has used the app before and has a database set up
           } else {
             // Create the Progress document for the user by initialising an empty array
             docRef.setData(["Progress":[]])
          }
        }
        
        if #available(iOS 13.0, *) {
          // Instantiate the identified view controller from the storyboard
          let vc = storyboard?.instantiateViewController(identifier: "record") as! ViewController
          // Push controller to navigation stack to change view
          navigationController?.pushViewController(vc, animated: true)
        } else {
          return
      }
    }
}

// Both extensions contain required functions to implement the picker on the form.
extension FormViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
      return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      return injuries.count
    }
    

}

extension FormViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return injuries[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerText = injuries[row]
    }
}
