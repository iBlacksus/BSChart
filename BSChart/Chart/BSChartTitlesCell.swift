//
//  BSChartCell.swift
//  BSChart
//
//  Created by iBlacksus on 3/12/19.
//  Copyright © 2019 iBlacksus. All rights reserved.
//

import UIKit

class BSChartTitlesCell: BSChartBaseCell {

    class var reusableIdentifier: String {
        return "BSChartTitlesCell"
    }
    
    @IBOutlet var collectionView: BSChartTitlesCollectionView!
    
    public func configure(items: Array<BSChartItem>, enabledItems: Array<String>, section: Int) {
        self.collectionView.configure(items: items, enabledItems: enabledItems, section: section)
    }

}
