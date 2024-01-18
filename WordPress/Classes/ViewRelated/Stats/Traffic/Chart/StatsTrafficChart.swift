import Foundation
import DGCharts
import DesignSystem

// MARK: - StatsTrafficBarChartFilterDimension

enum StatsTrafficBarChartFilterDimension: Int, CaseIterable {
    case views = 0, visitors, likes, comments
}

extension StatsTrafficBarChartFilterDimension {
    var accessibleDescription: String {
        switch self {
        case .views:
            return NSLocalizedString(
                "Bar Chart depicting Views for selected period, Visitors superimposed",
                comment: "This description is used to set the accessibility label for the Period chart, with Views selected."
            )
        case .visitors:
            return NSLocalizedString(
                "Bar Chart depicting Visitors for the selected period.",
                comment: "This description is used to set the accessibility label for the Period chart, with Visitors selected."
            )
        case .likes:
            return NSLocalizedString(
                "Bar Chart depicting Likes for the selected period.",
                comment: "This description is used to set the accessibility label for the Period chart, with Likes selected."
            )
        case .comments:
            return NSLocalizedString(
                "Bar Chart depicting Comments for the selected period.",
                comment: "This description is used to set the accessibility label for the Period chart, with Comments selected."
            )
        }
    }
}

// MARK: - StatsTrafficBarChart

final class StatsTrafficBarChart {

    private let rawChartData: StatsSummaryTimeIntervalData
    private var filterDimension: StatsTrafficBarChartFilterDimension

    private(set) var barChartData: [BarChartDataConvertible]
    private(set) var barChartStyling: [TrafficBarChartStyling]

    init(data: StatsSummaryTimeIntervalData, filterDimension: StatsTrafficBarChartFilterDimension = .views) {
        rawChartData = data
        self.filterDimension = filterDimension

        let (data, styling) = StatsTrafficBarChartDataTransformer.transform(data: data)

        barChartData = data
        barChartStyling = styling
    }
}

// MARK: - StatsTrafficBarChartData

private struct StatsTrafficBarChartData: BarChartDataConvertible {
    let accessibilityDescription: String
    let barChartData: BarChartData
}

// MARK: - StatsTrafficBarChartDataTransformer

private final class StatsTrafficBarChartDataTransformer {
    /// A formatter for the Chart values with no decimals
    ///
    /// The Charts' default formatter has a single decimal defined. This causes VoiceOver to
    /// sometimes read the decimal part. For example, VoiceOver would says “29.0” for a visitors
    /// value.
    ///
    /// - SeeAlso: ChartUtils.defaultValueFormatter()
    ///
    private static let dataSetValueFormatter = DefaultValueFormatter(decimals: 0)

    static func transform(data: StatsSummaryTimeIntervalData) -> (barChartData: [BarChartDataConvertible], barChartStyling: [TrafficBarChartStyling]) {
        let summaryData: [StatsSummaryData]

        switch data.period {
        case .day:
            summaryData = data.summaryData.suffix(7)
        case .week:
            // TODO
            summaryData = data.summaryData.suffix(5)
        case .month:
            summaryData = data.summaryData.suffix(12)
        default:
            summaryData = data.summaryData
        }

        let firstDateInterval: TimeInterval = summaryData.first?.periodStartDate.timeIntervalSince1970 ?? 0

        let totalViews = summaryData.compactMap({$0.viewsCount}).reduce(0, +)
        let totalVisitors = summaryData.compactMap({$0.visitorsCount}).reduce(0, +)
        let totalLikes = summaryData.compactMap({$0.likesCount}).reduce(0, +)
        let totalComments = summaryData.compactMap({$0.commentsCount}).reduce(0, +)

        var viewEntries: [BarChartDataEntry] = []
        var visitorEntries: [BarChartDataEntry] = []
        var likeEntries: [BarChartDataEntry] = []
        var commentEntries: [BarChartDataEntry] = []
        var xAxisIndexToDate: [Int: TimeInterval] = [:]

        for (x, data) in summaryData.enumerated() {
            let dateInterval = data.periodStartDate.timeIntervalSince1970
            let offset = dateInterval - firstDateInterval
            xAxisIndexToDate[x] = offset

            // If the chart has no data, show "stub" bars
            let emptyChartBarHeight = StatsTrafficBarChartView.emptyChartBarHeight
            let viewEntry = BarChartDataEntry(x: Double(x), y: totalViews > 0 ? Double(data.viewsCount) : emptyChartBarHeight)
            let visitorEntry = BarChartDataEntry(x: Double(x), y: totalVisitors > 0 ? Double(data.visitorsCount) : emptyChartBarHeight)
            let likeEntry = BarChartDataEntry(x: Double(x), y: totalLikes > 0 ? Double(data.likesCount) : emptyChartBarHeight)
            let commentEntry = BarChartDataEntry(x: Double(x), y: totalComments > 0 ? Double(data.commentsCount) : emptyChartBarHeight)

            viewEntries.append(viewEntry)
            visitorEntries.append(visitorEntry)
            likeEntries.append(likeEntry)
            commentEntries.append(commentEntry)
        }

        let horizontalAxisFormatter = StatsTrafficHorizontalAxisFormatter(initialDateInterval: firstDateInterval, period: data.period, xAxisIndexToDate: xAxisIndexToDate)

        var chartData = [BarChartData]()

        let viewsDataSet = BarChartDataSet(entries: viewEntries, valueFormatter: dataSetValueFormatter)
        let viewsChartData = BarChartData(dataSet: viewsDataSet)
        chartData.append(viewsChartData)

        let visitorsDataSet = BarChartDataSet(entries: visitorEntries, valueFormatter: dataSetValueFormatter)
        let visitorsChartData = BarChartData(dataSet: visitorsDataSet)
        chartData.append(visitorsChartData)

        let likesChartData = BarChartData(entries: likeEntries, valueFormatter: dataSetValueFormatter)
        chartData.append(likesChartData)

        let commentsChartData = BarChartData(entries: commentEntries, valueFormatter: dataSetValueFormatter)
        chartData.append(commentsChartData)

        var barChartDataConvertibles: [BarChartDataConvertible] = []
        var chartStyling: [TrafficBarChartStyling] = []
        for filterDimension in StatsTrafficBarChartFilterDimension.allCases {
            let filterIndex = filterDimension.rawValue

            let accessibleDescription = filterDimension.accessibleDescription
            let data = chartData[filterIndex]
            let periodChartData = StatsTrafficBarChartData(accessibilityDescription: accessibleDescription, barChartData: data)

            barChartDataConvertibles.append(periodChartData)
            chartStyling.append(DefaultStatsTrafficBarChartStyling(xAxisValueFormatter: horizontalAxisFormatter))
        }

        return (barChartDataConvertibles, chartStyling)
    }
}

