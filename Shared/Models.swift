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
    let group: String     // jump, squat, hinge, calf, core, pull
    let equip: String     // "", "box", "kb", "cable"
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
        "cmj", "pogo", "tuck", "box", "drop", "appr", "lateral", "jsq", "broad",
        "sq", "split", "legpress", "lunge", "stepup", "legext",
        "rdl", "dl", "hip", "nord", "legcurl", "swing", "bridge",
        "calf", "calfsit",
        "pall", "dead", "hangleg",
        "row", "pull", "bench", "ohp", "lat", "face"
    ]

    static func groupName(_ g: String) -> String {
        switch g {
        case "jump": return "Sprünge"
        case "squat": return "Kniebeugen"
        case "hinge": return "Hüfte und Beinrückseite"
        case "calf": return "Waden"
        case "core": return "Rumpf"
        case "pull": return "Oberkörper"
        default: return g
        }
    }

    static let groups: [String] = ["jump", "squat", "hinge", "calf", "core", "pull"]

    static let ex: [String: Exercise] = {
        var m: [String: Exercise] = [:]
        func add(_ id: String, _ name: String, unit: String, group: String, equip: String = "",
                 opt: Bool = false, rx: [RxDef?], cue: String) {
            m[id] = Exercise(id: id, name: name, unit: unit, optional: opt, group: group,
                             equip: equip, rx: rx, cue: cue)
        }

        add("cmj", "Maximalsprung (Counter-Movement)", unit: "", group: "jump",
            rx: [rxd(4, 5, 90, "Jeder Sprung 100 %"), rxd(4, 4, 90, "Jeder Sprung 100 %"), rxd(5, 3, 120, "Jeder Sprung 100 %")],
            cue: "Schnell nach unten, explosiv hoch, weich landen. Lange Pause: jeder Sprung muss maximal sein.")
        add("pogo", "Pogo-Hops", unit: "", group: "jump",
            rx: [rxd(3, 15, 60, "Kurzer Bodenkontakt, steife Knöchel"), nil, nil],
            cue: "Aus den Sprunggelenken federn, Knie fast gestreckt. Wie auf einer heißen Platte.")
        add("tuck", "Hocksprung (Tuck Jump)", unit: "", group: "jump",
            rx: [rxd(3, 6, 90, "Knie zur Brust"), rxd(3, 6, 90, "Knie zur Brust"), rxd(4, 5, 90, "Maximal hoch")],
            cue: "Aus dem Stand maximal hoch springen und die Knie zur Brust ziehen. Weich landen. Ersatz für Box-Sprünge.")
        add("box", "Box Jump", unit: "cm", group: "jump", equip: "box",
            rx: [rxd(4, 4, 90, "Niedrige Box, ruhig landen"), rxd(4, 4, 90, "Mittlere Box"), rxd(5, 3, 120, "So hoch wie sauber möglich")],
            cue: "Maximal hoch springen, oben weich in der Hocke landen, absteigen statt runterspringen.")
        add("drop", "Tiefsprung (Drop Jump)", unit: "cm", group: "jump", equip: "box",
            rx: [nil, rxd(3, 4, 120, "Kasten 30 cm, Kontakt minimal"), rxd(4, 4, 120, "Kasten 30 bis 40 cm")],
            cue: "Vom Kasten fallen lassen, beim Aufkommen sofort wieder maximal hoch. Bodenkontakt so kurz wie möglich.")
        add("appr", "Anlaufsprung (Angriff/Block)", unit: "", group: "jump",
            rx: [rxd(3, 4, 90, "Technik, 80 %"), rxd(4, 3, 90, "Voller Einsatz"), rxd(5, 3, 90, "Voller Einsatz")],
            cue: "Dein Angriffsanlauf: letzter Schritt lang, Arme schwingen, Hände so hoch wie möglich.")
        add("jsq", "Sprung-Kniebeuge", unit: "kg", group: "jump",
            rx: [rxd(3, 6, 90, "Körpergewicht oder leicht"), rxd(4, 4, 120, "ca. 20 % deines Kniebeugen-Maximums"), rxd(4, 3, 120, "ca. 30 %, maximal schnell")],
            cue: "Mit leichter Last so schnell wie möglich abspringen. Geschwindigkeit zählt, nicht das Gewicht.")
        add("broad", "Standweitsprung", unit: "", group: "jump",
            rx: [rxd(3, 4, 90, "Weich landen"), rxd(3, 4, 90, "Weich landen"), rxd(4, 3, 90, "Maximale Weite")],
            cue: "Arme schwingen, Hüfte nach hinten, so weit wie möglich. Landung stabil halten.")
        add("sq", "Kniebeuge (Langhantel)", unit: "kg", group: "squat",
            rx: [rxd(4, 6, 150, "3 Sek. runter, 3 Wdh. im Tank"), rxd(5, 3, 180, "Schwer, 1 bis 2 Wdh. im Tank"), rxd(3, 3, 150, "Mittelschwer, explosiv hoch")],
            cue: "Brust hoch, Knie folgen den Zehen, mindestens bis Oberschenkel parallel. Das ist deine wichtigste Kraftübung.")
        add("split", "Bulgarische Kniebeuge", unit: "kg", group: "squat",
            rx: [rxd(3, 8, 90, "Pro Bein"), rxd(3, 6, 120, "Pro Bein"), rxd(3, 5, 120, "Pro Bein")],
            cue: "Hinterer Fuß auf der Bank, Oberkörper leicht nach vorn. Hilft bei Absprung und Landung auf einem Bein.")
        add("rdl", "Rumänisches Kreuzheben", unit: "kg", group: "hinge",
            rx: [rxd(3, 8, 120, "Langsam ablassen"), rxd(4, 5, 150, "Schwer, Rücken gerade"), rxd(3, 5, 120, "Zügig hoch")],
            cue: "Hüfte nach hinten schieben, Stange nah am Bein, Rücken lang. Training für die Oberschenkelrückseite.")
        add("hip", "Hip Thrust", unit: "kg", group: "hinge",
            rx: [rxd(3, 10, 90, "Oben 1 Sek. halten"), rxd(4, 6, 120, "Schwer"), rxd(3, 5, 90, "Explosiv hoch")],
            cue: "Oberer Rücken auf der Bank, Hüfte stark nach oben strecken, Kinn zur Brust.")
        add("nord", "Nordic Curl", unit: "", group: "hinge",
            rx: [rxd(3, 5, 90, "Langsam ablassen"), rxd(3, 6, 90, "Langsam ablassen"), rxd(2, 6, 90, "Langsam ablassen")],
            cue: "Füße fixieren, Körper gerade nach vorn ablassen, mit den Händen abfangen. Schützt die Oberschenkelrückseite.")
        add("swing", "Kettlebell Swing", unit: "kg", group: "hinge", equip: "kb",
            rx: [rxd(3, 10, 75, "Hüfte schnappt nach vorn"), rxd(4, 8, 90, "Schwerer"), rxd(3, 8, 75, "Explosiv")],
            cue: "Die Hüfte macht die Arbeit, die Arme hängen nur dran. Oben stehen, nicht ins Hohlkreuz fallen.")
        add("bridge", "Einbeinige Hüftbrücke", unit: "", group: "hinge",
            rx: [rxd(3, 10, 60, "Pro Bein"), rxd(3, 10, 60, "Pro Bein"), rxd(3, 8, 60, "Pro Bein, explosiv")],
            cue: "Auf dem Rücken, ein Fuß am Boden, Hüfte hoch drücken. Ersatz für Kettlebell Swings.")
        add("calf", "Wadenheben stehend", unit: "kg", group: "calf", opt: true,
            rx: [rxd(3, 12, 60, "Voller Bewegungsumfang"), rxd(4, 8, 90, "Schwer, 2 Sek. unten halten"), rxd(3, 6, 60, "Explosiv hoch")],
            cue: "Ganz nach oben auf die Zehen, unten tief dehnen. Starke Waden bringen Federung.")
        add("pall", "Pallof Press", unit: "", group: "core", equip: "cable", opt: true,
            rx: [rxd(3, 10, 45, "Pro Seite"), rxd(3, 10, 45, "Pro Seite"), rxd(3, 10, 45, "Pro Seite")],
            cue: "Am Kabel seitlich stehen, Arme nach vorn drücken, nicht verdrehen lassen. Rumpfspannung für Sprünge.")
        add("dead", "Dead Bug", unit: "", group: "core", opt: true,
            rx: [rxd(3, 8, 45, "Pro Seite"), rxd(3, 8, 45, "Pro Seite"), rxd(3, 8, 45, "Pro Seite")],
            cue: "Rücken flach am Boden, Arm und gegenüberliegendes Bein langsam strecken.")
        add("row", "Rudern", unit: "kg", group: "pull",
            rx: [rxd(3, 8, 90, "Kontrolliert"), rxd(4, 6, 90, "Schwerer"), rxd(3, 6, 90, "Zügig")],
            cue: "Rücken gerade, Ellbogen nah am Körper, Schulterblätter zusammenziehen.")
        add("pull", "Klimmzüge", unit: "kg", group: "pull",
            rx: [rxd(3, 6, 90, "0 = Körpergewicht"), rxd(3, 6, 90, "Zusatzgewicht wenn möglich"), rxd(3, 5, 90, "Sauber ziehen")],
            cue: "Aus dem Hang, Brust zur Stange. Stark für Angriffsschlag und Schultern.")
        add("face", "Face Pull", unit: "kg", group: "pull", equip: "cable", opt: true,
            rx: [rxd(3, 12, 60, "Leichtes Gewicht"), rxd(3, 12, 60, "Leichtes Gewicht"), rxd(3, 12, 60, "Leichtes Gewicht")],
            cue: "Seil auf Gesichtshöhe ziehen, Ellbogen hoch. Hält deine Schultern gesund bei vielen Angriffen.")
        add("lateral", "Seitliche Sprünge (Skater)", unit: "", group: "jump",
            rx: [rxd(3, 8, 75, "Pro Seite"), rxd(3, 8, 75, "Pro Seite"), rxd(3, 6, 75, "Pro Seite, weit")],
            cue: "Von einem Bein seitlich auf das andere springen, stabil landen und kurz halten. Gut für Landungen beim Blocken.")
        add("legpress", "Beinpresse", unit: "kg", group: "squat",
            rx: [rxd(3, 10, 90, "Kontrolliert"), rxd(4, 6, 120, "Schwer"), rxd(3, 6, 90, "Explosiv drücken")],
            cue: "Füße schulterbreit, Knie folgen den Zehen, nicht ganz durchstrecken. Zusätzliche Beinkraft ohne Belastung für den Rücken.")
        add("lunge", "Ausfallschritte", unit: "kg", group: "squat",
            rx: [rxd(3, 10, 60, "Pro Bein"), rxd(3, 8, 90, "Pro Bein"), rxd(3, 6, 75, "Pro Bein")],
            cue: "Großer Schritt, hinteres Knie fast zum Boden, Oberkörper aufrecht. Mit Kurzhanteln oder ohne Gewicht.")
        add("stepup", "Step-ups", unit: "kg", group: "squat", equip: "box",
            rx: [rxd(3, 8, 60, "Pro Bein"), rxd(3, 6, 90, "Pro Bein"), rxd(3, 6, 60, "Pro Bein, explosiv")],
            cue: "Mit einem Fuß auf die Box, ganz hochdrücken, ohne mit dem anderen Bein abzustoßen. Trainiert den einbeinigen Absprung.")
        add("legext", "Beinstrecker (Maschine)", unit: "kg", group: "squat", opt: true,
            rx: [rxd(3, 12, 60, "Oben kurz halten"), rxd(3, 10, 60, "Kontrolliert"), rxd(2, 10, 60, "Kontrolliert")],
            cue: "Langsam strecken, oben 1 Sek. halten, langsam zurück. Kräftigt den Oberschenkel vorn und schützt die Knie.")
        add("dl", "Kreuzheben", unit: "kg", group: "hinge",
            rx: [rxd(3, 5, 150, "Technik zuerst"), rxd(4, 3, 180, "Schwer, Rücken gerade"), rxd(3, 3, 150, "Explosiv hoch")],
            cue: "Stange nah am Körper, Brust hoch, mit den Beinen vom Boden wegdrücken. Baut Kraft für den Absprung auf.")
        add("legcurl", "Beinbeuger (Maschine)", unit: "kg", group: "hinge",
            rx: [rxd(3, 12, 60, "Langsam zurück"), rxd(3, 8, 90, "Kontrolliert"), rxd(3, 8, 60, "Kontrolliert")],
            cue: "Fersen zum Gesäß ziehen, langsam ablassen. Schützt die Oberschenkelrückseite bei schnellen Sprüngen.")
        add("calfsit", "Wadenheben sitzend", unit: "kg", group: "calf", opt: true,
            rx: [rxd(3, 15, 45, "Voller Bewegungsumfang"), rxd(3, 12, 60, "Unten 2 Sek. halten"), rxd(3, 12, 45, "Zügig")],
            cue: "Knie 90 Grad, ganz hoch auf die Zehen, unten tief dehnen. Trainiert den tiefen Wadenmuskel.")
        add("hangleg", "Hängendes Beinheben", unit: "", group: "core", opt: true,
            rx: [rxd(3, 10, 45, "Langsam, ohne Schwung"), rxd(3, 10, 45, "Langsam, ohne Schwung"), rxd(3, 12, 45, "Kontrolliert")],
            cue: "An der Klimmzugstange hängen, Beine gestreckt oder angewinkelt anheben. Bauch und Hüftbeuger für kräftigen Armschwung.")
        add("bench", "Bankdrücken", unit: "kg", group: "pull",
            rx: [rxd(3, 8, 90, "Kontrolliert"), rxd(4, 6, 120, "Schwer"), rxd(3, 5, 90, "Zügig")],
            cue: "Schulterblätter zusammen, Füße fest am Boden, Stange kontrolliert zur Brust. Kraft für den Angriffsschlag.")
        add("ohp", "Schulterdrücken", unit: "kg", group: "pull",
            rx: [rxd(3, 8, 90, "Kontrolliert"), rxd(3, 6, 90, "Schwer"), rxd(3, 6, 90, "Zügig")],
            cue: "Rumpf fest, Gesäß angespannt, Gewicht gerade über den Kopf drücken. Mit Kurzhanteln oder Maschine.")
        add("lat", "Latzug", unit: "kg", group: "pull",
            rx: [rxd(3, 10, 75, "Kontrolliert"), rxd(3, 8, 90, "Schwer"), rxd(3, 8, 75, "Zügig")],
            cue: "Stange zur oberen Brust ziehen, Ellbogen nach unten. Alternative zu Klimmzügen.")
        return m
    }()
}

