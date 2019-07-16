//
//  BSChartItemsHelper.swift
//  BSChart
//
//  Created by iBlacksus on 3/19/19.
//  Copyright © 2019 iBlacksus. All rights reserved.
//

import UIKit

class BSChartItemsHelper: NSObject {
    
    class func getMinMax(_ items: Array<BSChartItem>) -> (min: [Int], max: [Int]) {
        var minInt: Int = 0
        var maxInt: Int = 0
        var min: [Int] = []
        var max: [Int] = []
        
        guard let firstItem = items.first else {
            return (min, max)
        }
        
        let yScaled = firstItem.yScaled!
        let stacked = firstItem.stacked!
        
        if stacked {
            guard let firstItemColumn = firstItem.column else {
                return (min, max)
            }
            
            for index in 0...firstItemColumn.count - 1 {
                var sum = 0
                for item in items {
                    if item.type == .x {
                        continue
                    }
                    
                    guard let column = item.column, index < column.count else {
                        return (min, max)
                    }
                    
                    sum += column[index]
                }
                
                max += [sum]
            }
            
            for value in max {
                if (value > maxInt) {
                    maxInt = value
                }
            }
        }
        else {
            for item in items {
                if item.type == .x {
                    continue
                }
                
                guard let column = item.column else {
                    continue
                }
                
                if yScaled {
                    minInt = Int(INT_MAX)
                    maxInt = 0
                }
                
                for value in column {
                    if (value < minInt) {
                        minInt = value
                    }
                    if (value > maxInt) {
                        maxInt = value
                    }
                }
                
                if yScaled {
                    min += [minInt]
                    max += [maxInt]
                }
            }
        }
        
        if !yScaled {
            min = [minInt]
            max = [maxInt]
        }
        
        return (min, max)
    }
    
    class func getLineItems(_ items: Array<BSChartItem>) -> Array<BSChartItem> {
        var lineItems: Array<BSChartItem> = []
        
        for item in items {
            if item.type == .x {
                continue
            }
            
            lineItems += [item]
        }
        
        return lineItems
    }
    
    class func getXItem(_ items: Array<BSChartItem>) -> BSChartItem? {
        for item in items {
            if item.type == .x {
                return item
            }
        }
        
        return nil
    }
    
}
