import SwiftUI
import Charts
import UIKit

// MARK: - Bausteine

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

extension View {
    func card() -> some View { modifier(CardStyle()) }
}

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }
}

struct Pill: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.footnote.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Color(.tertiarySystemFill))
            .clipShape(Capsule())
    }
}

struct RxList: View {
    let key: String
    let week: Int
    let compact: Bool

    var body: some View {
        let ids = Plan.exercises(key: key, week: week, compact: compact)
        VStack(spacing: 0) {
            ForEach(ids, id: \.self) { id in
                if let x = Catalog.ex[id], let r = Plan.rx(id, week: week, compact: compact) {
                    VStack(spacing: 0) {
                        HStack {
                            Text(x.name)
                            Spacer()
                            Text("\(r.sets) × \(r.reps)")
                                .fontWeight(.semibold)
                                .monospacedDigit()
                        }
                        .padding(.vertical, 9)
                        Divider()
                    }
                }
            }
        }
    }
}

// MARK: - Tabs

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView().tabItem { Label("Heute", systemImage: "house.fill") }
            PlanView().tabItem { Label("Plan", systemImage: "calendar") }
            JumpView().tabItem { Label("Sprung", systemImage: "chart.line.uptrend.xyaxis") }
            ExercisesView().tabItem { Label("Übungen", systemImage: "dumbbell.fill") }
            SettingsView().tabItem { Label("Optionen", systemImage: "gearshape.fill") }
        }
    }
}

// MARK: - Heute

struct HomeView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        NavigationStack {
            if store.workout != nil {
                WorkoutView()
            } else {
                Overview()
            }
        }
    }
}

struct Overview: View {
    @EnvironmentObject var store: Store

    var body: some View {
        let s = store.data.summary()
        let title: String = s.done >= s.planned ? "Woche geschafft" : (s.todayIsTraining ? "Heute ist Sprungtag" : "Nächste Einheit")
        let deload: String = Plan.isDeload(s.week) ? " · Entlastung" : ""
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Woche \(s.week) von 12 · \(Plan.phases[Plan.phase(s.week)].name)\(deload)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.accent)
                    Text(title).font(.largeTitle.bold())
                }
                if s.rawWeek > 12 {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Dein 12-Wochen-Zyklus ist fertig").font(.title3.bold())
                        Text("Mach einen letzten Sprungtest und starte dann den nächsten Zyklus. Deine Gewichte bleiben gespeichert.")
                            .foregroundStyle(.secondary)
                        PrimaryButton(title: "Neuen Zyklus starten") { store.data.start = Date() }
                    }
                    .card()
                }
                WeekCard(s: s)
                NextCard(s: s)
                JumpSummaryCard(s: s)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
    }
}

struct WeekCard: View {
    @EnvironmentObject var store: Store
    let s: Summary
    private let order: [Int] = [2, 3, 4, 5, 6, 7, 1]
    private let names: [String] = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Diese Woche").font(.subheadline).foregroundStyle(.secondary)
                    Text("\(s.done) von \(s.planned) Einheiten").font(.headline)
                    Text(s.done >= s.planned ? "Alles erledigt. Erholung gehört zum Plan." : "Noch \(s.planned - s.done) offen")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                ProgressRing(done: s.done, planned: s.planned)
                    .frame(width: 86, height: 86)
            }
            HStack {
                ForEach(0..<7, id: \.self) { i in
                    dayDot(i)
                }
            }
        }
        .card()
    }

    func dayDot(_ i: Int) -> some View {
        let date = Cal.c.date(byAdding: .day, value: i, to: Cal.monday(Date())) ?? Date()
        let planned = store.data.days.contains(order[i])
        let done = store.data.logs.contains { Cal.c.isDate($0.date, inSameDayAs: date) }
        let today = Cal.c.isDateInToday(date)
        let ring: Color = done ? Color.green : (planned ? Theme.accent : Color.secondary.opacity(0.4))
        let dash: [CGFloat] = (planned || done) ? [] : [3, 3]
        return VStack(spacing: 4) {
            Circle()
                .fill(done ? Color.green : Color.clear)
                .overlay(Circle().strokeBorder(ring, style: StrokeStyle(lineWidth: 2, dash: dash)))
                .frame(width: 28, height: 28)
            Text(names[i])
                .font(.caption)
                .fontWeight(today ? .bold : .regular)
                .foregroundStyle(today ? Color.primary : Color.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct NextCard: View {
    @EnvironmentObject var store: Store
    let s: Summary

    var body: some View {
        let name: String = Plan.sessionDefs[s.nextKey]?.name ?? ""
        let mins = Plan.estMinutes(key: s.nextKey, week: s.week, compact: store.data.compact)
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(s.done >= s.planned ? "Zusätzlich möglich" : "Als Nächstes")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.accent)
                    Text(name).font(.title2.bold())
                }
                Spacer()
                Pill(text: "ca. \(mins) Min.")
            }
            RxList(key: s.nextKey, week: s.week, compact: store.data.compact)
            PrimaryButton(title: "Training starten") { store.start(s.nextKey) }
        }
        .card()
    }
}

