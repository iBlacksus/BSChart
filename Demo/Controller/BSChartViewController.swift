//
//  ViewController.swift
//  BSChart
//
//  Created by iBlacksus on 3/11/19.
//  Copyright © 2019 iBlacksus. All rights reserved.
//

import UIKit

typealias BSChartList = [BSChartObject]

class BSChartViewController: UIViewController {

    @IBOutlet weak var tableView: BSChartTableView!
    @IBOutlet var switchModeButton: UIBarButtonItem!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.modeForStatusBar == .day ? .default : .lightContent
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    private var chartList: BSChartList = []
    private var modeForStatusBar: BSColorMode = .day
    private var startTime: Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.startTime = Date()
        
        NotificationCenter.default.addObserver(self, selector: #selector(colorModeChanged), name: .chartColorModeChanged, object: nil)
        self.colorModeChanged()
        
        self.title = "Statistics"
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        guard let chartList = self.loadData() else {
            NSLog("Wrong json data")
            return
        }
        
        var filteredChartList: BSChartList = []
        
        for chart in chartList {
            var items: Array<BSChartItem> = []
            var count = 0
            var skip = false
            var xFound = false
            for item in chart.items {
                guard let column = item.column else {
                    skip = true
                    break
                }
                
                if count == 0 {
                    count = column.count
                }
                else if count != column.count {
                    NSLog("Wrong column count")
                    skip = true
                    break
                }
                
                if item.type == "x" {
                    xFound = true
                }
                
                if item.type == "x" || item.type == "line" || item.type == "bar" || item.type == "area" {
                    items.append(item)
                }
            }
            
            if skip || items.count == 0 || !xFound {
                continue
            }
            
            chart.items = self.optimizeItems(items)
            filteredChartList += [chart]
        }
        
        self.chartList = filteredChartList
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.tableView.configure(self.chartList)
        
        let elapsed = Date().timeIntervalSince(self.startTime)
        NSLog("loading time: %f", elapsed)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.post(name: .chartAppDidLoad, object: nil)
    }
    
    private func optimizeItems(_ items: Array<BSChartItem>) -> Array<BSChartItem> {
        let widthMax = Int(UIScreen.main.bounds.width)
        
        for item in items {
            guard let column = item.column else {
                continue
            }
            
            if column.count <= widthMax {
                continue
            }
            
            let step = CGFloat(column.count) / CGFloat(widthMax)
            var optimizedColumn: Array<Int> = []
            
            var lastStart: Int = -1
            for index in 0...Int(widthMax) - 1 {
                var start = (CGFloat(index) * step).rounded(.toNearestOrEven)
                if Int(start) <= lastStart {
                    start = CGFloat(lastStart) + 1
                }
                var end = (start + step).rounded(.toNearestOrEven)
                end = Swift.min(end, CGFloat(column.count))
                lastStart = Int(start)
                
                let slice = Array(column[Int(start)..<Int(end)])
                let optimizeIndex = max(min((CGFloat(slice.count) / 2.0).rounded(.toNearestOrEven), CGFloat(slice.count)), 0)
                
                optimizedColumn += [slice[Int(optimizeIndex)]]
            }
            
            item.column = optimizedColumn
        }
        
        return items
    }
    
    private func loadData() -> BSChartList? {
        var chartList: BSChartList = []
        
        for i in 1...5 {
            guard let url = Bundle.main.url(forResource: "overview" + String(i), withExtension: "json") else {
                continue
            }
            
            do {
                let data = try Data(contentsOf: url)
                let chart = try JSONDecoder().decode(BSChartObject.self, from: data)
                
                if !chart.generateItems() {
                    NSLog("Error in chart")
                    continue
                }
                
                chartList += [chart]
            } catch {
                continue
            }
        }
        
        return chartList
    }
    
    private func updateColorMode(_ mode: BSColorMode)  {
        UIView.animate(withDuration: 0.25) {
            self.navigationController?.navigationBar.barTintColor = BSColorModeManager.shared.colorForItem(.navigationBarBackground, mode: mode)
            self.navigationController?.navigationBar.layoutIfNeeded()
            
            self.navigationController?.navigationBar.titleTextAttributes?.removeAll()
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: BSColorModeManager.shared.colorForItem(.navigationBarText, mode: mode)]
            
            self.modeForStatusBar = mode
            self.setNeedsStatusBarAppearanceUpdate()
            
            UIApplication.shared.statusBarStyle = mode == .day ? .default : .lightContent
        }
        
        self.switchModeButton.title = BSColorModeManager.shared.colorMode == .day ? "Night Mode" : "Day Mode"
    }
    
    @objc private func colorModeChanged() {
        self.updateColorMode(BSColorModeManager.shared.colorMode)
    }
    
    @IBAction func switchColorMode(_ sender: Any) {
        BSColorModeManager.shared.changeMode()
    }
    

}

