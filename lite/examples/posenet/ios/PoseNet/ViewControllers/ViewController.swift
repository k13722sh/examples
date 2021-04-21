// Copyright 2019 The TensorFlow Authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import AVFoundation
import AVKit
import FirebaseFirestore
import UIKit
import os

class ViewController: UIViewController {
  // STRINGS FOR TESTING (WILL BE PASSED FROM A FORM)
  let practioner = "Shawford House"
  let firstName = "Terry"
  let lastName = "Cruise"
  let injury = "Right Shoulder"
  
  // MARK: Storyboards Connections
  @IBOutlet weak var previewView: PreviewView!
  @IBOutlet weak var overlayView: OverlayView!
  @IBOutlet weak var resumeButton: UIButton!
  @IBOutlet weak var cameraUnavailableLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var startStopButton: UIButton!

  // MARK: ModelDataHandler traits
  var threadCount: Int = Constants.defaultThreadCount
  var delegate: Delegates = Constants.defaultDelegate
  var isSourceVideo: Bool = false // Variable used to determine whether camera feed should be used
  var test: Int = 0

  // MARK: Result Variables
  // Inferenced data to render.
  private var inferencedData: InferencedData?

  // Relative location of `overlayView` to `previewView`.
  private var overlayViewFrame: CGRect?
  private var previewViewFrame: CGRect?

  // MARK: Controllers that manage functionality
  // Handles all the camera related functionality
  private lazy var cameraCapture = CameraFeedManager(previewView: previewView)

  // Handles all data preprocessing and makes calls to run inference.
  private var modelDataHandler: ModelDataHandler?

  // MARK: View Handling Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    
    do {
      modelDataHandler = try ModelDataHandler()
    } catch let error {
      fatalError(error.localizedDescription)
    }

    cameraCapture.delegate = self
    tableView.delegate = self
    tableView.dataSource = self
    
    // Initialise an array of ROMEntry (date, angle) values for testing
    var dateInSeconds = Double(620672532)
    for x in 1..<5  {
      // Set the date of the measurement
      let dateOfMeasurement = Date(timeIntervalSinceReferenceDate: dateInSeconds)
      // Create arbitrary angle value for filling array
      let rom: CGFloat = 10.0 * CGFloat(x)
      // Create a ROMEntry and add that value to testROMEntry
      let entry = ROMEntry(date: dateOfMeasurement, angle: rom)
      testROMEntry.append(entry)
      // Update value of dateInSeconds so next iteration of the loop creates an entry for a month later
      dateInSeconds = dateInSeconds + (4 * 604800)
    }
    
    // Create a DateFormatter toprinnt out the values of the dates (check the code is working)
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    let romArraySize = (testROMEntry.count)
    for x in 0..<romArraySize {
      print(formatter.string(from: testROMEntry[x].date), "\t", testROMEntry[x].angle)
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    cameraCapture.checkCameraConfigurationAndStartSession()
    
  }
    
  override func viewWillDisappear(_ animated: Bool) {
    cameraCapture.stopSession()
  }

  override func viewDidLayoutSubviews() {
    overlayViewFrame = overlayView.frame
    previewViewFrame = previewView.frame
  }

  @IBAction func didTapResumeButton(_ sender: Any) {
    cameraCapture.resumeInterruptedSession { complete in

      if complete {
        self.resumeButton.isHidden = true
        self.cameraUnavailableLabel.isHidden = true
      } else {
        self.presentUnableToResumeSessionAlert()
      }
    }
  }
  
  @IBAction func didStartStopSession() {
    //print(recordingData)
    if recordingData == true {
      //print(pastAngles)
      // If data is currently being recorded stop the session by setting recording data to false
      recordingData = false
  
      // Save the maximum angle found in the session if there was one
      if maxAngle > 0.0 {
        let entry = ROMEntry(date: Date(), angle: maxAngle)
        testROMEntry.append(entry)
        saveAngle(angle: maxAngle)
      }
      //print(pastAngles)
    } else {
      // If not currently recording data begin recording data
      recordingData = true
    }
  }
  