// MARK: - Plan

struct PhaseInfo {
    let name: String
    let weeks: String
    let text: String
}

struct Opts {
    var compact: Bool = false
    var restMode: Int = 1      // 0 kurz, 1 normal, 2 lang
    var level: Int = 1         // 0 Einsteiger, 1 Fortgeschritten
    var hasBox: Bool = true
    var hasKB: Bool = true
    var hasCable: Bool = true
    var minutes: Int = 60      // gewünschte Dauer pro Einheit, 0 = Standardplan
}

struct FocusInfo {
    let id: String
    let name: String
    let detail: String
}

enum Plan {
    static let focuses: [FocusInfo] = [
        FocusInfo(id: "jump", name: "Sprung und Power", detail: "Sprünge zuerst, dann Kraft für den Absprung"),
        FocusInfo(id: "legs", name: "Beine und Kraft", detail: "Schwere Beinübungen für mehr Sprungkraft"),
        FocusInfo(id: "full", name: "Ganzkörper", detail: "Beine, Rücken, Brust und Rumpf in einer Einheit"),
        FocusInfo(id: "upper", name: "Oberkörper und Rumpf", detail: "Schultern, Rücken, Brust und Rumpf")
    ]

    static let focusPools: [String: [String]] = [
        "jump": ["cmj", "appr", "box", "drop", "tuck", "lateral", "broad", "jsq", "sq", "rdl", "split", "hip", "swing", "nord", "calf", "pall", "dead", "hangleg"],
        "legs": ["sq", "rdl", "legpress", "split", "hip", "legcurl", "nord", "legext", "stepup", "calf", "calfsit", "dead", "hangleg"],
        "full": ["cmj", "sq", "bench", "row", "rdl", "pull", "ohp", "split", "hip", "calf", "lat", "jsq", "dead", "pall", "face"],
        "upper": ["bench", "row", "ohp", "pull", "lat", "face", "hangleg", "dead", "pall"]
    ]

