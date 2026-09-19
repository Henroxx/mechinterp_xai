# Plan — Lesen gegen Steuern (Kandidat D, Phase 5)

Entschieden von Henry am 2026-09-19. Umfang bewusst klein: Uni-Projekt, kein
Masterarbeits-Maßstab. Anker im Volltext gelesen am 2026-09-19 (Fahrplan-Schritt 11), Plan
danach ausgearbeitet (Schritt 12). Die Zellfolge steht unten in Schritt 4.

## Fortschritt

- **Schritte 1–2 erledigt (2026-09-19).** Volltexte gelesen; Daten stehen als sechs kontrollierte
  Binärfamilien, ausgewählt durch Vorabmessung statt Vermutung.
- **Anker reproduziert (Schritt 12 des Fahrplans).** `notebooks/07_reading_vs_steering.ipynb`
  → DETAILS „Lesen gegen Steuern — Anker-Reproduktion". Damit sind `A_lin`, die Probe samt
  Kontrollaufgabe und die Mittelwertdifferenz-Steuerung pro Schicht schon gemessen.
- **Schritte 3–5 erledigt (2026-09-19).** `notebooks/08_direction_sources.ipynb` → DETAILS
  „Lesen gegen Steuern — Richtungsquellen bei gleicher Wirkung". **Der Block ist damit durch.**
  Abweichung vom Plan, von Henry entschieden: die Substrat-Prüfung läuft als beschreibender Befund
  statt als Abbruchkriterium — sie stammt von einer Ablations-Arbeit, wir addieren aber auf den
  echten Residual Stream und lesen die Wirkung am Modell ab, also validiert sich die Messung
  selbst. Der Fehleranteil entscheidet über die *Deutung*, nicht über die Gültigkeit der Zahl.

## Frage

Eine Richtung, die ein Konzept gut *ausliest*, muss das Verhalten nicht gut *steuern*. Für die
Wege zu einer Richtung — Mittelwertdifferenz, lineare Probe, SAE-Feature — beide Achsen messen
und gegeneinander auftragen: sagt Lesegüte die Steuerwirkung vorher, und welches Lesemaß tut es?

## Was der Volltext geändert hat

Billa, *Predicting Where Steering Vectors Succeed* (arXiv:2604.15557, Preprint, unbegutachtet).
Fünf Punkte, die den Plan verschoben haben:

1. **Unsere Notiz war falsch paraphrasiert.** Nicht „Steering wirkt auf der lesestärksten Schicht
   nicht", sondern: die trainierte Probe erreicht in *jeder* Schicht L0–L25 über 93 % und ist
   deshalb über die Tiefe gesättigt — sie hat keine Varianz, mit der sie die Schichtwahl leiten
   könnte. Das Maß, das es kann, ist `A_lin`.
2. **`A_lin` kommt als viertes, trainingsfreies Lesemaß dazu:** Unembedding auf den
   Zwischenzustand, argmax gegen das Zieltoken. Ein Forward-Pass, keine Gewichte, kein Training.
3. **Die Wirkung ist ein Forward-Pass-Maß,** nicht Generierung: ΔP auf dem Zieltoken bei
   Einzeltoken-Antworten. Damit fällt unsere Laufzeitsorge (2,7 Token/s) für das Kernraster weg.
4. **Metriken übernehmen statt erfinden:** Nebenwirkung = KL auf 50 fremden Prompts,
   Effizienz = ΔP/KL. So zitierbar statt selbstgebaut.
