import WidgetKit
import SwiftUI

private let appGroupId = "group.com.gaussdev.stayalive"
private let widgetKind = "DailyGoalWidget"

struct DailyGoalEntry: TimelineEntry {
    let date: Date
    let completed: Int
    let target: Int
    let percentage: Double
    let streak: Int
    let level: Int
    let dateLabel: String
}

struct DailyGoalProvider: TimelineProvider {
    func placeholder(in context: Context) -> DailyGoalEntry {
        DailyGoalEntry(
            date: Date(),
            completed: 0,
            target: 24,
            percentage: 0,
            streak: 0,
            level: 1,
            dateLabel: "Today"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (DailyGoalEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DailyGoalEntry>) -> Void) {
        let entry = loadEntry()
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }

    private func loadEntry() -> DailyGoalEntry {
        let defaults = UserDefaults(suiteName: appGroupId)
        let completed = defaults?.integer(forKey: "daily_goal_completed") ?? 0
        let target = max(defaults?.integer(forKey: "daily_goal_target") ?? 24, 1)
        let storedPercentage = defaults?.double(forKey: "daily_goal_percentage") ?? 0
        let percentage = storedPercentage > 0 ? storedPercentage / 100 : Double(completed) / Double(target)

        return DailyGoalEntry(
            date: Date(),
            completed: completed,
            target: target,
            percentage: min(max(percentage, 0), 1),
            streak: defaults?.integer(forKey: "daily_goal_streak") ?? 0,
            level: max(defaults?.integer(forKey: "daily_goal_level") ?? 1, 1),
            dateLabel: defaults?.string(forKey: "daily_goal_date") ?? "Today"
        )
    }
}

struct DailyGoalWidgetView: View {
    var entry: DailyGoalProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Daily Goal")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Text("Lv \(entry.level)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.18))
                    .clipShape(Capsule())
            }

            Text("\(entry.completed)/\(entry.target) servings")
                .font(.title3)
                .fontWeight(.semibold)

            ProgressView(value: entry.percentage)
                .accentColor(.green)

            HStack {
                Text("\(Int(entry.percentage * 100))%")
                Spacer()
                Text("🔥 \(entry.streak)d")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

@main
struct DailyGoalWidget: Widget {
    let kind: String = widgetKind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DailyGoalProvider()) { entry in
            DailyGoalWidgetView(entry: entry)
        }
        .configurationDisplayName("Daily Goal")
        .description("Track today's healthy eating goal at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
