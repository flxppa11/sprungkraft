import SwiftUI

// MARK: - Wochenplan

struct WeekPlanSection: View {
    @EnvironmentObject var store: Store
    private let order: [Int] = [2, 3, 4, 5, 6, 7, 1]
    private let names: [String] = ["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag"]

    var body: some View {
        let s = store.data.summary()
        let o = store.data.opts
        let keys = Plan.keys(forDays: store.data.days.count)
        let sorted = store.data.days.sorted { ($0 + 5) % 7 < ($1 + 5) % 7 }
        var total = 0
        for k in keys { total += Plan.estMinutes(key: k, week: s.week, opts: o) }
        return VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Diese Woche").font(.subheadline).foregroundStyle(.secondary)
                Text("\(keys.count) Einheiten · ca. \(fmtHours(total))").font(.title3.bold())
                Text("Ändere Tage und Dauer unter Profil → Trainingszeit.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            .card()
            ForEach(0..<7, id: \.self) { i in
                let wd = order[i]
                let date = Cal.c.date(byAdding: .day, value: i, to: Cal.monday(Date())) ?? Date()
                let idx = sorted.firstIndex(of: wd)
                HStack(spacing: 12) {
                    VStack(spacing: 2) {
                        Text(String(names[i].prefix(2))).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                        Text("\(Cal.c.component(.day, from: date))").font(.title3.bold())
                    }
                    .frame(width: 40)
                    if let idx = idx, idx < keys.count {
                        let k = keys[idx]
                        VStack(alignment: .leading, spacing: 2) {
                            Text(Plan.sessionDefs[k]?.name ?? "").font(.subheadline.weight(.semibold))
                            Text("ca. \(Plan.estMinutes(key: k, week: s.week, opts: o)) Min. · \(Plan.exercises(key: k, week: s.week, opts: o).count) Übungen")
                                .font(.footnote).foregroundStyle(.secondary)
                        }
                        Spacer()
                        if store.data.logs.contains(where: { $0.key != "S" && Cal.c.isDate($0.date, inSameDayAs: date) }) {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                        }
                    } else {
                        Text("Ruhetag").font(.subheadline).foregroundStyle(.secondary)
                        Spacer()
                    }
                }
                .card()
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.radius)
                        .stroke(Cal.c.isDateInToday(date) ? Theme.accent : Color.clear, lineWidth: 2)
                )
            }
        }
    }

    func fmtHours(_ min: Int) -> String {
        let h = min / 60, m = min % 60
        return m == 0 ? "\(h) Std." : "\(h) Std. \(m) Min."
    }
}

// MARK: - Monatsplan

struct MonthPlanSection: View {
    @EnvironmentObject var store: Store
    @State private var offset = 0

