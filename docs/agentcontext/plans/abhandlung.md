# Plan — Abhandlung (Phasen 6–7, Fahrplan-Schritte 14–22)

Struktur und Eckdaten entschieden von Henry am 2026-09-19. Schreiben beginnt erst auf sein Go.

## Eckdaten

- **Genre: Technical Report.** Aufbau wie ein Paper (Abstract, nummerierte Abschnitte, Literatur),
  aber mit Hintergrund, den ein Paper wegließe. Sprache Englisch, Typst (`report/main.typ`, Template
  vorhanden, noch auf Deutsch gesetzt), Literatur IEEE über `refs.bib`.
- **Umfang: unter 10 Seiten Hauptteil, eher weniger.** Grafiken dürfen darüber hinausschießen.
  Leitprinzip ist die Zeit des Dozenten: **jeder Abschnitt beginnt mit einem kurzen Absatz „was und
  warum", danach erst das Detail** — so kann er überspringen, was er nicht braucht.
- **Erste Person Singular für Entscheidungen,** unpersönlich für Messungen.
- **KI-Nutzung: ein Kasten „Use of AI" unter dem Abstract, sonst nichts** (geändert von Henry am
  2026-09-19: der ursprünglich geplante Abschnitt 7 war „viel zu viel Text"). Drei Sätze außerhalb
  des nummerierten Textes — womit gearbeitet wurde, dass die Entscheidungen seine sind, und dass
  Regeldatei und Agent-Kontext im Repo vollständig einsehbar sind. Keine Zuschreibung pro Schritt.
- **Selbstzitate zeigen auf einen Git-Tag** (`v1.0-submission`), nie auf `main`. Grund: Links auf
  einen Branch brechen beim nächsten Push.
- **Grafiken:** Notebook-Figuren als Vektor per einer `savefig`-Zeile in den Figurenzellen von 07
  und 08 (einzige Änderung an den Notebooks, danach neu ausführen). Grafiken aus dem Lerndokument
  sind deutsch beschriftet — bei Wiederverwendung Labels ins Englische.
- **Abgabe:** PDF mit Repo-Link (Tag) im Text, Notebooks und `results/` liegen im Repo.

## Titel

*Applied Mechanistic Interpretability Methods* — Untertitel (Arbeitsfassung): *Reading is not
steering: what a probe cannot tell you about a steering vector*.

## Struktur mit Seitenbudget

| # | Abschnitt | Seiten | Inhalt |
|---|---|---|---|
| 0 | Abstract | ½ | Hauptbefund in fünf Sätzen. Wird zuletzt geschrieben. |
| 1 | Introduction | 1 | XAI modellagnostisch gegen Blick ins Modell; Haltung: methodenkritisch, das Messinstrument prägt den Befund; ein Satz zur KI-Nutzung; Lesehinweis. |
| 2 | Background: four ways to look inside | 1½ | Residual Stream als Arbeitsraum (Grafik), LRH in drei Sätzen, vier Methoden als Tabelle: misst was, setzt voraus, scheitert woran. |
| 3 | Exploration: one station per method | 1½ | **Tabelle:** Station → Notebook → Frage → Befund → Lehre. Drei Sätze, was ins Hauptexperiment floss; Modellentscheidung. |
| 4 | Choosing the question | 1 | Landkarte in einem Absatz, Kandidat D und warum, Anker (Billa), zweite Arbeit (Tiwari), die zwei Lücken. |
| 5 | Reading versus steering | 3½–4 | Design; Anker-Reproduktion (07-Grafik); Richtungsquellen bei gleicher Wirkung (08-Grafik, Dosis-Tabelle); Diskussion; Grenzen. **Hauptteil.** |
| 6 | Conclusion | ⅓ | Ergebnisse in sechs Sätzen, dann die zwei Fragen an jedes Steering-Ergebnis. |
| — | References, Anhang | — | Anhang = Tabelle „Pfad im Repo → was liegt dort". |

