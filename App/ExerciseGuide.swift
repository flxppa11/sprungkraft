import SwiftUI

// Automatisch erzeugt: Erklärungen + animierte Strichfiguren (Seitenansicht)

struct Pose {
    var torso = 0.0, thigh = 0.0, shin = 0.0, ua = 0.0, fa = 0.0
    var dx = 0.0, lift = 0.0
    var hipY: Double? = nil
    var legB: [Double]? = nil
    var bar: Double? = nil
}

enum FigScene { case none, boxAhead, boxHere, benchBehind, benchUnder, pullbar, barBack, barHands, dbHands }

struct FigureSpec {
    let scene: FigScene
    let frames: [Pose]
    let labels: [String]
}

struct GuideText {
    let what: String
    let steps: [String]
    let mistakes: [String]
    let muscles: String
}

enum ExerciseGuide {
    static func text(_ id: String) -> GuideText? { texts[id] }
    static func figure(_ id: String) -> FigureSpec? { figures[id] }

    static let texts: [String: GuideText] = [
        "cmj": GuideText(what: "Der Standardtest und das Basistraining für Sprunghöhe: aus dem Stand mit Armschwung so hoch wie möglich springen.", steps: ["Hüftbreit stehen, Arme locker.", "Schnell in die Knie gehen und die Arme nach hinten schwingen.", "Ohne Pause explosiv strecken, Arme kräftig nach oben.", "Weich auf dem Vorfuß landen und tief abfedern."], mistakes: ["Zu lange Pause unten", "Knie fallen nach innen", "Steif landen"], muscles: "Quadrizeps, Gesäß, Waden"),
        "pogo": GuideText(what: "Kurze, reaktive Sprünge nur aus den Sprunggelenken. Trainiert die Sehnensteifigkeit.", steps: ["Aufrecht stehen, Knie fast gestreckt.", "Nur über die Fußgelenke hüpfen.", "Kontakt mit dem Boden so kurz wie möglich.", "Blick geradeaus, Oberkörper ruhig."], mistakes: ["Knie stark beugen", "Zu lange Bodenkontaktzeit", "Auf der Ferse landen"], muscles: "Waden, Achillessehne"),
        "tuck": GuideText(what: "Sprung, bei dem du die Knie in der Luft zur Brust ziehst. Fördert Explosivität und Hüftbeugung.", steps: ["Leicht eintauchen.", "Maximal hochspringen.", "Knie in der Luft zur Brust ziehen.", "Beine vor der Landung wieder strecken, weich landen."], mistakes: ["Zu früh anziehen", "Hart landen", "Oberkörper kippt vor"], muscles: "Hüftbeuger, Quadrizeps, Waden"),
        "box": GuideText(what: "Explosiver Sprung auf eine Box. Du trainierst Kraft nach oben, ohne harte Landung.", steps: ["Eine Armlänge vor der Box stehen.", "Eintauchen und Arme schwingen.", "Mit beiden Beinen auf die Box springen.", "Aufrecht landen, dann kontrolliert absteigen (nicht runterspringen)."], mistakes: ["Box zu hoch gewählt", "Landung mit durchgestreckten Beinen", "Runterspringen statt Absteigen"], muscles: "Gesäß, Quadrizeps, Waden"),
        "drop": GuideText(what: "Du steigst von einer Box, landest und springst sofort wieder hoch. Trainiert die Reaktivkraft.", steps: ["Auf die Box stellen, ein Fuß tritt ab (nicht springen).", "Beidbeinig landen, Knie leicht beugen.", "Sofort ohne Pause maximal hochspringen.", "Weich landen und die Box wieder erklimmen."], mistakes: ["Zu hohe Box", "Zu lange Bodenzeit", "Knie knicken nach innen"], muscles: "Beine, Gesäß, Waden"),
        "appr": GuideText(what: "Sprung mit 2–3 Schritten Anlauf, wie beim Angriff im Volleyball.", steps: ["2–3 Schritte mit steigender Geschwindigkeit.", "Letzten Schritt lang, Fersen zuerst aufsetzen.", "Beide Füße zusammen, Arme nach hinten.", "Beidarmig hochschwingen und voll strecken."], mistakes: ["Zu langsamer Anlauf", "Absprung zu nah am Netz", "Arme nicht eingesetzt"], muscles: "Gesamtes Bein, Rumpf"),
        "lateral": GuideText(what: "Seitliche Sprünge von Bein zu Bein. Verbessert Stabilität und seitliche Kraft.", steps: ["Auf einem Bein stehen.", "Seitlich zum anderen Bein abspringen.", "Stabil landen und kurz halten.", "Danach zurück springen."], mistakes: ["Wackelige Landung", "Knie fällt nach innen"], muscles: "Gesäß, Hüftabduktoren"),
        "jsq": GuideText(what: "Kniebeuge mit leichter Last, die du explosiv nach oben aus dem Boden springst.", steps: ["Stange locker auf dem Rücken oder Kurzhanteln halten.", "Bis ca. 90° beugen.", "Explosiv abspringen.", "Weich landen, sofort wieder vorbereiten."], mistakes: ["Zu viel Gewicht", "Hohlkreuz", "Harte Landung"], muscles: "Quadrizeps, Gesäß, Waden"),
        "broad": GuideText(what: "Weitsprung aus dem Stand. Trainiert horizontale Kraft und Hüftstreckung.", steps: ["Hüftbreit, Arme nach hinten schwingen.", "Mit Schwung nach vorn abspringen.", "In der Luft die Knie anziehen.", "Beidbeinig und stabil landen."], mistakes: ["Landen mit gestreckten Beinen", "Kein Armschwung"], muscles: "Gesäß, Hamstrings, Quadrizeps"),
        "sq": GuideText(what: "Die Basis für Beinkraft: Kniebeuge mit Langhantel. Mehr Kraft heißt später mehr Sprunghöhe.", steps: ["Stange auf dem oberen Rücken, Griff fest.", "Fußspitzen leicht nach außen.", "Hüfte nach hinten, Knie folgen den Zehen.", "Mindestens bis Oberschenkel parallel, dann kräftig hoch."], mistakes: ["Knie fallen nach innen", "Rücken wird rund", "Fersen heben ab"], muscles: "Quadrizeps, Gesäß, unterer Rücken"),
        "split": GuideText(what: "Bulgarische Kniebeuge: Einbeinige Kniebeuge mit dem hinteren Fuß auf einer Bank.", steps: ["Hinterer Fuß auf der Bank, Abstand ca. ein großer Schritt.", "Oberkörper leicht nach vorn, Blick nach vorn.", "Gerade runter, Knie über dem Fuß.", "Über die vordere Ferse hochdrücken."], mistakes: ["Schritt zu kurz", "Knie knickt nach innen", "Gewicht auf dem hinteren Bein"], muscles: "Quadrizeps, Gesäß"),
        "legpress": GuideText(what: "Beinpresse an der Maschine. Du trainierst die Beinkraft, ohne den Rücken zu belasten.", steps: ["Rücken fest an die Lehne, Füße schulterbreit auf die Platte.", "Gewicht kontrolliert absenken, Knie ca. 90°.", "Mit den Fersen kraftvoll wegdrücken.", "Knie oben nicht durchdrücken (nicht komplett strecken)."], mistakes: ["Gesäß hebt ab", "Knie zu weit nach innen", "Zu viel Gewicht, zu wenig Tiefe"], muscles: "Quadrizeps, Gesäß"),
        "lunge": GuideText(what: "Ausfallschritt: Einbeinige Kraft und Stabilität. Gut als Ergänzung zur Kniebeuge.", steps: ["Aufrecht stehen, großer Schritt nach vorn.", "Hinteres Knie senkt sich Richtung Boden.", "Vorderes Knie bleibt über dem Fuß.", "Mit dem vorderen Bein zurück in den Stand drücken."], mistakes: ["Zu kurzer Schritt", "Oberkörper kippt", "Knie berührt hart den Boden"], muscles: "Quadrizeps, Gesäß"),
        "stepup": GuideText(what: "Aufsteigen auf eine Bank oder Box mit einem Bein. Stärkt die Beinkraft, wie im Sprung.", steps: ["Ein Fuß vollständig auf der Box.", "Nur mit dem vorderen Bein hochdrücken.", "Oben aufrecht stehen, Knie strecken.", "Kontrolliert wieder absenken."], mistakes: ["Hinteres Bein hilft mit", "Box zu hoch"], muscles: "Quadrizeps, Gesäß"),
        "legext": GuideText(what: "Beinstrecker an der Maschine. Isoliert den vorderen Oberschenkel, gut für die Kniestabilität.", steps: ["Rolle knapp oberhalb der Füße einstellen.", "Beine kontrolliert strecken.", "Oben kurz halten.", "Langsam wieder absenken."], mistakes: ["Schwung statt Kontrolle", "Zu viel Gewicht"], muscles: "Quadrizeps"),
        "rdl": GuideText(what: "Rumänisches Kreuzheben: Hüftbeuger-Übung für Hamstrings und Gesäß mit fast gestreckten Beinen.", steps: ["Stange vor den Oberschenkeln, Knie leicht gebeugt.", "Hüfte weit nach hinten schieben.", "Rücken gerade, Stange nah am Bein bis unter die Knie.", "Hüfte nach vorn schieben und aufrichten."], mistakes: ["Rücken wird rund", "Stange weit vom Körper weg", "Kniebeuge statt Hüftbeuge"], muscles: "Hamstrings, Gesäß, unterer Rücken"),
        "dl": GuideText(what: "Kreuzheben: die Ganzkörper-Kraftübung. Starke Hüfte und Beine bringen mehr Sprungkraft.", steps: ["Stange über den Fußmitten, hüftbreit stehen.", "Rücken gerade, Brust raus, Griff schulterbreit.", "Mit den Beinen den Boden wegdrücken.", "Oben Hüfte komplett strecken, nicht überstrecken."], mistakes: ["Rücken rund", "Stange vom Körper weg", "Ruckartig anreißen"], muscles: "Gesäß, Hamstrings, Rücken, Beine"),
        "hip": GuideText(what: "Hip Thrust: Gesäßübung mit der Schulter auf einer Bank. Stärkt die Hüftstreckung für den Absprung.", steps: ["Oberer Rücken auf die Bank, Füße hüftbreit.", "Stange auf der Hüfte, mit Polster.", "Hüfte nach oben drücken, bis Rumpf gerade ist.", "Oben das Gesäß kurz anspannen, dann absenken."], mistakes: ["Hohlkreuz oben", "Füße zu weit weg", "Kinn rutscht nach oben"], muscles: "Gesäß, Hamstrings"),
        "nord": GuideText(what: "Nordic Curl: Du lässt dich langsam nach vorn sinken. Beste Hamstring-Übung und Verletzungsschutz.", steps: ["Auf den Knien, Füße fixieren (Partner oder Gerät).", "Körper gerade lassen.", "Langsam nach vorn sinken lassen, so weit wie du kontrollieren kannst.", "Mit Händen abfangen und hochdrücken."], mistakes: ["Hüfte knickt ab", "Zu schnell fallen"], muscles: "Hamstrings"),
        "legcurl": GuideText(what: "Beinbeuger an der Maschine, für die hintere Oberschenkelmuskulatur.", steps: ["Rolle knapp oberhalb der Fersen.", "Fersen zum Gesäß ziehen.", "Oben kurz halten.", "Langsam wieder strecken."], mistakes: ["Hüfte hebt ab", "Zu schnell zurück"], muscles: "Hamstrings"),
        "swing": GuideText(what: "Kettlebell Swing: Explosive Hüftstreckung. Trainiert genau die Bewegung, die im Sprung zählt.", steps: ["Kettlebell vor den Füßen, Hüfte weit zurück.", "Mit der Hüfte aufrichten, die Arme sind nur Haken.", "Kettlebell schwingt bis Brusthöhe.", "Hüfte zurück, Kettlebell durch die Beine."], mistakes: ["Mit den Armen hochziehen", "Rücken wird rund", "Kniebeuge statt Hüftbewegung"], muscles: "Gesäß, Hamstrings, Rücken"),
        "bridge": GuideText(what: "Gesäßbrücke am Boden. Einfach und gut für die Hüftstreckung.", steps: ["Auf dem Rücken, Füße aufgestellt.", "Hüfte hochdrücken, bis Rumpf eine Linie ist.", "Oben das Gesäß anspannen.", "Langsam absenken."], mistakes: ["Hohlkreuz", "Füße zu weit weg"], muscles: "Gesäß, Hamstrings"),
        "calf": GuideText(what: "Wadenheben im Stehen. Starke Waden sind direkt beteiligt am Absprung.", steps: ["Auf eine Stufe oder Platte, Fersen hängen frei.", "Langsam so hoch wie möglich auf die Zehen.", "Oben kurz halten.", "Langsam bis unter Stufenhöhe absenken."], mistakes: ["Zu wenig Bewegungsweite", "Mit Schwung"], muscles: "Waden"),
        "calfsit": GuideText(what: "Wadenheben im Sitzen an der Maschine. Trainiert den tiefen Wadenmuskel.", steps: ["Polster auf die Knie, Fußballen auf die Platte.", "Fersen langsam absenken, dann kraftvoll hoch.", "Oben kurz halten.", "Voller Bewegungsradius."], mistakes: ["Zu schnell", "Nur halbe Bewegung"], muscles: "Tiefer Wadenmuskel"),
        "pall": GuideText(what: "Pallof Press: Du drückst das Kabel gegen eine Drehung und stabilisierst den Rumpf.", steps: ["Seitlich zur Kabelstation stehen.", "Griff vor die Brust halten.", "Arme gerade nach vorn strecken, nicht drehen lassen.", "Kurz halten, zurück zur Brust."], mistakes: ["Oberkörper dreht mit", "Zu viel Gewicht"], muscles: "Rumpf, schräge Bauchmuskeln"),
        "dead": GuideText(what: "Dead Bug: Rumpfübung am Boden. Lernst, den Rumpf ruhig zu halten, während Arme und Beine sich bewegen.", steps: ["Auf dem Rücken, Arme hoch, Knie 90°.", "Unterer Rücken bleibt am Boden.", "Gegenüberliegenden Arm und Bein strecken.", "Zurück, Seite wechseln."], mistakes: ["Hohlkreuz", "Zu schnell"], muscles: "Tiefe Bauchmuskeln"),
        "hangleg": GuideText(what: "Beinheben im Hang. Starke Bauchmuskeln helfen, die Kraft vom Bein in den Sprung zu übertragen.", steps: ["An der Stange hängen, Schultern aktiv.", "Beine gestreckt oder leicht gebeugt anheben.", "Auf Hüfthöhe oder höher.", "Kontrolliert absenken, nicht schwingen."], mistakes: ["Schwung holen", "Schultern hängen schlaff"], muscles: "Bauch, Hüftbeuger"),
        "row": GuideText(what: "Rudern mit der Langhantel. Stärkt den Rücken für eine gute Haltung und stabile Schultern.", steps: ["Oberkörper nach vorn gebeugt, Rücken gerade.", "Stange zum Bauchnabel ziehen.", "Schulterblätter zusammenziehen.", "Kontrolliert wieder strecken."], mistakes: ["Oberkörper schwingt", "Rücken wird rund"], muscles: "Rücken, hintere Schulter"),
        "pull": GuideText(what: "Klimmzug: Stärkt Rücken und Arme, wichtig für den Armschwung und die Schulter.", steps: ["Griff etwas weiter als schulterbreit.", "Schulterblätter nach unten ziehen.", "Kinn über die Stange ziehen.", "Langsam komplett hängen lassen."], mistakes: ["Mit Schwung", "Halbe Wiederholung"], muscles: "Latissimus, Bizeps"),
        "bench": GuideText(what: "Bankdrücken: Oberkörper-Kraft für Schulter und Brust. Wichtig für einen kräftigen Angriffsschlag.", steps: ["Liegen, Füße fest am Boden.", "Stange mit schulterbreitem Griff abnehmen.", "Zur Brust absenken.", "Kraftvoll nach oben drücken."], mistakes: ["Gesäß hebt ab", "Ellbogen zu weit außen"], muscles: "Brust, Schulter, Trizeps"),
        "ohp": GuideText(what: "Schulterdrücken: Stärkt Schultern und Rumpf, wichtig fürs Überkopfspiel.", steps: ["Stange auf Schulterhöhe, Ellbogen vor der Stange.", "Rumpf fest, Gesäß anspannen.", "Stange gerade nach oben drücken.", "Oben Arme strecken, Kopf leicht nach vorn."], mistakes: ["Hohlkreuz", "Stange schwingt nach vorn"], muscles: "Schulter, Trizeps"),
        "lat": GuideText(what: "Latzug an der Maschine. Alternative zum Klimmzug, trainiert den breiten Rückenmuskel.", steps: ["Griff etwas weiter als schulterbreit.", "Leicht zurücklehnen, Brust raus.", "Zur oberen Brust ziehen.", "Kontrolliert nach oben lassen."], mistakes: ["Mit Schwung", "Hinter den Nacken ziehen"], muscles: "Latissimus, Bizeps"),
        "face": GuideText(what: "Face Pull am Kabel. Schützt die Schulter und stärkt die hintere Schulterpartie.", steps: ["Seil auf Augenhöhe.", "Zum Gesicht ziehen, Ellbogen hoch.", "Hände auseinander, Außenrotation.", "Kontrolliert zurück."], mistakes: ["Zu viel Gewicht", "Oberkörper lehnt sich zurück"], muscles: "Hintere Schulter, Rotatoren"),
    ]

