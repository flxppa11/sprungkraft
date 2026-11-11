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
    var note: String?
}

struct ActiveWorkout: Codable {
    var key: String
    var start: Date
    var week: Int
    var ex: [ActiveEx]
}

struct FinishSummary: Identifiable {
    let id = UUID()
    let minutes: Int
    let sets: Int
    let volume: Double
    let prs: [String]
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

    @Published var summary: FinishSummary? = nil

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
        let v = Double(s.replacingOccurrences(of: ",", with: ".")) ?? 0
        return v.isFinite ? v : 0
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

    func addJump(date: Date, cm: Double) {
        data.jumps.append(JumpLog(id: UUID(), date: date, cm: (cm * 10).rounded() / 10))
    }

    // MARK: Training

    private func makeSets(_ id: String, _ r: RxDef) -> [ActiveSet] {
        let last = lastPerf(id)?.map { $0.kg }.max() ?? 0
        let kgText = last > 0 ? Store.fmt(last) : ""
        var sets: [ActiveSet] = []
        for _ in 0..<r.sets {
            sets.append(ActiveSet(kg: kgText, reps: String(r.reps)))
        }
        return sets
    }

    func start(_ key: String) {
        let s = data.summary()
        let o = data.opts
        var list: [ActiveEx] = []
        for id in Plan.exercises(key: key, week: s.week, opts: o) {
            guard let r = Plan.anyRx(id, week: s.week, opts: o) else { continue }
            list.append(ActiveEx(id: id, sets: makeSets(id, r)))
        }
        workout = ActiveWorkout(key: key, start: Date(), week: s.week, ex: list)
    }

    func startCustom(focus: String, minutes: Int) {
        let s = data.summary()
        var o = data.opts
        o.minutes = minutes
        var list: [ActiveEx] = []
        for id in Plan.custom(focus: focus, minutes: minutes, week: s.week, opts: o) {
            guard let r = Plan.anyRx(id, week: s.week, opts: o) else { continue }
            list.append(ActiveEx(id: id, sets: makeSets(id, r)))
        }
        workout = ActiveWorkout(key: "S", start: Date(), week: s.week, ex: list)
    }

    func alternatives(for i: Int) -> [String] {
        guard let w = workout, i < w.ex.count, let cur = Catalog.ex[w.ex[i].id] else { return [] }
        let used = Set(w.ex.map { $0.id })
        let o = data.opts
        return Catalog.order.filter { id in
            guard let e = Catalog.ex[id] else { return false }
            if e.group != cur.group || id == cur.id || used.contains(id) { return false }
            if !Plan.available(e.equip, o) { return false }
            return Plan.anyRx(id, week: w.week, opts: o) != nil
        }
    }

    func swapExercise(_ i: Int, to id: String) {
        guard var w = workout, i < w.ex.count,
              let r = Plan.anyRx(id, week: w.week, opts: data.opts) else { return }
        w.ex[i] = ActiveEx(id: id, sets: makeSets(id, r))
        workout = w
    }

    func addSet(_ i: Int) {
        guard var w = workout, i < w.ex.count else { return }
        let last = w.ex[i].sets.last
        w.ex[i].sets.append(ActiveSet(kg: last?.kg ?? "", reps: last?.reps ?? ""))
        workout = w
    }

    func removeSet(_ i: Int) {
        guard var w = workout, i < w.ex.count, w.ex[i].sets.count > 1 else { return }
        w.ex[i].sets.removeLast()
        workout = w
    }

    func hasDoneSet() -> Bool {
        guard let w = workout else { return false }
        for e in w.ex {
            for s in e.sets where s.done { return true }
        }
        return false
    }

    @discardableResult
    func finishWorkout(feel: Int?, note: String?) -> Bool {
        guard let w = workout else { return false }
        let before = data.prs()
        var exLogs: [ExLog] = []
        var setCount = 0
        var volume = 0.0
        var prs: [String] = []
        for e in w.ex {
            var sets: [SetLog] = []
            for s in e.sets where s.done {
                sets.append(SetLog(kg: Store.num(s.kg), reps: Int(Store.num(s.reps))))
            }
            if sets.isEmpty { continue }
            let n = (e.note ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            exLogs.append(ExLog(id: e.id, sets: sets, note: n.isEmpty ? nil : n))
            setCount += sets.count
            for s in sets { volume += s.kg * Double(s.reps) }
            let top = sets.map { $0.kg }.max() ?? 0
            if top > 0, let prev = before[e.id], top > prev, let x = Catalog.ex[e.id] {
                prs.append("\(x.name): \(Store.fmt(top)) kg")
            }
        }
        if exLogs.isEmpty { return false }
        let minutes = max(1, Int(Date().timeIntervalSince(w.start) / 60))
        let cleanNote = (note ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        data.logs.append(WorkoutLog(id: UUID(), date: Date(), key: w.key, week: w.week,
                                    minutes: minutes, ex: exLogs, feel: feel,
                                    note: cleanNote.isEmpty ? nil : cleanNote))
        workout = nil
        Reminder.cancelRest()
        summary = FinishSummary(minutes: minutes, sets: setCount, volume: volume, prs: prs)
        return true
    }

    // MARK: Daten

    func exportJSON() -> String {
        let enc = JSONEncoder()
        enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        if let d = try? enc.encode(data), let s = String(data: d, encoding: .utf8) { return s }
        return "{}"
    }

    func importJSON(_ text: String) -> Bool {
        guard let d = text.data(using: .utf8),
              let v = try? JSONDecoder().decode(AppData.self, from: d) else { return false }
        data = v
        return true
    }
}

enum Reminder {
    static func apply(enabled: Bool, days: [Int], hour: Int) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { reqs in
            let ids = reqs.map { $0.identifier }.filter { $0.hasPrefix("train-") }
            center.removePendingNotificationRequests(withIdentifiers: ids)
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

    static func scheduleRest(seconds: Int) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { ok, _ in
            guard ok, seconds > 0 else { return }
            center.removePendingNotificationRequests(withIdentifiers: ["rest"])
            let content = UNMutableNotificationContent()
            content.title = "Pause vorbei"
            content.body = "Weiter mit dem nächsten Satz."
            content.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)
            center.add(UNNotificationRequest(identifier: "rest", content: content, trigger: trigger))
        }
    }

    static func cancelRest() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["rest"])
    }
}