    var body: some View {
        let cal = Cal.c
        let base = cal.date(byAdding: .month, value: offset, to: Date()) ?? Date()
        let first = cal.date(from: cal.dateComponents([.year, .month], from: base)) ?? base
        let range = cal.range(of: .day, in: .month, for: first) ?? 1..<31
        let lead = (cal.component(.weekday, from: first) + 5) % 7
        let o = store.data.opts
        let df: DateFormatter = {
            let f = DateFormatter(); f.locale = Locale(identifier: "de_DE"); f.dateFormat = "LLLL yyyy"; return f
        }()
        var sessions = 0, minutes = 0, doneCount = 0
        for d in range {
            guard let date = cal.date(byAdding: .day, value: d - 1, to: first) else { continue }
            if let k = store.data.plannedKey(on: date) {
                sessions += 1
                let w = store.data.summary(now: date).week
                minutes += Plan.estMinutes(key: k, week: w, opts: o)
            }
            if store.data.logs.contains(where: { cal.isDate($0.date, inSameDayAs: date) }) { doneCount += 1 }
        }
        return VStack(spacing: 12) {
            HStack {
                Button { offset -= 1 } label: { Image(systemName: "chevron.left") }
                Spacer()
                Text(df.string(from: first)).font(.title3.bold())
                Spacer()
                Button { offset += 1 } label: { Image(systemName: "chevron.right") }
            }
            .padding(.horizontal, 4)
            HStack {
                ForEach(["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"], id: \.self) { n in
                    Text(n).font(.caption).foregroundStyle(.secondary).frame(maxWidth: .infinity)
                }
            }
            let cols = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
            LazyVGrid(columns: cols, spacing: 6) {
                ForEach(0..<lead, id: \.self) { _ in Color.clear.frame(height: 44) }
                ForEach(Array(range), id: \.self) { d in
                    let date = cal.date(byAdding: .day, value: d - 1, to: first) ?? first
                    dayCell(d, date)
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("\(sessions) geplante Einheiten · ca. \(minutes / 60) Std. \(minutes % 60) Min.").font(.subheadline.weight(.semibold))
                Text("\(doneCount) Trainingstage bereits absolviert").font(.footnote).foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .card()
        }
    }

    func dayCell(_ d: Int, _ date: Date) -> some View {
        let planned = store.data.plannedKey(on: date) != nil
        let done = store.data.logs.contains { Cal.c.isDate($0.date, inSameDayAs: date) }
        let today = Cal.c.isDateInToday(date)
        return VStack(spacing: 3) {
            Text("\(d)").font(.subheadline.weight(today ? .bold : .regular))
            Circle()
                .fill(done ? Color.green : (planned ? Theme.accent : Color.clear))
                .frame(width: 7, height: 7)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(today ? Theme.accent : Color.clear, lineWidth: 2))
    }
}

// MARK: - Werkzeuge

struct PlateCalcView: View {
    @State private var target = "100"
    @State private var bar = 20.0
    private let plates: [Double] = [25, 20, 15, 10, 5, 2.5, 1.25]

    var body: some View {
        let t = Store.num(target)
        var side = (t - bar) / 2
        var used: [(Double, Int)] = []
        if side > 0 {
            for p in plates {
                let n = Int((side / p).rounded(.down) + 0.0001)
                if n > 0 { used.append((p, n)); side -= Double(n) * p }
            }
        }
        return Form {
            Section("Zielgewicht") {
                TextField("Gesamtgewicht in kg", text: $target).keyboardType(.decimalPad)
                Picker("Stange", selection: $bar) {
                    Text("20 kg").tag(20.0)
                    Text("15 kg").tag(15.0)
                    Text("10 kg").tag(10.0)
                }
                .pickerStyle(.segmented)
            }
            Section("Pro Seite auflegen") {
                if t <= bar {
                    Text("Nur die Stange.")
                } else if used.isEmpty {
                    Text("Zu leicht für Standardscheiben.")
                } else {
                    ForEach(used, id: \.0) { u in
                        HStack { Text("\(Store.fmt(u.0)) kg"); Spacer(); Text("× \(u.1)").fontWeight(.semibold) }
                    }
                    if side > 0.01 {
                        Text("Rest \(Store.fmt(side * 2)) kg nicht mit Scheiben erreichbar.")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Scheibenrechner")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct OneRMView: View {
    @State private var weight = ""
    @State private var reps = ""

    var body: some View {
        let w = Store.num(weight), r = Store.num(reps)
        let rm: Double = (w > 0 && r > 0) ? (r <= 1 ? w : w * (1 + r / 30)) : 0
        return Form {
            Section("Dein Satz") {
                TextField("Gewicht in kg", text: $weight).keyboardType(.decimalPad)
                TextField("Wiederholungen", text: $reps).keyboardType(.numberPad)
            }
            if rm > 0 {
                Section("Geschätztes 1RM") {
                    Text("\(Store.fmt(rm)) kg").font(.title2.bold())
                }
                Section("Prozente") {
                    ForEach([95, 90, 85, 80, 75, 70, 60, 50], id: \.self) { p in
                        HStack { Text("\(p) %"); Spacer(); Text("\(Store.fmt((rm * Double(p) / 100 * 2).rounded() / 2)) kg").fontWeight(.semibold) }
                    }
                }
            }
        }
        .navigationTitle("1RM-Rechner")
        .navigationBarTitleDisplayMode(.inline)
    }
}
