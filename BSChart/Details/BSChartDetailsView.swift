//
//  BSChartDetailsView.swift
//  BSChart
//
//  Created by iBlacksus on 3/19/19.
//  Copyright © 2019 iBlacksus. All rights reserved.
//

import UIKit

class BSChartDetailsView: BSChartBaseView, UIGestureRecognizerDelegate {
    
    class var identifier: String {
        return "BSChartDetailsView"
    }

    @IBOutlet var lineView: UIView!
    @IBOutlet var detailsView: UIView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var chartDetailsTableView: BSChartDetailsTableView!
    @IBOutlet weak var panGesture: UIPanGestureRecognizer!
    
    @IBOutlet var lineViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var detailsViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var detailsViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var lineViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var detailsViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var detailsViewWidthConstraint: NSLayoutConstraint!
    
    private var items: Array<BSChartItem> = []
    private var max: [Int] = []
    private var min: [Int] = []
    private var dotViews: Array<BSChartDetailsDotView> = []
    private var isBar: Bool = false
    private var isArea: Bool = false
    private var percentage: Bool = false
    private var stacked: Bool = false
    private var showSum: Bool = false
    private var leftSide: Bool = true
    private var section: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.lineView.alpha = 0
        self.detailsView.alpha = 0
        self.backgroundColor = .clear
        self.detailsView.layer.cornerRadius = 4
        
        NotificationCenter.default.addObserver(self, selector: #selector(colorModeChanged), name: .chartColorModeChanged, object: nil)
        self.colorModeChanged()
    }
    
    public func configure(_ items: Array<BSChartItem>, min: [Int], max: [Int], offset: CGFloat, section: Int) {
        guard let item = items.last else {
            return
        }
        
        self.isBar = item.type == .bar
        self.isArea = item.type == .area
        self.percentage = item.percentage
        self.stacked = item.stacked
        self.showSum = item.sum
        let recreateDots = self.items.count != items.count
        self.items = items
        self.min = min
        self.max = max
        self.clearLabels()
        self.lineViewTopConstraint.constant = self.percentage ? 20 : -8
        self.detailsViewTopConstraint.constant = self.percentage ? 8 : 0
        self.section = section
        
        if recreateDots && !self.isBar && !self.isArea {
            self.createDots()
        }
        
        var count = items.count
        if (self.isBar && self.stacked) || self.showSum {
            count += 1
        }
        self.detailsViewHeightConstraint.constant = CGFloat(count) * BSChartDetailsCell.height() + 8.0
    }
    
    private func createDots() {
        for dot in self.dotViews {
            dot.removeFromSuperview()
        }
        
        self.dotViews = []
        
        let lineItems = BSChartItemsHelper.getLineItems(self.items)
        for item in lineItems {
            let dot = BSChartDetailsDotView(color: item.color)
            self.addSubview(dot)
            self.dotViews += [dot]
        }
        
        self.bringSubviewToFront(self.detailsView)
    }
    
    private func clearLabels() {
        self.dateLabel.text = nil
    }
    
