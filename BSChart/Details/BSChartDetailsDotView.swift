//
//  BSChartDetailsDotView.swift
//  BSChart
//
//  Created by iBlacksus on 3/21/19.
//  Copyright © 2019 iBlacksus. All rights reserved.
//

import UIKit

class BSChartDetailsDotView: UIView {

    init(color: UIColor?) {
        super.init(frame: CGRect(x: 0, y: 0, width: 8, height: 8))
        
        self.backgroundColor = BSColorModeManager.shared.colorForItem(.cellBackground)
        self.layer.cornerRadius = self.frame.width / 2.0
        self.layer.borderWidth = 1.5
        self.clipsToBounds = true
        self.alpha = 0
        
        if color != nil {
            self.layer.borderColor = color!.cgColor
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
