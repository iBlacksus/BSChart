//
//  BSChartView.swift
//  BSChart
//
//  Created by iBlacksus on 3/17/19.
//  Copyright © 2019 iBlacksus. All rights reserved.
//

import UIKit

@IBDesignable
class BSChartView: BSChartBaseView {

    @IBInspectable private var isMiniMap: Bool = false
    
    private var items: Array<BSChartItem> = []
    private var offset: CGFloat = 0
    private var lastFrame: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    private var max: [Int] = []
    private var min: [Int] = []
    private var shapeLayers: Dictionary<String, CAShapeLayer> = [:]
    private var paths: Dictionary<String, UIBezierPath> = [:]
    private var visibleLayers: Array<String> = []
    private var updateInProgress: Bool = false
    private var needUpdate: Bool = false
    private var lastDrawColumn: Array<CGFloat> = []
    private var sumColumn: Array<Int> = []
    private var selectedItem: Int?
    private var selectionLayer: CAShapeLayer?
    private var section: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(selectItem), name: .chartSelectItem, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeSelection), name: .chartRemoveSelection, object: nil)
    }
    
    public func configure(_ items: Array<BSChartItem>, min: [Int], max: [Int], offset: CGFloat, section: Int) {
        if self.isMiniMap {
            var needUpdate = min.count != self.min.count || max.count != self.max.count || items.count != self.items.count || !self.frame.equalTo(self.lastFrame)
            if !needUpdate {
                for i in 0...min.count - 1 {
                    needUpdate = needUpdate || min[i] != self.min[i]
                }
                for i in 0...max.count - 1 {
                    needUpdate = needUpdate || max[i] != self.max[i]
                }
                for i in 0...max.count - 1 {
                    needUpdate = needUpdate || items[i].key != self.items[i].key
                }
            }
            if !needUpdate {
                return
            }
        }
        
        self.items = items
        self.min = min
        self.max = max
        self.offset = offset
        self.lastFrame = self.frame
        self.removeSelection()
        self.section = section
        
//        NSLog("%f", offset)
        
        var needAnimation = false
        
//        if self.shapeLayers.count > 0 {
//            needAnimation = self.min != min || self.max != max
//        }
        
        needAnimation = needAnimation || visibleLayers.count != self.items.count
        if !needAnimation {
            for item in self.items {
                if !visibleLayers.contains(item.key) {
                    needAnimation = true
                    break
                }
            }
        }
        
        for key in self.shapeLayers.keys {
            guard let layer = self.shapeLayers[key] else {
                continue
            }
            layer.removeFromSuperlayer()
            if !self.visibleLayers.contains(key) {
                var index = 0
                for item in self.items {
                    if item.key == key {
                        guard let column = item.column else {
                            break
                        }
                        layer.path = self.drawLine(column, index: index, type: item.type).cgPath
                    }
                    index += 1
                }
            }
        }
        
        self.visibleLayers = []
        self.paths = [:]
        
        let lineItems = BSChartItemsHelper.getLineItems(self.items)
        var index = -1
        self.lastDrawColumn = []
        
        guard let item = lineItems.first else {
            return
        }
        
        if item.percentage {
            self.createSumColumn(lineItems)
        }
        else {
            self.sumColumn = []
        }
        
        for item in lineItems {
            index += 1
            
            guard let column = item.column else {
                continue
            }
            
            var layer: CAShapeLayer
            let path = self.drawColumn(column, index: index, type: item.type, stacked: item.stacked, isLast: index == lineItems.count - 1)
            
            if self.shapeLayers[item.key] != nil {
                layer = self.shapeLayers[item.key]!
            }
            else {
                layer = CAShapeLayer()
                layer.path = path.cgPath
                layer.lineWidth = self.isMiniMap ? 0.5 : 1.5
                layer.lineCap = .round
                
                self.shapeLayers[item.key] = layer
            }
            
            if item.type == .bar || item.type == .area {
                layer.fillColor = item.color!.cgColor
                layer.strokeColor = UIColor.clear.cgColor
            }
            else {
                layer.fillColor = UIColor.clear.cgColor
                layer.strokeColor = item.color!.cgColor
            }
            
            
            self.layer.addSublayer(layer)
            self.visibleLayers.append(item.key)
            self.paths[item.key] = path
        }
        
//        if self.updateInProgress {
//            self.needUpdate = true
//            return
//        }
//
//        self.needUpdate = false
        self.updateWithAnimation(needAnimation)
    }
    
    private func createSumColumn(_ items: Array<BSChartItem>) {
        self.sumColumn = []
        
        for item in items {
            guard let column = item.column else {
                return
            }
            
            var columnIndex = -1
            for columnItem in column {
                columnIndex += 1
                if columnIndex >= self.sumColumn.count {
                    self.sumColumn.append(columnItem)
                    continue
                }
                
                self.sumColumn[columnIndex] += columnItem
            }
        }
    }
    
    private func updateWithAnimation(_ needAnimation: Bool) {
//        self.updateInProgress = true
        
        for key in self.paths.keys {
            guard let path = self.paths[key], let layer = self.shapeLayers[key] else {
                return
            }
            
            if !needAnimation {
                layer.path = path.cgPath
            }
            else {
                let animation = CABasicAnimation(keyPath: "path")
                animation.fromValue = layer.path
                animation.toValue = path.cgPath
                animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                animation.repeatCount = 1.0
                animation.duration = 0.25
                animation.isRemovedOnCompletion = true
                animation.fillMode = .forwards
                animation.beginTime = CACurrentMediaTime()
                
                layer.add(animation, forKey: "animation")
                layer.path = path.cgPath
            }
        }
        
//        let deadlineTime = DispatchTime.now() + .milliseconds(250)
//        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
//            self.updateInProgress = false
//
//            if self.needUpdate {
//                self.needUpdate = false
//                self.updateWithAnimation(true)
//            }
//        }
    }
    
    @objc func removeSelection() {
        self.selectedItem = nil
        if self.selectionLayer != nil {
            self.selectionLayer?.removeFromSuperlayer()
            self.selectionLayer = nil
        }
    }
    
    @objc func selectItem(notification: NSNotification) {
        guard let section = notification.userInfo?["section"] as? Int else {
            return
        }
        
        if section != self.section {
            return
        }
        
        guard let item = notification.userInfo?["item"] as? Int else {
            return
        }
        
        if self.selectedItem == item {
            return
        }
        
        self.selectedItem = item
        
        guard let firstItem = items.first, let firstItemColumn = firstItem.column else {
            return
        }
        
        var column: Array<Int> = []
        for index in 0...firstItemColumn.count - 1 {
            var sum = 0
            for item in items {
                guard let column = item.column, index < column.count else {
                    return
                }
                
                sum += column[index]
            }
            
            column += [sum]
        }
        
        if self.selectionLayer != nil {
            self.selectionLayer?.removeFromSuperlayer()
            self.selectionLayer = nil
        }
        
        let path = self.drawSelection(column)
        
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.lineWidth = 0.5
        layer.lineCap = CAShapeLayerLineCap.round
        layer.fillColor = BSColorModeManager.shared.colorForItem(.detailsViewOverlay).cgColor
        layer.strokeColor = UIColor.clear.cgColor
        
        self.layer.addSublayer(layer)
        self.selectionLayer = layer
    }
    
    private func drawSelection(_ column: [Int]) -> UIBezierPath {
        guard let min = self.min.first, let max = self.max.first else {
            return UIBezierPath()
        }
        
        let path = UIBezierPath()
        let height = self.frame.height
        let factor = height / CGFloat(abs(max) - abs(min))
        let step = self.frame.width / CGFloat(column.count)
        var x: CGFloat = self.offset
        path.move(to: CGPoint(x: x, y: height))
        
        var index: Int = 0
        for item in column {
            let y = height - CGFloat(item) * factor + CGFloat(min) * factor
            
            path.addLine(to: CGPoint(x: x, y: y))
            
            if index == self.selectedItem {
                path.addLine(to: CGPoint(x: x, y: height))
                path.addLine(to: CGPoint(x: x + step, y: height))
            }
            
            path.addLine(to: CGPoint(x: x + step, y: y))
            
            x += step
            index += 1
        }
        
        path.addLine(to: CGPoint(x: x, y: height))
        path.close()
        
        return path
    }
    
    private func drawColumn(_ column: [Int], index: Int, type: BSType?, stacked: Bool, isLast: Bool) -> UIBezierPath {
        guard let type = type else {
            return UIBezierPath()
        }
        
        if column.count < 1 {
            return UIBezierPath()
        }
        
        switch type {
        case .line:
            return self.drawLineColumn(column, index: index)
            
        case .bar:
            return stacked ? self.drawStackedBarColumn(column) : self.drawBarColumn(column)
            
        case .area:
            return self.drawAreaColumn(column, isLast: isLast)
            
        default:
            return UIBezierPath()
        }
    }
    
    private func drawLineColumn(_ column: [Int], index: Int) -> UIBezierPath {
        var mmIndex = index
        if mmIndex >= self.min.count {
            mmIndex = self.min.count - 1
        }
        
        let min = self.min[mmIndex]
        let max = self.max[mmIndex]
        let path = UIBezierPath()
        let height = self.frame.height
        let factor = height / CGFloat(abs(max) - abs(min))
        let step = self.frame.width / CGFloat(column.count - 1)
        let y = height - CGFloat(column.first!) * factor + CGFloat(min) * factor
        path.move(to: CGPoint(x: 0, y: y))
        var x: CGFloat = self.offset
        
        for item in column {
            let y = height - CGFloat(item) * factor + CGFloat(min) * factor
            path.addLine(to: CGPoint(x: x, y: y))
            x += step
        }
        
        return path
    }
    
    private func drawBarColumn(_ column: [Int]) -> UIBezierPath {
        guard let min = self.min.first, let max = self.max.first else {
            return UIBezierPath()
        }
        
        let path = UIBezierPath()
        let height = self.frame.height
        let factor = height / CGFloat(abs(max) - abs(min))
        let step = self.frame.width / CGFloat(column.count)
        var x: CGFloat = self.offset
        
        for item in column {
            let y = height - CGFloat(item) * factor + CGFloat(min) * factor
            
            path.move(to: CGPoint(x: x, y: height))
            path.addLine(to: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: x + step, y: y))
            path.addLine(to: CGPoint(x: x + step, y: height))
            path.close()
            
            x += step
        }
        
        return path
    }
    
    private func drawStackedBarColumn(_ column: [Int]) -> UIBezierPath {
        guard let min = self.min.first, let max = self.max.first else {
            return UIBezierPath()
        }
        
        let path = UIBezierPath()
        let height = self.frame.height
        let factor = height / CGFloat(abs(max) - abs(min))
        let step = self.frame.width / CGFloat(column.count)
        var x: CGFloat = self.offset
        var itemIndex = 0
        var lastColumn: Array<CGFloat> = []
        
        for item in column {
            var y = height - CGFloat(item) * factor + CGFloat(min) * factor
            var bottomY: CGFloat = height
            
            if self.lastDrawColumn.count > itemIndex {
                let lastY = self.lastDrawColumn[itemIndex]
                y -= height - lastY
                bottomY = lastY
            }
            
            lastColumn += [y]
            
            path.move(to: CGPoint(x: x, y: bottomY))
            path.addLine(to: CGPoint(x: x, y: y))
            path.addLine(to: CGPoint(x: x + step, y: y))
            path.addLine(to: CGPoint(x: x + step, y: bottomY))
            path.close()
            
            x += step
            itemIndex += 1
        }
        
        self.lastDrawColumn = lastColumn
        
        return path
    }
    
    private func drawAreaColumn(_ column: [Int], isLast: Bool) -> UIBezierPath {
        guard let min = self.min.first else {
            return UIBezierPath()
        }
        
        let max = 100
        
        let path = UIBezierPath()
        let height = self.frame.height
        let factor = height / CGFloat(abs(max) - abs(min))
        let step = self.frame.width / CGFloat(column.count - 1)
        var x: CGFloat = self.offset
        var itemIndex: Int = 0
        var lastColumn: Array<CGFloat> = []
        var bottomY: CGFloat = height
        if self.lastDrawColumn.count > 0 {
            bottomY = self.lastDrawColumn.first!
        }
        
        path.move(to: CGPoint(x: 0, y: bottomY))
        
        for item in column {
            var sum = 0
            var percent: CGFloat = 0.0
            
            if self.sumColumn.count > 0 {
                sum = self.sumColumn[itemIndex]
                percent = CGFloat(item) / CGFloat(sum) * 100.0
            }
            
            var y = height - CGFloat(percent) * factor
            
            if self.lastDrawColumn.count > itemIndex {
                let lastY = self.lastDrawColumn[itemIndex]
                y -= height - lastY
            }
            
            lastColumn += [y]
            
            path.addLine(to: CGPoint(x: x, y: y))
            
            x += step
            itemIndex += 1
        }
        
        if self.lastDrawColumn.count > 0 {
            bottomY = self.lastDrawColumn.last!
        }
        path.addLine(to: CGPoint(x: x - step, y: bottomY))
        
        for item in self.lastDrawColumn.reversed() {
            x -= step
            path.addLine(to: CGPoint(x: x, y: item))
        }
        
        path.close()
        
        self.lastDrawColumn = lastColumn
        
        return path
    }
    
    private func drawLine(_ column: [Int], index: Int, type: BSType?) -> UIBezierPath {
        guard let type = type else {
            return UIBezierPath()
        }
        
        if column.count < 1 {
            return UIBezierPath()
        }
        
        var mmIndex = index
        if mmIndex >= self.min.count {
            mmIndex = self.min.count - 1
        }
        
        let min = self.min[mmIndex]
        let max = self.max[mmIndex]
        
        let path = UIBezierPath()
        let height = self.frame.height
        let factor = height / CGFloat(abs(max) - abs(min))
        
        let step = self.frame.size.width / CGFloat(column.count)
        var y = height - CGFloat(column.first!) * factor + CGFloat(min) * factor
        
        if type == .line {
            path.move(to: CGPoint(x: 0, y: y))
        }
        
        y = height - CGFloat(column.first!) * factor + CGFloat(min) * factor
        for index in 0...column.count - 1 {
            let x = CGFloat(index) * step + self.offset
            
            if type == .bar {
                path.move(to: CGPoint(x: x, y: height))
            }
            
            path.addLine(to: CGPoint(x: x, y: y))
            
            if type == .bar {
                path.addLine(to: CGPoint(x: x + step, y: y))
                path.addLine(to: CGPoint(x: x + step, y: height))
                path.close()
            }
        }
        
        return path
    }

}
