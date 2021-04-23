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

  @IBOutlet weak var improvementLabel: UILabel!
  @IBOutlet weak var entryLabel: UILabel!
  @IBOutlet weak var timeFrameSegmentedControl: UISegmentedControl!
  
  var timeFrame = 0.0
  var timeFrameString = "Since your injury"
    
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
    entryLabel.isHidden = true
  }
    @IBAction func indexChanged(_ sender: Any) {
    switch timeFrameSegmentedControl.selectedSegmentIndex
    {
    case 0:
      timeFrame = 0
      timeFrameString = "Since your injury"
    case 1:
      // 3 Months
      timeFrame = Date().timeIntervalSinceReferenceDate - (2630000*3)
      timeFrameString = "In the last three months"
    case 2:
      // 1 Month
      timeFrame = Date().timeIntervalSinceReferenceDate - 2630000
      timeFrameString = "In the last month"
    case 3:
      // 2 Weeks
      timeFrame = Date().timeIntervalSinceReferenceDate - (604800*2)
      timeFrameString = "In the last two weeks"
    default:
        break
    }
    // Refresh view
    entryLabel.isHidden = true
    viewDidLayoutSubviews()
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
    var firstEntrySet = false
    var firstEntry = 0
    for x in 0..<progressArray.count {
      if progressArray[x].Date.timeIntervalSinceReferenceDate > timeFrame {
        if !(firstEntrySet) {
          firstEntry = x
          firstEntrySet = true
        }
        entries.append(ChartDataEntry(x: Double(progressArray[x].Date.timeIntervalSinceReferenceDate), y: Double(progressArray[x].Angle)))
      }
    }
    // Add the data to the chart and make changes to the appearance.
    let set = LineChartDataSet(entries: entries)
    set.colors = ChartColorTemplates.material()
    let data = LineChartData(dataSet: set)
    progressChart.data = data
    // Alter xAxis
    progressChart.xAxis.labelPosition = .bottom
    progressChart.xAxis.labelRotationAngle = 60
    //progressChart.xAxis.drawLabelsEnabled = false
    progressChart.legend.enabled = false
    progressChart.rightAxis.drawLabelsEnabled = false
    progressChart.xAxis.valueFormatter = axisValueFormatter()
    progressChart.xAxis.axisMaxLabels = 4
    
    var romIncrease = progressArray[progressArray.count-1].Angle - progressArray[firstEntry].Angle
    romIncrease.round()
    improvementLabel.text = "\(timeFrameString), your range of motion has improved by \(romIncrease) degrees"
  }
  
  func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
      let date = Date(timeIntervalSinceReferenceDate: entry.x)
      let formatter = DateFormatter()
      formatter.dateStyle = .short
      var angle: Double = entry.y
      angle.round()
      entryLabel.text = "Angle: \(angle) Date: \(formatter.string(from: date))"
      entryLabel.isHidden = false
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

class axisValueFormatter: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
      let date = Date(timeIntervalSinceReferenceDate: value)
      let formatter = DateFormatter()
      formatter.dateStyle = .short
      return formatter.string(from: date)
    }
    
    let timeFrame: Double = 0.0
}
