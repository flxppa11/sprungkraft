import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var store: Store
    @State private var currentText = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Willkommen")
                            .font(.largeTitle.bold())
                        Text("Dein 12-Wochen-Plan für maximale Sprungkraft im Volleyball. Ein paar Angaben, dann geht es los. Alles lässt sich später ändern.")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                Section("Über dich") {
                    TextField("Name (optional)", text: $store.data.name)
                    Picker("Level", selection: $store.data.level) {
                        Text("Einsteiger").tag(0)
                        Text("Fortgeschritten").tag(1)
                    }
                    .pickerStyle(.segmented)
                    Stepper(value: $store.data.bodyKg, in: 30...200, step: 1) {
                        Text("Körpergewicht: \(Int(store.data.bodyKg)) kg")
                    }
                }

                Section {
                    TextField("Aktuelle Sprunghöhe in cm (optional)", text: $currentText)
                        .keyboardType(.decimalPad)
                    Stepper(value: $store.data.goalCm, in: 0...120, step: 1) {
                        Text(store.data.goalCm > 0 ? "Ziel-Sprunghöhe: \(Int(store.data.goalCm)) cm" : "Ziel-Sprunghöhe: nicht gesetzt")
                    }
                } header: {
                    Text("Sprungkraft")
                } footer: {
                    Text("Eine Messung am Anfang zeigt dir später genau, wie viel höher du springst.")
                }

                Section {
                    DayChips()
                    Stepper(value: $store.data.sessionMin, in: 20...180, step: 5) {
                        Text("Dauer pro Einheit: \(store.data.sessionMin) Min.")
                    }
                    TextField("Gym (optional)", text: $store.data.gym)
                } header: {
                    Text("Trainingstage")
                } footer: {
                    Text("Weniger Tage heißt kürzere Pläne, die auf das Wichtigste setzen.")
                }

                Section {
                    Toggle("Sprungbox", isOn: $store.data.hasBox)
                    Toggle("Kettlebell", isOn: $store.data.hasKB)
                    Toggle("Kabelzug", isOn: $store.data.hasCable)
                } header: {
                    Text("Ausstattung im Gym")
                } footer: {
                    Text("Fehlt ein Gerät, tauscht die App die Übung automatisch aus.")
                }

                Section {
                    Button {
                        finish()
                    } label: {
                        Text("Los geht's")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.borderedProminent)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Einrichtung")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    func finish() {
        let cm = Store.num(currentText)
        if cm >= 10 && cm <= 150 {
            store.addJump(date: Date(), cm: cm)
        }
        store.data.start = Date()
        store.data.onboarded = true
    }
}
