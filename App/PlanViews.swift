import SwiftUI

// MARK: - Plan

struct PlanView: View {
    @EnvironmentObject var store: Store
    @State private var picked: Int = 0
    @State private var mode = 0

    var body: some View {
        let cur = store.data.summary().week
        let week = picked == 0 ? cur : picked
        let keys = Plan.keys(forDays: store.data.days.count)
        let o = store.data.opts
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Picker("Ansicht", selection: $mode) {
                        Text("Woche").tag(0)
                        Text("Monat").tag(1)
                        Text("12 Wochen").tag(2)
                    }
                    .pickerStyle(.segmented)
                    if mode == 0 { WeekPlanSection() }
                    if mode == 1 { MonthPlanSection() }
                    if mode == 2 {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(1..<13, id: \.self) { w in
                                weekChip(w, cur: cur, selected: week)
                            }
                        }
                    }

                    phaseCard(week)

                    if Plan.isDeload(week) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Entlastungswoche").font(.headline)
                            Text("Diese Woche machst du einen Satz weniger pro Übung. So erholt sich dein Körper und die nächsten Sprünge werden stärker.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .card()
                    }

                    Text("Woche \(week): deine Einheiten").font(.title2.bold())
                    ForEach(0..<keys.count, id: \.self) { idx in
                        sessionCard(idx, keys[idx], week, o)
                    }
                    }
                }
                .padding()
            }
            .background(Theme.bg)
            .navigationTitle("Plan")
        }
    }

    func weekChip(_ w: Int, cur: Int, selected: Int) -> some View {
        let isSel = w == selected
        let isCur = w == cur
        return Text("\(w)")
            .font(.subheadline.weight(.semibold))
            .frame(width: 42, height: 42)
            .background(isSel ? Theme.accent : Theme.card)
            .foregroundStyle(isSel ? Color.white : Color.primary)
            .clipShape(Circle())
            .overlay(Circle().stroke(isCur ? Theme.accent : Color.clear, lineWidth: 2))
            .onTapGesture { picked = w }
            .accessibilityAddTraits(.isButton)
            .accessibilityLabel("Woche \(w)")
    }

    func phaseCard(_ week: Int) -> some View {
        let p = Plan.phases[Plan.phase(week)]
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(p.name).font(.title3.bold())
                Spacer()
                Pill(text: p.weeks)
            }
            Text(p.text).foregroundStyle(.secondary)
        }
        .card()
    }

    func sessionCard(_ idx: Int, _ key: String, _ week: Int, _ o: Opts) -> some View {
        let name: String = Plan.sessionDefs[key]?.name ?? ""
        let mins = Plan.estMinutes(key: key, week: week, opts: o)
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(idx + 1). \(name)").font(.title3.bold())
                Spacer()
                Pill(text: "ca. \(mins) Min.")
            }
            RxList(key: key, week: week, opts: o)
        }
        .card()
    }
}

// MARK: - Übungen

struct ExercisesView: View {
    @State private var query = ""

    var body: some View {
        NavigationStack {
            List {
                Section("Werkzeuge") {
                    NavigationLink { PlateCalcView() } label: { Label("Scheibenrechner", systemImage: "circle.grid.2x1") }
                    NavigationLink { OneRMView() } label: { Label("1RM- und Prozentrechner", systemImage: "percent") }
                }
                ForEach(Catalog.groups, id: \.self) { g in
                    let ids = filtered(g)
                    if !ids.isEmpty {
                        Section(Catalog.groupName(g)) {
                            ForEach(ids, id: \.self) { id in
                                if let x = Catalog.ex[id] {
                                    NavigationLink {
                                        ExerciseDetail(x: x)
                                    } label: {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(x.name).font(.headline)
                                            Text(x.cue)
                                                .font(.footnote)
                                                .foregroundStyle(.secondary)
                                                .lineLimit(2)
                                        }
                                    }
                                }
                            }
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
            .searchable(text: $query, prompt: "Übung suchen")
            .navigationTitle("Übungen")
        }
    }

    func filtered(_ g: String) -> [String] {
        Catalog.order.filter { id in
            guard let x = Catalog.ex[id], x.group == g else { return false }
            if query.isEmpty { return true }
            return x.name.localizedCaseInsensitiveContains(query)
        }
    }
}

struct ExerciseDetail: View {
    let x: Exercise

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(Catalog.groupName(x.group)).font(.subheadline.weight(.semibold)).foregroundStyle(Theme.accent)
                    Text(x.name).font(.title.bold())
                    Text(x.cue)
                }
                .card()
                GuideView(exercise: x)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Vorgabe je Phase").font(.title3.bold())
                    ForEach(0..<3, id: \.self) { p in
                        HStack(alignment: .top) {
                            Text(Plan.phases[p].name).fontWeight(.semibold)
                            Spacer()
                            if let r = x.rx[p] {
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("\(r.sets) × \(r.reps)").monospacedDigit()
                                    Text(r.note).font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.trailing)
                                }
                            } else {
                                Text("nicht in dieser Phase").foregroundStyle(.secondary).font(.footnote)
                            }
                        }
                        Divider()
                    }
                }
                .card()
                if !x.equip.isEmpty {
                    Text("Benötigt: \(equipName(x.equip)). Ohne dieses Gerät ersetzt die App die Übung automatisch.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
        .background(Theme.bg)
        .navigationTitle(x.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    func equipName(_ e: String) -> String {
        switch e {
        case "box": return "Sprungbox"
        case "kb": return "Kettlebell"
        case "cable": return "Kabelzug"
        default: return e
        }
    }
}
