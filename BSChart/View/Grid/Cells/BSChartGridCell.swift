//
//  BSChartGridCell.swift
//  BSChart
//
//  Created by iBlacksus on 3/15/19.
//  Copyright © 2019 iBlacksus. All rights reserved.
//

import UIKit

class BSChartGridCell: UITableViewCell {

    class var reusableIdentifier: String {
        return "BSChartGridCell"
    }
    
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    
    private var yScaled: Bool!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.yScaled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(colorModeChanged), name: .chartColorModeChanged, object: nil)
        self.colorModeChanged()
    }
    
    public func configureWithItems(items: [Int], colors: [UIColor]?, left: Bool, yScaled: Bool) {
        guard let leftItem = items.first else {
            return
        }
        
        self.leftLabel.text = self.formatItem(leftItem)
        
        self.yScaled = yScaled
        
        if !yScaled {
            self.leftLabel.isHidden = false
            self.rightLabel.isHidden = true
            self.colorModeChanged()
            return
        }
        
        guard let rightItem = items.last, let leftColor = colors?.first, let rightColor = colors?.last else {
            return
        }
        
        self.rightLabel.text = self.formatItem(rightItem)
        self.leftLabel.textColor = leftColor
        self.rightLabel.textColor = rightColor
        
        if colors?.count == 1 {
            self.leftLabel.isHidden = !left
            self.rightLabel.isHidden = left
        }
        else {
            self.leftLabel.isHidden = false
            self.rightLabel.isHidden = false
        }
    }
    
    func formatItem(_ item: Int) -> String {
        if item > 1000000000 {
            return String(item / 1000000000) + "BN"
        }
        
        if item > 1000000 {
            return String(item / 1000000) + "M"
        }
        
        if item > 1000 {
            let f = CGFloat(item) / 1000.0
            return String(format: "%.1fK", f)
        }
        
        return String(item)
    }
    
    @objc func colorModeChanged() {
        if self.yScaled {
            return
        }
        
        UIView.animate(withDuration: 0.25) {
            self.leftLabel.textColor = BSColorModeManager.shared.colorForItem(.gridCellText)
        }
    }
    
}