struct JumpSummaryCard: View {
    let s: Summary

    var body: some View {
        if let best = s.best {
            let gain = s.gain ?? 0
            HStack {
                VStack(alignment: .leading) {
                    Text("Bester Sprung").font(.subheadline).foregroundStyle(.secondary)
                    Text("\(Store.fmt(best)) cm").font(.system(size: 40, weight: .bold, design: .rounded))
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Seit Start").font(.subheadline).foregroundStyle(.secondary)
                    Text("\(gain >= 0 ? "+" : "")\(Store.fmt(gain)) cm")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.green)
                }
            }
            .card()
        } else {
            VStack(alignment: .leading, spacing: 6) {
                Text("Starthöhe messen").font(.title3.bold())
                Text("Trage im Tab Sprung deinen ersten Test ein, damit du deinen Fortschritt siehst.")
                    .foregroundStyle(.secondary)
            }
            .card()
        }
    }
}

// MARK: - Training

struct WorkoutView: View {
    @EnvironmentObject var store: Store
    @State private var restEnd: Date? = nil
    @State private var confirmCancel = false
    @State private var alertMsg: String? = nil
    @State private var showWarm = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    header
                    DisclosureGroup("Aufwärmen (ca. 8 Min.)", isExpanded: $showWarm) {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(Plan.warmup, id: \.self) { line in
                                Text("• " + line)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 6)
                    }
                    .card()
                    ForEach(0..<(store.workout?.ex.count ?? 0), id: \.self) { i in
                        ExerciseCard(i: i, restEnd: $restEnd)
                    }
                    PrimaryButton(title: "Einheit abschließen") { finish() }
                    Button("Abbrechen", role: .destructive) { confirmCancel = true }
                        .frame(maxWidth: .infinity)
                }
                .padding()
                .padding(.bottom, restEnd == nil ? 0 : 80)
            }
            .scrollDismissesKeyboard(.interactively)
            if let end = restEnd {
                RestBar(end: end, restEnd: $restEnd)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Fertig") {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
        }
        .confirmationDialog("Einheit verwerfen? Eingaben gehen verloren.", isPresented: $confirmCancel, titleVisibility: .visible) {
            Button("Verwerfen", role: .destructive) { store.workout = nil }
        }
        .alert("Hinweis", isPresented: Binding(get: { alertMsg != nil }, set: { if !$0 { alertMsg = nil } })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMsg ?? "")
        }
    }

    var header: some View {
        let w = store.workout
        let name: String = Plan.sessionDefs[w?.key ?? ""]?.name ?? "Training"
        return VStack(alignment: .leading, spacing: 2) {
            TimelineView(.periodic(from: .now, by: 30)) { ctx in
                let mins = Int(ctx.date.timeIntervalSince(w?.start ?? ctx.date) / 60)
                Text("Woche \(w?.week ?? 1) · \(mins) Min.")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.accent)
            }
            Text(name).font(.largeTitle.bold())
        }
    }

    func finish() {
        if store.finishWorkout() {
            restEnd = nil
        } else {
            alertMsg = "Hake mindestens einen Satz ab."
        }
    }
}