    /// Zusatzübungen, mit denen eine Einheit bei längerer Dauer aufgefüllt wird
    static let extras: [String: [String]] = [
        "F": ["split", "hip", "bench", "row", "pull", "dead", "pall"],
        "A": ["split", "legpress", "hip", "calf", "legcurl", "stepup", "dead"],
        "B": ["broad", "tuck", "lateral", "rdl", "calf", "bench", "row", "pall"],
        "C": ["legcurl", "legpress", "calf", "lunge", "pall", "hangleg"],
        "D": ["bench", "ohp", "lat", "face", "hangleg", "pall"],
        "E": ["lat", "split", "hip", "legcurl", "pall", "face"]
    ]

    /// Reihenfolge, in der Übungen bei kurzer Dauer weggelassen werden (zuerst die unwichtigsten)
    static let dropOrder: [String] = [
        "pall", "dead", "hangleg", "face", "calfsit", "calf", "legext", "nord", "bridge", "lunge", "stepup",
        "swing", "hip", "split", "lateral", "row", "pull", "bench", "ohp", "lat", "pogo", "drop", "box",
        "broad", "tuck", "appr", "legpress", "legcurl", "dl", "rdl", "jsq", "cmj", "sq"
    ]

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
        "D": SessionDef(key: "D", name: "Oberkörper und Rumpf", ex: ["row", "pull", "face", "dead", "pall"]),
        "E": SessionDef(key: "E", name: "Ganzkörper Kraft", ex: ["sq", "bench", "row", "rdl", "ohp", "pull", "calf", "dead"]),
        "S": SessionDef(key: "S", name: "Einzeltraining", ex: [])
    ]

    static let layout: [Int: [String]] = [
        1: ["F"], 2: ["A", "B"], 3: ["A", "B", "C"], 4: ["A", "B", "C", "D"], 5: ["A", "B", "C", "D", "E"]
    ]

    static func keys(forDays n: Int) -> [String] {
        layout[min(5, max(1, n))] ?? ["F"]
    }

    static func phase(_ week: Int) -> Int {
        week <= 4 ? 0 : (week <= 8 ? 1 : 2)
    }

    static func isDeload(_ week: Int) -> Bool {
        week == 4 || week == 8 || week == 12
    }

    static func available(_ equip: String, _ o: Opts) -> Bool {
        switch equip {
        case "box": return o.hasBox
        case "kb": return o.hasKB
        case "cable": return o.hasCable
        default: return true
        }
    }

    static func adjust(_ b: RxDef, week: Int, opts: Opts) -> RxDef {
        var sets = b.sets
        if opts.level == 0 && sets >= 4 { sets -= 1 }
        if isDeload(week) { sets = max(2, sets - 1) }
        let factors: [Double] = [0.75, 1.0, 1.25]
        let idx = min(2, max(0, opts.restMode))
        var rest = Double(b.rest) * factors[idx]
        if opts.compact { rest *= 0.8 }
        return RxDef(sets: sets, reps: b.reps, rest: Int(rest.rounded()), note: b.note)
    }

    /// Vorgabe der aktuellen Phase. nil, wenn die Übung in dieser Phase nicht vorkommt.
    static func rx(_ id: String, week: Int, opts: Opts) -> RxDef? {
        guard let e = Catalog.ex[id], let b = e.rx[phase(week)] else { return nil }
        return adjust(b, week: week, opts: opts)
    }

    /// Wie rx, nimmt aber eine andere Phase, falls die Übung in dieser Phase fehlt.
    static func anyRx(_ id: String, week: Int, opts: Opts) -> RxDef? {
        guard let e = Catalog.ex[id] else { return nil }
        var base: RxDef? = e.rx[phase(week)]
        if base == nil {
            for candidate in e.rx {
                if let c = candidate { base = c; break }
            }
        }
        guard let b = base else { return nil }
        return adjust(b, week: week, opts: opts)
    }

    static func resolve(_ id: String, _ o: Opts) -> String? {
        guard let e = Catalog.ex[id] else { return nil }
        if available(e.equip, o) { return id }
        switch id {
        case "box", "drop": return "tuck"
        case "swing": return "bridge"
        case "pall": return "dead"
        case "stepup": return "lunge"
        default: return nil
        }
    }

    /// Geschätzte Dauer in Sekunden inklusive 8 Minuten Aufwärmen
    static func seconds(_ ids: [String], week: Int, opts: Opts) -> Int {
        var s = 8 * 60
        for id in ids {
            if let r = anyRx(id, week: week, opts: opts) {
                s += r.sets * (35 + r.rest)
            }
        }
        return s
    }

    static func baseExercises(key: String, week: Int, opts: Opts) -> [String] {
        guard let def = sessionDefs[key] else { return [] }
        var out: [String] = []
        for id0 in def.ex {
            if rx(id0, week: week, opts: opts) == nil { continue }
            guard let id = resolve(id0, opts) else { continue }
            if opts.compact, let e = Catalog.ex[id], e.optional { continue }
            if out.contains(id) { continue }
            out.append(id)
        }
        return out
    }

    /// Einheit eines Plantags, an die gewünschte Dauer angepasst
    static func exercises(key: String, week: Int, opts: Opts) -> [String] {
        var list = baseExercises(key: key, week: week, opts: opts)
        if key == "S" || opts.minutes <= 0 { return list }
        let budget = opts.minutes * 60

        // Zu lang: unwichtige Übungen zuerst weglassen
        while list.count > 3 && seconds(list, week: week, opts: opts) > budget {
            var removed = false
            for d in dropOrder {
                if let idx = list.firstIndex(of: d) {
                    list.remove(at: idx)
                    removed = true
                    break
                }
            }
            if !removed { list.removeLast() }
        }

        // Zu kurz: Zusatzübungen anhängen
        for id0 in extras[key] ?? [] {
            if list.count >= 14 { break }
            if rx(id0, week: week, opts: opts) == nil { continue }
            guard let id = resolve(id0, opts) else { continue }
            if list.contains(id) { continue }
            if opts.compact, let e = Catalog.ex[id], e.optional { continue }
            if seconds(list + [id], week: week, opts: opts) <= budget {
                list.append(id)
            }
        }
        return list
    }

    /// Frei zusammengestelltes Einzeltraining nach Schwerpunkt und Dauer
    static func custom(focus: String, minutes: Int, week: Int, opts: Opts) -> [String] {
        let pool = focusPools[focus] ?? focusPools["full"] ?? []
        let budget = minutes * 60
        var list: [String] = []
        for id0 in pool {
            if list.count >= 14 { break }
            if rx(id0, week: week, opts: opts) == nil { continue }
            guard let id = resolve(id0, opts) else { continue }
            if list.contains(id) { continue }
            if opts.compact, let e = Catalog.ex[id], e.optional { continue }
            if list.count < 3 || seconds(list + [id], week: week, opts: opts) <= budget {
                list.append(id)
            }
        }
        return list
    }

    static func estMinutes(key: String, week: Int, opts: Opts) -> Int {
        let s = seconds(exercises(key: key, week: week, opts: opts), week: week, opts: opts)
        return Int((Double(s) / 60.0 / 5.0).rounded()) * 5
    }

    static func estMinutes(ids: [String], week: Int, opts: Opts) -> Int {
        let s = seconds(ids, week: week, opts: opts)
        return Int((Double(s) / 60.0 / 5.0).rounded()) * 5
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
    var note: String?
}

