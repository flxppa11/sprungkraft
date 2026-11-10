import WidgetKit
import SwiftUI

struct SprungEntry: TimelineEntry {
    let date: Date
    let s: Summary
}

struct SprungProvider: TimelineProvider {
    func placeholder(in context: Context) -> SprungEntry {
        SprungEntry(date: Date(), s: AppData.fresh().summary())
    }

    func getSnapshot(in context: Context, completion: @escaping (SprungEntry) -> Void) {
        completion(SprungEntry(date: Date(), s: Persistence.load().summary()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SprungEntry>) -> Void) {
        let now = Date()
        let entry = SprungEntry(date: now, s: Persistence.load().summary(now: now))
        let tomorrow = Calendar.current.startOfDay(for: now).addingTimeInterval(86400 + 60)
        completion(Timeline(entries: [entry], policy: .after(tomorrow)))
    }
}

struct SprungWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: SprungEntry

    var body: some View {
        let s = entry.s
        switch family {
        case .accessoryCircular:
            Gauge(value: Double(s.done), in: 0...Double(max(s.planned, 1))) {
                Image(systemName: "figure.jumprope")
            } currentValueLabel: {
                Text("\(s.done)/\(s.planned)")
            }
            .gaugeStyle(.accessoryCircularCapacity)
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                Text(s.done >= s.planned ? "Woche geschafft" : s.nextName).font(.headline)
                Text("Woche \(s.week) · \(s.done)/\(s.planned) diese Woche").font(.caption)
            }
        case .systemMedium:
            HStack(spacing: 16) {
                ProgressRing(done: s.done, planned: s.planned).frame(width: 84, height: 84)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Woche \(s.week) von 12").font(.caption.weight(.semibold)).foregroundStyle(Theme.accent)
                    Text(s.done >= s.planned ? "Woche geschafft" : s.nextName).font(.title3.bold())
                    if let b = s.best {
                        Text("Bester Sprung \(fmt(b)) cm").font(.footnote).foregroundStyle(.secondary)
                    } else {
                        Text(s.todayIsTraining ? "Heute ist Sprungtag" : "Nächste Einheit").font(.footnote).foregroundStyle(.secondary)
                    }
                }
                Spacer()
            }
        default:
            VStack(alignment: .leading, spacing: 4) {
                Text("Woche \(s.week)").font(.caption.weight(.semibold)).foregroundStyle(Theme.accent)
                Text(s.done >= s.planned ? "Woche geschafft" : s.nextName).font(.headline)
                Spacer()
                Text("\(s.done)/\(s.planned) Einheiten").font(.subheadline.weight(.semibold))
                if let b = s.best {
                    Text("\(fmt(b)) cm").font(.title2.bold())
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    func fmt(_ v: Double) -> String {
        v == v.rounded() ? String(Int(v)) : String(format: "%.1f", v)
    }
}

struct SprungWidget: Widget {
    let kind = "SprungWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SprungProvider()) { entry in
            SprungWidgetView(entry: entry)
                .containerBackground(for: .widget) { Color(.systemBackground) }
        }
        .configurationDisplayName("Sprungkraft")
        .description("Nächste Einheit und Wochenfortschritt.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
    }
}

@main
struct SprungWidgetBundle: WidgetBundle {
    var body: some Widget {
        SprungWidget()
    }
}
