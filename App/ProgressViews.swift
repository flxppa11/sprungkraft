import SwiftUI
import Charts

struct ProgressTab: View {
    @State private var section = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Bereich", selection: $section) {
                    Text("Sprung").tag(0)
                    Text("Statistik").tag(1)
                    Text("Verlauf").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)
                if section == 0 {
                    JumpSection()
                } else if section == 1 {
                    StatsSection()
                } else {
                    HistorySection()
                }
            }
            .background(Theme.bg)
            .navigationTitle("Fortschritt")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Sprung

struct JumpSection: View {
    @EnvironmentObject var store: Store
    @State private var date = Date()
    @State private var cmText = ""
    @State private var error: String? = nil

    var body: some View {
        let desc = store.data.jumps.sorted { $0.date > $1.date }
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Neuer Test").font(.title3.bold())
                    DatePicker("Datum", selection: $date, displayedComponents: .date)
                    TextField("Sprunghöhe in cm", text: $cmText)
                        .keyboardType(.decimalPad)
                        .padding(10)
                        .background(Theme.bg)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    if let e = error { Text(e).foregroundStyle(.red).font(.footnote) }
                    PrimaryButton(title: "Eintragen") { add() }
                }
                .card()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Verlauf").font(.title3.bold())
                    chart
                }
                .card()

                if !desc.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Alle Tests").font(.title3.bold())
                        ForEach(desc) { j in
                            HStack {
                                Text(j.date.formatted(date: .abbreviated, time: .omitted))
                                Spacer()
                                Text("\(Store.fmt(j.cm)) cm").bold()
                                Button(role: .destructive) {
                                    store.data.jumps.removeAll { $0.id == j.id }
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .buttonStyle(.borderless)
                                .padding(.leading, 8)
                            }
                            Divider()
                        }
                    }
                    .card()
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("So misst du richtig").font(.title3.bold())
                    Text("Stelle dich seitlich an eine Wand. Greife mit der Hand so hoch wie möglich und mache eine Markierung. Springe dann aus dem Stand mit Armschwung und markiere den höchsten Punkt. Der Abstand ist deine Sprunghöhe. Teste ausgeruht, nach dem Aufwärmen, mit 3 Versuchen. Zähle den besten.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .card()
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }

    @ViewBuilder
    var chart: some View {
        let asc = store.data.jumps.sorted { $0.date < $1.date }
        if asc.count < 2 {
            Text("Ab zwei Tests siehst du hier deine Kurve.").foregroundStyle(.secondary)
        } else {
            let goal = store.data.goalCm
            let minV: Double = asc.map { $0.cm }.min() ?? 0
            let maxV: Double = asc.map { $0.cm }.max() ?? 0
            let lo: Double = minV - 2
            let hi: Double = max(maxV, goal) + 2
            Chart {
                ForEach(asc) { j in
                    LineMark(x: .value("Datum", j.date), y: .value("cm", j.cm))
                        .foregroundStyle(Theme.accent)
                    PointMark(x: .value("Datum", j.date), y: .value("cm", j.cm))
                        .foregroundStyle(Theme.accent)
                }
                if goal > 0 {
                    RuleMark(y: .value("Ziel", goal))
                        .foregroundStyle(Color.green)
                        .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                }
            }
            .chartYScale(domain: lo...hi)
            .frame(height: 200)
        }
    }

    func add() {
        let cm = Store.num(cmText)
        if cm < 10 || cm > 150 {
            error = "Gib eine Höhe zwischen 10 und 150 cm ein."
            return
        }
        error = nil
        store.addJump(date: date, cm: cm)
        cmText = ""
    }
}

// MARK: - Statistik

struct StatsSection: View {
    @EnvironmentObject var store: Store
    @State private var selected: String = ""

    var body: some View {
        let d = store.data
        let weeks = d.weeklyStats()
        let prs = d.prs()
        let loaded = d.exercisesWithLoad()
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 10) {
                    tile("\(d.logs.count)", "Einheiten")
                    tile("\(d.totalMinutes / 60) h \(d.totalMinutes % 60) min", "Trainingszeit")
                }
                HStack(spacing: 10) {
                    tile("\(d.totalSets)", "Sätze")
                    tile("\(d.summary().streak)", "Wochen Serie")
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Sätze pro Woche").font(.title3.bold())
                    Chart(weeks) { w in
                        BarMark(x: .value("Woche", w.id, unit: .weekOfYear), y: .value("Sätze", w.sets))
                            .foregroundStyle(Theme.accent)
                    }
                    .frame(height: 160)
                    Text("Letzte 8 Wochen")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .card()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Bestwerte").font(.title3.bold())
                    if loaded.isEmpty {
                        Text("Nach deiner ersten Einheit mit Gewichten erscheinen hier deine Bestwerte.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(loaded, id: \.self) { id in
                            HStack {
                                Text(Catalog.ex[id]?.name ?? id)
                                Spacer()
                                Text("\(Store.fmt(prs[id] ?? 0)) kg").fontWeight(.semibold).monospacedDigit()
                            }
                            Divider()
                        }
                        if let one = d.est1RM("sq") {
                            Text("Geschätztes Kniebeugen-Maximum: \(Store.fmt(one.rounded())) kg")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .card()

                if !loaded.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Verlauf pro Übung").font(.title3.bold())
                        Picker("Übung", selection: $selected) {
                            ForEach(loaded, id: \.self) { id in
                                Text(Catalog.ex[id]?.name ?? id).tag(id)
                            }
                        }
                        .pickerStyle(.menu)
                        let pts = d.series(selected.isEmpty ? (loaded.first ?? "") : selected)
                        if pts.count < 2 {
                            Text("Ab zwei Einheiten mit dieser Übung siehst du hier die Kurve.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        } else {
                            Chart(pts) { p in
                                LineMark(x: .value("Datum", p.date), y: .value("kg", p.value))
                                    .foregroundStyle(Theme.accent)
                                PointMark(x: .value("Datum", p.date), y: .value("kg", p.value))
                                    .foregroundStyle(Theme.accent)
                            }
                            .chartYScale(domain: .automatic(includesZero: false))
                            .frame(height: 160)
                        }
                    }
                    .card()
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Erfolge").font(.title3.bold())
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(d.achievements()) { a in
                            badge(a)
                        }
                    }
                }
                .card()
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .onAppear {
            if selected.isEmpty { selected = loaded.first ?? "" }
        }
    }