struct WorkoutLog: Codable, Equatable, Identifiable {
    var id: UUID
    var date: Date
    var key: String
    var week: Int
    var minutes: Int
    var ex: [ExLog]
    var feel: Int?
    var note: String?
}

struct JumpLog: Codable, Equatable, Identifiable {
    var id: UUID
    var date: Date
    var cm: Double
}

struct AppData: Codable, Equatable {
    var start: Date = Date()
    var days: [Int] = [2, 4, 6]       // 1 = Sonntag, 2 = Montag ... 7 = Samstag
    var compact: Bool = false
    var remind: Bool = false
    var remindHour: Int = 17
    var logs: [WorkoutLog] = []
    var jumps: [JumpLog] = []
    // Profil und Einstellungen (neu)
    var name: String = ""
    var level: Int = 1
    var bodyKg: Double = 75
    var goalCm: Double = 0
    var hasBox: Bool = true
    var hasKB: Bool = true
    var hasCable: Bool = true
    var restMode: Int = 1
    var showWarmup: Bool = true
    var haptics: Bool = true
    var appearance: Int = 0           // 0 System, 1 Hell, 2 Dunkel
    var onboarded: Bool = false
    var sessionMin: Int = 60
    var gym: String = ""
    var accentHex: String = "1E6FF0"
    var bgStyle: Int = 0              // 0 weiß, 1 grau, 2 getönt, 3 dunkel
    var radius: Int = 16
    var fontDesign: Int = 0           // 0 Standard, 1 Rund, 2 Serif, 3 Mono
    var textSize: Int = 3             // 0 klein ... 6 groß (DynamicTypeSize)