    static let figures: [String: FigureSpec] = [
        "cmj": FigureSpec(scene: .none, frames: [Pose(torso: 0.0, thigh: 0.0, shin: 0.0, ua: 8.0, fa: 5.0), Pose(torso: 35.0, thigh: 60.0, shin: -25.0, ua: -50.0, fa: -40.0), Pose(torso: 0.0, thigh: 0.0, shin: 0.0, ua: 172.0, fa: 172.0, lift: 0.55)], labels: ["Stehen", "Eintauchen", "Absprung"]),
        "pogo": FigureSpec(scene: .none, frames: [Pose(torso: 0.0, thigh: 0.0, shin: 0.0, ua: 35.0, fa: 85.0), Pose(torso: 0.0, thigh: 0.0, shin: 0.0, ua: 35.0, fa: 85.0, lift: 0.2)], labels: ["Kontakt", "Abfedern"]),
        "tuck": FigureSpec(scene: .none, frames: [Pose(torso: 0.0, thigh: 0.0, shin: 0.0, ua: 8.0, fa: 5.0), Pose(torso: 5.0, thigh: 112.0, shin: -8.0, ua: 60.0, fa: 95.0, lift: 0.75)], labels: ["Stehen", "Knie zur Brust"]),
        "box": FigureSpec(scene: .boxAhead, frames: [Pose(torso: 35.0, thigh: 60.0, shin: -25.0, ua: -50.0, fa: -40.0), Pose(torso: 15.0, thigh: 60.0, shin: -45.0, ua: 140.0, fa: 150.0, dx: 0.5, lift: 0.9), Pose(torso: 20.0, thigh: 50.0, shin: -20.0, ua: 40.0, fa: 70.0, dx: 0.95, lift: 0.45)], labels: ["Eintauchen", "Sprung", "Weich landen"]),
        "drop": FigureSpec(scene: .boxHere, frames: [Pose(torso: 0.0, thigh: 0.0, shin: 0.0, ua: 8.0, fa: 5.0, lift: 0.45), Pose(torso: 30.0, thigh: 70.0, shin: -35.0, ua: -30.0, fa: -20.0, dx: 0.7), Pose(torso: 0.0, thigh: 0.0, shin: 0.0, ua: 172.0, fa: 172.0, dx: 0.7, lift: 0.6)], labels: ["Auf der Box", "Landung", "Sofort hoch"]),
        "appr": FigureSpec(scene: .none, frames: [Pose(torso: 25.0, thigh: 35.0, shin: -15.0, ua: -60.0, fa: -40.0), Pose(torso: 35.0, thigh: 60.0, shin: -25.0, ua: -50.0, fa: -40.0), Pose(torso: -5.0, thigh: 25.0, shin: -30.0, ua: 172.0, fa: 172.0, lift: 0.6)], labels: ["Anlauf", "Absprung vorbereiten", "Strecken"]),
        "lateral": FigureSpec(scene: .none, frames: [Pose(torso: 20.0, thigh: 40.0, shin: -20.0, ua: -40.0, fa: -30.0), Pose(torso: 10.0, thigh: 10.0, shin: -20.0, ua: 40.0, fa: 60.0, dx: 0.7, lift: 0.3), Pose(torso: 20.0, thigh: 45.0, shin: -25.0, ua: 40.0, fa: 60.0, dx: 0.7)], labels: ["Abdruck", "Flug", "Stabil landen"]),
        "jsq": FigureSpec(scene: .barBack, frames: [Pose(torso: 0.0, thigh: 0.0, shin: 0.0, ua: 30.0, fa: -151.0), Pose(torso: 30.0, thigh: 60.0, shin: -28.0, ua: 30.0, fa: -151.0), Pose(torso: 0.0, thigh: 0.0, shin: 0.0, ua: 30.0, fa: -151.0, lift: 0.5)], labels: ["Stehen", "Eintauchen", "Absprung"]),
        "broad": FigureSpec(scene: .none, frames: [Pose(torso: 0.0, thigh: 0.0, shin: 0.0, ua: 8.0, fa: 5.0), Pose(torso: 40.0, thigh: 65.0, shin: -30.0, ua: -55.0, fa: -45.0), Pose(torso: 20.0, thigh: 85.0, shin: -15.0, ua: 120.0, fa: 130.0, dx: 0.7, lift: 0.3), Pose(torso: 30.0, thigh: 80.0, shin: -40.0, ua: 85.0, fa: 85.0, dx: 1.3)], labels: ["Stehen", "Ausholen", "Flug", "Landung"]),
        "sq": FigureSpec(scene: .barBack, frames: [Pose(torso: 0.0, thigh: 0.0, shin: 0.0, ua: 30.0, fa: -151.0), Pose(torso: 35.0, thigh: 95.0, shin: -42.0, ua: 30.0, fa: -151.0)], labels: ["Stehen", "Tief"]),
        "split": FigureSpec(scene: .benchBehind, frames: [Pose(torso: 5.0, thigh: 15.0, shin: -5.0, ua: 10.0, fa: 10.0, legB: [-30.0, -110.0]), Pose(torso: 15.0, thigh: 85.0, shin: -20.0, ua: 10.0, fa: 10.0, legB: [-40.0, -115.0])], labels: ["Oben", "Tief"]),
        "legpress": FigureSpec(scene: .none, frames: [Pose(torso: -50.0, thigh: 140.0, shin: 75.0, ua: 20.0, fa: 40.0, hipY: 0.5), Pose(torso: -50.0, thigh: 105.0, shin: 105.0, ua: 20.0, fa: 40.0, hipY: 0.5)], labels: ["Gebeugt", "Gestreckt"]),
        "lunge": FigureSpec(scene: .none, frames: [Pose(torso: 0.0, thigh: 0.0, shin: 0.0, ua: 8.0, fa: 5.0), Pose(torso: 0.0, thigh: 85.0, shin: -5.0, ua: 8.0, fa: 5.0, legB: [-15.0, -85.0])], labels: ["Stehen", "Tief"]),
        "stepup": FigureSpec(scene: .boxAhead, frames: [Pose(torso: 10.0, thigh: 50.0, shin: -5.0, ua: 8.0, fa: 5.0, dx: 0.1), Pose(torso: 0.0, thigh: 0.0, shin: 0.0, dx: 0.95, lift: 0.45)], labels: ["Fuß auf die Box", "Oben stehen"]),
        "legext": FigureSpec(scene: .none, frames: [Pose(torso: -10.0, thigh: 90.0, shin: -5.0, ua: 20.0, fa: 60.0, hipY: 0.85), Pose(torso: -10.0, thigh: 90.0, shin: 88.0, ua: 20.0, fa: 60.0, hipY: 0.85)], labels: ["Gebeugt", "Gestreckt"]),
        "rdl": FigureSpec(scene: .barHands, frames: [Pose(torso: 0.0, thigh: 0.0, shin: 0.0, ua: 5.0, fa: 0.0), Pose(torso: 75.0, thigh: 18.0, shin: -8.0, ua: 5.0, fa: 0.0)], labels: ["Stehen", "Hüfte nach hinten"]),
        "dl": FigureSpec(scene: .barHands, frames: [Pose(torso: 50.0, thigh: 75.0, shin: -25.0, ua: 0.0, fa: 0.0), Pose(torso: 0.0, thigh: 0.0, shin: 0.0, ua: 5.0, fa: 0.0)], labels: ["Boden", "Aufrecht"]),
        "hip": FigureSpec(scene: .benchUnder, frames: [Pose(torso: -75.0, thigh: 108.0, shin: -30.0, ua: 0.0, fa: 0.0), Pose(torso: -100.0, thigh: 88.0, shin: -15.0, ua: 0.0, fa: 0.0)], labels: ["Unten", "Hüfte oben"]),
        "nord": FigureSpec(scene: .none, frames: [Pose(torso: 0.0, thigh: 0.0, shin: -90.0, ua: 60.0, fa: 95.0), Pose(torso: 70.0, thigh: -70.0, shin: -90.0, ua: 100.0, fa: 100.0)], labels: ["Kniend", "Langsam nach vorn"]),
        "legcurl": FigureSpec(scene: .none, frames: [Pose(torso: -90.0, thigh: 90.0, shin: 90.0, ua: 0.0, fa: 0.0, hipY: 0.25), Pose(torso: -90.0, thigh: 90.0, shin: -10.0, ua: 0.0, fa: 0.0, hipY: 0.25)], labels: ["Gestreckt", "Fersen zum Gesäß"]),
        "swing": FigureSpec(scene: .dbHands, frames: [Pose(torso: 55.0, thigh: 25.0, shin: -10.0, ua: 15.0, fa: 10.0), Pose(torso: 0.0, thigh: 0.0, shin: 0.0, ua: 90.0, fa: 90.0)], labels: ["Hüfte zurück", "Hüfte vor"]),
        "bridge": FigureSpec(scene: .none, frames: [Pose(torso: -95.0, thigh: 118.0, shin: -54.0, ua: 0.0, fa: 0.0, legB: [100.0, 100.0]), Pose(torso: -105.0, thigh: 95.0, shin: -40.0, ua: 0.0, fa: 0.0, legB: [100.0, 100.0])], labels: ["Unten", "Hüfte hoch"]),
        "calf": FigureSpec(scene: .dbHands, frames: [Pose(torso: 0.0, thigh: 0.0, shin: 0.0, ua: 5.0, fa: 0.0), Pose(torso: 0.0, thigh: 0.0, shin: 0.0, ua: 5.0, fa: 0.0, lift: 0.14)], labels: ["Unten", "Hoch auf die Zehen"]),
        "calfsit": FigureSpec(scene: .none, frames: [Pose(torso: 0.0, thigh: 90.0, shin: 0.0, ua: 5.0, fa: 60.0, hipY: 0.85), Pose(torso: 0.0, thigh: 90.0, shin: 0.0, ua: 5.0, fa: 60.0, lift: 0.1, hipY: 0.85)], labels: ["Unten", "Hoch"]),
        "pall": FigureSpec(scene: .none, frames: [Pose(torso: 0.0, thigh: 0.0, shin: 0.0, ua: 20.0, fa: 120.0), Pose(torso: 0.0, thigh: 0.0, shin: 0.0, ua: 90.0, fa: 90.0)], labels: ["Vor der Brust", "Arme strecken"]),
        "dead": FigureSpec(scene: .none, frames: [Pose(torso: -90.0, thigh: 115.0, shin: 25.0, ua: 175.0, fa: 175.0, hipY: 0.15), Pose(torso: -90.0, thigh: 100.0, shin: 96.0, ua: 255.0, fa: 255.0, hipY: 0.15)], labels: ["Tischposition", "Arm und Bein strecken"]),
        "hangleg": FigureSpec(scene: .pullbar, frames: [Pose(torso: 0.0, thigh: 0.0, shin: 0.0, ua: 176.0, fa: 176.0, lift: 0.35, bar: 3.9974422527728155), Pose(torso: 0.0, thigh: 90.0, shin: 92.0, ua: 176.0, fa: 176.0, lift: 2.08, bar: 3.9974422527728155)], labels: ["Hängen", "Beine heben"]),
        "row": FigureSpec(scene: .barHands, frames: [Pose(torso: 70.0, thigh: 20.0, shin: -15.0, ua: 0.0, fa: 0.0), Pose(torso: 70.0, thigh: 20.0, shin: -15.0, ua: -80.0, fa: 5.0)], labels: ["Arme gestreckt", "Zum Bauch ziehen"]),
        "pull": FigureSpec(scene: .pullbar, frames: [Pose(torso: 0.0, thigh: 0.0, shin: 0.0, ua: 176.0, fa: 176.0, lift: 0.3, bar: 3.9474422527728157), Pose(torso: 0.0, thigh: 0.0, shin: 0.0, ua: 20.0, fa: 172.0, lift: 1.37, bar: 3.9474422527728157)], labels: ["Hängen", "Kinn über die Stange"]),
        "bench": FigureSpec(scene: .none, frames: [Pose(torso: -90.0, thigh: 90.0, shin: 0.0, ua: 180.0, fa: 180.0, hipY: 0.5), Pose(torso: -90.0, thigh: 90.0, shin: 0.0, ua: 120.0, fa: 180.0, hipY: 0.5)], labels: ["Arme gestreckt", "Zur Brust"]),
        "ohp": FigureSpec(scene: .barHands, frames: [Pose(torso: 0.0, thigh: 0.0, shin: 0.0, ua: 20.0, fa: -160.0), Pose(torso: 0.0, thigh: 0.0, shin: 0.0, ua: 176.0, fa: 176.0)], labels: ["Auf Schulterhöhe", "Über den Kopf"]),
        "lat": FigureSpec(scene: .none, frames: [Pose(torso: -8.0, thigh: 90.0, shin: 0.0, ua: 176.0, fa: 176.0, hipY: 0.85), Pose(torso: -12.0, thigh: 90.0, shin: 0.0, ua: 35.0, fa: 150.0, hipY: 0.85)], labels: ["Oben", "Zur Brust ziehen"]),
        "face": FigureSpec(scene: .none, frames: [Pose(torso: 0.0, thigh: 0.0, shin: 0.0, ua: 90.0, fa: 90.0), Pose(torso: 0.0, thigh: 0.0, shin: 0.0, ua: 55.0, fa: 165.0)], labels: ["Arme vorn", "Zum Gesicht"]),
    ]
}


