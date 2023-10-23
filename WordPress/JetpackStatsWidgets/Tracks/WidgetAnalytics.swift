import Foundation
import WidgetKit

@objcMembers class WidgetAnalytics: NSObject {
    static func trackLoadedWidgetsOnApplicationOpened() {
        guard AppConfiguration.isJetpack else { return }

        WidgetCenter.shared.getCurrentConfigurations { result in
            let properties = self.properties(from: result)
            WPAnalytics.track(.widgetsLoadedOnApplicationOpened, properties: properties)
        }
    }

    private static func properties(from widgetInfo: Result<[WidgetInfo], Error>) -> [String: String] {
        guard let installedWidgets = try? widgetInfo.get() else {
            return [:]
        }

        let widgetAnalyticNames: [String] = installedWidgets.map { widgetInfo in
            guard let eventKind = AppConfiguration.Widget.Stats.Kind(rawValue: widgetInfo.kind) else {
                DDLogWarn("⚠️ Make sure the widget: \(widgetInfo.kind), has the correct kind.")
                return "\(widgetInfo.kind)_\(widgetInfo.family)"
            }
            return "\(Events.eventPrefix(for: eventKind).rawValue)_\(widgetInfo.family.description.lowercased())"
        }

        let dict = Dictionary(uniqueKeysWithValues: widgetAnalyticNames.map { name in
            return (name, "true")
        })

        return dict
    }

    private enum Events: String {
        case homeTodayWidget = "widget_today_home_extension"
        case homeAllTimeWidget = "widget_alltime_home_extension"
        case homeThisWeekWidget = "widget_thisweek_home_extension"
        case lockScreenTodayViewsWidget = "widget_today_views_lockscreen"
        case lockScreenTodayLikesCommentsWidget = "widget_today_likes_comments_lockscreen"
        case lockScreenTodayViewsVisitorsWidget = "widget_today_views_visitors_lockscreen"
        case lockScreenAllTimeViewsWidget = "widget_all_time_views_lockscreen"
        case lockScreenAllTimeViewsVisitorsWidget = "widget_all_time_views_visitors_lockscreen"
        case lockScreenAllTimePostsBestViewsWidget = "widget_all_time_posts_best_views_lockscreen"

        static func eventPrefix(for widgetKind: AppConfiguration.Widget.Stats.Kind) -> Events {
            switch widgetKind {
            case .homeToday:
                return .homeTodayWidget
            case .homeAllTime:
                return .homeAllTimeWidget
            case .homeThisWeek:
                return .homeThisWeekWidget
            case .lockScreenTodayViews:
                return .lockScreenTodayViewsWidget
            case .lockScreenTodayLikesComments:
                 return .lockScreenTodayLikesCommentsWidget
             case .lockScreenTodayViewsVisitors:
                 return .lockScreenTodayViewsVisitorsWidget
             case .lockScreenAllTimeViews:
                 return .lockScreenAllTimeViewsWidget
             case .lockScreenAllTimeViewsVisitors:
                 return .lockScreenAllTimeViewsVisitorsWidget
             case .lockScreenAllTimePostsBestViews:
                 return .lockScreenAllTimePostsBestViewsWidget
            }
        }
    }
}
