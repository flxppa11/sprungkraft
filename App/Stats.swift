import Foundation

struct WeekStat: Identifiable {
    let id: Date
    let sets: Int
    let volume: Double
}

struct SeriesPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

struct Achievement: Identifiable {
    let id: String
    let title: String
    let detail: String
    let done: Bool
    let icon: String
}

extension AppData {
    /// Bestes Gewicht pro Übung über alle Einheiten
    func prs() -> [String: Double] {
        var best: [String: Double] = [:]
        for l in logs {
            for e in l.ex {
                let top = e.sets.map { $0.kg }.max() ?? 0
                if top > (best[e.id] ?? 0) { best[e.id] = top }
            }
        }
        return best
    }

    /// Geschätztes Maximum für eine Wiederholung (Epley-Formel)
    func est1RM(_ id: String) -> Double? {
        var best = 0.0
        for l in logs {
            for e in l.ex where e.id == id {
                for s in e.sets where s.kg > 0 && s.reps >= 1 && s.reps <= 12 {
                    let v = s.kg * (1.0 + Double(s.reps) / 30.0)
                    if v > best { best = v }
                }
            }
        }
        return best > 0 ? best : nil
    }

    /// Bestes Gewicht pro Einheit für eine Übung, zeitlich sortiert
    func series(_ id: String) -> [SeriesPoint] {
        var out: [SeriesPoint] = []
        for l in logs.sorted(by: { $0.date < $1.date }) {
            for e in l.ex where e.id == id {
                let top = e.sets.map { $0.kg }.max() ?? 0
                if top > 0 { out.append(SeriesPoint(date: l.date, value: top)) }
            }
        }
        return out
    }

    func exercisesWithLoad() -> [String] {
        var found: Set<String> = []
        for l in logs {
            for e in l.ex {
                if (e.sets.map { $0.kg }.max() ?? 0) > 0 { found.insert(e.id) }
            }
        }
        return Catalog.order.filter { found.contains($0) }
    }

    func weeklyStats(count: Int = 8, now: Date = Date()) -> [WeekStat] {
        var out: [WeekStat] = []
        let thisMonday = Cal.monday(now)
        for i in stride(from: count - 1, through: 0, by: -1) {
            let m = Cal.c.date(byAdding: .weekOfYear, value: -i, to: thisMonday) ?? thisMonday
            var sets = 0
            var vol = 0.0
            for l in logs where Cal.monday(l.date) == m {
                for e in l.ex {
                    sets += e.sets.count
                    for s in e.sets { vol += s.kg * Double(s.reps) }
                }
            }
            out.append(WeekStat(id: m, sets: sets, volume: vol))
        }
        return out
    }

    var totalMinutes: Int { logs.reduce(0) { $0 + $1.minutes } }

    var totalSets: Int {
        var n = 0
        for l in logs { for e in l.ex { n += e.sets.count } }
        return n
    }

    func achievements() -> [Achievement] {
        let s = summary()
        let gain = s.gain ?? 0
        let best = s.best ?? 0
        let squat = prs()["sq"] ?? 0
        let n = logs.count
        return [
            Achievement(id: "first", title: "Erste Einheit", detail: "Eine Einheit abschließen", done: n >= 1, icon: "flag.fill"),
            Achievement(id: "ten", title: "10 Einheiten", detail: "10 Einheiten abschließen", done: n >= 10, icon: "10.circle.fill"),
            Achievement(id: "twentyfive", title: "25 Einheiten", detail: "25 Einheiten abschließen", done: n >= 25, icon: "25.circle.fill"),
            Achievement(id: "streak4", title: "4 Wochen Serie", detail: "4 Wochen in Folge alle Einheiten", done: s.streak >= 4, icon: "flame.fill"),
            Achievement(id: "plus5", title: "+5 cm", detail: "5 cm höher als beim Start", done: gain >= 5, icon: "arrow.up.circle.fill"),
            Achievement(id: "plus10", title: "+10 cm", detail: "10 cm höher als beim Start", done: gain >= 10, icon: "arrow.up.forward.circle.fill"),
            Achievement(id: "goal", title: "Ziel erreicht", detail: "Deine Ziel-Sprunghöhe springen", done: goalCm > 0 && best >= goalCm, icon: "trophy.fill"),
            Achievement(id: "sq1", title: "Kniebeuge 1× Körpergewicht", detail: "Kniebeuge mit deinem Körpergewicht", done: bodyKg > 0 && squat >= bodyKg, icon: "figure.strengthtraining.traditional"),
            Achievement(id: "sq15", title: "Kniebeuge 1,5× Körpergewicht", detail: "Kniebeuge mit dem 1,5-fachen", done: bodyKg > 0 && squat >= bodyKg * 1.5, icon: "bolt.fill")
        ]
    }
}
