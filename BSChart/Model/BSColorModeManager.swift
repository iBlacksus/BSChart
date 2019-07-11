//
//  BSColorModeHelper.swift
//  BSChart
//
//  Created by iBlacksus on 3/19/19.
//  Copyright © 2019 iBlacksus. All rights reserved.
//

import UIKit

enum BSColorMode {
    case day
    case night
}

enum BSColorItem {
    case navigationBarBackground
    case navigationBarText
    case tableViewBackground
    case tableViewSeparator
    case cellBackground
    case gridViewSeparator
    case gridCellText
    case chartDetailsBackground
    case chartDetailsText
    case chartDetailsLine
    case titleCellText
    case mapOverlay
    case mapWindow
    case dateCellText
    case detailsViewOverlay
}

class BSColorModeManager: NSObject {
    
    static let shared = BSColorModeManager()
    
    public var colorMode: BSColorMode = .day
    
    public func changeMode() {
        self.colorMode = self.colorMode == .day ? .night : .day
        
        NotificationCenter.default.post(name: .chartColorModeChanged, object: nil)
    }
    
    public func colorForItem(_ item: BSColorItem) -> UIColor {
        return self.colorForItem(item, mode: self.colorMode)
    }
    
    public func colorForItem(_ item: BSColorItem, mode: BSColorMode) -> UIColor {
        let colors: Dictionary<BSColorItem, [BSColorMode:[CGFloat]]> = [
            .navigationBarBackground:   [.day:[248, 248, 248],      .night:[52, 64, 80]],
            .navigationBarText:         [.day:[0, 0, 0],            .night:[255, 255, 255]],
            .tableViewBackground:       [.day:[242, 242, 246],      .night:[40, 49, 61]],
            .tableViewSeparator:        [.day:[24, 45, 59, 0.1],    .night:[133, 150, 171, 0.2]],
            .cellBackground:            [.day:[254, 254, 254],      .night:[52, 64, 80]],
            .gridViewSeparator:         [.day:[24, 45, 59, 0.1],    .night:[133, 150, 171, 0.2]],
            .gridCellText:              [.day:[142, 142, 147],      .night:[133, 150, 171]],
            .chartDetailsBackground:    [.day:[246, 246, 251],      .night:[44, 56, 71]],
            .chartDetailsText:          [.day:[128, 128, 132],      .night:[255, 255, 255]],
            .chartDetailsLine:          [.day:[24, 45, 59, 0.1],    .night:[133, 150, 171, 0.2]],
            .titleCellText:             [.day:[0, 0, 0],            .night:[255, 255, 255]],
            .mapOverlay:                [.day:[226, 238, 249, 0.6], .night:[24, 34, 45, 0.6]],
            .mapWindow:                 [.day:[192, 209, 225],      .night:[86, 98, 109]],
            .dateCellText:              [.day:[168, 172, 176],      .night:[116, 127, 142]],
            .detailsViewOverlay:        [.day:[255, 255, 255, 0.5], .night:[33, 47, 63, 0.5]],
        ]
        
        let color: Dictionary<BSColorMode, [CGFloat]> = colors[item]!
        
        return self.createColor(rgb: color[mode]!)
    }
    
    private func createColor(rgb: Array<CGFloat>) -> UIColor {
        let alpha: CGFloat = rgb.count > 3 ? rgb[3] : 1.0
        
        return UIColor(red: rgb[0] / 255.0, green: rgb[1] / 255.0, blue: rgb[2] / 255.0, alpha: alpha)
    }
    
}
