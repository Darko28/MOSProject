//
//  SensorLineChartViewController.swift
//  MOSProject
//
//  Created by Darko on 2017/11/29.
//  Copyright © 2017年 Darko. All rights reserved.
//

import UIKit
import Charts

class SensorLineChartViewController: UIViewController, ChartViewDelegate {
    
    var lineChartView: LineChartView!
    
    var backBtn: UIButton!
    
    //    var pm25numbers: [Double] = [1.0, 2.0, 4.0, 2.5, 3.0, 1.2, 2.8, 5.0, 4.4, 4.3, 1.1]
    //    var pm10numbers: [Double] = [2.0, 5.0, 3.2, 4.2, 2.8, 3.1, 1.1, 4.8, 3.0, 5.8, 2.4]
    var date: [String] = []
    var pm25numbers: [Double] = []
    var pm10numbers: [Double] = []
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.lineChartView = LineChartView.init(frame: self.view.bounds)
        self.view.addSubview(self.lineChartView)
        
        self.backBtn = UIButton(frame: CGRect(x: 24, y: 12, width: 48, height: 48))
        self.backBtn.setTitle("back", for: UIControlState.normal)
        self.backBtn.addTarget(self, action: #selector(back), for: UIControlEvents.touchUpInside)
        self.backBtn.setTitleColor(UIColor.blue, for: .normal)
        self.lineChartView.addSubview(self.backBtn)
        
        self.initGraph()
        self.updateGraph()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        self.backBtn.removeFromSuperview()
        self.lineChartView.removeFromSuperview()
        self.lineChartView = LineChartView.init(frame: self.view.bounds)
        self.view.addSubview(self.lineChartView)
        self.backBtn = UIButton(frame: CGRect(x: 24, y: 12, width: 48, height: 48))
        self.backBtn.setTitle("back", for: UIControlState.normal)
        self.backBtn.addTarget(self, action: #selector(back), for: UIControlEvents.touchUpInside)
        self.backBtn.setTitleColor(UIColor.blue, for: .normal)
        self.lineChartView.addSubview(self.backBtn)
        self.initGraph()
        self.updateGraph()
    }
    
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initGraph() {
        self.lineChartView.delegate = self
        self.lineChartView.backgroundColor = UIColor.init(red: 230/255.0, green: 253/255.0, blue: 253/255.0, alpha: 1)
        self.lineChartView.noDataText = "no sensor data"
        self.lineChartView.dragEnabled = true
        self.lineChartView.setScaleEnabled(true)
        self.lineChartView.dragDecelerationEnabled = true
        self.lineChartView.dragDecelerationFrictionCoef = 0.8
    }
    

    func updateGraph() {
        
        var lineChartEntry1 = [ChartDataEntry]()
        var lineChartEntry2 = [ChartDataEntry]()
        
        for i in 0..<pm25numbers.count {
            let value = ChartDataEntry(x: Double(i), y: pm25numbers[i])
            lineChartEntry1.append(value)
        }
        
        for i in 0..<pm10numbers.count {
            let value = ChartDataEntry(x: Double(i), y: pm10numbers[i])
            lineChartEntry2.append(value)
        }

        let line1 = LineChartDataSet(values: lineChartEntry1, label: "pm2.5")
        line1.colors = [NSUIColor.blue]
        line1.mode = LineChartDataSet.Mode.cubicBezier
        line1.circleRadius = 6.0
        line1.drawFilledEnabled = true
        line1.fillColor = .blue
        line1.drawValuesEnabled = true
        line1.drawCircleHoleEnabled = false
        line1.drawCirclesEnabled = false
        
        let line2 = LineChartDataSet(values: lineChartEntry2, label: "pm10")
        line2.colors = [NSUIColor.cyan]
        line2.drawFilledEnabled = true
        line2.mode = LineChartDataSet.Mode.cubicBezier
        line2.circleRadius = 6.0
        line2.drawFilledEnabled = true
        line2.drawValuesEnabled = true
        line2.drawCircleHoleEnabled = false
        line2.drawCirclesEnabled = false

        let data = LineChartData()  // This is the object that will be added to the chart
        data.addDataSet(line1)
        data.addDataSet(line2)
        
        self.lineChartView.data = data   // final - It adds the chart data to the chart and causes an update
        
        self.lineChartView.chartDescription?.text = "Sensor data chart"
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
