import Foundation

// MARK: - Übungen

struct RxDef {
    let sets: Int
    let reps: Int
    let rest: Int
    let note: String
}

func rxd(_ sets: Int, _ reps: Int, _ rest: Int, _ note: String) -> RxDef {
    RxDef(sets: sets, reps: reps, rest: rest, note: note)
}

struct Exercise {
    let id: String
    let name: String
    let unit: String      // "kg", "cm" oder "" (ohne Last)
    let optional: Bool    // wird im Kompakt-Modus weggelassen
    let rx: [RxDef?]      // pro Phase: Fundament, Maximalkraft, Power
    let cue: String
}

struct SessionDef {
    let key: String
    let name: String
    let ex: [String]
}

enum Catalog {
    static let order: [String] = [
        "cmj", "pogo", "box", "drop", "appr", "jsq", "broad", "sq", "rdl", "split",
        "hip", "nord", "calf", "swing", "pall", "dead", "row", "pull", "face"
    ]

    static let ex: [String: Exercise] = {
        var m: [String: Exercise] = [:]
        func add(_ e: Exercise) { m[e.id] = e }

        add(Exercise(id: "cmj", name: "Maximalsprung (Counter-Movement)", unit: "", optional: false,
            rx: [rxd(4, 5, 90, "Jeder Sprung 100 %"), rxd(4, 4, 90, "Jeder Sprung 100 %"), rxd(5, 3, 120, "Jeder Sprung 100 %")],
            cue: "Schnell nach unten, explosiv hoch, weich landen. Lange Pause: jeder Sprung muss maximal sein."))
        add(Exercise(id: "pogo", name: "Pogo-Hops", unit: "", optional: false,
            rx: [rxd(3, 15, 60, "Kurzer Bodenkontakt, steife Knöchel"), nil, nil],
            cue: "Aus den Sprunggelenken federn, Knie fast gestreckt. Wie auf einer heißen Platte."))
        add(Exercise(id: "box", name: "Box Jump", unit: "cm", optional: false,
            rx: [rxd(4, 4, 90, "Niedrige Box, ruhig landen"), rxd(4, 4, 90, "Mittlere Box"), rxd(5, 3, 120, "So hoch wie sauber möglich")],
            cue: "Maximal hoch springen, oben weich in der Hocke landen, absteigen statt runterspringen."))
        add(Exercise(id: "drop", name: "Tiefsprung (Drop Jump)", unit: "cm", optional: false,
            rx: [nil, rxd(3, 4, 120, "Kasten 30 cm, Kontakt minimal"), rxd(4, 4, 120, "Kasten 30 bis 40 cm")],
            cue: "Vom Kasten fallen lassen, beim Aufkommen sofort wieder maximal hoch. Bodenkontakt so kurz wie möglich."))
        add(Exercise(id: "appr", name: "Anlaufsprung (Angriff/Block)", unit: "", optional: false,
            rx: [rxd(3, 4, 90, "Technik, 80 %"), rxd(4, 3, 90, "Voller Einsatz"), rxd(5, 3, 90, "Voller Einsatz")],
            cue: "Dein Angriffsanlauf: letzter Schritt lang, Arme schwingen, Hände so hoch wie möglich."))
        add(Exercise(id: "jsq", name: "Sprung-Kniebeuge", unit: "kg", optional: false,
            rx: [rxd(3, 6, 90, "Körpergewicht oder leicht"), rxd(4, 4, 120, "ca. 20 % deines Kniebeugen-Maximums"), rxd(4, 3, 120, "ca. 30 %, maximal schnell")],
            cue: "Mit leichter Last so schnell wie möglich abspringen. Geschwindigkeit zählt, nicht das Gewicht."))
        add(Exercise(id: "broad", name: "Standweitsprung", unit: "", optional: false,
            rx: [rxd(3, 4, 90, "Weich landen"), rxd(3, 4, 90, "Weich landen"), rxd(4, 3, 90, "Maximale Weite")],
            cue: "Arme schwingen, Hüfte nach hinten, so weit wie möglich. Landung stabil halten."))
        add(Exercise(id: "sq", name: "Kniebeuge (Langhantel)", unit: "kg", optional: false,
            rx: [rxd(4, 6, 150, "3 Sek. runter, 3 Wdh. im Tank"), rxd(5, 3, 180, "Schwer, 1 bis 2 Wdh. im Tank"), rxd(3, 3, 150, "Mittelschwer, explosiv hoch")],
            cue: "Brust hoch, Knie folgen den Zehen, mindestens bis Oberschenkel parallel. Das ist deine wichtigste Kraftübung."))
        add(Exercise(id: "rdl", name: "Rumänisches Kreuzheben", unit: "kg", optional: false,
            rx: [rxd(3, 8, 120, "Langsam ablassen"), rxd(4, 5, 150, "Schwer, Rücken gerade"), rxd(3, 5, 120, "Zügig hoch")],
            cue: "Hüfte nach hinten schieben, Stange nah am Bein, Rücken lang. Training für die Oberschenkelrückseite."))
        add(Exercise(id: "split", name: "Bulgarische Kniebeuge", unit: "kg", optional: false,
            rx: [rxd(3, 8, 90, "Pro Bein"), rxd(3, 6, 120, "Pro Bein"), rxd(3, 5, 120, "Pro Bein")],
            cue: "Hinterer Fuß auf der Bank, Oberkörper leicht nach vorn. Hilft bei Absprung und Landung auf einem Bein."))
        add(Exercise(id: "hip", name: "Hip Thrust", unit: "kg", optional: false,
            rx: [rxd(3, 10, 90, "Oben 1 Sek. halten"), rxd(4, 6, 120, "Schwer"), rxd(3, 5, 90, "Explosiv hoch")],
            cue: "Oberer Rücken auf der Bank, Hüfte stark nach oben strecken, Kinn zur Brust."))
        add(Exercise(id: "nord", name: "Nordic Curl", unit: "", optional: false,
            rx: [rxd(3, 5, 90, "Langsam ablassen"), rxd(3, 6, 90, "Langsam ablassen"), rxd(2, 6, 90, "Langsam ablassen")],
            cue: "Füße fixieren, Körper gerade nach vorn ablassen, mit den Händen abfangen. Schützt die Oberschenkelrückseite."))
        add(Exercise(id: "calf", name: "Wadenheben stehend", unit: "kg", optional: true,
            rx: [rxd(3, 12, 60, "Voller Bewegungsumfang"), rxd(4, 8, 90, "Schwer, 2 Sek. unten halten"), rxd(3, 6, 60, "Explosiv hoch")],
            cue: "Ganz nach oben auf die Zehen, unten tief dehnen. Starke Waden bringen Federung."))
        add(Exercise(id: "swing", name: "Kettlebell Swing", unit: "kg", optional: false,
            rx: [rxd(3, 10, 75, "Hüfte schnappt nach vorn"), rxd(4, 8, 90, "Schwerer"), rxd(3, 8, 75, "Explosiv")],
            cue: "Die Hüfte macht die Arbeit, die Arme hängen nur dran. Oben stehen, nicht ins Hohlkreuz fallen."))
        add(Exercise(id: "pall", name: "Pallof Press", unit: "", optional: true,
            rx: [rxd(3, 10, 45, "Pro Seite"), rxd(3, 10, 45, "Pro Seite"), rxd(3, 10, 45, "Pro Seite")],
            cue: "Am Kabel seitlich stehen, Arme nach vorn drücken, nicht verdrehen lassen. Rumpfspannung für Sprünge."))
        add(Exercise(id: "dead", name: "Dead Bug", unit: "", optional: true,
            rx: [rxd(3, 8, 45, "Pro Seite"), rxd(3, 8, 45, "Pro Seite"), rxd(3, 8, 45, "Pro Seite")],
            cue: "Rücken flach am Boden, Arm und gegenüberliegendes Bein langsam strecken."))
        add(Exercise(id: "row", name: "Rudern", unit: "kg", optional: false,
            rx: [rxd(3, 8, 90, "Kontrolliert"), rxd(4, 6, 90, "Schwerer"), rxd(3, 6, 90, "Zügig")],
            cue: "Rücken gerade, Ellbogen nah am Körper, Schulterblätter zusammenziehen."))
        add(Exercise(id: "pull", name: "Klimmzüge", unit: "kg", optional: false,
            rx: [rxd(3, 6, 90, "0 = Körpergewicht"), rxd(3, 6, 90, "Zusatzgewicht wenn möglich"), rxd(3, 5, 90, "Sauber ziehen")],
            cue: "Aus dem Hang, Brust zur Stange. Stark für Angriffsschlag und Schultern."))
        add(Exercise(id: "face", name: "Face Pull", unit: "kg", optional: true,
            rx: [rxd(3, 12, 60, "Leichtes Gewicht"), rxd(3, 12, 60, "Leichtes Gewicht"), rxd(3, 12, 60, "Leichtes Gewicht")],
            cue: "Seil auf Gesichtshöhe ziehen, Ellbogen hoch. Hält deine Schultern gesund bei vielen Angriffen."))
        return m
    }()
}

