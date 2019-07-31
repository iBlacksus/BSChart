//
//  BSTitlesCollectionView.swift
//  BSChart
//
//  Created by iBlacksus on 4/15/19.
//  Copyright © 2019 iBlacksus. All rights reserved.
//

import UIKit

class BSChartTitlesCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    private var chartTitlesDataSource: BSChartTitlesDataSource!
    public var section: Int!

    required init?(coder aDecoder: NSCoder) {
        super .init(coder: aDecoder)
        
        self.chartTitlesDataSource = BSChartTitlesDataSource(collectionView: self)
        self.dataSource = self.chartTitlesDataSource
        self.delegate = self
        
        let layout = self.collectionViewLayout as! BSChartTitlesFlowLayout
        layout.horizontalAlignment = .left
        layout.minimumLineSpacing = 6.0
        layout.minimumInteritemSpacing = 6.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let item = self.chartTitlesDataSource?.items[indexPath.row] else {
            return CGSize(width: 0, height: 0)
        }
        
        return BSChartTitleCell.sizeForItem(item.name)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.reloadData()
    }
    
    public func configure(items: Array<BSChartItem>, enabledItems: Array<String>, section: Int) {
        self.section = section
        self.chartTitlesDataSource.items = items
        self.chartTitlesDataSource.enabledItems = enabledItems
        self.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! BSChartTitleCell
        let item = self.chartTitlesDataSource.items[indexPath.row]
        var enabledItems = self.chartTitlesDataSource.enabledItems
        
        if enabledItems.contains(item.key) {
            if enabledItems.count <= 1 {
                cell.shake()
                return
            }
            
            let index = enabledItems.firstIndex(of: item.key)
            enabledItems.remove(at: index!)
            cell.enable(false)
        }
        else {
            enabledItems.append(item.key)
            cell.enable(true)
        }
        
        self.chartTitlesDataSource.enabledItems = enabledItems
        
        NotificationCenter.default.post(name: .chartEnabledItemsChanged, object: nil, userInfo: ["section": self.section!, "items": enabledItems])
    }
}