// MARK: - Geometrie

struct FigJoints {
    var hip, sho, head, knee, ank, toe, elb, hnd: CGPoint
    var kneeB: CGPoint? = nil
    var ankB: CGPoint? = nil
}

enum Geo {
    static func rad(_ a: Double) -> Double { a * .pi / 180 }
    static func down(_ a: Double, _ l: Double) -> CGPoint { CGPoint(x: sin(rad(a)) * l, y: -cos(rad(a)) * l) }
    static func up(_ a: Double, _ l: Double) -> CGPoint { CGPoint(x: sin(rad(a)) * l, y: cos(rad(a)) * l) }
    static func add(_ a: CGPoint, _ b: CGPoint) -> CGPoint { CGPoint(x: a.x + b.x, y: a.y + b.y) }

    static func joints(_ p: Pose) -> FigJoints {
        let hip = CGPoint.zero
        let sho = up(p.torso, 0.9)
        let head = add(sho, up(p.torso, 0.27))
        let knee = down(p.thigh, 0.85)
        let ank = add(knee, down(p.shin, 0.85))
        let elb = add(sho, down(p.ua, 0.55))
        let hnd = add(elb, down(p.fa, 0.5))
        let dy = p.hipY ?? (-ank.y + p.lift)
        func m(_ q: CGPoint) -> CGPoint { CGPoint(x: q.x + p.dx, y: q.y + dy) }
        var j = FigJoints(hip: m(hip), sho: m(sho), head: m(head), knee: m(knee), ank: m(ank),
                          toe: m(CGPoint(x: ank.x + 0.28, y: ank.y)), elb: m(elb), hnd: m(hnd))
        if let b = p.legB, b.count == 2 {
            let kb = down(b[0], 0.85)
            let ab = add(kb, down(b[1], 0.85))
            j.kneeB = m(kb); j.ankB = m(ab)
        }
        return j
    }

