//
//  BSChartObject.swift
//  BSChartObject
//
//  Created by iBlacksus on 3/11/19.
//  Copyright © 2019 iBlacksus. All rights reserved.
//

import UIKit

class BSChartItem: NSObject {
    public var key: String!
    public var name: String!
    public var type: String?
    public var color: UIColor!
    public var column: [Int]?
    public var yScaled: Bool!
    public var percentage: Bool!
    public var stacked: Bool!
    public var single: Bool!
    public var index: Int!
    
    func copy(item: BSChartItem, start: Int, count: Int) {
        self.key = item.key
        self.name = item.name
        self.type = item.type
        self.color = item.color
        self.yScaled = item.yScaled
        self.percentage = item.percentage
        self.stacked = item.stacked
        self.single = item.single
        self.index = item.index
        
        guard let column = item.column else {
            return
        }
        
        var startIndex = start
        if startIndex < 0 {
            startIndex = 0
        }
        
        var endIndex = startIndex + count
        if endIndex > column.count {
            endIndex = column.count
        }
        
        self.column = Array(column[startIndex..<endIndex])
    }
}

class BSChartObject: Decodable {
    private let columns: [[BSJSONValue]]?
    private let types: [String:String]?
    private let names: [String:String]?
    private var colors: [String:String]?
    private var yScaled: Bool?
    private var percentage: Bool?
    private var stacked: Bool?
    public var items: [BSChartItem] = []
    
    enum CodingKeys: String, CodingKey {
        case columns = "columns"
        case types = "types"
        case names = "names"
        case colors = "colors"
        case yScaled = "y_scaled"
        case percentage = "percentage"
        case stacked = "stacked"
    }
    
    func generateItems() -> Bool {
        self.items = []
        
        guard let columns = self.columns else {
            return false
        }
        
        var index: Int = 0
        for column in columns {
            guard let item = self.createItem(column: column, index: index) else {
                return false
            }
            
            item.single = columns.count == 2
            
            self.items.append(item)
            
            index += 1
        }
        
        return true
    }
    
    func createItem(column: [BSJSONValue], index: Int) -> BSChartItem? {
        guard let key: String = column.first?.get() as? String else {
            return nil
        }
        
        let item = BSChartItem()
        item.key = key
        item.yScaled = false
        item.percentage = false
        item.stacked = false
        item.index = index
        
        if self.yScaled != nil {
            item.yScaled = self.yScaled!
        }
        
        if self.percentage != nil {
            item.percentage = self.percentage!
        }
        
        if self.stacked != nil {
            item.stacked = self.stacked!
        }
        
        if self.names != nil {
            item.name = self.names![key]
        }
        else {
            item.name = ""
        }
        
        if let types = self.types, let value = types[key], let type = BSType(rawValue: value) {
            item.type = type
        }
        
        if self.colors == nil {
            self.colors = [:]
        }
        
        if self.colors![key] != nil {
            item.color = self.hexStringToUIColor(self.colors![key]!)
        }
        else {
            item.color = .black
        }
        
        
        item.column = []
        let intColumn = Array(column[1..<column.endIndex])
        for value in intColumn {
            guard let intValue: Int = value.get() as? Int else {
                return nil
            }
            item.column!.append(intValue)
        }
        
        return item
    }
    
    func hexStringToUIColor (_ hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
