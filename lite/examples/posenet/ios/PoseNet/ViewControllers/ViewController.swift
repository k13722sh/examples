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
import UIKit
import os

class ViewController: UIViewController {
    // MARK: Storyboards Connections
  @IBOutlet weak var previewView: PreviewView!

  @IBOutlet weak var overlayView: OverlayView!

  @IBOutlet weak var resumeButton: UIButton!
  @IBOutlet weak var cameraUnavailableLabel: UILabel!

  @IBOutlet weak var tableView: UITableView!
  
  @IBOutlet weak var startStopButton: UIButton!

  //@IBOutlet weak var threadCountLabel: UILabel!
  //@IBOutlet weak var threadCountStepper: UIStepper!

  //@IBOutlet weak var delegatesControl: UISegmentedControl!

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
    
    //threadCountLabel.isHidden = true
    //threadCountStepper.isHidden = true
    //delegatesControl.isHidden = true

    // MARK: UI Initialization
    // Setup thread count stepper with white color.
    // https://forums.developer.apple.com/thread/121495
    /*threadCountStepper.setDecrementImage(
      threadCountStepper.decrementImage(for: .normal), for: .normal)
    threadCountStepper.setIncrementImage(
      threadCountStepper.incrementImage(for: .normal), for: .normal)
    // Setup initial stepper value and its label.
    threadCountStepper.value = Double(Constants.defaultThreadCount)
    threadCountLabel.text = Constants.defaultThreadCount.description

    // Setup segmented controller's color.
    delegatesControl.setTitleTextAttributes(
      [NSAttributedString.Key.foregroundColor: UIColor.lightGray],
      for: .normal)
    delegatesControl.setTitleTextAttributes(
      [NSAttributedString.Key.foregroundColor: UIColor.black],
      for: .selected)
    // Remove existing segments to initialize it with `Delegates` entries.
    delegatesControl.removeAllSegments()
    Delegates.allCases.forEach { delegate in
      delegatesControl.insertSegment(
        withTitle: delegate.description,
        at: delegate.rawValue,
        animated: false)
    }
    delegatesControl.selectedSegmentIndex = 0*/
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

  // MARK: Button Actions
  /*@IBAction func didChangeThreadCount(_ sender: UIStepper) {
    let changedCount = Int(sender.value)
    if threadCountLabel.text == changedCount.description {
      return
    }

    do {
      modelDataHandler = try ModelDataHandler(threadCount: changedCount, delegate: delegate)
    } catch let error {
      fatalError(error.localizedDescription)
    }
    threadCount = changedCount
    threadCountLabel.text = changedCount.description
    os_log("Thread count is changed to: %d", threadCount)
  }*/

  /*@IBAction func didChangeDelegate(_ sender: UISegmentedControl) {
    guard let changedDelegate = Delegates(rawValue: delegatesControl.selectedSegmentIndex) else {
      fatalError("Unexpected value from delegates segemented controller.")
    }
    do {
      modelDataHandler = try ModelDataHandler(threadCount: threadCount, delegate: changedDelegate)
    } catch let error {
      fatalError(error.localizedDescription)
    }
    delegate = changedDelegate
    os_log("Delegate is changed to: %s", delegate.description)
  }*/

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
        pastAngles.append(maxAngle)
      }
      //print(pastAngles)
    } else {
      recordingData = true
      //startStopButton.setTitle("STOP", for: UIControl.State.normal)
    }
    //print(recordingData)
  }
  
  @IBAction func didTapProgressButton() {
    if #available(iOS 13.0, *) {
        let vc = storyboard?.instantiateViewController(identifier: "progress") as! ProgressViewController
        navigationController?.pushViewController(vc, animated: true)
    } else {
        return
    }
  }
    
  /*@IBAction func didTapVideoButton() {
    let vc = UIImagePickerController()
    vc.sourceType = .savedPhotosAlbum
    vc.delegate = self
    // Need to explicitly set media type in order to select video
    vc.mediaTypes = ["public.movie"]
    present(vc, animated: true)
    
  }*/

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
    // Handles session run time error by updating the UI and providing a button if session can be
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

    // Run PoseNet model.
    // MARK: Model Run Here?
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
    //print("#Sections:")
    //print(InferenceSections.allCases.count)
    return InferenceSections.allCases.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let section = InferenceSections(rawValue: section) else {
      return 0
    }
    //print("Section:")
    //print(section)
    //print(section.subcaseCount)
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
    /*
    case .Time:
      guard let row = ProcessingTimes(rawValue: indexPath.row) else {
        return cell
      }
      var time: Double
      switch row {
      case .InferenceTime:
        time = data.times.inference
      }
      fieldName = row.description
      info = String(format: "%.2fms", time) */
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
