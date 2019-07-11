//
//  BSChartDateCell.swift
//  BSChart
//
//  Created by iBlacksus on 3/15/19.
//  Copyright © 2019 iBlacksus. All rights reserved.
//

import UIKit

class BSChartDateCell: UICollectionViewCell {
    
    class var reusableIdentifier: String {
        return "BSChartDateCell"
    }
    
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(colorModeChanged), name: .chartColorModeChanged, object: nil)
        self.colorModeChanged()
    }
    
    public func configure(item: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM"
        
        self.label.text = dateFormatter.string(from: item)
    }
    
    @objc func colorModeChanged() {
        UIView.animate(withDuration: 0.25) {
            self.label.textColor = BSColorModeManager.shared.colorForItem(.dateCellText)
        }
    }

}
