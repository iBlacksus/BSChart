//
//  BSChartMapView.swift
//  BSChart
//
//  Created by iBlacksus on 3/14/19.
//  Copyright © 2019 iBlacksus. All rights reserved.
//

import UIKit

class BSChartMapView: BSChartBaseView, UIGestureRecognizerDelegate {
    
    class var identifier: String {
        return "BSChartMapView"
    }
    
    @IBOutlet weak var chartView: BSChartView!
    @IBOutlet weak var windowView: UIView!
    @IBOutlet weak var leftArrowView: BSArrowView!
    @IBOutlet weak var rightArrowView: BSArrowView!
    @IBOutlet weak var windowCenterView: UIView!
    @IBOutlet weak var leftOverlayView: UIView!
    @IBOutlet weak var rightOverlayView: UIView!
    @IBOutlet weak var leftBorderView: UIView!
    @IBOutlet weak var topBorderView: UIView!
    @IBOutlet weak var rightBorderView: UIView!
    @IBOutlet weak var bottomBorderView: UIView!
    @IBOutlet weak var leftArrowPanGesture: UIPanGestureRecognizer!
    @IBOutlet weak var rightArrowPanGesture: UIPanGestureRecognizer!
    @IBOutlet weak var windowPanGesture: UIPanGestureRecognizer!
    
    @IBOutlet weak var windowViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var windowViewTrailingConstraint: NSLayoutConstraint!
    
    public var dataChangedHandler: ((_ left: CGFloat, _ width: CGFloat) -> Void)? = nil
    
    private var panLastX: CGFloat = 0.0
    private let windowViewWidthMin: CGFloat = 60.0
    private var items: Array<BSChartItem> = []
    private var min: [Int] = []
    private var max: [Int] = []
    private var left: CGFloat = 0
    private var width: CGFloat = 0
    private var section: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.windowView.layer.cornerRadius = 5
        self.layer.cornerRadius = 5
        
        NotificationCenter.default.addObserver(self, selector: #selector(colorModeChanged), name: .chartColorModeChanged, object: nil)
        self.colorModeChanged()
    }
    
    public func configure(_ items: Array<BSChartItem>, min: [Int], max: [Int], left: CGFloat, width: CGFloat, section: Int) {
        self.items = items
        self.min = min
        self.max = max
        self.left = left
        self.width = width
        
        self.chartView.configure(items, min: min, max: max, offset: 0, section: self.section)
        self.updatePosition()
        self.dataChanged()
    }
    
    private func updatePosition() {
        var width, trailing: CGFloat
        if self.left == 0 && self.width == 0 {
            trailing = 0
            width = windowViewWidthMin
        }
        else {
            let widthFactor = self.frame.width / 100.0
            width = Swift.max(Swift.min(widthFactor * self.width, self.frame.width), windowViewWidthMin)
            trailing = Swift.min(Swift.max(self.frame.width - width - widthFactor * self.left, 0), self.frame.width - width)
        }
        
        self.windowViewTrailingConstraint.constant = trailing
        self.windowViewWidthConstraint.constant = width
    }
    
    @objc func colorModeChanged() {
        UIView.animate(withDuration: 0.25) {
            self.leftOverlayView.backgroundColor = BSColorModeManager.shared.colorForItem(.mapOverlay)
            self.rightOverlayView.backgroundColor = BSColorModeManager.shared.colorForItem(.mapOverlay)
            self.leftBorderView.backgroundColor = BSColorModeManager.shared.colorForItem(.mapWindow)
            self.topBorderView.backgroundColor = BSColorModeManager.shared.colorForItem(.mapWindow)
            self.rightBorderView.backgroundColor = BSColorModeManager.shared.colorForItem(.mapWindow)
            self.bottomBorderView.backgroundColor = BSColorModeManager.shared.colorForItem(.mapWindow)
        }
    }
    
    @IBAction func leftArrowPan(_ sender: UIPanGestureRecognizer) {
        self.gestureChanged(sender)
        
        let point = sender.translation(in: self.windowView.superview)
        let offset = point.x - self.panLastX
        var width = self.windowViewWidthConstraint.constant - offset
        if width < windowViewWidthMin {
            width = windowViewWidthMin
        }
        
        if width > self.frame.size.width - self.windowViewTrailingConstraint.constant {
            width = self.frame.size.width - self.windowViewTrailingConstraint.constant - 0.1
        }
        
        self.windowViewWidthConstraint.constant = width
        self.panLastX = point.x
        
        self.dataChanged()
    }
    
    
    @IBAction func rightArrowPan(_ sender: UIPanGestureRecognizer) {
        self.gestureChanged(sender)
        
        let point = sender.translation(in: self.windowView.superview)
        let offset = point.x - self.panLastX
        var width = self.windowViewWidthConstraint.constant + offset
        
        if width < windowViewWidthMin {
            return
        }
        
        var trailing = self.windowViewTrailingConstraint.constant - offset
        
        if trailing < 0 {
            trailing = 0
            width = self.frame.size.width - self.windowView.frame.origin.x - trailing - 0.1
        }
        
        self.windowViewWidthConstraint.constant = width
        self.windowViewTrailingConstraint.constant = trailing
        
        self.panLastX = point.x
        
        self.dataChanged()
    }
    
    @IBAction func movePan(_ sender: UIPanGestureRecognizer) {
        self.gestureChanged(sender)
        
        if (sender.state == .cancelled) {
            return
        }
        
        let point = sender.translation(in: self.windowView.superview)
        let offset = point.x - self.panLastX
        
        var trailing = self.windowViewTrailingConstraint.constant - offset
        if trailing < 0 {
            trailing = 0
        }
        
        if trailing > self.frame.size.width - self.windowViewWidthConstraint.constant {
            trailing = self.frame.size.width - self.windowViewWidthConstraint.constant - 0.1
        }
        
        self.windowViewTrailingConstraint.constant = trailing
        self.panLastX = point.x
        
        self.dataChanged()
    }
    
    private func gestureChanged(_ sender: UIPanGestureRecognizer) {
        var enabled = true
        switch sender.state {
        case .began:
            self.panLastX = 0
            enabled = false
        case .ended:
            enabled = true
        default:
            return
        }
        
        let gestures = [self.leftArrowPanGesture, self.windowPanGesture, self.rightArrowPanGesture]
        for gesture in gestures {
            if gesture == sender {
                continue
            }
            
            gesture?.isEnabled = enabled
        }
    }
    
    private func dataChanged() {
        guard let handler = self.dataChangedHandler else {
            return
        }
        
        let left = self.windowView.frame.minX / self.frame.width * 100.0
        let width = self.windowView.frame.width / self.frame.width * 100.0
        
        handler(left, width)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
