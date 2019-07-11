//
//  BSAppNotifications.swift
//  BSChart
//
//  Created by iBlacksus on 3/18/19.
//  Copyright © 2019 iBlacksus. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let chartAppDidLoad = Notification.Name("chartAppDidLoad")
    static let chartEnabledItemsChanged = Notification.Name("chartEnabledItemsChanged")
    static let chartColorModeChanged = Notification.Name("chartColorModeChanged")
    static let chartSelectItem = Notification.Name("chartSelectItem")
    static let chartRemoveSelection = Notification.Name("chartRemoveSelection")
}