  @IBAction func didTapProgressButton() {
    if #available(iOS 13.0, *) {
        let vc = storyboard?.instantiateViewController(identifier: "progress") as! ProgressViewController
        navigationController?.pushViewController(vc, animated: true)
    } else {
        return
    }
  }
  
  func saveAngle(angle: CGFloat) {
    // Create a reference to the database
    let database = Firestore.firestore()

    // Get today's date and create a formatter so that it can be converted to a string.
    let today = Date()
    let formatter = DateFormatter()
    formatter.dateStyle = .short

    // Add the max angle achieved on the current date to the database. If the client has used the app before this will update an existing document, otherwise a new one will be created
    database.collection("/\(practioner)/Database/Users/\(firstName) \(lastName)/Injuries").document("\(injury) Progress").setData([formatter.string(from: today) : angle], merge: true)
    
    let entryData: [String : Any] = [
       "Array" : [["Date": today,"Angle": angle], ["Date": today,"Angle": angle]]
    ]
    
    database.collection("testit").document("Injuries").setData(entryData, merge: true) { err in
      if let err = err {
        print("Error writing document: \(err)")
      } else {
        print("Document successfully written!")
      }
    }
    
    //database.collection("testit").document("Injuries").updateData(["regions": FieldValue.arrayUnion(["Date": today,"Angle":angle])])
    
    // This will still create the array if it doesn not exist already
    database.collection("testit").document("Injuries").updateData(["regions": FieldValue.arrayUnion([["Date": today,"Angle": angle]])]) { err in
      if let err = err {
        print("Error writing document: \(err)")
      } else {
        print("Document successfully written!")
      }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
  }

  func presentUnableToResumeSessionAlert() {
    let alert = UIAlertController(
      title: "Unable to Resume Session",
      message: "There was an error while attempting to resume session.",
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

    self.present(alert, animated: true)
  }
}



// MARK: - CameraFeedManagerDelegate Methods
extension ViewController: CameraFeedManagerDelegate {
  func cameraFeedManager(_ manager: CameraFeedManager, didOutput pixelBuffer: CVPixelBuffer) {
    runModel(on: pixelBuffer)
  }

  // MARK: Session Handling Alerts
  func cameraFeedManagerDidEncounterSessionRunTimeError(_ manager: CameraFeedManager) {
    // Handles session run time error by updating the UI and providing a button if session angle: <#CGFloat#>can be
    // manually resumed.
    self.resumeButton.isHidden = false
  }

  func cameraFeedManager(
    _ manager: CameraFeedManager, sessionWasInterrupted canResumeManually: Bool
  ) {
    // Updates the UI when session is interupted.
    if canResumeManually {
      self.resumeButton.isHidden = false
    } else {
      self.cameraUnavailableLabel.isHidden = false
    }
  }

  func cameraFeedManagerDidEndSessionInterruption(_ manager: CameraFeedManager) {
    // Updates UI once session interruption has ended.
    self.cameraUnavailableLabel.isHidden = true
    self.resumeButton.isHidden = true
  }

  func presentVideoConfigurationErrorAlert(_ manager: CameraFeedManager) {
    let alertController = UIAlertController(
      title: "Confirguration Failed", message: "Configuration of camera has failed.",
      preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    alertController.addAction(okAction)

    present(alertController, animated: true, completion: nil)
  }

  func presentCameraPermissionsDeniedAlert(_ manager: CameraFeedManager) {
    let alertController = UIAlertController(
      title: "Camera Permissions Denied",
      message:
        "Camera permissions have been denied for this app. You can change this by going to Settings",
      preferredStyle: .alert)

    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    let settingsAction = UIAlertAction(title: "Settings", style: .default) { action in
      if let url = URL.init(string: UIApplication.openSettingsURLString) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
      }
    }

    alertController.addAction(cancelAction)
    alertController.addAction(settingsAction)

    present(alertController, animated: true, completion: nil)
  }

  @objc func runModel(on pixelBuffer: CVPixelBuffer) {
    guard let overlayViewFrame = overlayViewFrame, let previewViewFrame = previewViewFrame
    else {
      return
    }
    // To put `overlayView` area as model input, transform `overlayViewFrame` following transform
    // from `previewView` to `pixelBuffer`. `previewView` area is transformed to fit in
    // `pixelBuffer`, because `pixelBuffer` as a camera output is resized to fill `previewView`.
    // https://developer.apple.com/documentation/avfoundation/avlayervideogravity/1385607-resizeaspectfill
    let modelInputRange = overlayViewFrame.applying(
      previewViewFrame.size.transformKeepAspect(toFitIn: pixelBuffer.size))

    // Run PoseNet model
    guard
      let (result, times) = self.modelDataHandler?.runPoseNet(
        on: pixelBuffer,
        from: modelInputRange,
        to: overlayViewFrame.size)
    else {
      os_log("Cannot get inference result.", type: .error)
      return
    }

    // Udpate `inferencedData` to render data in `tableView`.
    inferencedData = InferencedData(score: result.score, angle: result.angle, times: times)

    // Draw result.
    DispatchQueue.main.async {
      self.tableView.reloadData()
      // If score is too low, clear result remaining in the overlayView.
      if result.score < minimumScore {
        self.clearResult()
        return
      }
      self.drawResult(of: result)
    }
  }

  func drawResult(of result: Result) {
    self.overlayView.dots = result.dots
    self.overlayView.lines = result.lines
    self.overlayView.setNeedsDisplay()
  }

  func clearResult() {
    self.overlayView.clear()
    self.overlayView.setNeedsDisplay()
  }
}

// MARK: - TableViewDelegate, TableViewDataSource Methods
extension ViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return InferenceSections.allCases.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let section = InferenceSections(rawValue: section) else {
      return 0
    }
    return section.subcaseCount
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ScoreCell") as! InfoCell
    guard let section = InferenceSections(rawValue: indexPath.section) else {
      return cell
    }
    guard let data = inferencedData else { return cell }

    var fieldName: String
    var info: String

    switch section {
    case .Score:
        fieldName = section.description
        info = String(format: "%.3f", data.score) // data.score vs angle
    case .Angle:
        fieldName = section.description
        info = String(format: "%.3f", data.angle) // data.score vs angle
    case .MaxAngle:
        fieldName = section.description
        info = String(format: "%.3f", maxAngle) // data.score vs angle
    case .HighScore:
        fieldName = section.description
        info = String(format: "%.3f", highScore) // data.score vs angle
    }

    cell.fieldNameLabel.text = fieldName
    cell.infoLabel.text = info

    return cell
  }

 /* func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    guard let section = InferenceSections(rawValue: indexPath.section) else {
      return 0
    }

    var height = Traits.normalCellHeight
    if indexPath.row == section.subcaseCount - 1 {
      height = Traits.separatorCellHeight + Traits.bottomSpacing
    }
    return height
  }*/

}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("\(info)")
        
        if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL {
            print("Ta-da:")
            print(videoURL)
            //imageView.image = previewImageFromVideo(url: videoURL)!
            //imageView.contentMode = .scaleAspectFit
            
            // Add code to use video input
            isSourceVideo = true
            cameraCapture.stopSession()
            let video = AVPlayer(url: (videoURL as URL))
            // I want to add AVPlayer to the previewView layer (i.e where the camera feed plays)
            //previewView.previewLayer = AVPlayerLayer(player: video)
            //layer.frame = view.bounds
            //view.layer.insertSublayer(layer, at: 1)
            
            video.play()
    
            picker.dismiss(animated: true, completion: nil)

        } else {
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


// MARK: - Private enums
/// UI coinstraint values
fileprivate enum Traits {
  static let normalCellHeight: CGFloat = 35.0
  static let separatorCellHeight: CGFloat = 25.0
  static let bottomSpacing: CGFloat = 30.0
}

fileprivate struct InferencedData {
  var score: Float
  var angle: CGFloat
  var times: Times
}

/// Type of sections in Info Cell
fileprivate enum InferenceSections: Int, CaseIterable {
    case Score
    case Angle
    case MaxAngle
    case HighScore
    //case Time

  var description: String {
    switch self {
    case .Score:
        return "Score" // Score vs Angle
    case .Angle:
        return "Angle"
    case .MaxAngle:
        return "MaxAngle"
    case .HighScore:
        return "Highest Score"
    /*
    case .Time:
        return "Processing Time"
    */
    }
  }

  var subcaseCount: Int {
    switch self {
    case .Score:
        return 1
    case .Angle:
        return 1
    case .MaxAngle:
        return 1
    case .HighScore:
        return 1
    /*
    case .Time:
        return ProcessingTimes.allCases.count
    */
    }
  }
}

/// Type of processing times in Time section in Info Cell
fileprivate enum ProcessingTimes: Int, CaseIterable {
  case InferenceTime

  var description: String {
    switch self {
    case .InferenceTime:
      return "Inference Time"
    }
  }
}
