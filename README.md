# BSChart

![Image](ReadmeResources/demo1.jpg)
![Image](ReadmeResources/demo2.jpg)
![Image](ReadmeResources/demo.gif)

## Installation
  * Download whole project
  * Drag the folder `BSChart` into your project

## JSON specification

  * `chart.columns` – List of all data columns in the chart. Each column has its label at position 0, followed by values.x values are UNIX timestamps in milliseconds
  * `chart.types` – Chart types for each of the columns. Supported values: "line", "area”, "bar”, "x" (x axis values for each of the charts at the corresponding positions)
  * `chart.colors` – Color for each variable in 6-hex-digit format (e.g. "#AAAAAA")
  * `chart.names` – Name for each variable
  * `chart.percentage` – true for percentage based values
  * `chart.stacked` – true for values stacking on top of each other
  * `chart.y_scaled` – true for charts with 2 Y axes

## Available loading charts from JSON files (see Demo) and creating objects manually

## Requirements
  * iOS 10.0 or higher
  * ARC

## Author

iBlacksus, iblacksus@gmail.com

## License

BSChart is available under the MIT license. See the LICENSE file for more info.
