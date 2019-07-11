//
//  BSChartGridDataSource.swift
//  BSChart
//
//  Created by iBlacksus on 3/15/19.
//  Copyright © 2019 iBlacksus. All rights reserved.
//

import UIKit

class BSChartGridDataSource: NSObject, UITableViewDataSource {
    private var tableView: UITableView!
    public var items: Array<Array<Int>> = []
    public var colors: Array<UIColor> = []
    public var leftLabels: Bool = true
    public var yScaled: Bool = false
    
    init(tableView: UITableView) {
        super.init()
        
        self.tableView = tableView
        self.tableView.register(UINib(nibName: BSChartGridCell.reusableIdentifier, bundle: Bundle(for: BSChartGridCell.self)), forCellReuseIdentifier: BSChartGridCell.reusableIdentifier)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let item = self.items.first else {
            return 0
        }
        
        return item.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: BSChartGridCell.reusableIdentifier, for: indexPath) as! BSChartGridCell
        guard let firstItem = self.items.first, let lastItem = self.items.last else {
            return cell
        }
        
        cell.configureWithItems(items: [firstItem[indexPath.row], lastItem[indexPath.row]], colors: self.colors, left: leftLabels, yScaled: yScaled)
        
        return cell
    }
}