    private func showDetails(_ show: Bool) {
        if show {
            self.detailsViewWidthConstraint.constant = self.frame.width / 2.0 - 16.0
        }
        else {
            NotificationCenter.default.post(name: .chartRemoveSelection, object: nil)
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            self.lineView.alpha = show && !self.isBar ? 1 : 0
            self.detailsView.alpha = show ? 1 : 0
            
            for dot in self.dotViews {
                dot.alpha = show && !self.isBar ? 1 : 0
            }
        })
    }
    
    @objc func colorModeChanged() {
        UIView.animate(withDuration: 0.25) {
            self.detailsView.backgroundColor = BSColorModeManager.shared.colorForItem(.chartDetailsBackground)
            self.lineView.backgroundColor = BSColorModeManager.shared.colorForItem(.chartDetailsLine)
            self.dateLabel.textColor = BSColorModeManager.shared.colorForItem(.chartDetailsText)
            
            for dot in self.dotViews {
                dot.backgroundColor = BSColorModeManager.shared.colorForItem(.cellBackground)
            }
        }
    }
    
    func getXDetails(_ x: CGFloat) -> CGFloat {
        var xDetails: CGFloat = 0
        
        if self.leftSide {
            xDetails = x - self.detailsView.frame.width - 8.0
            if xDetails < 0 {
                self.leftSide = false
                return self.getXDetails(x)
            }
        }
        else {
            xDetails = x + 8.0
            if xDetails > self.frame.width - self.detailsView.frame.width {
                self.leftSide = true
                return self.getXDetails(x)
            }
        }
        
        return xDetails
    }
    
    @IBAction func pan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            self.showDetails(true)
        case .cancelled, .ended, .failed:
            self.showDetails(false)
            return
        default:
            break
        }
        
        let point = sender.location(in: self)
        let xLine = Swift.max(Swift.min(point.x, self.frame.width - 1), 0)
        let xDetails = Swift.max(Swift.min(self.getXDetails(point.x), self.frame.width - self.detailsView.frame.width - 4.0), 4.0)
        
        self.lineViewLeadingConstraint.constant = xLine
        self.detailsViewLeadingConstraint.constant = xDetails
        
        self.clearLabels()
        var index: Int = -1
        var names: Array<String> = []
        var values: Array<Int> = []
        var colors: Array<UIColor> = []
        for item in self.items {
            index += item.type == .x ? 0 : 1
            
            guard let column = item.column else {
                continue
            }
            
            var columnIndex = Int((CGFloat(column.count - 1) / self.frame.width * xLine).rounded(.toNearestOrEven))
            columnIndex = Swift.max(Swift.min(columnIndex, column.count - 1), 0)
            
            if item.type == .x {
                let date = Date(timeIntervalSince1970: TimeInterval(column[columnIndex]) / 1000.0)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEE, dd MMM yyyy"
                self.dateLabel.text = dateFormatter.string(from: date)
            }
            else {
                names += [item.name]
                values += [column[columnIndex]]
                colors += [item.color!]
                
                var mmIndex = index
                if mmIndex >= self.min.count {
                    mmIndex = self.min.count - 1
                }
                
                let min = self.min[mmIndex]
                let max = self.max[mmIndex]
                
                let step = self.frame.width / CGFloat(column.count - 1)
                let x = CGFloat(columnIndex) * step
                
                if !self.isBar && !self.isArea {
                    let height = self.frame.height
                    let factor = height / CGFloat(abs(max) - abs(min))
                    let y = height - CGFloat(column[columnIndex]) * factor + CGFloat(min) * factor// + 12.0
                    
                    let dot = self.dotViews[index]
                    dot.layer.borderColor = item.color?.cgColor
                    dot.alpha = 1
                    dot.frame.origin.x = x - dot.frame.width / 2.0
                    dot.frame.origin.y = y - dot.frame.height / 2.0
                }
                else if self.isBar {
//                    self.leftOverlayViewWidthConstraint.constant = x
//                    self.leftOverlayViewTrailingConstraint.constant = step
                    NotificationCenter.default.post(name: .chartSelectItem, object: nil, userInfo: ["section": self.section, "item": columnIndex])
                }
            }
        }
        
        guard let dataSource = self.chartDetailsTableView.dataSource as? BSChartDetailsDataSource else {
            return
        }
        
        if (self.isBar && self.stacked) || self.showSum {
            var sum = 0
            for value in values {
                sum += value
            }
            names += ["All"]
            values += [sum]
            colors += [BSColorModeManager.shared.colorForItem(.chartDetailsText)]
        }
        
        dataSource.names = names
        dataSource.values = values
        dataSource.colors = colors
        dataSource.percentage = self.percentage
        self.chartDetailsTableView.reloadData()
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        NSLog("%@", gestureRecognizer)
        
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        if otherGestureRecognizer == self.panGesture {
//            NSLog("%@", otherGestureRecognizer)
//        }
        
        if self.panGesture.state == .changed {
            return false
        }
        
        return true//otherGestureRecognizer.state != .began
    }
    
}
