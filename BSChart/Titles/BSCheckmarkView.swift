//
//  BSCheckmarkView.swift
//  BSChart
//
//  Created by iBlacksus on 4/15/19.
//  Copyright © 2019 iBlacksus. All rights reserved.
//

import UIKit

class BSCheckmarkView: UIView {

    private var checkmarkLayer: CAShapeLayer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: rect.height - rect.height / 3.0))
        path.addLine(to: CGPoint(x: rect.width / 3.0, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        
        if self.checkmarkLayer != nil {
            self.checkmarkLayer.removeFromSuperlayer()
        }
        
        self.checkmarkLayer = CAShapeLayer()
        self.checkmarkLayer.path = path.cgPath
        self.checkmarkLayer.strokeColor = UIColor(white: 1.0, alpha: 1.0).cgColor
        self.checkmarkLayer.fillColor = UIColor.clear.cgColor
        self.checkmarkLayer.lineWidth = 1.5
        self.checkmarkLayer.lineCap = CAShapeLayerLineCap.round
        
        self.layer.addSublayer(self.checkmarkLayer)
    }

}
