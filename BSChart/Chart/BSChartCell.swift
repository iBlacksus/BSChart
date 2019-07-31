//
//  BSChartCell.swift
//  BSChart
//
//  Created by iBlacksus on 3/13/19.
//  Copyright © 2019 iBlacksus. All rights reserved.
//

import UIKit

class BSChartCell: BSChartBaseCell {
    
    class var reusableIdentifier: String {
        return "BSChartCell"
    }
    
    public var dataChangedHandler: ((_ section: Int, _ left: CGFloat, _ width: CGFloat) -> Void)? = nil
    public var section: Int = 0
    public var items: Array<BSChartItem> = []
    public var enabledItems: Array<String> = []
    public var left: CGFloat = 0.0
    public var width: CGFloat = 0.0
    public var start: Int = 0
    public var count: Int = 0
    
    private var gridView: BSChartGridView!
    private var datesView: BSChartDatesView!
    private var mapView: BSChartMapView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        loadInterface()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.width, bottom: 0, right: 0);
        
        NotificationCenter.default.addObserver(self, selector: #selector(enabledItemsChanged), name: .chartEnabledItemsChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidLoad), name: .chartAppDidLoad, object: nil)
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        self.configure()
//    }
    
//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//
//        self.configure()
//    }
    
    public func configure() {
        self.datesView.item = BSChartItemsHelper.getXItem(self.items)
        self.updateMap()
//        self.dataChanged(true)
    }
    
    private func loadInterface() {
        self.gridView = (UINib(nibName: BSChartGridView.identifier, bundle: nil).instantiate(withOwner: self, options: nil)[0] as! BSChartGridView)
        self.datesView = (UINib(nibName: BSChartDatesView.identifier, bundle: nil).instantiate(withOwner: self, options: nil)[0] as! BSChartDatesView)
        self.mapView = (UINib(nibName: BSChartMapView.identifier, bundle: nil).instantiate(withOwner: self, options: nil)[0] as! BSChartMapView)
        
        self.addSubview(self.gridView)
        self.addSubview(self.datesView)
        self.addSubview(self.mapView)
        
        let views: [String: Any] = [
            "gridView": self.gridView!,
            "datesView": self.datesView!,
            "mapView": self.mapView!]
        
        var allConstraints: [NSLayoutConstraint] = []
        
        let verticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-[gridView][datesView(32)][mapView(38)]-|",
            metrics: nil,
            views: views)
        allConstraints += verticalConstraints
        
        let gridViewConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-[gridView]-|",
            metrics: nil,
            views: views)
        allConstraints += gridViewConstraints
        
        let datesViewConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-[datesView]-|",
            metrics: nil,
            views: views)
        allConstraints += datesViewConstraints

        let mapViewConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-[mapView]-|",
            metrics: nil,
            views: views)
        allConstraints += mapViewConstraints
        
        NSLayoutConstraint.activate(allConstraints)
        
        self.mapViewHandlers()
    }
    
    private func updateData(_ items: Array<BSChartItem>, offset: CGFloat) {
        let lineItems = BSChartItemsHelper.getLineItems(items)
        
        let (min, max) = BSChartItemsHelper.getMinMax(lineItems)
        self.gridView.configure(items, min: min, max: max, offset: offset, section: self.section)
        self.datesView.configure(left: self.left, width: self.width)
    }
    
    private func updateMap() {
        var items: Array<BSChartItem> = []
        for item in BSChartItemsHelper.getLineItems(self.items) {
            if !self.enabledItems.contains(item.key) {
                continue
            }
            
            items += [item]
        }
        
        let (min, max) = BSChartItemsHelper.getMinMax(items)
        self.mapView.configure(items, min: min, max: max, left: self.left, width: self.width, section: self.section)
    }
    
    private func mapViewHandlers() {
        self.mapView.dataChangedHandler = { (left, width) in
            self.left = left
            self.width = width
            
            self.dataChanged()
            
            guard let handler = self.dataChangedHandler else {
                return
            }
            
            handler(self.section, self.left, self.width)
        }
    }
    
    @objc private func enabledItemsChanged(notification: NSNotification) {
        guard let section = notification.userInfo?["section"] as? Int else {
            return
        }
        
        if section != self.section {
            return
        }
        
        guard let items = notification.userInfo?["items"] as? Array<String> else {
            return
        }
        
        self.enabledItems = items
        self.dataChanged(true)
        self.updateMap()
    }
    
    @objc private func appDidLoad() {
        self.configure()
        self.dataChanged(true)
    }
    
    private func dataChanged(_ force: Bool = false) {
        if self.width == 0 {
            return
        }
        
        guard let xItem = BSChartItemsHelper.getXItem(self.items), let column = xItem.column else {
            return
        }
        
        if column.count == 0 {
            return
        }
        
        let start = Int((CGFloat(column.count) / 100.0 * self.left).rounded(.down))
        let count = Int((CGFloat(column.count) / 100.0 * self.width).rounded(.up))
        
        if start == self.start && count == self.count && !force {
            return
        }
        
        self.start = start
        self.count = count
        
//        let leftPixel = self.frame.width / 100.0 * self.left
//        let itemWidth = self.frame.width / CGFloat(count)
//        var offset = (self.frame.width / 100.0 * CGFloat(start) - leftPixel)
//        while offset > itemWidth {
//            offset -= itemWidth
//        }
//        offset *= UIScreen.main.scale
//        NSLog("%f", offset)
        
        var items: Array<BSChartItem> = []
        for item in self.items {
            if !self.enabledItems.contains(item.key) && item.type != .x {
                continue
            }
            
            let slicedItem = BSChartItem()
            slicedItem.copy(item: item, start: start, count: count)
            items += [slicedItem]
        }
        
        self.updateData(items, offset: 0)
    }
    
}
