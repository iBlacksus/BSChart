//
//  BSChartGridView.swift
//  BSChart
//
//  Created by iBlacksus on 3/14/19.
//  Copyright © 2019 iBlacksus. All rights reserved.
//

import UIKit

class BSChartGridView: BSChartBaseView {

    class var identifier: String {
        return "BSChartGridView"
    }
    
    @IBOutlet weak var tableView: BSChartGridTableView!
    @IBOutlet weak var chartView: BSChartView!
    @IBOutlet weak var separator: UIView!
    @IBOutlet var dateLabel: UILabel!
    
    @IBOutlet weak var chartViewTopConstraint: NSLayoutConstraint!
    
    private var chartDetailsView: BSChartDetailsView!
    private var items: Array<BSChartItem> = []
    private var min: [Int] = []
    private var max: [Int] = []
    private var section: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.loadInterface()
        
        NotificationCenter.default.addObserver(self, selector: #selector(colorModeChanged), name: .chartColorModeChanged, object: nil)
        self.colorModeChanged()
    }
    
    public func configure(_ items: Array<BSChartItem>, min: [Int], max: [Int], offset: CGFloat, section: Int) {
        self.items = items
        self.min = min
        self.max = max
        self.section = section
        self.updateDate()
        
        guard let item = items.first else {
            return
        }
        
        self.chartViewTopConstraint.constant = item.percentage ? 53 : 33
        
        let lineItems = BSChartItemsHelper.getLineItems(items)
        self.tableView.configure(lineItems, min: min, max: max)
        self.chartView.configure(lineItems, min: min, max: max, offset: offset, section: self.section)
        self.chartDetailsView.configure(items, min: min, max: max, offset: offset, section: self.section)
    }
    
    private func loadInterface() {
        self.chartDetailsView = (UINib(nibName: BSChartDetailsView.identifier, bundle: nil).instantiate(withOwner: self, options: nil)[0] as! BSChartDetailsView)
        self.addSubview(self.chartDetailsView)
        
        let views: [String: Any] = ["chartDetailsView": self.chartDetailsView!]
        
        var allConstraints: [NSLayoutConstraint] = []
        
        let verticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-33-[chartDetailsView]|",
            metrics: nil,
            views: views)
        allConstraints += verticalConstraints
        
        let horizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[chartDetailsView]|",
            metrics: nil,
            views: views)
        allConstraints += horizontalConstraints
        
        NSLayoutConstraint.activate(allConstraints)
    }
    
    func updateDate() {
        guard let first = self.items.first?.column?.first, let last = self.items.first?.column?.last else {
            return
        }
        
        let firstDate: String = self.formatDate(first)
        let lastDate: String = self.formatDate(last)
        if firstDate == lastDate {
            self.dateLabel.text = self.formatDate(first, extended: true)
            return
        }
        
        self.dateLabel.text = firstDate + " - " + lastDate
    }
    
    func formatDate(_ date: Int, extended: Bool = false) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(date) / 1000.0)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = extended ? "EEEE, d MMM yyyy" : "d MMM yyyy"
        return dateFormatter.string(from: date)
    }
    
    @objc func colorModeChanged() {
        UIView.animate(withDuration: 0.25) {
            self.separator.backgroundColor = BSColorModeManager.shared.colorForItem(.tableViewSeparator)
            self.dateLabel.textColor = BSColorModeManager.shared.colorForItem(.titleCellText)
        }
    }
    
}
