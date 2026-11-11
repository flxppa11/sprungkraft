import SwiftUI
import UIKit

// MARK: - Bausteine

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: Theme.radius))
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

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .buttonStyle(.bordered)
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
            .background(Theme.field)
            .clipShape(Capsule())
    }
}

struct RxList: View {
    let key: String
    let week: Int
    let opts: Opts

    var body: some View {
        let ids = Plan.exercises(key: key, week: week, opts: opts)
        VStack(spacing: 0) {
            ForEach(ids, id: \.self) { id in
                if let x = Catalog.ex[id], let r = Plan.anyRx(id, week: week, opts: opts) {
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

struct DayChips: View {
    @EnvironmentObject var store: Store
    private let order: [Int] = [2, 3, 4, 5, 6, 7, 1]
    private let names: [String] = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                ForEach(0..<7, id: \.self) { i in
                    chip(i)
                }
            }
            Text("\(store.data.days.count) Einheit\(store.data.days.count == 1 ? "" : "en") pro Woche. Wähle 1 bis 5 Tage.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    func chip(_ i: Int) -> some View {
        let d = order[i]
        let on = store.data.days.contains(d)
        return Text(names[i])
            .font(.subheadline.weight(.semibold))
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .background(on ? Theme.accent : Theme.field)
            .foregroundStyle(on ? Color.white : Color.primary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .onTapGesture { toggle(d) }
            .accessibilityAddTraits(.isButton)
    }

    func toggle(_ d: Int) {
        if let idx = store.data.days.firstIndex(of: d) {
            if store.data.days.count > 1 { store.data.days.remove(at: idx) }
        } else if store.data.days.count < 5 {
            store.data.days.append(d)
        }
    }
}

// MARK: - Tabs

struct ContentView: View {
    @EnvironmentObject var store: Store
    @State private var tab = 0

    var body: some View {
        let d = store.data
        let _ = Theme.apply(accentHex: d.accentHex, bgStyle: d.bgStyle, radius: d.radius)
        let themeKey = "\(d.accentHex)-\(d.bgStyle)-\(d.radius)-\(d.fontDesign)"
        TabView(selection: $tab) {
            HomeView().tabItem { Label("Heute", systemImage: "house.fill") }.tag(0)
            PlanView().tabItem { Label("Plan", systemImage: "calendar") }.tag(1)
            ProgressTab().tabItem { Label("Fortschritt", systemImage: "chart.line.uptrend.xyaxis") }.tag(2)
            ExercisesView().tabItem { Label("Übungen", systemImage: "dumbbell.fill") }.tag(3)
            SettingsView().tabItem { Label("Profil", systemImage: "person.crop.circle") }.tag(4)
        }
        .id(themeKey)
        .tint(Theme.accent)
        .fontDesign(design)
        .dynamicTypeSize(typeSize)
        .preferredColorScheme(scheme)
        .fullScreenCover(isPresented: Binding(get: { !store.data.onboarded }, set: { _ in })) {
            OnboardingView()
                .environmentObject(store)
                .tint(Theme.accent)
                .preferredColorScheme(scheme)
        }
        .sheet(item: $store.summary) { s in
            SummarySheet(s: s)
                .presentationDetents([.medium, .large])
        }
    }

    var scheme: ColorScheme { store.data.bgStyle == 3 ? .dark : .light }

    var design: Font.Design {
        switch store.data.fontDesign {
        case 1: return .rounded
        case 2: return .serif
        case 3: return .monospaced
        default: return .default
        }
    }

    var typeSize: DynamicTypeSize {
        let all: [DynamicTypeSize] = [.xSmall, .small, .medium, .large, .xLarge, .xxLarge, .xxxLarge]
        return all[min(max(store.data.textSize, 0), all.count - 1)]
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
    @State private var showJump = false

    var body: some View {
        let s = store.data.summary()
        let title: String = s.done >= s.planned ? "Woche geschafft" : (s.todayIsTraining ? "Heute ist Sprungtag" : "Nächste Einheit")
        let deload: String = Plan.isDeload(s.week) ? " · Entlastung" : ""
        let hello: String = (s.name.isEmpty ? "" : "Hi \(s.name) · ") + (store.data.gym.isEmpty ? "" : "\(store.data.gym) · ")
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(hello)Woche \(s.week) von 12 · \(Plan.phases[Plan.phase(s.week)].name)\(deload)")
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
                SingleCard()
                GoalCard(s: s, showJump: $showJump)
            }
            .padding()
        }
        .background(Theme.bg)
        .navigationBarHidden(true)
        .sheet(isPresented: $showJump) {
            QuickJumpSheet()
                .presentationDetents([.medium])
        }
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
                    if s.streak > 0 {
                        Label("\(s.streak) Woche\(s.streak == 1 ? "" : "n") in Serie", systemImage: "flame.fill")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Theme.accent)
                    }
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
        let o = store.data.opts
        let mins = Plan.estMinutes(key: s.nextKey, week: s.week, opts: o)
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(s.done >= s.planned ? "Zusätzlich möglich" : "Als Nächstes")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.accent)
                    Text(name).font(.title2.bold())
                }
                Spacer()
                Menu {
                    ForEach([30, 45, 60, 75, 90, 120, 150, 180], id: \.self) { m in
                        Button("\(m) Min.") { store.data.sessionMin = m }
                    }
                } label: {
                    Label("\(store.data.sessionMin) Min.", systemImage: "clock")
                        .font(.footnote.weight(.semibold))
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Theme.field).clipShape(Capsule())
                }
            }
            RxList(key: s.nextKey, week: s.week, opts: o)
            PrimaryButton(title: "Training starten") { store.start(s.nextKey) }
        }
        .card()
    }
}