// MARK: - Plan

struct PhaseInfo {
    let name: String
    let weeks: String
    let text: String
}

enum Plan {
    static let phases: [PhaseInfo] = [
        PhaseInfo(name: "Fundament", weeks: "Woche 1 bis 4",
                  text: "Technik, Sehnen und Grundkraft aufbauen. Du lernst saubere Landungen und moderate Sprünge."),
        PhaseInfo(name: "Maximalkraft", weeks: "Woche 5 bis 8",
                  text: "Schwere Sätze mit wenigen Wiederholungen. Tiefsprünge kommen dazu. Hier wächst dein Kraftpotenzial."),
        PhaseInfo(name: "Power", weeks: "Woche 9 bis 12",
                  text: "Die Kraft wird in Tempo umgewandelt. Leichtere Lasten, maximale Geschwindigkeit, hohe Sprünge. Woche 12 ist Testwoche.")
    ]

    static let warmup: [String] = [
        "3 Min. locker einlaufen oder Seilspringen",
        "Hüftkreisen und Beinschwingen, je 10 pro Seite",
        "10 Kniebeugen mit Körpergewicht, unten 2 Sek. halten",
        "10 Glute Bridges",
        "3 Steigerungssprünge, jeder etwas höher als der vorige"
    ]

    static let sessionDefs: [String: SessionDef] = [
        "F": SessionDef(key: "F", name: "Ganzkörper Sprung", ex: ["cmj", "sq", "rdl", "calf", "pall"]),
        "A": SessionDef(key: "A", name: "Kraft und Landung", ex: ["pogo", "box", "drop", "sq", "nord", "pall"]),
        "B": SessionDef(key: "B", name: "Power und Sprung", ex: ["cmj", "appr", "jsq", "swing", "hip", "calf"]),
        "C": SessionDef(key: "C", name: "Einbeinig und Hüfte", ex: ["broad", "split", "rdl", "hip", "dead"]),
        "D": SessionDef(key: "D", name: "Oberkörper und Rumpf", ex: ["row", "pull", "face", "dead", "pall"])
    ]