    static func mix(_ a: Pose, _ b: Pose, _ t: Double) -> Pose {
        func l(_ x: Double, _ y: Double) -> Double { x + (y - x) * t }
        var r = Pose()
        r.torso = l(a.torso, b.torso); r.thigh = l(a.thigh, b.thigh); r.shin = l(a.shin, b.shin)
        r.ua = l(a.ua, b.ua); r.fa = l(a.fa, b.fa); r.dx = l(a.dx, b.dx); r.lift = l(a.lift, b.lift)
        if let x = a.hipY, let y = b.hipY { r.hipY = l(x, y) } else { r.hipY = a.hipY ?? b.hipY }
        if let x = a.legB, let y = b.legB, x.count == 2, y.count == 2 { r.legB = [l(x[0], y[0]), l(x[1], y[1])] } else { r.legB = a.legB ?? b.legB }
        r.bar = a.bar ?? b.bar
        return r
    }
}

// MARK: - Animierte Figur

struct StickFigureView: View {
    let spec: FigureSpec
    var color: Color = Theme.accent
    private let hold = 0.55, move = 0.9

    var body: some View {
        TimelineView(.animation) { ctx in
            let n = spec.frames.count
            let seq = n + max(0, n - 2)             // hin und zurück
            let cycle = Double(seq) * (hold + move)
            let t = ctx.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: cycle)
            let slot = Int(t / (hold + move))
            let local = t - Double(slot) * (hold + move)
            let idx: (Int) -> Int = { s in s < n ? s : max(0, 2 * (n - 1) - s) }
            let from = idx(slot), to = idx(slot + 1)
            let raw = local < hold ? 0.0 : (local - hold) / move
            let e = raw < 0.5 ? 2 * raw * raw : 1 - pow(-2 * raw + 2, 2) / 2
            let pose = Geo.mix(spec.frames[from], spec.frames[to], e)
            VStack(spacing: 6) {
                Canvas { g, size in draw(g, size, pose) }
                    .frame(height: 230)
                Text(raw > 0.5 ? spec.labels[to] : spec.labels[from])
                    .font(.footnote.weight(.semibold)).foregroundStyle(.secondary)
            }
        }
    }

    private func bounds() -> (CGFloat, CGFloat, CGFloat) {
        var xs: [CGFloat] = [], ys: [CGFloat] = [0]
        for f in spec.frames {
            let j = Geo.joints(f)
            var pts = [j.hip, j.sho, j.head, j.knee, j.ank, j.toe, j.elb, j.hnd]
            if let a = j.kneeB { pts.append(a) }
            if let a = j.ankB { pts.append(a) }
            for p in pts { xs.append(p.x); ys.append(p.y) }
        }
        switch spec.scene {
        case .boxAhead: xs += [0.55, 1.35]
        case .boxHere: xs += [-0.45, 0.35]
        case .benchBehind: xs += [-1.25, -0.55]
        default: break
        }
        let minx = (xs.min() ?? 0) - 0.3, maxx = (xs.max() ?? 1) + 0.3
        return (minx, maxx, (ys.max() ?? 1) + 0.2)
    }

    private func draw(_ g: GraphicsContext, _ size: CGSize, _ p: Pose) {
        let (minx, maxx, maxy) = bounds()
        let sc = min((size.width - 20) / (maxx - minx), (size.height - 20) / maxy)
        let ox = (size.width - (maxx - minx) * sc) / 2
        func T(_ q: CGPoint) -> CGPoint { CGPoint(x: ox + (q.x - minx) * sc, y: size.height - 10 - q.y * sc) }
        let j = Geo.joints(p)
        let grey = Color.gray.opacity(0.55)
        func line(_ a: CGPoint, _ b: CGPoint, _ w: CGFloat, _ c: Color) {
            var path = Path(); path.move(to: T(a)); path.addLine(to: T(b))
            g.stroke(path, with: .color(c), style: StrokeStyle(lineWidth: w, lineCap: .round))
        }
        func rect(_ x1: Double, _ x2: Double, _ h: Double) {
            let r = CGRect(x: T(CGPoint(x: x1, y: h)).x, y: T(CGPoint(x: x1, y: h)).y, width: (x2 - x1) * sc, height: h * sc)
            g.stroke(Path(roundedRect: r, cornerRadius: 3), with: .color(grey), lineWidth: 2)
        }
        func circle(_ c: CGPoint, _ rr: Double, fill: Bool = false) {
            let q = T(c); let r = rr * sc
            let path = Path(ellipseIn: CGRect(x: q.x - r, y: q.y - r, width: r * 2, height: r * 2))
            if fill { g.fill(path, with: .color(grey)) } else { g.stroke(path, with: .color(grey), lineWidth: 3) }
        }
        line(CGPoint(x: minx, y: 0), CGPoint(x: maxx, y: 0), 2, grey)
        switch spec.scene {
        case .boxAhead: rect(0.55, 1.35, 0.45)
        case .boxHere: rect(-0.45, 0.35, 0.45)
        case .benchBehind: rect(-1.25, -0.55, 0.45)
        case .benchUnder:
            let sx = Geo.joints(spec.frames[0]).sho.x
            rect(sx - 0.5, sx + 0.15, 0.45)
        case .pullbar:
            if let by = p.bar { line(CGPoint(x: j.hnd.x - 0.5, y: by), CGPoint(x: j.hnd.x + 0.5, y: by), 3, grey) }
        default: break
        }
        if let kb = j.kneeB, let ab = j.ankB {
            let light = color.opacity(0.4)
            line(j.hip, kb, 4, light); line(kb, ab, 4, light)
        }
        line(j.hip, j.knee, 5, color); line(j.knee, j.ank, 5, color); line(j.ank, j.toe, 5, color)
        line(j.hip, j.sho, 6, color); line(j.sho, j.elb, 5, color); line(j.elb, j.hnd, 5, color)
        let h = T(j.head); let hr = 0.13 * sc
        g.stroke(Path(ellipseIn: CGRect(x: h.x - hr, y: h.y - hr, width: hr * 2, height: hr * 2)), with: .color(color), lineWidth: 4)
        switch spec.scene {
        case .barBack: circle(j.sho, 0.2)
        case .barHands: circle(j.hnd, 0.17)
        case .dbHands: circle(j.hnd, 0.08, fill: true)
        default: break
        }
    }
}