struct RestBar: View {
    let end: Date
    @Binding var restEnd: Date?

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.5)) { ctx in
            let left = Int(end.timeIntervalSince(ctx.date).rounded())
            let a = abs(left)
            let sign: String = left < 0 ? "+" : ""
            let secText = String(format: "%02d", a % 60)
            HStack(spacing: 10) {
                Text("Pause").font(.footnote).opacity(0.7)
                Text("\(sign)\(a / 60):\(secText)")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(left <= 0 ? Theme.accent : Color.white)
                Spacer()
                Button("−15") { restEnd = end.addingTimeInterval(-15) }
                Button("+15") { restEnd = end.addingTimeInterval(15) }
                Button("Weiter") { restEnd = nil }
            }
            .buttonStyle(.bordered)
            .foregroundStyle(Color.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
    }
}

struct ExerciseCard: View {
    @EnvironmentObject var store: Store
    let i: Int
    @Binding var restEnd: Date?

    var body: some View {
        if let w = store.workout, i < w.ex.count,
           let x = Catalog.ex[w.ex[i].id],
           let r = Plan.rx(w.ex[i].id, week: w.week, compact: store.data.compact) {
            content(w.ex[i], x, r)
        }
    }

    func content(_ e: ActiveEx, _ x: Exercise, _ r: RxDef) -> some View {
        let note: String = r.note.isEmpty ? "" : " · " + r.note
        return VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(x.name).font(.title3.bold())
                Text("\(r.sets) × \(r.reps) · Pause \(r.rest) Sek.\(note)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                if let h = store.hint(for: e.id, rx: r) {
                    Text(h).font(.footnote).foregroundStyle(Theme.accent)
                }
            }
            ForEach(0..<e.sets.count, id: \.self) { j in
                setRow(j, x, r, e.sets[j])
            }
        }
        .card()
    }

    func setRow(_ j: Int, _ x: Exercise, _ r: RxDef, _ s: ActiveSet) -> some View {
        HStack(spacing: 8) {
            Text("\(j + 1)")
                .font(.title3.bold())
                .foregroundStyle(.secondary)
                .frame(width: 26)
            if !x.unit.isEmpty {
                numField(x.unit, Binding(
                    get: { store.workout?.ex[i].sets[j].kg ?? "" },
                    set: { store.workout?.ex[i].sets[j].kg = $0 }
                ), decimal: true)
            }
            numField("Wdh.", Binding(
                get: { store.workout?.ex[i].sets[j].reps ?? "" },
                set: { store.workout?.ex[i].sets[j].reps = $0 }
            ), decimal: false)
            Button {
                toggle(j, rest: r.rest)
            } label: {
                Image(systemName: s.done ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 34))
                    .foregroundStyle(s.done ? Color.green : Color.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Satz \(j + 1) erledigt")
        }
    }

    func numField(_ unit: String, _ b: Binding<String>, decimal: Bool) -> some View {
        TextField("", text: b)
            .keyboardType(decimal ? .decimalPad : .numberPad)
            .multilineTextAlignment(.center)
            .font(.title3.weight(.semibold).monospacedDigit())
            .padding(.vertical, 10)
            .padding(.horizontal, 6)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(alignment: .topTrailing) {
                Text(unit)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .padding(.trailing, 6)
                    .padding(.top, 2)
            }
    }

    func toggle(_ j: Int, rest: Int) {
        store.workout?.ex[i].sets[j].done.toggle()
        let nowDone = store.workout?.ex[i].sets[j].done ?? false
        if nowDone {
            restEnd = Date().addingTimeInterval(Double(rest))
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } else {
            restEnd = nil
        }
    }
}

// MARK: - Plan

struct PlanView: View {
    @EnvironmentObject var store: Store

