//
//  BSArrowView.swift
//  BSChart
//
//  Created by iBlacksus on 3/22/19.
//  Copyright © 2019 iBlacksus. All rights reserved.
//

import UIKit

@IBDesignable
class BSArrowView: UIView {
    
    @IBInspectable var leftSide: Bool = true
    private var arrowLayer: CAShapeLayer!

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let path = UIBezierPath()
        if self.leftSide {
            path.move(to: CGPoint(x: rect.width, y: 0))
            path.addLine(to: CGPoint(x: 0, y: rect.height / 2.0))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        }
        else {
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height / 2.0))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
        }
        
        
        if self.arrowLayer != nil {
            self.arrowLayer.removeFromSuperlayer()
        }
        
        self.arrowLayer = CAShapeLayer()
        self.arrowLayer.path = path.cgPath
        self.arrowLayer.strokeColor = UIColor(white: 1.0, alpha: 0.6).cgColor
        self.arrowLayer.fillColor = UIColor.clear.cgColor
        self.arrowLayer.lineWidth = 1.5
        self.arrowLayer.lineCap = CAShapeLayerLineCap.round
        
        self.layer.addSublayer(self.arrowLayer)
    }
    
}