    func tile(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Text(label).font(.footnote).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    func badge(_ a: Achievement) -> some View {
        VStack(spacing: 6) {
            Image(systemName: a.icon)
                .font(.title)
                .foregroundStyle(a.done ? Theme.accent : Color.secondary.opacity(0.5))
            Text(a.title)
                .font(.footnote.weight(.semibold))
                .multilineTextAlignment(.center)
            Text(a.detail)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(Theme.field.opacity(a.done ? 1 : 0.4))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .opacity(a.done ? 1 : 0.7)
    }
}

// MARK: - Verlauf

struct HistorySection: View {
    @EnvironmentObject var store: Store

    var body: some View {
        let logs = store.data.logs.sorted { $0.date > $1.date }
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                if logs.isEmpty {
                    Text("Noch keine Einheiten. Starte dein erstes Training im Tab Heute.")
                        .foregroundStyle(.secondary)
                        .card()
                }
                ForEach(logs) { l in
                    NavigationLink {
                        LogDetailView(logID: l.id)
                    } label: {
                        row(l)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }

    func row(_ l: WorkoutLog) -> some View {
        let name: String = Plan.sessionDefs[l.key]?.name ?? "Training"
        var sets = 0
        for e in l.ex { sets += e.sets.count }
        return HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(.headline)
                Text(l.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(sets) Sätze").font(.subheadline.weight(.semibold))
                Text("\(l.minutes) Min.").font(.footnote).foregroundStyle(.secondary)
            }
            Image(systemName: "chevron.right").font(.footnote).foregroundStyle(.tertiary)
        }
        .card()
    }
}

struct LogDetailView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss
    let logID: UUID
    @State private var confirmDelete = false

    private let feelLabels: [String] = ["Sehr leicht", "Leicht", "Genau richtig", "Hart", "Sehr hart"]

    var body: some View {
        ScrollView {
            if let l = store.data.logs.first(where: { $0.id == logID }) {
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(Plan.sessionDefs[l.key]?.name ?? "Training").font(.title2.bold())
                        Text("\(l.date.formatted(date: .complete, time: .shortened)) · \(l.minutes) Min. · Woche \(l.week)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        if let f = l.feel, f >= 1, f <= 5 {
                            Text("Gefühl: \(feelLabels[f - 1])").font(.subheadline)
                        }
                        if let n = l.note { Text(n).font(.subheadline).foregroundStyle(.secondary) }
                    }
                    .card()
                    ForEach(0..<l.ex.count, id: \.self) { i in
                        exerciseCard(l.ex[i])
                    }
                    Button("Einheit löschen", role: .destructive) { confirmDelete = true }
                        .frame(maxWidth: .infinity)
                }
                .padding()
            }
        }
        .background(Theme.bg)
        .navigationTitle("Einheit")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Diese Einheit löschen?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Löschen", role: .destructive) {
                store.data.logs.removeAll { $0.id == logID }
                dismiss()
            }
        }
    }

    func exerciseCard(_ e: ExLog) -> some View {
        let x = Catalog.ex[e.id]
        let unit: String = x?.unit ?? ""
        return VStack(alignment: .leading, spacing: 6) {
            Text(x?.name ?? e.id).font(.headline)
            ForEach(0..<e.sets.count, id: \.self) { j in
                let s = e.sets[j]
                HStack {
                    Text("Satz \(j + 1)").foregroundStyle(.secondary)
                    Spacer()
                    if unit.isEmpty {
                        Text("\(s.reps) Wdh.").monospacedDigit()
                    } else {
                        Text("\(Store.fmt(s.kg)) \(unit) × \(s.reps)").monospacedDigit()
                    }
                }
                .font(.subheadline)
            }
            if let n = e.note {
                Text(n).font(.footnote).foregroundStyle(.secondary)
            }
        }
        .card()
    }
}
