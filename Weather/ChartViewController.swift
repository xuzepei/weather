//
//  ChartViewController.swift
//  Weather
//
//  Created by xuzepei on 2025/2/19.
//

import UIKit
import Charts

class ChartViewController: BaseViewController {
    
    var weatherData:Dictionary<String, AnyObject>? = nil
    var nowIndex = -1
    @IBOutlet weak var lineChartView: LineChartView!
    var timeNum:Int = 0
    var xAxisLabels:[String] = []
    var temperatures:[Double] = []
    
    deinit {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Temperature Chart"
        self.navBar.titleLabel?.text = self.title
        
        // Do any additional setup after loading the view.
        self.navBar.setLeftButton(nil, target: self, action: #selector(clickedLeftBtn))
        
        setup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @objc func clickedLeftBtn() {

        self.navigationController?.popViewController(animated: true)
    }
    
    func setup() {
        self.view.backgroundColor = .white
        
        initChartView()
        
        updateContent()
    }
    
    func updateContent() {
        
        if let timeDataArray = self.weatherData?["time"] as? [String] {
            
            if let temperatureDataArray = self.weatherData?["temperature_2m"] as? [Any] {
                
                if timeDataArray.count == temperatureDataArray.count && self.nowIndex != -1 {
                    
                    xAxisLabels.removeAll()
                    temperatures.removeAll()
                    
                    for (index, dateStr) in timeDataArray.enumerated() {
                        
                        //the next 24hrs
                        if index >= self.nowIndex &&  xAxisLabels.count <= Tool.MAX_TIME_COUNT {
                            var timeStr = Tool.convertGMTToLocalHour(gmtDateString: dateStr)
                            if index == self.nowIndex {
                                timeStr = "Now"
                            }
                            
                            if let temperatureNum = temperatureDataArray[index] as? NSNumber {
                                let temperature = temperatureNum.doubleValue
                                xAxisLabels.append(timeStr)
                                temperatures.append(temperature)
                            } else {
                                showNoData(true)
                                return
                            }
                        }
                        

                    }
                } else {
                    showNoData(true)
                    return
                }
            }
            
        } else {
            showNoData(true)
            return
        }
        
        
        // Set the custom labels for the X-axis
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xAxisLabels)
        updateChart()
    }
    
    func showNoData(_ value: Bool) {
        
    }
    
    func initChartView() {
        
        lineChartView.rightAxis.enabled = false
        // Hide the vertical (X-axis) grid lines
        lineChartView.xAxis.drawGridLinesEnabled = false
        // Keep the horizontal (Y-axis) grid lines visible
        lineChartView.leftAxis.drawGridLinesEnabled = true
        lineChartView.leftAxis.gridLineWidth = 1.0
        lineChartView.leftAxis.gridColor = UIColor.systemGray6
        
        // Set the X-axis labels to appear at the bottom
        lineChartView.xAxis.labelPosition = .bottom
        

        
        lineChartView.xAxis.granularity = 1
        //lineChartView.xAxis.axisMinimum = 3
        
        // Disable zooming
        lineChartView.setScaleEnabled(true)
        
        lineChartView.dragEnabled = true
        //lineChartView.pinchZoomEnabled = false
        
        lineChartView.noDataText = "No Data"
        lineChartView.noDataTextColor = UIColor.systemGray
        lineChartView.noDataFont = UIFont.systemFont(ofSize: 18)
        lineChartView.noDataTextAlignment = .center
        
        //lineChartView.data = nil
        
//        // Customize the left axis
//        let leftAxis = lineChartView.leftAxis
//
//        // Use a value formatter to display units on the left axis
//        let valueFormatter = NumberFormatter()
//        valueFormatter.numberStyle = .decimal
//
//        // Example: Add "USD" to each value on the left axis
//        valueFormatter.positiveSuffix = " °C"  // You can change this to any unit like "%" or "€"
//
//        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: valueFormatter)
//
//        // Optionally, customize the appearance of the left axis
//        leftAxis.labelFont = UIFont.systemFont(ofSize: 12)
//        leftAxis.labelTextColor = .black
        
        
 
    }

    
    func updateChart() {
        
        var lineChartEntry = [ChartDataEntry]()
        
        for i in 0..<xAxisLabels.count {
            let value = ChartDataEntry(x: Double(i), y: temperatures[i])
            lineChartEntry.append(value)
        }
        
        let lineDataSet = LineChartDataSet(entries: lineChartEntry, label: "Temperature °C")
        lineDataSet.colors = [UIColor.blue]
        lineDataSet.mode = .cubicBezier
        lineDataSet.drawFilledEnabled = true
        lineDataSet.fillColor = UIColor.blue
        lineDataSet.fillAlpha = 0.5
        lineDataSet.drawCirclesEnabled = false
        lineDataSet.drawValuesEnabled = false
        
        let data = LineChartData(dataSet: lineDataSet)
        self.lineChartView.data = data
        
        // Notify the chart that the data has changed and animate it
        self.lineChartView.notifyDataSetChanged()
        self.lineChartView.animate(xAxisDuration: 1, yAxisDuration: 1)
        
        lineChartView.chartDescription.text = "Future 24-hour Temperature Chart"
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