    var body: some View {
        let s = store.data.summary()
        let keys = Plan.keys(forDays: store.data.days.count)
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(0..<3, id: \.self) { i in
                        phaseCard(i, s.week)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Entlastungswochen").font(.title3.bold())
                        Text("In Woche 4, 8 und 12 machst du einen Satz weniger pro Übung. So erholt sich dein Körper und die Sprünge werden stärker.")
                            .foregroundStyle(.secondary)
                    }
                    .card()
                    Text("Woche \(s.week): deine Einheiten").font(.title2.bold())
                    ForEach(0..<keys.count, id: \.self) { idx in
                        sessionCard(idx, keys[idx], s.week)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Plan")
        }
    }

    func phaseCard(_ i: Int, _ week: Int) -> some View {
        let p = Plan.phases[i]
        let active = Plan.phase(week) == i
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(p.name).font(.title3.bold())
                Spacer()
                Pill(text: p.weeks)
            }
            Text(p.text).foregroundStyle(.secondary)
        }
        .card()
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(active ? Theme.accent : Color.clear, lineWidth: 2))
    }

    func sessionCard(_ idx: Int, _ key: String, _ week: Int) -> some View {
        let name: String = Plan.sessionDefs[key]?.name ?? ""
        let mins = Plan.estMinutes(key: key, week: week, compact: store.data.compact)
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(idx + 1). \(name)").font(.title3.bold())
                Spacer()
                Pill(text: "ca. \(mins) Min.")
            }
            RxList(key: key, week: week, compact: store.data.compact)
        }
        .card()
    }
}

// MARK: - Sprungtest

struct JumpView: View {
    @EnvironmentObject var store: Store
    @State private var date = Date()
    @State private var cmText = ""
    @State private var error: String? = nil

    var body: some View {
        let desc = store.data.jumps.sorted { $0.date > $1.date }
        NavigationStack {
            Form {
                Section("Neuer Test") {
                    DatePicker("Datum", selection: $date, displayedComponents: .date)
                    TextField("Sprunghöhe in cm", text: $cmText).keyboardType(.decimalPad)
                    if let e = error { Text(e).foregroundStyle(.red).font(.footnote) }
                    Button("Eintragen") { add() }
                }
                Section("Verlauf") { chart }
                if !desc.isEmpty {
                    Section("Alle Tests") {
                        ForEach(desc) { j in
                            HStack {
                                Text(j.date, style: .date)
                                Spacer()
                                Text("\(Store.fmt(j.cm)) cm").bold()
                            }
                        }
                        .onDelete { offsets in
                            var ids = Set<UUID>()
                            for o in offsets { ids.insert(desc[o].id) }
                            store.data.jumps.removeAll { ids.contains($0.id) }
                        }
                    }
                }
                Section("So misst du richtig") {
                    Text("Stelle dich seitlich an eine Wand. Greife mit der Hand so hoch wie möglich und mache eine Markierung. Springe dann aus dem Stand mit Armschwung und markiere den höchsten Punkt. Der Abstand ist deine Sprunghöhe. Teste ausgeruht, nach dem Aufwärmen, mit 3 Versuchen. Zähle den besten.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Sprungtest")
        }
    }

    @ViewBuilder
    var chart: some View {
        let asc = store.data.jumps.sorted { $0.date < $1.date }
        if asc.count < 2 {
            Text("Ab zwei Tests siehst du hier deine Kurve.").foregroundStyle(.secondary)
        } else {
            let lo: Double = (asc.map { $0.cm }.min() ?? 0) - 2
            let hi: Double = (asc.map { $0.cm }.max() ?? 0) + 2
            Chart(asc) { j in
                LineMark(x: .value("Datum", j.date), y: .value("cm", j.cm))
                    .foregroundStyle(Theme.accent)
                PointMark(x: .value("Datum", j.date), y: .value("cm", j.cm))
                    .foregroundStyle(Theme.accent)
            }
            .chartYScale(domain: lo...hi)
            .frame(height: 180)
        }
    }

    func add() {
        let cm = Store.num(cmText)
        if cm < 10 || cm > 150 {
            error = "Gib eine Höhe zwischen 10 und 150 cm ein."
            return
        }
        error = nil
        store.data.jumps.append(JumpLog(id: UUID(), date: date, cm: (cm * 10).rounded() / 10))
        cmText = ""
    }
}

// MARK: - Übungen

struct ExercisesView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Technik") {
                    ForEach(Catalog.order, id: \.self) { id in
                        if let x = Catalog.ex[id] {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(x.name).font(.headline)
                                Text(x.cue).font(.subheadline).foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
                Section("Grundregeln für hohe Sprünge") {
                    Text("Schlaf: 7 bis 9 Stunden. Hier passiert die Anpassung.")
                    Text("Eiweiß: ca. 1,6 bis 2 g pro kg Körpergewicht am Tag.")
                    Text("Sprünge nur frisch: Zuerst springen, dann Kraft. Nie müde maximal springen.")
                    Text("Schmerz (nicht Muskelkater): Pause machen und die Übung ersetzen.")
                    Text("Keine medizinische Beratung. Bei Beschwerden ärztlich abklären.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Übungen")
        }
    }
}

// MARK: - Optionen

struct SettingsView: View {
    @EnvironmentObject var store: Store
    @State private var confirmRestart = false
    @State private var confirmWipe = false

    private let order: [Int] = [2, 3, 4, 5, 6, 7, 1]
    private let names: [String] = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 6) {
                        ForEach(0..<7, id: \.self) { i in
                            chip(i)
                        }
                    }
                    Text("\(store.data.days.count) Einheit\(store.data.days.count == 1 ? "" : "en") pro Woche. Wähle 1 bis 4 Tage.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Trainingstage")
                }