5. **Zwei Lücken, die das Paper selbst offenlässt** — sie sind unser Beitrag:
   - Es nennt **nirgends die Dosis**, und berichtet ρ(‖d‖, KL) = +0,96. Die gemessene
     Nebenwirkung ist also fast nur die Norm des addierten Vektors, und die Effizienz-Zahlen
     vergleichen Konzepte, deren Mittelwertdifferenzen Normen von 2,4 bis 149 haben.
   - Die **SAE-Vorhersage ist ausdrücklich ungetestet** („natural direction for future work"):
     SAE-Features sollen in Regime 2 (nichtlinear kodiert) helfen und in Regime 3 (schon
     output-aligned) wenig beitragen.

## Was die zweite Arbeit beiträgt

Tiwari et al., *Decodability is Not Causality* (arXiv:2609.18080, COLM-2026-Workshop). Sie
ablieren nur und steuern nicht, haben keine Mittelwertdifferenz-Quelle, und vergleichen bei
gleicher Set-Größe statt gleicher Wirkung — unser Zuschnitt ist damit kein Nachbau. Zwei Dinge
übernehmen wir:

- **Substrat-Prüfung als Abbruchkriterium vor jeder SAE-Aussage:** welcher Anteil der
  Lese-Trennung überlebt die SAE-Rekonstruktion? Bei ihnen lagen im Qwen3-8B-Versuch 74 % des
  Probe-Margins im Rekonstruktionsfehler — dort messen SAE-Eingriffe nur noch sich selbst.
- **Gleich große Zufallskontrolle und die ganze Richtung als Obergrenze,** damit eine
  Feature-Auswahl gegen beides steht statt gegen nichts.

## Der Beitrag in einem Satz

Billas Diagnose bei *gleicher Wirkung und gleicher Nebenwirkung* nachmessen statt bei der Dosis,
die sich zufällig aus der Vektornorm ergibt — und dabei seine offene SAE-Vorhersage im Kleinen
prüfen.

## Annahmen: beide geklärt (2026-09-19)

- **Modell GPT-2 small — bestätigt, gemessen.** Billas Skalierungstabelle (5/23 steuerbare
  Konzepte bei 160M) ließ einen Bodeneffekt befürchten. `A_lin` selbst gemessen: geography
  0,774 · sequence 0,909 · word transform 0,292, alle mit Maximum in L10, alle exakt 0 bis L7.
  Zwei Familien weit über der go/no-go-Schwelle 0,1, eine im Mittelfeld — brauchbarer Spread.
  Gemma-2-2B ist damit als Hauptmodell nicht nötig, höchstens als Gegenprobe an einer Schicht.
- **SAEs für alle 12 Schichten — belegt.** `jbloom/GPT2-Small-SAEs-Reformatted` liefert
  `blocks.0`–`blocks.11` je `hook_resid_pre`, 144 MiB pro Schicht, nur `HOOK` tauschen
  (Station 5 nutzte L6). Haken: Feature-Indizes sind pro Schicht unabhängig trainiert, also
  nicht über Schichten identifizierbar — die Feature-Suche läuft pro Schicht neu.

## Schritte

1. **Daten.** Drei Konzeptfamilien mit Einzeltoken-Antwort nach Billas Bauart (seine Tabelle 7):
   `geography` (»Paris is the capital of« → France), `sequence` (Tage, Monate, Alphabet),
   `word transform` (Gegensatzpaare). Heterogen in Form und Thema, damit Probe und
   Mittelwertdifferenz auseinanderfallen können — die 20 Minimalpaare aus Station 2 sind der
   Entartungsfall (cos ≥ 0,95). Antworten werden auf Einzeltoken geprüft und Ausfälle berichtet.
2. **Lesen (Achse A), pro Schicht und Konzept.** `A_lin` trainingsfrei · Probe-Accuracy
   held-out mit Kontrollaufgabe und Selectivity daneben (Kandidat C steckt hier) ·
   Separabilität der Mittelwertdifferenz als AUROC der Projektion · SAE-Encoder-Aktivierung
   als AUROC. Vier Lesemaße, damit die Frage „welches Lesen sagt Steuern vorher" überhaupt
   beantwortbar ist.
3. **Richtungen (drei Quellen + Boden), pro Schicht und Konzept.** Davor die Substrat-Prüfung
   nach Tiwari: hält die SAE-Rekonstruktion die Lese-Trennung des Konzepts? Wenn nicht, wird die
   SAE-Quelle als nicht tragfähig berichtet statt gemessen.
   Quellen: Mittelwertdifferenz ·
   Probe-Gewichtsvektor · SAE-Decoder-Zeile (Feature über den Encoder gesucht wie in Station 5) ·
   norm-matched Zufallsrichtung als Boden. Alle auf Einheitsnorm gebracht, die Dosis ist der
   einzige Skalenparameter.
4. **Steuern (Achse B).** Richtung auf den Residual Stream addieren, ΔP auf dem Zieltoken,
   KL auf 50 fremden Prompts. Dosis-Sweep pro Kombination, daraus zwei Vergleiche:
   Wirkung bei gleichem KL-Budget, und KL bei gleicher Wirkung (ΔP-Ziel fixiert). Billas
   Effizienz ΔP/KL kommt als drittes Maß dazu, damit die Zahlen vergleichbar bleiben.
   Raster: 12 Schichten × 3 Konzepte × 4 Quellen × ~6 Dosen, alles Forward-Pässe auf GPT-2
   small — Minuten, nicht Stunden.
5. **Auswerten.** Pro Schicht: die vier Lesemaße gegen die Steuerwirkung. Pro Quelle: Kosten
   bei gleicher Wirkung. Kernfrage an die SAE-Vorhersage: liegt GPT-2 small in L8–L10 in
   Regime 3, und ist das SAE-Feature dort wie vorhergesagt kein Gewinn?

## Erwartung

`A_lin` sagt die Steuerwirkung über die Schichten vorher, die Probe-Accuracy nicht — sie
sättigt, wie bei Billa. Die Mittelwertdifferenz steuert am verlässlichsten; das SAE-Feature
verliert bei gleicher Wirkung, wie in Station 5 schon gesehen, und das wäre eine Bestätigung
seiner Regime-3-Vorhersage. Am interessantesten wäre der Fall, dass die Effizienz-Reihenfolge
der Quellen kippt, sobald man norm-matched statt bei Rohnorm vergleicht — dann steckt sein
Effizienzmaß den Befund selbst hinein.

## Zuschnitt entschieden (Henry, 2026-09-19)

- **Vier Familien tragen das Ergebnis:** `temperature`, `size`, `pronoun`, `daynight`. `parity` und
  `continent` laufen als Bodenfälle mit — sie kosten nichts, weil alles Forward-Pässe sind —
  erscheinen im Text aber nur als Kontrolle, nicht als eigene Fälle. Grund: vier Familien × drei
  Richtungsquellen ist bereits ein volles Kapitel, und ohne Bodenfall ist die go/no-go-Schwelle
  nicht prüfbar.
- **Billas nichtlinearer Teil bleibt draußen.** Kein `A_mlp`, kein trainiertes MLP pro Schicht —
  die Grenze „kein Training" bleibt damit sauber und der Umfang klein.
  **Ersatz statt Lücke:** die Regime-Einordnung läuft über die Probe, die ohnehin pro Schicht
  gemessen wird. Liest eine Probe das Konzept, wo `A_lin` es nicht liest, ist es vorhanden aber
  nicht output-aligned — operativ genau Billas Regime 2 (`continent` ist dieser Fall: Probe 1,00
  gegen `A_lin` 0,04). Die Einschränkung wird mitgeschrieben: eine *scheiternde* Probe belegt
  keine Abwesenheit, also bleibt die Grenze zwischen „gar nicht da" und „nur nichtlinear da"
  unscharf. Damit ist von seiner SAE-Vorhersage die Regime-3-Hälfte prüfbar (`A_lin` hoch → das
  SAE-Feature soll wenig beitragen), die Regime-2-Hälfte nur unter diesem Vorbehalt.