## Kernaussagen (bestätigt 2026-09-19 beim Schreiben von Abschnitt 5 — alle fünf hielten,
Nummer 1 wurde schärfer: die Probe ist bei zwei Familien über alle zwölf Schichten konstant
1,00, ihre Korrelation mit der Steuerwirkung ist also nicht schwach, sondern undefiniert)

1. **Lesen ist nicht Steuern.** Perfekt lesbare Konzepte sind unsteuerbar (`continent`); das
   trainingsfreie `A_lin` sagt Steuerbarkeit vorher, die Probe nicht, weil sie sättigt.
2. **Billas Zahlen sind dosis-konfundiert, sein Prädiktor ist trotzdem echt.** Implizite Dosis
   korreliert mit `A_lin` bei +0,76 bis +0,91; bei fester Dosis schwächer, bei gleicher Nebenwirkung
   überlebt die Reihenfolge bis auf eine Vertauschung.
3. **Herkunft der Richtung zählt weniger als Schicht und Dosis.** Drei Quellen in L10 innerhalb von
   0,03; Billas SAE-Vorhersage gilt nicht durchgängig.
4. **Erklärte Varianz ist blind für das Konzept.** 93–99 % erklärt, 35–99 % der Trennung im Fehler.
5. **Ohne Kontrollen ist nichts interpretierbar.** Zufall schlägt drei Richtungen bei `daynight` L6,
   `parity` bleibt 0,000, die Control Task entlarvt die Probe.

Roter Faden: das Messinstrument bestimmt das Ergebnis mit.

## Ablauf pro Abschnitt

**Geändert am 2026-09-19 (Henry):** erst schreiben, dann verstehen — nicht umgekehrt. Der
ursprüngliche Ablauf begann mit höchstens fünf Lückenfragen an Henry; die setzten Kenntnis des
Materials voraus, die der Abschnitt erst herstellt, und waren bei Abschnitt 5 unbeantwortbar.

1. Claude schreibt den Abschnitt aus DETAILS und den Notebooks, setzt die Schwerpunkte selbst.
2. Henry liest, versucht ihn zu verstehen und fragt. Claude erklärt und ändert den Text, wo
   Henrys Lesart zeigt, dass eine Stelle nicht trägt — eine Stelle, die erklärt werden muss,
   ist schlecht geschrieben.
3. **Am Ende zurück zu Abschnitt 5:** Verständnis nachschärfen und alles insgesamt glätten.
   Der Hauptteil wird zuerst geschrieben und zuletzt verstanden.

**Reihenfolge:** 5 → 4 → 3 → 2 → 6 → 1 → Abstract. Alles andere verweist auf Abschnitt 5,
nicht umgekehrt: die Introduction muss wissen, was herauskam, und die Kernaussagen sind aus dem
Hauptteil destilliert.

## Fortschritt

Wird im Dashboard geführt, **Phase 7 in `docs/fahrplan/index.html`** — ein Schritt pro Abschnitt
in Schreibreihenfolge, je mit Inhalt und den Konzepten, die Henry dafür verstehen muss (Marker
⬜ / 🟡 / ✅ wie im Lerndokument). Grund für den Umzug: Henry priorisiert mit dem Blick auf das
Dashboard, und eine zweite Checkliste hier wäre die Stelle, die als Erstes veraltet.

## Offen

- Endgültige Formulierung des Untertitels.
- Seitenbudget: Hauptteil liegt nach Abschnitt 6 bei rund 10,5 statt „unter 10". Entschieden wird
  nach Schritt 21, wenn der Umbruch echt ist; Kürzungskandidaten in dieser Reihenfolge: Tour-Tabelle
  in 3, die vier „further findings" in 5.4, die Spalte „What it assumes" in Tabelle 1.
- Literaturverzeichnis: Typsts IEEE-Stil wirft `note`-Felder weg, damit fehlen TransformerLens 3.5.1,
  der Fundort von Blooms SAE-Set und die LessWrong-Herkunft des Logit-Lens-Posts (→ Schritt 22).
- Welche Lerndokument-Grafiken wiederverwendet werden (entscheidet sich in Abschnitt 2).