    init() {}

    enum CodingKeys: String, CodingKey {
        case start, days, compact, remind, remindHour, logs, jumps
        case name, level, bodyKg, goalCm, hasBox, hasKB, hasCable
        case restMode, showWarmup, haptics, appearance, onboarded
        case sessionMin, gym, accentHex, bgStyle, radius, fontDesign, textSize
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        start = try c.decodeIfPresent(Date.self, forKey: .start) ?? start
        days = try c.decodeIfPresent([Int].self, forKey: .days) ?? days
        compact = try c.decodeIfPresent(Bool.self, forKey: .compact) ?? compact
        remind = try c.decodeIfPresent(Bool.self, forKey: .remind) ?? remind
        remindHour = try c.decodeIfPresent(Int.self, forKey: .remindHour) ?? remindHour
        logs = try c.decodeIfPresent([WorkoutLog].self, forKey: .logs) ?? logs
        jumps = try c.decodeIfPresent([JumpLog].self, forKey: .jumps) ?? jumps
        name = try c.decodeIfPresent(String.self, forKey: .name) ?? name
        level = try c.decodeIfPresent(Int.self, forKey: .level) ?? level
        bodyKg = try c.decodeIfPresent(Double.self, forKey: .bodyKg) ?? bodyKg
        goalCm = try c.decodeIfPresent(Double.self, forKey: .goalCm) ?? goalCm
        hasBox = try c.decodeIfPresent(Bool.self, forKey: .hasBox) ?? hasBox
        hasKB = try c.decodeIfPresent(Bool.self, forKey: .hasKB) ?? hasKB
        hasCable = try c.decodeIfPresent(Bool.self, forKey: .hasCable) ?? hasCable
        restMode = try c.decodeIfPresent(Int.self, forKey: .restMode) ?? restMode
        showWarmup = try c.decodeIfPresent(Bool.self, forKey: .showWarmup) ?? showWarmup
        haptics = try c.decodeIfPresent(Bool.self, forKey: .haptics) ?? haptics
        appearance = try c.decodeIfPresent(Int.self, forKey: .appearance) ?? appearance
        onboarded = try c.decodeIfPresent(Bool.self, forKey: .onboarded) ?? onboarded
        sessionMin = try c.decodeIfPresent(Int.self, forKey: .sessionMin) ?? sessionMin
        gym = try c.decodeIfPresent(String.self, forKey: .gym) ?? gym
        accentHex = try c.decodeIfPresent(String.self, forKey: .accentHex) ?? accentHex
        bgStyle = try c.decodeIfPresent(Int.self, forKey: .bgStyle) ?? bgStyle
        radius = try c.decodeIfPresent(Int.self, forKey: .radius) ?? radius
        fontDesign = try c.decodeIfPresent(Int.self, forKey: .fontDesign) ?? fontDesign
        textSize = try c.decodeIfPresent(Int.self, forKey: .textSize) ?? textSize
    }