                Section {
                    Toggle("Kompakt-Modus", isOn: $store.data.compact)
                } footer: {
                    Text("Weniger Zubehör und kürzere Pausen. Spart ca. 10 Minuten pro Einheit.")
                }

                Section {
                    Toggle("Erinnerung am Trainingstag", isOn: $store.data.remind)
                    if store.data.remind {
                        Picker("Uhrzeit", selection: $store.data.remindHour) {
                            ForEach(6..<23, id: \.self) { h in
                                Text("\(h):00 Uhr").tag(h)
                            }
                        }
                    }
                } header: {
                    Text("Erinnerung")
                }

                Section {
                    Button("Programm neu starten (Woche 1)") { confirmRestart = true }
                    ShareLink(item: store.exportJSON()) {
                        Label("Sicherung teilen", systemImage: "square.and.arrow.up")
                    }
                    Button("Alle Daten löschen", role: .destructive) { confirmWipe = true }
                } header: {
                    Text("Programm und Daten")
                }
            }
            .navigationTitle("Optionen")
            .onChange(of: store.data.days) { _, _ in applyReminder() }
            .onChange(of: store.data.remind) { _, _ in applyReminder() }
            .onChange(of: store.data.remindHour) { _, _ in applyReminder() }
            .confirmationDialog("Programm bei Woche 1 neu starten? Deine Protokolle bleiben erhalten.", isPresented: $confirmRestart, titleVisibility: .visible) {
                Button("Neu starten") { store.data.start = Date() }
            }
            .confirmationDialog("Wirklich alle Daten löschen?", isPresented: $confirmWipe, titleVisibility: .visible) {
                Button("Alles löschen", role: .destructive) {
                    store.workout = nil
                    store.data = AppData.fresh()
                }
            }
        }
    }

    func chip(_ i: Int) -> some View {
        let d = order[i]
        let on = store.data.days.contains(d)
        return Text(names[i])
            .font(.subheadline.weight(.semibold))
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(on ? Theme.accent : Color(.tertiarySystemFill))
            .foregroundStyle(on ? Color.white : Color.primary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .onTapGesture { toggleDay(d) }
            .accessibilityAddTraits(.isButton)
    }

    func toggleDay(_ d: Int) {
        if let idx = store.data.days.firstIndex(of: d) {
            if store.data.days.count > 1 { store.data.days.remove(at: idx) }
        } else if store.data.days.count < 4 {
            store.data.days.append(d)
        }
    }

    func applyReminder() {
        Reminder.apply(enabled: store.data.remind, days: store.data.days, hour: store.data.remindHour)
    }
}
