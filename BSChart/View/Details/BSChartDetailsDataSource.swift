//
//  BSChartDetailsDataSource.swift
//  BSChart
//
//  Created by iBlacksus on 4/14/19.
//  Copyright © 2019 iBlacksus. All rights reserved.
//

import UIKit

class BSChartDetailsDataSource: NSObject, UITableViewDataSource {
    
    public var names: Array<String> = []
    public var values: Array<Int> = []
    public var colors: Array<UIColor> = []
    public var percentage: Bool = false
    
    private var tableView: UITableView!
    private var sum: Int = 1
    
    init(tableView: UITableView) {
        super.init()
        
        self.tableView = tableView
        tableView.register(UINib(nibName: BSChartDetailsCell.reusableIdentifier, bundle: Bundle(for: BSChartDetailsCell.self)), forCellReuseIdentifier: BSChartDetailsCell.reusableIdentifier)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BSChartDetailsCell.reusableIdentifier, for: indexPath) as! BSChartDetailsCell
        
        if percentage {
            self.sum = 0
            for value in self.values {
                self.sum += value
            }
        }
        
        cell.configure(name: self.names[indexPath.row], value: self.values[indexPath.row], color: self.colors[indexPath.row], percentage: self.percentage, sum: self.sum)
        
        return cell
    }
    
}
