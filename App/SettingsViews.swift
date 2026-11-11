import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: Store
    @State private var confirmRestart = false
    @State private var confirmWipe = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Profil") {
                    TextField("Name (optional)", text: $store.data.name)
                    Picker("Level", selection: $store.data.level) {
                        Text("Einsteiger").tag(0)
                        Text("Fortgeschritten").tag(1)
                    }
                    .pickerStyle(.segmented)
                    Stepper(value: $store.data.bodyKg, in: 30...200, step: 1) {
                        Text("Körpergewicht: \(Int(store.data.bodyKg)) kg")
                    }
                    Stepper(value: $store.data.goalCm, in: 0...120, step: 1) {
                        Text(store.data.goalCm > 0 ? "Ziel-Sprunghöhe: \(Int(store.data.goalCm)) cm" : "Ziel-Sprunghöhe: nicht gesetzt")
                    }
                }

                Section {
                    TextField("Gym (z. B. McFit Brünnerstraße)", text: $store.data.gym)
                } header: {
                    Text("Dein Gym")
                }

                Section {
                    DayChips()
                    Stepper(value: $store.data.sessionMin, in: 20...180, step: 5) {
                        Text("Dauer pro Einheit: \(store.data.sessionMin) Min.")
                    }
                    let perWeek = store.data.days.count * store.data.sessionMin
                    LabeledContent("Pro Woche", value: SettingsView.hours(perWeek))
                    LabeledContent("Pro Monat (ca.)", value: SettingsView.hours(perWeek * 4))
                } header: {
                    Text("Trainingszeit planen")
                } footer: {
                    Text("Die App passt jede Einheit an deine Dauer an: Bei 2 bis 3 Stunden kommen mehr Übungen und Sätze dazu, bei wenig Zeit wird gekürzt.")
                }

                Section {
                    Toggle("Kompakt-Modus", isOn: $store.data.compact)
                    Picker("Pausen", selection: $store.data.restMode) {
                        Text("Kurz").tag(0)
                        Text("Normal").tag(1)
                        Text("Lang").tag(2)
                    }
                    .pickerStyle(.segmented)
                    Toggle("Aufwärmen anzeigen", isOn: $store.data.showWarmup)
                    Toggle("Vibration", isOn: $store.data.haptics)
                } header: {
                    Text("Training")
                } footer: {
                    Text("Kompakt lässt Zubehörübungen weg und kürzt die Pausen. Einsteiger machen bei schweren Übungen einen Satz weniger.")
                }

                Section {
                    Toggle("Sprungbox", isOn: $store.data.hasBox)
                    Toggle("Kettlebell", isOn: $store.data.hasKB)
                    Toggle("Kabelzug", isOn: $store.data.hasCable)
                } header: {
                    Text("Ausstattung im Gym")
                } footer: {
                    Text("Fehlt ein Gerät, ersetzt die App die Übung automatisch durch eine passende Alternative.")
                }

                Section {
                    LabeledContent("Akzentfarbe") {
                        HStack(spacing: 8) {
                            ForEach(SettingsView.presets, id: \.self) { h in
                                Circle().fill(Color(hex: h)).frame(width: 26, height: 26)
                                    .overlay(Circle().stroke(Color.primary.opacity(store.data.accentHex == h ? 0.8 : 0), lineWidth: 2).padding(-3))
                                    .onTapGesture { store.data.accentHex = h }
                            }
                        }
                    }
                    ColorPicker("Eigene Farbe", selection: Binding(
                        get: { Color(hex: store.data.accentHex) },
                        set: { store.data.accentHex = SettingsView.hex($0) }), supportsOpacity: false)
                    Picker("Hintergrund", selection: $store.data.bgStyle) {
                        Text("Weiß").tag(0)
                        Text("Grau").tag(1)
                        Text("Blau").tag(2)
                        Text("Dunkel").tag(3)
                    }
                    .pickerStyle(.segmented)
                    Picker("Schrift", selection: $store.data.fontDesign) {
                        Text("Standard").tag(0)
                        Text("Rund").tag(1)
                        Text("Serif").tag(2)
                        Text("Mono").tag(3)
                    }
                    Stepper(value: $store.data.radius, in: 0...28, step: 4) {
                        Text("Ecken: \(store.data.radius)")
                    }
                    Stepper(value: $store.data.textSize, in: 0...6) {
                        Text("Textgröße: \(store.data.textSize - 2 > 0 ? "+" : "")\(store.data.textSize - 3)")
                    }
                    Button("Design zurücksetzen") {
                        store.data.accentHex = "1E6FF0"; store.data.bgStyle = 0; store.data.radius = 16
                        store.data.fontDesign = 0; store.data.textSize = 3
                    }
                } header: {
                    Text("Design")
                } footer: {
                    Text("Standard ist Weiß mit blauen Akzenten. Alles lässt sich ändern.")
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

                Section("Programm und Daten") {
                    Button("Programm neu starten (Woche 1)") { confirmRestart = true }
                    ShareLink(item: store.exportJSON()) {
                        Label("Sicherung teilen", systemImage: "square.and.arrow.up")
                    }
                    NavigationLink("Sicherung wiederherstellen") { ImportView() }
                    Button("Alle Daten löschen", role: .destructive) { confirmWipe = true }
                }

                Section("Info") {
                    LabeledContent("Version", value: "1.2")
                    Text("Diese App ersetzt keine ärztliche oder trainerische Beratung. Bei Schmerzen oder Beschwerden pausiere das Training und lass dich untersuchen.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Profil")
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

    static let presets = ["1E6FF0", "0A84FF", "00A3A3", "2EAD5B", "F58A07", "E23B3B", "8E44EC", "111111"]

    static func hex(_ c: Color) -> String {
        let u = UIColor(c)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        u.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }

    static func hours(_ min: Int) -> String {
        let h = min / 60, m = min % 60
        return m == 0 ? "\(h) Std." : "\(h) Std. \(m) Min."
    }

    func applyReminder() {
        Reminder.apply(enabled: store.data.remind, days: store.data.days, hour: store.data.remindHour)
    }
}

struct ImportView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss
    @State private var text = ""
    @State private var msg: String? = nil

    var body: some View {
        Form {
            Section {
                TextEditor(text: $text)
                    .font(.system(size: 12, design: .monospaced))
                    .frame(minHeight: 220)
            } header: {
                Text("Sicherung einfügen")
            } footer: {
                Text("Füge hier den Text einer früheren Sicherung ein. Die aktuellen Daten werden ersetzt.")
            }
            if let m = msg {
                Text(m).foregroundStyle(.red)
            }
            Button("Wiederherstellen") {
                if store.importJSON(text) {
                    dismiss()
                } else {
                    msg = "Die Sicherung konnte nicht gelesen werden."
                }
            }
        }
        .navigationTitle("Wiederherstellen")
        .navigationBarTitleDisplayMode(.inline)
    }
}