    static let layout: [Int: [String]] = [
        1: ["F"], 2: ["A", "B"], 3: ["A", "B", "C"], 4: ["A", "B", "C", "D"]
    ]

    static func keys(forDays n: Int) -> [String] {
        layout[min(4, max(1, n))] ?? ["F"]
    }

    static func phase(_ week: Int) -> Int {
        week <= 4 ? 0 : (week <= 8 ? 1 : 2)
    }

    static func isDeload(_ week: Int) -> Bool {
        week == 4 || week == 8 || week == 12
    }

    static func rx(_ id: String, week: Int, compact: Bool) -> RxDef? {
        guard let e = Catalog.ex[id], let b = e.rx[phase(week)] else { return nil }
        let sets = isDeload(week) ? max(2, b.sets - 1) : b.sets
        let rest = compact ? Int((Double(b.rest) * 0.8).rounded()) : b.rest
        return RxDef(sets: sets, reps: b.reps, rest: rest, note: b.note)
    }

    static func exercises(key: String, week: Int, compact: Bool) -> [String] {
        guard let def = sessionDefs[key] else { return [] }
        return def.ex.filter { id in
            guard let e = Catalog.ex[id] else { return false }
            if rx(id, week: week, compact: compact) == nil { return false }
            if compact && e.optional { return false }
            return true
        }
    }

