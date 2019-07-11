//
//  BSChartDetailsTableView.swift
//  BSChart
//
//  Created by iBlacksus on 4/14/19.
//  Copyright © 2019 iBlacksus. All rights reserved.
//

import UIKit

class BSChartDetailsTableView: UITableView, UITableViewDelegate {

    private var chartDetailsDataSource: BSChartDetailsDataSource?
    
    required init?(coder aDecoder: NSCoder) {
        super .init(coder: aDecoder)
        
        self.chartDetailsDataSource = BSChartDetailsDataSource(tableView: self)
        self.dataSource = self.chartDetailsDataSource
        self.delegate = self
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return BSChartDetailsCell.height()
    }

}
