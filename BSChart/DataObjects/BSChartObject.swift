//
//  BSChartObject.swift
//  BSChartObject
//
//  Created by iBlacksus on 3/11/19.
//  Copyright © 2019 iBlacksus. All rights reserved.
//

import UIKit

class BSChartObject: Decodable {
    private let columns: [[BSJSONValue]]?
    private let types: [String:String]?
    private let names: [String:String]?
    private var colors: [String:String]?
    private var yScaled: Bool?
    private var percentage: Bool?
    private var stacked: Bool?
    private var sum: Bool?
    public var items: [BSChartItem] = []
    enum CodingKeys: String, CodingKey {
        case columns = "columns"
        case types = "types"
        case names = "names"
        case colors = "colors"
        case yScaled = "y_scaled"
        case percentage = "percentage"
        case stacked = "stacked"
        case sum = "sum"
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
        item.sum = false
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
        
        if self.sum != nil {
            item.sum = self.sum!
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
            item.color = UIColor.init(hexString: self.colors![key]!) ?? UIColor.gray
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
}
