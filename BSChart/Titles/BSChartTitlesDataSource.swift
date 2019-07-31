//
//  BSChartTitlesDataSource.swift
//  BSChart
//
//  Created by iBlacksus on 4/15/19.
//  Copyright © 2019 iBlacksus. All rights reserved.
//

import UIKit

class BSChartTitlesDataSource: NSObject, UICollectionViewDataSource {
    
    public var items: Array<BSChartItem> = []
    public var enabledItems: Array<String> = []
    
    private var collectionView: BSChartTitlesCollectionView!
    
    init(collectionView: BSChartTitlesCollectionView) {
        super.init()
        
        self.collectionView = collectionView
        self.collectionView.register(UINib(nibName: BSChartTitleCell.reusableIdentifier, bundle: nil), forCellWithReuseIdentifier: BSChartTitleCell.reusableIdentifier)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: BSChartTitleCell.reusableIdentifier, for: indexPath) as! BSChartTitleCell
        let item = self.items[indexPath.row]
        let enabled = self.enabledItems.contains(item.key)
        cell.configure(self.items[indexPath.row], enabled: enabled, row: indexPath.row)
        
        cell.singleSelectHandler = { (row) in
            self.singleSelect(row)
        }
        
        return cell
    }
    
    private func singleSelect(_ row: Int) {
        let item = self.items[row]
        self.enabledItems = [item.key]
        
        for i in 0...self.items.count - 1 {
            let indexPath = IndexPath(item: i, section: 0)
            let cell = self.collectionView.cellForItem(at: indexPath) as! BSChartTitleCell
            cell.enable(i == row)
        }
        
        NotificationCenter.default.post(name: .chartEnabledItemsChanged, object: nil, userInfo: ["section": self.collectionView.section!, "items": self.enabledItems])
    }

}
