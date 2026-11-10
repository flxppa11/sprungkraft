import Foundation
import SwiftUI
import WidgetKit
import UserNotifications

struct ActiveSet: Codable, Identifiable {
    var id = UUID()
    var kg: String
    var reps: String
    var done: Bool = false
}

struct ActiveEx: Codable, Identifiable {
    var id: String
    var sets: [ActiveSet]
}

struct ActiveWorkout: Codable {
    var key: String
    var start: Date
    var week: Int
    var ex: [ActiveEx]
}

final class Store: ObservableObject {
    @Published var data: AppData {
        didSet {
            Persistence.save(data)
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    @Published var workout: ActiveWorkout? {
        didSet { saveWorkout() }
    }

    init() {
        self.data = Persistence.load()
        if let d = UserDefaults.standard.data(forKey: "activeWorkout"),
           let w = try? JSONDecoder().decode(ActiveWorkout.self, from: d) {
            self.workout = w
        } else {
            self.workout = nil
        }
    }

    private func saveWorkout() {
        if let w = workout, let e = try? JSONEncoder().encode(w) {
            UserDefaults.standard.set(e, forKey: "activeWorkout")
        } else {
            UserDefaults.standard.removeObject(forKey: "activeWorkout")
        }
    }

    // MARK: Hilfen

    static func fmt(_ v: Double) -> String {
        if v == v.rounded() { return String(Int(v)) }
        return String(format: "%.1f", v)
    }

    static func num(_ s: String) -> Double {
        Double(s.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    func lastPerf(_ id: String) -> [SetLog]? {
        for log in data.logs.reversed() {
            if let e = log.ex.first(where: { $0.id == id }), !e.sets.isEmpty {
                return e.sets
            }
        }
        return nil
    }

    func hint(for id: String, rx r: RxDef) -> String? {
        guard let p = lastPerf(id), !p.isEmpty, let x = Catalog.ex[id] else { return nil }
        let kg = p.map { $0.kg }.max() ?? 0
        if x.unit == "kg" && kg > 0 {
            let ok = p.count >= r.sets - 1 && p.allSatisfy { $0.reps >= r.reps }
            let extra = ok ? " · heute +2,5 kg versuchen" : ""
            return "Letztes Mal: \(Store.fmt(kg)) kg" + extra
        }
        if x.unit == "cm" && kg > 0 {
            return "Letztes Mal: \(Store.fmt(kg)) cm"
        }
        return "Letztes Mal: \(p.count) Sätze"
    }

    // MARK: Training

    func start(_ key: String) {
        let s = data.summary()
        let compact = data.compact
        var list: [ActiveEx] = []
        for id in Plan.exercises(key: key, week: s.week, compact: compact) {
            guard let r = Plan.rx(id, week: s.week, compact: compact) else { continue }
            let last = lastPerf(id)?.map { $0.kg }.max() ?? 0
            let kgText = last > 0 ? Store.fmt(last) : ""
            var sets: [ActiveSet] = []
            for _ in 0..<r.sets {
                sets.append(ActiveSet(kg: kgText, reps: String(r.reps)))
            }
            list.append(ActiveEx(id: id, sets: sets))
        }
        workout = ActiveWorkout(key: key, start: Date(), week: s.week, ex: list)
    }

    @discardableResult
    func finishWorkout() -> Bool {
        guard let w = workout else { return false }
        var exLogs: [ExLog] = []
        for e in w.ex {
            var sets: [SetLog] = []
            for s in e.sets where s.done {
                sets.append(SetLog(kg: Store.num(s.kg), reps: Int(Store.num(s.reps))))
            }
            if !sets.isEmpty { exLogs.append(ExLog(id: e.id, sets: sets)) }
        }
        if exLogs.isEmpty { return false }
        let minutes = max(1, Int(Date().timeIntervalSince(w.start) / 60))
        data.logs.append(WorkoutLog(id: UUID(), date: Date(), key: w.key, week: w.week, minutes: minutes, ex: exLogs))
        workout = nil
        return true
    }

    func exportJSON() -> String {
        let enc = JSONEncoder()
        enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        if let d = try? enc.encode(data), let s = String(data: d, encoding: .utf8) { return s }
        return "{}"
    }
}

enum Reminder {
    static func apply(enabled: Bool, days: [Int], hour: Int) {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        guard enabled else { return }
        center.requestAuthorization(options: [.alert, .sound]) { ok, _ in
            guard ok else { return }
            for d in days {
                var dc = DateComponents()
                dc.weekday = d
                dc.hour = hour
                dc.minute = 0
                let content = UNMutableNotificationContent()
                content.title = "Sprungtag"
                content.body = "Heute steht dein Sprungkraft-Training an."
                let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
                let req = UNNotificationRequest(identifier: "train-\(d)", content: content, trigger: trigger)
                center.add(req)
            }
        }
    }
}
