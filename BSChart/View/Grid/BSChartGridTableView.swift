//
//  BSChartGridTableView.swift
//  BSChart
//
//  Created by iBlacksus on 3/15/19.
//  Copyright © 2019 iBlacksus. All rights reserved.
//

import UIKit

class BSChartGridTableView: UITableView, UITableViewDelegate {

    private var chartGridDataSource: BSChartGridDataSource?
    private var rows = 6
    private var items: Array<BSChartItem> = []
    private var min: [Int] = []
    private var max: [Int] = []
    private var updateInProgress: Bool = false
    private var needUpdate: Bool = false
    private var updateAnimation: RowAnimation = .automatic
    
    required init?(coder aDecoder: NSCoder) {
        super .init(coder: aDecoder)
        
        self.chartGridDataSource = BSChartGridDataSource(tableView: self)
        self.dataSource = self.chartGridDataSource
        self.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(colorModeChanged), name: .chartColorModeChanged, object: nil)
        self.colorModeChanged()
    }
    
    public func configure(_ chartItems: Array<BSChartItem>, min: [Int], max: [Int]) {
        if chartItems.count < 1 {
            self.chartGridDataSource?.items = []
            self.reloadData()
            return
        }
        
        self.needUpdate = self.needUpdate || self.identifyAnimation(min: min, max: max)
        
        self.items = chartItems
        self.min = min
        self.max = max
        
        guard let firstItem = chartItems.first else {
            return
        }
        
        var allItems: Array<Array<Int>> = []
        for i in 0...min.count - 1 {
            var items: Array<Int> = []
            
            self.rows = firstItem.percentage ? 5 : 6
            let minItem = firstItem.percentage ? 0 : min[i]
            var maxItem = firstItem.percentage ? 100 : max[i]
            if !firstItem.percentage {
                maxItem -= Int(CGFloat(abs(maxItem) - abs(minItem)) / CGFloat(self.rows) / 4.0)
            }
            let step = CGFloat((abs(maxItem) - abs(minItem))) / CGFloat(self.rows - 1)
            
            for j in 0...self.rows - 2 {
                items += [Int(CGFloat(maxItem) - step * CGFloat(j))]
            }
            items += [minItem]
            
            allItems += [items]
        }
        
        self.chartGridDataSource?.leftLabels = firstItem.index == 1
        self.chartGridDataSource?.yScaled = firstItem.yScaled
        self.chartGridDataSource?.items = allItems
        var colors: Array<UIColor> = []
        for item in chartItems {
            guard let color = item.color else {
                continue
            }
            colors += [color]
        }
        self.chartGridDataSource?.colors = colors
        
        if self.needUpdate {
            if self.updateInProgress {
                self.needUpdate = true
                return
            }
            
            self.needUpdate = false
            self.updateWithAnimation()
        }
    }
    
    private func identifyAnimation(min: [Int], max: [Int]) -> Bool {
        if self.min.count != min.count || self.max.count != max.count {
            self.updateAnimation = .fade
            
            return true
        }
        
        var needUpdate = false
//        var minGT = false
//        var minLT = false
//        var maxGT = false
//        var maxLT = false
        var index = -1
        for item in self.min {
            index += 1
            
            if item != min[index] {
                needUpdate = true
                break
            }
        }
        
        index = -1
        for item in self.max {
            index += 1
            
            if item != max[index] {
                needUpdate = true
                break
            }
        }
        
        self.updateAnimation = .fade
        
        return needUpdate
        
//        if self.min != min || self.max != max {
//            if max > self.max {
//                self.updateAnimation = .bottom
//            }
//            else if max < self.max {
//                self.updateAnimation = .top
//            }
//            else {
//                self.updateAnimation = .fade
//            }
//        }
    }
    
    private func updateWithAnimation() {
        self.updateInProgress = true
        
        let indexSet = IndexSet(arrayLiteral: 0)
        self.reloadSections(indexSet, with: self.updateAnimation)
        
        
//        UIView.animate(withDuration: 0.20, delay: 0.0, options: .curveEaseInOut, animations: {
//            self.beginUpdates()
//            let indexSet = IndexSet(arrayLiteral: 0)
//            self.reloadSections(indexSet, with: self.updateAnimation)
//            self.endUpdates()
//        }) { isFinished in
//
//        }
        
        let deadlineTime = DispatchTime.now() + .milliseconds(300)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.updateInProgress = false
            
            if self.needUpdate {
                self.needUpdate = false
                self.updateWithAnimation()
            }
        }
    }
    
    @objc func colorModeChanged() {
        UIView.animate(withDuration: 0.25) {
            self.separatorColor = BSColorModeManager.shared.colorForItem(.gridViewSeparator)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let rowHeight = self.frame.size.height / CGFloat(self.rows)
//        let firstRow = rowHeight / 2.0
//
//        if indexPath.row == 0 {
//            return firstRow
//        }
        
        return self.frame.height / CGFloat((self.rows))
    }

}
