//
//  ProgressViewController.swift
//  PoseNet
//
//  Created by Sean Harris on 08/04/2021.
//  Copyright © 2021 tensorflow. All rights reserved.
//
import Charts
import FirebaseFirestore
import FirebaseFirestoreSwift
import UIKit

class ProgressViewController: UIViewController, ChartViewDelegate {

  @IBOutlet weak var testButton: UIButton!
    
  var progressChart = LineChartView()
    
  // STRINGS FOR TESTING (WILL BE PASSED FROM A FORM)
  let practioner = "Shawford House"
  let firstName = "Terry"
  let lastName = "Cruise"
  let injury = "Right Shoulder"
    
  override func viewDidLoad() {
    // Call the superclass
    super.viewDidLoad()
    // Set VC properties
    view.backgroundColor = .black
    title = "Progress"
    progressChart.delegate = self
  }
    
  @IBAction func testButtonPressed(_ sender: Any) {
    // Establish the database connection
    let database = Firestore.firestore()
    
    print(clientData)
    let aDate = clientData.Progress[0].Date
    let noOfDates = clientData.Progress.count
    print(noOfDates)
    print(aDate)
    
    // TEST CODE - SETting a report
    let today = Date()
    let angle: CGFloat = 73.6
    let rom = Entry(Date: today, Angle: angle)
    let report = Report(Progress: [rom, rom, rom])
    let progressRef = database.collection("/\(practioner)/Database/Users/\(firstName) \(lastName)/Injuries").document("\(injury)")

    do {
        try progressRef.setData(from: report)
    } catch let error {
    print("Error writing report to Firestore: \(error)")
    }
    
    // TEST CODE - GETting a report
    //let docRef = database.collection("cities").document("LA")

    progressRef.getDocument { (document, error) in
    // Construct a Result type to encapsulate deserialization errors or
    // successful deserialization. Note that if there is no error thrown
    // the value may still be `nil`, indicating a successful deserialization
    // of a value that does not exist.
    //
    // There are thus three cases to handle, which Swift lets us describe
    // nicely with built-in Result types:
    //
    //      Result
    //        /\
    //   Error  Optional<City>
    //               /\
    //            Nil  City
    let result = Result {
      try document?.data(as: Report.self)
    }
    switch result {
    case .success(let report):
        if let report = report {
            // A report value was successfully initialized from the DocumentSnapshot.
            print("report: \(report)")
            let test1 = report.Progress[0]
            let test2 = report.Progress
            let testSize = test2.count
            print("Printing Test...")
            //print("\(test2) Size:\(testSize) First Element:\(String(describing: test1))")
        } else {
            // A nil value was successfully initialized from the DocumentSnapshot,
            // or the DocumentSnapshot was nil.
            print("Document does not exist")
        }
    case .failure(let error):
        // A report value could not be initialized from the DocumentSnapshot.
        print("Error decoding report: \(error)")
    }
    }
    
  }
    
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    // Set frame and centre for the progress chart and add to the view
    progressChart.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height:self.view.frame.size.width)
    progressChart.center = view.center
    view.addSubview(progressChart)
    
    // Unwrap the progress array from clientData and store in a variable
    let progressArray = clientData.Progress
    print("Progress Array is filled with:\(progressArray)")
    // Create an array of ChartEntryData and by using the date of the first ROMEntry
    // calculate the width of the chart. Use the width to adjust the other entries so that they fit while using a for loop to add the user entries
    var entries = [ChartDataEntry]()
    for x in 0..<progressArray.count {
        entries.append(ChartDataEntry(x: Double(progressArray[x].Date.timeIntervalSinceReferenceDate), y: Double(progressArray[x].Angle)))
    }
    // Add the data to the chart and make changes to the appearance.
    let set = LineChartDataSet(entries: entries)
    set.colors = ChartColorTemplates.material()
    let data = LineChartData(dataSet: set)
    progressChart.data = data
    let romIncrease = progressArray[progressArray.count-1].Angle - progressArray[0].Angle
    print(romIncrease)
  }
  
  
}

  public struct Entry: Codable {
    let Date: Date
    let Angle: CGFloat
    
    enum CodingKeys: String, CodingKey {
      case Date
      case Angle
    }
  }

  public struct Report: Codable {
    var Progress: [Entry]

    enum CodingKeys: String, CodingKey {
        case Progress
    }
}

