//
//  ViewController.swift
//  Commalytics
//
//  Created by Muneeb Awan on 1/3/18.
//  Copyright © 2018 Muneeb Awan. All rights reserved.
//

import UIKit
import Charts
import Alamofire

class ViewController: UIViewController, ChartViewDelegate {
    
    // IBOutlets
    @IBOutlet var chartView: BarChartView!
    @IBOutlet var noShowLabel: UILabel!
    
    // Variables
    var months = [String]()
    var quantity = [Int]()
    var respArray = [AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.chartView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func actionXValChange(_ sender: UISlider) {
        self.setDataCount(Int(sender.value) + 1, range: UInt32(100), chartView: self.chartView)
    }
    
    func setup(barLineChartView chartView: BarLineChartViewBase) {
        chartView.chartDescription?.enabled = false
        
        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = false
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        
        chartView.rightAxis.enabled = false
    }
    
    func setUpMyChart(chartView: BarChartView) {
        chartView.drawBarShadowEnabled = false
        chartView.drawValueAboveBarEnabled = false
        
        chartView.maxVisibleCount = 60
        
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10)
        
        xAxis.gridColor = .white
        xAxis.axisLineColor = .white
        xAxis.labelTextColor = .white
        
        xAxis.granularity = 1
        xAxis.labelCount = 7
        xAxis.valueFormatter = MonthAxisValueFormatter(labels: months)
        
        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.minimumFractionDigits = 0
        leftAxisFormatter.maximumFractionDigits = 1
        leftAxisFormatter.negativeSuffix = " $"
        leftAxisFormatter.positiveSuffix = " $"
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.labelCount = 8
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        leftAxis.labelPosition = .outsideChart
        leftAxis.spaceTop = 0.15
        
        leftAxis.gridColor = .white
        leftAxis.axisLineColor = .white
        leftAxis.labelTextColor = .white
        
        leftAxis.axisMinimum = 0
        
        let rightAxis = chartView.rightAxis
        rightAxis.enabled = true
        rightAxis.labelFont = .systemFont(ofSize: 10)
        rightAxis.labelCount = 8
        rightAxis.valueFormatter = leftAxis.valueFormatter
        
        rightAxis.gridColor = .white
        rightAxis.axisLineColor = .white
        rightAxis.labelTextColor = .white
        
        rightAxis.spaceTop = 0.15
        rightAxis.axisMinimum = 0
        
        let l = chartView.legend
        l.horizontalAlignment = .left
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        l.form = .circle
        l.formSize = 9
        l.font = UIFont(name: "HelveticaNeue-Light", size: 11)!
        l.xEntrySpace = 4
        
        let marker = XYMarkerView(color: UIColor(white: 180/250, alpha: 1),
                                  font: .systemFont(ofSize: 12),
                                  textColor: .white,
                                  insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8),
                                  xAxisValueFormatter: chartView.xAxis.valueFormatter!)
        marker.chartView = chartView
        marker.minimumSize = CGSize(width: 80, height: 40)
        chartView.marker = marker
        
        self.setDataCount(months.count - 2, range: UInt32(100), chartView: chartView)
    }
    
    func setDataCount(_ count: Int, range: UInt32, chartView: BarChartView) {
        let start = 1
        
        let yVals = (start..<start+count+1).map { (i) -> BarChartDataEntry in
            return BarChartDataEntry(x: Double(i), y: Double(quantity[i]))
        }
        
        var set1: BarChartDataSet! = nil
        if let set = chartView.data?.dataSets.first as? BarChartDataSet {
            set1 = set
            set1.values = yVals
            chartView.data?.notifyDataChanged()
            chartView.notifyDataSetChanged()
        } else {
            set1 = BarChartDataSet(values: yVals, label: "The year 2017")
            set1.colors = ChartColorTemplates.material()
            set1.drawValuesEnabled = false
            
            let data = BarChartData(dataSet: set1)
            data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10)!)
            data.barWidth = 0.9
            chartView.data = data
        }
    }
    
    //MARK: -IBAction
    
    @IBAction func salesByYear(_ sender: Any) {
        months.removeAll()
        quantity.removeAll()
        noShowLabel?.text = "Please Wait We Are Fetching The Data."
        Alamofire.request("\(Constants.reqUrl)GetYearWiseSalesVolume").responseJSON { responce in
            let result = responce.result
            self.noShowLabel?.text = ""
            if let arr = result.value as? NSArray {
                for d in arr {
                    let dict = d as! NSDictionary
                    print("key: \(String(describing: dict["year"]!)) value: \(String(describing: dict["quantity"]!))")
                    self.months.append(String(describing: dict["year"]!))
                    if ((dict["quantity"]!) as! Int) > 4855 {
                        self.quantity.append(2320)
                    } else {
                        self.quantity.append((dict["quantity"]!) as! Int)
                    }
                }
                self.setup(barLineChartView: self.chartView)
                self.setUpMyChart(chartView: self.chartView)
            }
        }
    }
    
    @IBAction func topTenCust(_ sender: Any) {
        months.removeAll()
        quantity.removeAll()
        noShowLabel?.text = "Please Wait We Are Fetching The Data."
        Alamofire.request("\(Constants.reqUrl)Get10CustomersByVolume").responseJSON { responce in
            let result = responce.result
            self.noShowLabel?.text = ""
            if let arr = result.value as? NSArray {
                for d in arr {
                    let dict = d as! NSDictionary
                    print("key: \(String(describing: dict["customer"]!)) value: \(String(describing: dict["quantity"]!))")
                    self.months.append(String(describing: dict["customer"]!))
                    self.quantity.append((dict["quantity"]!) as! Int)
                }
                self.setup(barLineChartView: self.chartView)
                self.setUpMyChart(chartView: self.chartView)
            }
        }
    }
    
    @IBAction func topTenCat(_ sender: Any) {
        months.removeAll()
        quantity.removeAll()
        noShowLabel?.text = "Please Wait We Are Fetching The Data."
        Alamofire.request("\(Constants.reqUrl)Get10CategoryByVolume").responseJSON { responce in
            let result = responce.result
            self.noShowLabel?.text = ""
            if let arr = result.value as? NSArray {
                for d in arr {
                    let dict = d as! NSDictionary
                    print("key: \(String(describing: dict["category"]!)) value: \(String(describing: dict["quantity"]!))")
                    self.months.append(String(describing: dict["category"]!))
                    self.quantity.append((dict["quantity"]!) as! Int)
                }
                self.setup(barLineChartView: self.chartView)
                self.setUpMyChart(chartView: self.chartView)
            }
        }
    }
    
    @IBAction func locationByVolume(_ sender: Any) {
        months.removeAll()
        quantity.removeAll()
        noShowLabel?.text = "Please Wait We Are Fetching The Data."
        Alamofire.request("\(Constants.reqUrl)GetLocationByVolume").responseJSON { responce in
            let result = responce.result
            self.noShowLabel?.text = ""
            if let arr = result.value as? NSArray {
                for d in arr {
                    let dict = d as! NSDictionary
                    print("key: \(String(describing: dict["location"]!)) value: \(String(describing: dict["quantity"]!))")
                    self.months.append(String(describing: dict["location"]!))
                    self.quantity.append((dict["quantity"]!) as! Int)
                }
                self.setup(barLineChartView: self.chartView)
                self.setUpMyChart(chartView: self.chartView)
            }
        }
    }
    
}

