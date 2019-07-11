//
//  BSChartTableViewDataSource.swift
//  BSChart
//
//  Created by iBlacksus on 3/12/19.
//  Copyright © 2019 iBlacksus. All rights reserved.
//

import UIKit

class BSChartDataSource: NSObject, UITableViewDataSource {
    
    public var enabledItems: Array<Array<String>> = []
    public var left: Dictionary<Int, CGFloat> = [:]
    public var width: Dictionary<Int, CGFloat> = [:]
    public var chartList: BSChartList = []
    
    private var tableView: UITableView!
    
    public init(tableView: UITableView) {
        super.init()
        
        self.tableView = tableView
        for i in 0...4 {
            self.tableView.register(UINib(nibName: BSChartCell.reusableIdentifier, bundle: Bundle(for: BSChartCell.self)), forCellReuseIdentifier: BSChartCell.reusableIdentifier + String(i))
        }
        self.tableView.register(UINib(nibName: BSChartTitlesCell.reusableIdentifier, bundle: Bundle(for: BSChartTitlesCell.self)), forCellReuseIdentifier: BSChartTitlesCell.reusableIdentifier)
        
        NotificationCenter.default.addObserver(self, selector: #selector(enabledItemsChanged), name: .chartEnabledItemsChanged, object: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.chartList.count == 0 ? 0 : self.chartList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let chart = self.chartList[section]
        
        guard let item = chart.items.first else {
            return 0
        }
        
        var count = chart.items.count < 2 ? 0 : 2
        if item.single {
            count = 1
        }
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chart = self.chartList[indexPath.section]
        let enabledItems = self.enabledItems[indexPath.section]
        
        if indexPath.row == 0 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: BSChartCell.reusableIdentifier + String(indexPath.section), for: indexPath) as! BSChartCell
            
            cell.dataChangedHandler = { (section, left, width) in
                self.left[section] = left
                self.width[section] = width
            }
            
            if self.left[indexPath.section] != nil {
                cell.left = self.left[indexPath.section]!
            }
            
            if self.width[indexPath.section] != nil {
                cell.width = self.width[indexPath.section]!
            }
            
            cell.section = indexPath.section
            cell.enabledItems = enabledItems
            cell.items = chart.items
            cell.configure()
            
            return cell
        }
        
        let lineItems = BSChartItemsHelper.getLineItems(chart.items)
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: BSChartTitlesCell.reusableIdentifier, for: indexPath) as! BSChartTitlesCell
        cell.configure(items: lineItems, enabledItems: enabledItems, section: indexPath.section)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "FOLLOWERS"
        case 1:
            return "INTERACTIONS"
        case 2:
            return "FOOD"
        case 3:
            return "VIEWS"
        case 4:
            return "FOOD"
        default:
            return nil
        }
    }
    
    @objc private func enabledItemsChanged(notification: NSNotification) {
        guard let section = notification.userInfo?["section"] as? Int else {
            return
        }
        
        guard let items = notification.userInfo?["items"] as? Array<String> else {
            return
        }
        
        self.enabledItems[section] = items
    }
    
}