// MARK: - DefaultStatsTrafficBarChartStyling

private struct DefaultStatsTrafficBarChartStyling: TrafficBarChartStyling {
    let primaryBarColor: UIColor = UIColor(red: 6/255, green: 116/255, blue: 196/255, alpha: 1.0)
    let labelColor: UIColor = UIColor.DS.Foreground.secondary
    let lineColor: UIColor = UIColor.DS.Foreground.quaternary
    let xAxisValueFormatter: AxisValueFormatter
    let yAxisValueFormatter: AxisValueFormatter = StatsTrafficVerticalAxisFormatter()
}

class StatsTrafficHorizontalAxisFormatter: AxisValueFormatter {

    // MARK: Properties

    private let initialDateInterval: TimeInterval
    private let period: StatsPeriodUnit
    private let periodHelper = StatsPeriodHelper()
    private let xAxisIndexToDate: [Int: TimeInterval]

    private lazy var formatter = DateFormatter()

    // MARK: HorizontalAxisFormatter

    init(
        initialDateInterval: TimeInterval,
        period: StatsPeriodUnit = .day,
        xAxisIndexToDate: [Int: TimeInterval] = [:]
    ) {
        self.initialDateInterval = initialDateInterval
        self.period = period
        self.xAxisIndexToDate = xAxisIndexToDate
    }

    // MARK: AxisValueFormatter

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        updateFormatterTemplate()

        guard let value = xAxisIndexToDate[Int(value)] else {
            return ""
        }

        let adjustedValue = initialDateInterval + (value < 0 ? 0 : value)
        let date = Date(timeIntervalSince1970: adjustedValue)

        switch period {
            // TODO
        case .day:
            return "\(date.dateAndTimeComponents().day ?? 0)"
        case .week:
            return "\(date.dateAndTimeComponents().weekday ?? 0)"
        case .month:
            return "\(date.dateAndTimeComponents().month ?? 0)"
        case .year:
            return "\(date.dateAndTimeComponents().year ?? 0)"

        }
    }

    private func updateFormatterTemplate() {
        formatter.setLocalizedDateFormatFromTemplate(period.dateFormatTemplate)
    }

    private func formattedDate(forWeekContaining date: Date) -> String {
        let week = periodHelper.weekIncludingDate(date)
        guard let weekStart = week?.weekStart, let weekEnd = week?.weekEnd else {
            return ""
        }

        return "\(formatter.string(from: weekStart)) to \(formatter.string(from: weekEnd))"
    }
}

// MARK: - VerticalAxisFormatter

class StatsTrafficVerticalAxisFormatter: AxisValueFormatter {

    // MARK: Properties

    private let largeValueFormatter = LargeValueFormatter()

    // MARK: AxisValueFormatter

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        if value <= 0.0 {
            return "0"
        }

        return largeValueFormatter.stringForValue(value, axis: axis)
    }

    // Matches WPAndroid behavior to produce neater rounded values on
    // the vertical axis.
    static func roundUpAxisMaximum(_ input: Double) -> Double {
        if input > 100 {
            return roundUpAxisMaximum(input / 10) * 10
        } else {
            for i in 1..<25 {
                let limit = Double(4 * i)
                if input < limit {
                    return limit
                }
            }
            return Double(100)
        }
    }
}
