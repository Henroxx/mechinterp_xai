# Plan — Lesen gegen Steuern (Kandidat D, Phase 5)

Entschieden von Henry am 2026-09-19. Umfang bewusst klein: Uni-Projekt, kein
Masterarbeits-Maßstab. Dieser Plan ist der abgestimmte Grobschnitt; der ausgearbeitete Plan
mit Datensätzen und Zellfolge entsteht als Fahrplan-Schritt 12, nach dem Volltext-Lesen.

## Frage

Eine Richtung, die ein Konzept gut *ausliest*, muss das Verhalten nicht gut *steuern*. Für drei
Wege zu einer Richtung — Mittelwertdifferenz, lineare Probe, SAE-Feature — beide Achsen messen
und gegeneinander auftragen: sagt Lesegüte die Steuerwirkung vorher?

## Warum das der Zuschnitt ist

- Zieht die Stationen 2 (Steering), 3 (Probing) und 5 (SAE) zusammen; alle drei Richtungsquellen
  sind schon gebaut, das Dosis-Werkzeug läuft.
- Kein neues Tooling, kein fremder Benchmark-Code, keine Versionspins fremder Repos.
- Anker zum Reproduzieren: Billa (arXiv:2604.15557) — Probe über L0–L25 mit >93 % Genauigkeit,
  Steering auf der lesestärksten Schicht nahezu wirkungslos.
- Sitzt auf der Kernfrage der Landkarte: das Messinstrument bestimmt das Ergebnis mit.
- Kandidat C (Kontrollaufgabe, Selectivity) ist als Schritt 3 enthalten, nicht verworfen.

## Schritte

1. **Volltext lesen** (Fahrplan-Schritt 11): Billa arXiv:2604.15557 als Anker. Kandidat für die
   zweite Arbeit: Tiwari et al. arXiv:2609.18080 („Decodability is Not Causality") — beide sind
   Preprints ohne Begutachtung, das gehört beim Zitieren gesagt. Prüfen, was der Volltext an den
   abstract-basierten Notizen korrigiert (bei SteeringSafety waren es mehrere Punkte).
2. **Daten heterogener machen.** Die 20 Minimalpaare sind der Entartungsfall: dort liegen Probe
   und Mittelwertdifferenz bei cos ≥ 0,95 und können nicht auseinanderfallen. Gebraucht werden
   Sätze, die im Konzept variieren und in Form, Länge und Thema *nicht* gekoppelt sind.
3. **Richtungen erzeugen**, pro Konzept und Schicht: Mittelwertdifferenz · Probe (mit
   Kontrollaufgabe und Selectivity daneben, nicht nur Trefferquote) · SAE-Feature (Decoder-Zeile,
   Auswahl über den Encoder wie in Station 5).
4. **Beide Achsen messen.** Lesegüte held-out; Steuerwirkung über den Dosis-Sweep, und zwar bei
   *gleicher Wirkung und gleicher Nebenwirkung*, nicht bei gleicher Dosis — diese Unterscheidung
   hat bei der SAE-Station das Ergebnis gedreht. Norm-matched Zufallsrichtung als Boden.
5. **Auswerten:** Lesegüte gegen Steuerwirkung, pro Schicht und Richtungsquelle.

## Offene Punkte, vor Schritt 3 zu klären

> **ANNAHME:** Modell ist GPT-2 small, weil dort alle drei Richtungsquellen billig sind. Gemma-2-2B
> höchstens als Gegenprobe an einer Schicht — offen, ob das überhaupt nötig ist.

> **ANNAHME:** Fertige SAEs liegen für mehr als Schicht 6 vor. Nur für `blocks.6.hook_resid_pre`
> ist das belegt (Station 5). Trifft es nicht zu, begrenzt das die Schichtachse für die
> SAE-Quelle — dann werden nur die verfügbaren Schichten verglichen und das offen berichtet.

- Welche und wie viele Konzepte? Zwei reichen, wenn sie unterschiedlich geartet sind; ein
  bewusst oberflächliches Konzept als Gegenprobe ist die Überlegung aus Kandidat C.
- Maß für die Lesegüte: Trefferquote, Margin oder AUROC — Station 3 hat gezeigt, dass Trefferquote
  und Margin verschiedene Fragen beantworten und nur die Richtung aufs Steuern übergeht.

## Erwartung

Die Mittelwertdifferenz steuert am verlässlichsten, die Probe liest am besten, und das SAE-Feature
verliert auf beiden Achsen — Letzteres haben wir in Station 5 schon einmal gesehen. Wenn die
Lesegüte über die Schichten ein anderes Maximum hat als die Steuerwirkung, ist der Kern von Billa
im Kleinen reproduziert. Interessanter wäre der Fall, dass es *kein* Auseinanderfallen gibt: dann
liegt es an den Daten, und das wäre ein Befund über die Methode, nicht über das Modell.