// MARK: - Erklär-Ansicht

struct GuideView: View {
    let exercise: Exercise
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let f = ExerciseGuide.figure(exercise.id) {
                StickFigureView(spec: f)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.radius))
            }
            if let t = ExerciseGuide.text(exercise.id) {
                Text(t.what).font(.body)
                GuideBlock(title: "So geht's", icon: "list.number") {
                    ForEach(Array(t.steps.enumerated()), id: \.offset) { i, s in
                        HStack(alignment: .top, spacing: 10) {
                            Text("\(i + 1)").font(.caption.bold()).foregroundStyle(.white)
                                .frame(width: 22, height: 22).background(Theme.accent, in: Circle())
                            Text(s).font(.subheadline)
                        }
                    }
                }
                GuideBlock(title: "Häufige Fehler", icon: "exclamationmark.triangle") {
                    ForEach(t.mistakes, id: \.self) { m in
                        Label(m, systemImage: "xmark.circle").font(.subheadline).foregroundStyle(.primary)
                    }
                }
                GuideBlock(title: "Trainierte Muskeln", icon: "figure.strengthtraining.traditional") {
                    Text(t.muscles).font(.subheadline)
                }
            }
            if !exercise.cue.isEmpty {
                Label(exercise.cue, systemImage: "lightbulb").font(.subheadline).foregroundStyle(.secondary)
            }
        }
    }
}

struct GuideBlock<Content: View>: View {
    let title: String; let icon: String
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon).font(.headline)
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: Theme.radius))
    }
}

struct GuideSheet: View {
    let exercise: Exercise
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ScrollView { GuideView(exercise: exercise).padding() }
                .background(Theme.bg.ignoresSafeArea())
                .navigationTitle(exercise.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Fertig") { dismiss() } } }
        }
        .presentationDetents([.large])
    }
}
