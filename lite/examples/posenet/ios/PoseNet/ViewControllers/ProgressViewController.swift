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

    var lineChart = LineChartView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        title = "Progress"
        lineChart.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        lineChart.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.width)
        lineChart.center = view.center
        view.addSubview(lineChart)
        var entries = [ChartDataEntry]()
        //let noOfEntries = testROMEntry.count
        let firstEntry = testROMEntry[0].date.timeIntervalSinceReferenceDate
        let dateToday = Date().timeIntervalSinceReferenceDate
        let xWidth = dateToday - firstEntry
        for x in 0..<testROMEntry.count {
          let adjustedDate = testROMEntry[x].date.timeIntervalSinceReferenceDate - xWidth
          entries.append(ChartDataEntry(x: Double(adjustedDate), y: Double(testROMEntry[x].angle)))
        }
        let set = LineChartDataSet(entries: entries)
        set.colors = ChartColorTemplates.material()
        let data = LineChartData(dataSet: set)
        lineChart.data = data
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
