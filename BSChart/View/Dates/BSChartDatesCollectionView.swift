//
//  BSChartDatesCollectionView.swift
//  BSChart
//
//  Created by iBlacksus on 3/15/19.
//  Copyright © 2019 iBlacksus. All rights reserved.
//

import UIKit

class BSChartDatesCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    private var chartDatesDataSource: BSChartDatesDataSource?
    private var items: Array<Date> = []
    private var left: CGFloat = 0.0
    private var width: CGFloat = 0.0
    private var updateInProgress: Bool = false
    private var needUpdate: Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        super .init(coder: aDecoder)
        
        self.chartDatesDataSource = BSChartDatesDataSource(collectionView: self)
        self.dataSource = self.chartDatesDataSource
        self.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = self.frame.size.height
        let width = self.contentSize.width / CGFloat(self.items.count)
        
        return CGSize(width: width, height: height)
    }
    
//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//
//        self.reloadData()
//    }
    
    public func configure(items: Array<Date>, left: CGFloat, width: CGFloat) {
        self.items = items
        self.left = left
        self.width = width
        
        if items.count < 1 {
            self.chartDatesDataSource?.items = []
            self.reloadData()
            return
        }
        
        self.chartDatesDataSource?.items = items
        
        if self.updateInProgress {
            self.needUpdate = true
            return
        }
        
        self.needUpdate = false
        self.updateWithAnimation()
    }
    
    private func updateWithAnimation() {
        self.updateInProgress = true
        
        UIView.transition(with: self, duration: 0.25, options: .transitionCrossDissolve, animations: {
            if self.items.count > 0 && self.width > 0 {
                let fullWidth = self.frame.width / self.width * 100.0
                self.contentSize = CGSize(width: fullWidth, height: self.frame.height)
                self.updateOffset(left: self.left)
            }
            else {
                self.contentSize = CGSize(width: 0, height: 0)
            }
            
            self.reloadData()
        }, completion: nil)
        
        let deadlineTime = DispatchTime.now() + .milliseconds(250)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.updateInProgress = false
            
            if self.needUpdate {
                self.needUpdate = false
                self.updateWithAnimation()
            }
        }
    }
    
    public func updateOffset(left: CGFloat) {
        if self.items.count == 0 || self.width == 0 {
            return
        }
        
        let fullWidth = self.frame.width / self.width * 100.0
        self.contentOffset.x = fullWidth / 100.0 * left
    }

}
