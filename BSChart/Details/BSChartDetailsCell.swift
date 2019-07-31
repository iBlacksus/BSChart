//
//  BSChartDetailsCell.swift
//  BSChart
//
//  Created by iBlacksus on 4/14/19.
//  Copyright © 2019 iBlacksus. All rights reserved.
//

import UIKit

class BSChartDetailsCell: BSChartBaseCell {

    class var reusableIdentifier: String {
        return "BSChartDetailsCell"
    }
    
    @IBOutlet var percentLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
    
    @IBOutlet var percentTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var percentWidthConstraint: NSLayoutConstraint!
    
    func configure(name: String, value: Int, color: UIColor, percentage: Bool = false, sum: Int = 1) {
        let sum = max(sum, 1)
        
        self.backgroundColor = BSColorModeManager.shared.colorForItem(.chartDetailsBackground)
        self.contentView.backgroundColor = BSColorModeManager.shared.colorForItem(.chartDetailsBackground)
        
        if !percentage {
            self.percentTrailingConstraint.constant = 0
            self.percentWidthConstraint.constant = 0
            self.percentLabel.text = nil
        }
        else {
            self.percentTrailingConstraint.constant = 4
            self.percentWidthConstraint.constant = 25
            let percent: CGFloat = CGFloat(value) / CGFloat(sum) * 100
            self.percentLabel.text = String(Int(percent.rounded())) + "%"
        }
        
        self.nameLabel.text = name
        self.valueLabel.text = String(value)
        self.valueLabel.textColor = color
    }
    
    class func height() -> CGFloat {
        return 20
    }
    
    override func colorModeChanged() {
        UIView.animate(withDuration: 0.25) {
            self.percentLabel.textColor = BSColorModeManager.shared.colorForItem(.chartDetailsText)
            self.nameLabel.textColor = BSColorModeManager.shared.colorForItem(.chartDetailsText)
        }
    }
    
}