    static func estMinutes(key: String, week: Int, compact: Bool) -> Int {
        var seconds = 8 * 60
        for id in exercises(key: key, week: week, compact: compact) {
            if let r = rx(id, week: week, compact: compact) {
                seconds += r.sets * (35 + r.rest)
            }
        }
        return Int((Double(seconds) / 60.0 / 5.0).rounded()) * 5
    }
}

// MARK: - Gespeicherte Daten

struct SetLog: Codable, Equatable {
    var kg: Double
    var reps: Int
}

struct ExLog: Codable, Equatable {
    var id: String
    var sets: [SetLog]
}

struct WorkoutLog: Codable, Equatable, Identifiable {
    var id: UUID
    var date: Date
    var key: String
    var week: Int
    var minutes: Int
    var ex: [ExLog]
}

struct JumpLog: Codable, Equatable, Identifiable {
    var id: UUID
    var date: Date
    var cm: Double
}

struct AppData: Codable, Equatable {
    var start: Date
    var days: [Int]          // 1 = Sonntag, 2 = Montag ... 7 = Samstag
    var compact: Bool
    var remind: Bool
    var remindHour: Int
    var logs: [WorkoutLog]
    var jumps: [JumpLog]

    static func fresh() -> AppData {
        AppData(start: Date(), days: [2, 4, 6], compact: false, remind: false,
                remindHour: 17, logs: [], jumps: [])
    }
}

enum Cal {
    static var c: Calendar {
        var x = Calendar(identifier: .gregorian)
        x.firstWeekday = 2
        return x
    }

    static func monday(_ d: Date) -> Date {
        c.dateInterval(of: .weekOfYear, for: d)?.start ?? d
    }
}

struct Summary {
    var week: Int
    var rawWeek: Int
    var done: Int
    var planned: Int
    var nextKey: String
    var nextName: String
    var todayIsTraining: Bool
    var best: Double?
    var gain: Double?
}

extension AppData {
    func summary(now: Date = Date()) -> Summary {
        let diff = Cal.c.dateComponents([.day], from: Cal.monday(start), to: Cal.monday(now)).day ?? 0
        let raw = diff / 7 + 1
        let week = min(12, max(1, raw))
        let keys = Plan.keys(forDays: days.count)
        let done = logs.filter { Cal.c.isDate($0.date, equalTo: now, toGranularity: .weekOfYear) }.count
        let key = keys[done % keys.count]
        let today = Cal.c.component(.weekday, from: now)
        let asc = jumps.sorted { $0.date < $1.date }
        let best = jumps.map { $0.cm }.max()
        var gain: Double? = nil
        if let b = best, let first = asc.first {
            gain = b - first.cm
        }
        return Summary(week: week, rawWeek: raw, done: done, planned: keys.count,
                       nextKey: key, nextName: Plan.sessionDefs[key]?.name ?? "",
                       todayIsTraining: days.contains(today), best: best, gain: gain)
    }
}

// MARK: - Speicher (App und Widget)

enum Persistence {
    static let group = "group.com.sprungkraft.app"

    static var defaults: UserDefaults {
        UserDefaults(suiteName: group) ?? UserDefaults.standard
    }

    static func load() -> AppData {
        if let d = defaults.data(forKey: "appdata"),
           let v = try? JSONDecoder().decode(AppData.self, from: d) {
            return v
        }
        return AppData.fresh()
    }

    static func save(_ d: AppData) {
        if let e = try? JSONEncoder().encode(d) {
            defaults.set(e, forKey: "appdata")
        }
    }
}
