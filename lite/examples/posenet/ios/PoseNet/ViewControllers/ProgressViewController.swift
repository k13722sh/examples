//
//  ProgressViewController.swift
//  PoseNet
//
//  Created by Sean Harris on 08/04/2021.
//  Copyright © 2021 tensorflow. All rights reserved.
//
import Charts
import UIKit

class ProgressViewController: UIViewController, ChartViewDelegate {

    var progressChart = LineChartView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        title = "Progress"
        progressChart.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Set frame and centre for the progress chart and add to the view
        progressChart.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.width)
        progressChart.center = view.center
        view.addSubview(progressChart)
        // Create an array of ChartEntryData and by using the date of the first ROMEntry
        // calculate the width of the chart. Use the width to adjust the other entries so that they fit while using a for loop to add the user entries
        var entries = [ChartDataEntry]()
        let firstEntry = testROMEntry[0].date.timeIntervalSinceReferenceDate
        let dateToday = Date().timeIntervalSinceReferenceDate
        let xWidth = dateToday - firstEntry
        for x in 0..<testROMEntry.count {
          let adjustedDate = testROMEntry[x].date.timeIntervalSinceReferenceDate - xWidth
          entries.append(ChartDataEntry(x: Double(adjustedDate), y: Double(testROMEntry[x].angle)))
        }
        // Add the data to the chart and make changes to the appearance.
        let set = LineChartDataSet(entries: entries)
        set.colors = ChartColorTemplates.material()
        let data = LineChartData(dataSet: set)
        progressChart.data = data
    }

}
