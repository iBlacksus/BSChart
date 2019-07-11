//
//  BSChartDatesDataSource.swift
//  BSChart
//
//  Created by iBlacksus on 3/15/19.
//  Copyright © 2019 iBlacksus. All rights reserved.
//

import UIKit

class BSChartDatesDataSource: NSObject, UICollectionViewDataSource {
    private var collectionView: BSChartDatesCollectionView!
    public var items: Array<Date> = []
    
    init(collectionView: BSChartDatesCollectionView) {
        super.init()
        
        self.collectionView = collectionView
        self.collectionView.register(UINib(nibName: BSChartDateCell.reusableIdentifier, bundle: nil), forCellWithReuseIdentifier: BSChartDateCell.reusableIdentifier)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: BSChartDateCell.reusableIdentifier, for: indexPath) as! BSChartDateCell
        cell.configure(item: self.items[indexPath.row])
        
        return cell
    }
}
