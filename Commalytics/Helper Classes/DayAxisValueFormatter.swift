//
//  DayAxisValueFormatter.swift
//  Commalytics
//
//  Created by Muneeb Awan on 1/3/18.
//  Copyright © 2018 Muneeb Awan. All rights reserved.
//

import Foundation
import Charts

public class MonthAxisValueFormatter: NSObject, IAxisValueFormatter {
    var labels: [String] = []
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return labels[Int(value)]
    }
    
    init(labels: [String]) {
        super.init()
        self.labels = labels
    }
}


