import SwiftUI
import UIKit

// MARK: - Training

struct WorkoutView: View {
    @EnvironmentObject var store: Store
    @State private var restEnd: Date? = nil
    @State private var confirmCancel = false
    @State private var alertMsg: String? = nil
    @State private var showWarm = false
    @State private var showFinish = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    header
                    if store.data.showWarmup {
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
                    }
                    ForEach(0..<(store.workout?.ex.count ?? 0), id: \.self) { i in
                        ExerciseCard(i: i, restEnd: $restEnd)
                    }
                    PrimaryButton(title: "Einheit abschließen") { finishTapped() }
                    Button("Abbrechen", role: .destructive) { confirmCancel = true }
                        .frame(maxWidth: .infinity)
                }
                .padding()
                .padding(.bottom, restEnd == nil ? 0 : 80)
            }
            .scrollDismissesKeyboard(.interactively)
            if let end = restEnd {
                RestBar(end: end, haptics: store.data.haptics, restEnd: $restEnd)
            }
        }
        .background(Theme.bg)
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
            Button("Verwerfen", role: .destructive) {
                Reminder.cancelRest()
                store.workout = nil
            }
        }
        .alert("Hinweis", isPresented: Binding(get: { alertMsg != nil }, set: { if !$0 { alertMsg = nil } })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMsg ?? "")
        }
        .sheet(isPresented: $showFinish) {
            FinishSheet { feel, note in
                restEnd = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    store.finishWorkout(feel: feel, note: note)
                }
            }
            .presentationDetents([.medium, .large])
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

    func finishTapped() {
        if store.hasDoneSet() {
            showFinish = true
        } else {
            alertMsg = "Hake mindestens einen Satz ab."
        }
    }
}

struct RestBar: View {
    let end: Date
    let haptics: Bool
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
                Button("−15") { shift(-15) }
                Button("+15") { shift(15) }
                Button("Weiter") { stop() }
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
        .task(id: end) {
            let wait = max(0, end.timeIntervalSinceNow)
            try? await Task.sleep(nanoseconds: UInt64(wait * 1_000_000_000))
            if Task.isCancelled { return }
            if haptics {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        }
    }

    func shift(_ seconds: Double) {
        let newEnd = end.addingTimeInterval(seconds)
        restEnd = newEnd
        let left = Int(newEnd.timeIntervalSinceNow)
        if left > 0 { Reminder.scheduleRest(seconds: left) } else { Reminder.cancelRest() }
    }

    func stop() {
        restEnd = nil
        Reminder.cancelRest()
    }
}

struct ExerciseCard: View {
    @EnvironmentObject var store: Store
    let i: Int
    @Binding var restEnd: Date?
    @State private var showGuide = false

    var body: some View {
        if let w = store.workout, i < w.ex.count,
           let x = Catalog.ex[w.ex[i].id],
           let r = Plan.anyRx(w.ex[i].id, week: w.week, opts: store.data.opts) {
            content(w.ex[i], x, r)
        }
    }

    func content(_ e: ActiveEx, _ x: Exercise, _ r: RxDef) -> some View {
        let note: String = r.note.isEmpty ? "" : " · " + r.note
        let alts = store.alternatives(for: i)
        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(x.name).font(.title3.bold())
                    Text("\(r.sets) × \(r.reps) · Pause \(r.rest) Sek.\(note)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    if let h = store.hint(for: e.id, rx: r) {
                        Text(h).font(.footnote).foregroundStyle(Theme.accent)
                    }
                }
                Spacer()
                Menu {
                    Button { store.addSet(i) } label: { Label("Satz hinzufügen", systemImage: "plus") }
                    Button { store.removeSet(i) } label: { Label("Letzten Satz entfernen", systemImage: "minus") }
                    Button { showGuide = true } label: { Label("Was ist das?", systemImage: "questionmark.circle") }
                    if !alts.isEmpty {
                        Menu {
                            ForEach(alts, id: \.self) { id in
                                Button(Catalog.ex[id]?.name ?? id) { store.swapExercise(i, to: id) }
                            }
                        } label: {
                            Label("Übung tauschen", systemImage: "arrow.triangle.2.circlepath")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title2)
                        .padding(4)
                }
            }
            Button { showGuide = true } label: {
                Label("Was ist das?", systemImage: "play.circle.fill")
                    .font(.subheadline.weight(.semibold))
            }
            .buttonStyle(.plain)
            .foregroundStyle(Theme.accent)
            ForEach(0..<e.sets.count, id: \.self) { j in
                setRow(j, x, r, e.sets[j])
            }
            TextField("Notiz (optional)", text: Binding(
                get: { store.workout?.ex[i].note ?? "" },
                set: { store.workout?.ex[i].note = $0 }
            ))
            .font(.subheadline)
            .padding(10)
            .background(Theme.bg)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .card()
        .sheet(isPresented: $showGuide) { GuideSheet(exercise: x) }
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
            .background(Theme.bg)
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
            Reminder.scheduleRest(seconds: rest)
            if store.data.haptics {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        } else {
            restEnd = nil
            Reminder.cancelRest()
        }
    }
}

// MARK: - Abschluss

struct FinishSheet: View {
    @Environment(\.dismiss) var dismiss
    let onSave: (Int?, String?) -> Void
    @State private var feel: Int = 3
    @State private var note: String = ""

    private let labels: [String] = ["Sehr leicht", "Leicht", "Genau richtig", "Hart", "Sehr hart"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Wie fühlte sich die Einheit an?") {
                    Picker("Gefühl", selection: $feel) {
                        ForEach(1..<6, id: \.self) { n in
                            Text("\(n)").tag(n)
                        }
                    }
                    .pickerStyle(.segmented)
                    Text(labels[feel - 1])
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Section("Notiz zur Einheit") {
                    TextField("Optional", text: $note, axis: .vertical)
                        .lineLimit(2...5)
                }
            }
            .navigationTitle("Einheit abschließen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Zurück") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        let f = feel
                        let n = note
                        dismiss()
                        onSave(f, n)
                    }
                }
            }
        }
    }
}

struct SummarySheet: View {
    @Environment(\.dismiss) var dismiss
    let s: FinishSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Geschafft").font(.largeTitle.bold())
            HStack(spacing: 12) {
                stat("\(s.minutes)", "Minuten")
                stat("\(s.sets)", "Sätze")
                stat(Store.fmt((s.volume / 1000 * 10).rounded() / 10), "Tonnen bewegt")
            }
            if s.prs.isEmpty {
                Text("Weiter so. Neue Bestwerte kommen, wenn du die Gewichte langsam steigerst.")
                    .foregroundStyle(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Label("Neue Bestwerte", systemImage: "trophy.fill")
                        .font(.headline)
                        .foregroundStyle(Theme.accent)
                    ForEach(s.prs, id: \.self) { p in
                        Text(p)
                    }
                }
            }
            Spacer()
            PrimaryButton(title: "Fertig") { dismiss() }
        }
        .padding(20)
    }

    func stat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.system(size: 30, weight: .bold, design: .rounded))
            Text(label).font(.footnote).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