struct GoalCard: View {
    let s: Summary
    @Binding var showJump: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
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
                if s.goal > 0 {
                    let frac: Double = min(1.0, max(0.0, best / s.goal))
                    VStack(alignment: .leading, spacing: 4) {
                        ProgressView(value: frac).tint(Theme.accent)
                        Text(best >= s.goal ? "Ziel von \(Store.fmt(s.goal)) cm erreicht" : "Noch \(Store.fmt(s.goal - best)) cm bis zu deinen \(Store.fmt(s.goal)) cm")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                Text("Starthöhe messen").font(.title3.bold())
                Text("Trage deinen ersten Sprungtest ein, damit du deinen Fortschritt siehst.")
                    .foregroundStyle(.secondary)
            }
            SecondaryButton(title: "Sprung eintragen") { showJump = true }
        }
        .card()
    }
}

struct QuickJumpSheet: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss
    @State private var date = Date()
    @State private var cmText = ""
    @State private var error: String? = nil

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Datum", selection: $date, displayedComponents: .date)
                TextField("Sprunghöhe in cm", text: $cmText).keyboardType(.decimalPad)
                if let e = error { Text(e).foregroundStyle(.red).font(.footnote) }
            }
            .navigationTitle("Sprung eintragen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Abbrechen") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Speichern") { save() } }
            }
        }
    }

    func save() {
        let cm = Store.num(cmText)
        if cm < 10 || cm > 150 {
            error = "Gib eine Höhe zwischen 10 und 150 cm ein."
            return
        }
        store.addJump(date: date, cm: cm)
        dismiss()
    }
}


// MARK: - Einzeltraining

struct SingleCard: View {
    @State private var show = false
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Einzeltraining", systemImage: "bolt.fill").font(.headline)
            Text("Nur für heute: wähle Schwerpunkt und Dauer, die App baut dir eine komplette Einheit.")
                .font(.subheadline).foregroundStyle(.secondary)
            SecondaryButton(title: "Einheit zusammenstellen") { show = true }
        }
        .card()
        .sheet(isPresented: $show) { SingleSessionSheet().presentationDetents([.large]) }
    }
}

struct SingleSessionSheet: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss
    @State private var focus = "full"
    @State private var minutes = 90

    func optsFor(_ m: Int) -> Opts {
        var o = store.data.opts
        o.minutes = m
        return o
    }

    var body: some View {
        let s = store.data.summary()
        let o = optsFor(minutes)
        let ids = Plan.custom(focus: focus, minutes: minutes, week: s.week, opts: o)
        let est = Plan.estMinutes(ids: ids, week: s.week, opts: o)
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Schwerpunkt").font(.headline)
                    ForEach(Plan.focuses, id: \.id) { f in
                        Button { focus = f.id } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(f.name).font(.subheadline.weight(.semibold))
                                    Text(f.detail).font(.footnote).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: focus == f.id ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(focus == f.id ? Theme.accent : Color.secondary)
                            }
                            .foregroundStyle(.primary)
                            .padding(12)
                            .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.radius))
                        }
                    }
                    Text("Dauer: \(minutes) Min.").font(.headline)
                    Slider(value: Binding(get: { Double(minutes) }, set: { minutes = Int(($0 / 15).rounded()) * 15 }), in: 30...180, step: 15)
                    Text("\(ids.count) Übungen · ca. \(est) Min.").font(.footnote).foregroundStyle(.secondary)
                    VStack(spacing: 0) {
                        ForEach(ids, id: \.self) { id in
                            if let x = Catalog.ex[id], let r = Plan.anyRx(id, week: s.week, opts: o) {
                                HStack {
                                    Text(x.name)
                                    Spacer()
                                    Text("\(r.sets) × \(r.reps)").fontWeight(.semibold).monospacedDigit()
                                }
                                .padding(.vertical, 8)
                                Divider()
                            }
                        }
                    }
                    PrimaryButton(title: "Los geht's") {
                        dismiss()
                        store.startCustom(focus: focus, minutes: minutes)
                    }
                }
                .padding()
            }
            .background(Theme.bg.ignoresSafeArea())
            .navigationTitle("Einzeltraining")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Schließen") { dismiss() } } }
        }
    }
}
