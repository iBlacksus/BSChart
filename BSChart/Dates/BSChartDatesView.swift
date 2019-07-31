//
//  BSChartDatesView.swift
//  BSChart
//
//  Created by iBlacksus on 3/14/19.
//  Copyright © 2019 iBlacksus. All rights reserved.
//

import UIKit

class BSChartDatesView: BSChartBaseView {

    class var identifier: String {
        return "BSChartDatesView"
    }
    
    @IBOutlet weak var collectionView: BSChartDatesCollectionView!
    
    public var item: BSChartItem?
    private var left: CGFloat = 0.0
    private var width: CGFloat = 0.0
    private var dates: Array<Date> = []
    
    public func configure(left: CGFloat, width: CGFloat) {
        let oldLeft = self.left
        let oldWidth = self.width
        self.left = left
        self.width = width
        
        if oldWidth == width {
            if oldLeft != left {
                self.collectionView.updateOffset(left: left)
            }
            
            return
        }
        
        guard let column = self.item?.column else {
            self.collectionView.configure(items: [], left: 0, width: 0)
            
            return
        }
        
        if column.count < 1 {
            self.collectionView.configure(items: [], left: 0, width: 0)
            
            return
        }
        
        let fullWidth = self.frame.width / width * 100.0
        let cellWidth = self.frame.width / 6.0
        let cellsCount = Int((fullWidth / cellWidth).rounded(.toNearestOrEven))
        let step = CGFloat(column.count) / CGFloat(cellsCount)
        
        var dates: Array<Date> = []
        var lastYear = 0
        var lastMonth = 0
        var lastDay = 0
        let calendar = Calendar.current
        var possibleDate: Date?
        
        if column.count > 0 {
            let date = Date(timeIntervalSince1970: TimeInterval(column.first!) / 1000.0)
            dates += [date]
        }
        
        var lastStart: CGFloat = 0.0
        for index in 1...cellsCount - 2 {
            var start = (CGFloat(index) * step).rounded(.down)
            if start <= lastStart {
                start = CGFloat(lastStart) + 1.0
            }
            start = min(start, CGFloat(column.count))
            lastStart = start
            var end = (start + step).rounded(.up)
            end = min(end, CGFloat(column.count))
            
            let items = Array(column[Int(start)..<Int(end)])
            possibleDate = nil
            var itemIndex = 0
            for item in items {
                itemIndex += 1
                
                let date = Date(timeIntervalSince1970: TimeInterval(item) / 1000.0)
                let year = calendar.component(.year, from: date)
                let month = calendar.component(.month, from: date)
                let day = calendar.component(.day, from: date)
                
                if lastYear == year && lastMonth == month && lastDay == day {
                    continue
                }
                
                lastYear = year
                lastMonth = month
                lastDay = day
                possibleDate = date
                
                if itemIndex > items.count / 2 && possibleDate != nil {
                    dates += [possibleDate!]
                    
                    break
                }
            }
        }
        
        if column.count > 1 {
            let date = Date(timeIntervalSince1970: TimeInterval(column.last!) / 1000.0)
            dates += [date]
        }
        
        self.dates = dates
        
        self.collectionView.configure(items: dates, left: left, width: width)
    }
    
}