    static func fresh() -> AppData { AppData() }

    var opts: Opts {
        Opts(compact: compact, restMode: restMode, level: level,
             hasBox: hasBox, hasKB: hasKB, hasCable: hasCable, minutes: sessionMin)
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
    var goal: Double
    var streak: Int
    var name: String
}

extension AppData {
    /// Geplante Einheit (Schlüssel) für einen Kalendertag, nil = Ruhetag
    func plannedKey(on date: Date) -> String? {
        let wd = Cal.c.component(.weekday, from: date)
        let order = days.sorted { ($0 + 5) % 7 < ($1 + 5) % 7 }
        guard let i = order.firstIndex(of: wd) else { return nil }
        let keys = Plan.keys(forDays: days.count)
        return i < keys.count ? keys[i] : nil
    }

    func streak(now: Date = Date()) -> Int {
        let planned = Plan.keys(forDays: days.count).count
        var counts: [Date: Int] = [:]
        for l in logs where l.key != "S" {
            let m = Cal.monday(l.date)
            counts[m, default: 0] += 1
        }
        var cursor = Cal.monday(now)
        var n = 0
        if (counts[cursor] ?? 0) >= planned { n += 1 }
        for _ in 0..<520 {
            cursor = Cal.c.date(byAdding: .weekOfYear, value: -1, to: cursor) ?? cursor.addingTimeInterval(-7 * 86400)
            if (counts[cursor] ?? 0) >= planned { n += 1 } else { break }
        }
        return n
    }

    func summary(now: Date = Date()) -> Summary {
        let diff = Cal.c.dateComponents([.day], from: Cal.monday(start), to: Cal.monday(now)).day ?? 0
        let raw = diff / 7 + 1
        let week = min(12, max(1, raw))
        let keys = Plan.keys(forDays: days.count)
        let done = logs.filter { $0.key != "S" && Cal.c.isDate($0.date, equalTo: now, toGranularity: .weekOfYear) }.count
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
                       todayIsTraining: days.contains(today), best: best, gain: gain,
                       goal: goalCm, streak: streak(now: now), name: name)
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
