# Plan — Abhandlung (Phase 6, Fahrplan-Schritte 14–15)

Struktur und Eckdaten entschieden von Henry am 2026-09-19. Schreiben beginnt erst auf sein Go.

## Eckdaten

- **Genre: Technical Report.** Aufbau wie ein Paper (Abstract, nummerierte Abschnitte, Literatur),
  aber mit Hintergrund, den ein Paper wegließe. Sprache Englisch, Typst (`report/main.typ`, Template
  vorhanden, noch auf Deutsch gesetzt), Literatur IEEE über `refs.bib`.
- **Umfang: unter 10 Seiten Hauptteil, eher weniger.** Grafiken dürfen darüber hinausschießen.
  Leitprinzip ist die Zeit des Dozenten: **jeder Abschnitt beginnt mit einem kurzen Absatz „was und
  warum", danach erst das Detail** — so kann er überspringen, was er nicht braucht.
- **Erste Person Singular für Entscheidungen,** unpersönlich für Messungen.
- **KI-Nutzung: ein Satz am Anfang plus der kurze Abschnitt 7.** Keine Zuschreibung bei jedem
  einzelnen Schritt — das wäre Lärm, nicht Ehrlichkeit. Der Agent-Kontext im Repo bleibt sichtbar.
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
| 6 | What I take from this | ½ | Vier, fünf methodische Punkte. |
| 7 | Working method and use of AI | ½ | Regeln der Zusammenarbeit, wo der Agent-Kontext liegt. Kurz. |
| — | References, Anhang | — | Anhang = Tabelle „Pfad im Repo → was liegt dort". |

## Kernaussagen (vorläufig — werden beim Schreiben von Abschnitt 5 bestätigt)

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

1. **Höchstens fünf Lückenfragen** an Henry im Chat, kurz durchsprechen. Die Kappung macht die
   Dauer planbar.
2. Claude schreibt den Abschnitt; Henry liest parallel die Grundlage dazu (Notebook, Lerndokument).
3. Am Ende alles gemeinsam lesen und korrigieren.

**Reihenfolge:** 5 → 4 → 3 → 2 → 6 → 7 → 1 → Abstract. Der Hauptteil ist das Frischeste und das,
wonach am ehesten gefragt wird — dort lohnt die Fragerunde am meisten.

## Fortschritt

- [ ] Vorarbeit: `main.typ` auf Englisch, `savefig` in 07/08, Figuren exportiert
- [ ] 5 Reading versus steering
- [ ] 4 Choosing the question
- [ ] 3 Exploration
- [ ] 2 Background
- [ ] 6 What I take from this · 7 Working method
- [ ] 1 Introduction · 0 Abstract
- [ ] Gesamtlesung, Korrektur, Tag `v1.0-submission`, Links prüfen

## Offen

- Endgültige Formulierung des Untertitels.
- Welche Lerndokument-Grafiken wiederverwendet werden (entscheidet sich in Abschnitt 2).
