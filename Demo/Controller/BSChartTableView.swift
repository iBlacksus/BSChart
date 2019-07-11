//
//  BSChartCollectionView.swift
//  BSChart
//
//  Created by iBlacksus on 3/12/19.
//  Copyright © 2019 iBlacksus. All rights reserved.
//

import UIKit

class BSChartTableView: UITableView, UITableViewDelegate, UIGestureRecognizerDelegate {

    private var chartDataSource: BSChartDataSource!
    private var chartList: BSChartList = []
    
    required init?(coder aDecoder: NSCoder) {
        super .init(coder: aDecoder)
        
        self.chartDataSource = BSChartDataSource(tableView: self)
        self.dataSource = self.chartDataSource
        self.delegate = self
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(colorModeChanged), name: .chartColorModeChanged, object: nil)
        self.colorModeChanged()
    }
    
    public func configure(_ chartList: BSChartList) {
        self.chartList = chartList
        
        self.chartDataSource.enabledItems = []
        for chart in chartList {
            let lineItems = BSChartItemsHelper.getLineItems(chart.items)
            var chartEnabledItems: Array<String> = []
            for item in lineItems {
                chartEnabledItems += [item.key]
            }
            
            self.chartDataSource.enabledItems += [chartEnabledItems]
        }
        
        self.chartDataSource.chartList = chartList
        self.reloadData()
    }
    
    @objc func colorModeChanged() {
        UIView.animate(withDuration: 0.25) {
            self.backgroundColor = BSColorModeManager.shared.colorForItem(.tableViewBackground)
            self.separatorColor = BSColorModeManager.shared.colorForItem(.tableViewSeparator)
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 360.0
        }
        
        let chart = self.chartList[indexPath.section]
        let lineItems = BSChartItemsHelper.getLineItems(chart.items)
        
        var width: CGFloat = 32.0
        let step: CGFloat = 38.0
        var height: CGFloat = step
        for item in lineItems {
            let itemWidth = BSChartTitleCell.sizeForItem(item.name).width + 4.0
            width += itemWidth
            if width > self.frame.width {
                height += step
                width = 32.0 + itemWidth
            }
        }

        return height
    }
    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return false
//    }
    
}
