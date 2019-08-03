//
//  BSChartItem.swift
//  BSChart
//
//  Created by Bernhard Weiß on 16.07.19.
//  Copyright © 2019 iBlacksus. All rights reserved.
//

import Foundation
import UIKit

class BSChartItem {
    public var key: String!
    public var name: String!
    public var type: BSType?
    public var color: UIColor!
    public var column: [Int]?
    public var yScaled: Bool!
    public var percentage: Bool!
    public var stacked: Bool!
    public var sum: Bool!
    public var single: Bool!
    public var index: Int!
    
    func copy(item: BSChartItem, start: Int, count: Int) {
        self.key = item.key
        self.name = item.name
        self.type = item.type
        self.color = item.color
        self.yScaled = item.yScaled
        self.percentage = item.percentage
        self.stacked = item.stacked
        self.sum = item.sum
        self.single = item.single
        self.index = item.index
        
        guard let column = item.column else {
            return
        }
        
        var startIndex = start
        if startIndex < 0 {
            startIndex = 0
        }
        
        var endIndex = startIndex + count
        if endIndex > column.count {
            endIndex = column.count
        }
        
        self.column = Array(column[startIndex..<endIndex])
    }
}
