//
//  BSChartTitleCell.swift
//  BSChart
//
//  Created by iBlacksus on 4/15/19.
//  Copyright © 2019 iBlacksus. All rights reserved.
//

import UIKit
//import AudioToolbox

class BSChartTitleCell: UICollectionViewCell {

    class var reusableIdentifier: String {
        return "BSChartTitleCell"
    }
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var checkmarkView: UIView!
    
    @IBOutlet var checkmarkViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var titleLabelLeadingConstraint: NSLayoutConstraint!
    
    public var singleSelectHandler: ((_ row: Int) -> Void)? = nil
    
    private var item: BSChartItem!
    private var row: Int!
    private var enabled: Bool = false
    private var lognTapGesture: UILongPressGestureRecognizer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.clear.cgColor
        
        self.lognTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        self.addGestureRecognizer(self.lognTapGesture)
    }
    
    class func sizeForItem(_ item: String) -> CGSize {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: 30.0)
        let frame = item.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: UIFont.boldSystemFont(ofSize: 13.0)], context: nil)
        let width = 8.0 + 11.0 + 8.0 + frame.width + 8.0
        
        return CGSize(width: width, height: 30)
    }
    
    public func configure(_ item: BSChartItem, enabled: Bool, row: Int) {
        self.item = item
        self.row = row
        
        self.titleLabel.text = item.name
        self.enable(enabled, force: true)
    }
    
    public func enable(_ enable: Bool, force: Bool = false) {
        if enable == self.enabled && !force{
            return
        }
        
        var textColor: UIColor!
        
        UIView.animate(withDuration: force ? 0 : 0.25) {
            if enable {
                self.layer.borderColor = UIColor.clear.cgColor
                textColor = .white
                self.backgroundColor = self.item.color
                self.checkmarkViewLeadingConstraint.constant = 8
                self.titleLabelLeadingConstraint.constant = 8
                self.checkmarkView.alpha = 1
            }
            else {
                self.layer.borderColor = self.item.color.cgColor
                textColor = self.item.color
                self.backgroundColor = .clear
                self.checkmarkViewLeadingConstraint.constant = -self.checkmarkView.frame.width
                self.titleLabelLeadingConstraint.constant = 8 + self.checkmarkView.frame.width
                self.checkmarkView.alpha = 0
            }
            
            self.layoutIfNeeded()
        }
        
        UIView.transition(with: self.titleLabel, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.titleLabel.textColor = textColor
        })
        
        self.enabled = enable
    }
    
    public func shake() {
        UIView.animate(withDuration: 0.1, animations: {
            self.checkmarkViewLeadingConstraint.constant = -self.checkmarkView.frame.width
            self.layoutIfNeeded()
        }) { (completion) in
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            
            UIView.animate(withDuration: 0.1, animations: {
                self.checkmarkViewLeadingConstraint.constant = 8
                self.layoutIfNeeded()
            }) { (completion) in
//                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()
            }
        }
    }
    
    @objc func longTap() {
        guard let handler = self.singleSelectHandler else {
            return
        }

        handler(row)
    }
    

}
