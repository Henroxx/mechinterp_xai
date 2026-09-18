# Plan — Schnuppertour Station 2: Steering auf GPT-2 small

> **Abgeschlossen 2026-09-18.** Schritte 1–8 gelaufen, Schritt 9 (SAE-Decoder-Zeile) bewusst
> ausgelassen — kommt als eigene Station. Befund → DETAILS „Steering — Befund GPT-2 small".

Abgestimmt 2026-09-18 (Henry: „Machen wir so"). Notebook `notebooks/03_steering.ipynb`,
Titelzelle steht. Eine Session, dann Befund nach DETAILS und dieser Plan nach `done/`.
Konzept dazu im Lerndokument: Abschnitt 6 (LRH, vier Wege zu einer Richtung), 7 (SAE).

## Frage

Verschiebt eine Difference-in-Means-Richtung für Sentiment die Next-Token-Verteilung von
GPT-2 small dosisabhängig, und was kostet das an Loss auf neutralem Text, verglichen mit
einem Zufallsvektor gleicher Norm?

## Schritte

1. Zwei Satz-Sets: ~20 klar positive, ~20 klar negative kurze Sätze, gleich lang, gleiches
   Thema. Der Set-Unterschied definiert das Konzept, alles andere landet mit in d.
2. Aktivierungen an `blocks.6.hook_resid_pre`, pro Satz Mittel über Positionen ohne BOS.
3. d = mean(pos) − mean(neg), auf Länge 1.
4. Sanity-Check Lesen: Projektion x·d pro Satz, positive oben, negative unten, mit Abstand.
   Fällt das durch: Layer wechseln, nicht weitersteuern.
5. Zielmetrik: neutrale Prompts („The movie was", …), am letzten Token Logit-Differenz
   mean(positive Tokens) − mean(negative Tokens). Ein Forward-Pass, kein Generieren.
6. Dosis-Sweep: α·d an Layer 6 auf alle Positionen außer BOS, α in Vielfachen der mittleren
   Residual-Norm des Layers, fein von negativ bis positiv. Zielmetrik gegen α als Kurve.
7. Nebenwirkung: Loss auf neutralen Sätzen gegen dasselbe α.
8. Kontrollen: Zufallsvektor gleicher Norm, gleicher Layer, gleicher Sweep; d zusätzlich an
   Layer 2 und 10 gezogen und dort addiert.
9. Optional: Decoder-Zeile aus `jbloom/GPT2-Small-SAEs-Reformatted` Layer 6 (Feature über
   Neuronpedia `6-res-jb` gesucht) durch denselben Sweep → DETAILS „Tooling-Realität".

## Gesetzt, nicht hergeleitet

> **ANNAHME:** Layer 6 als Startlayer — ActAdd lief dort (auf GPT-2 XL), die Induction Heads
> sitzen bei 5–7. Keine Herleitung.

> **ANNAHME:** Mittel über Positionen statt letztes Token. SteeringSafety nimmt das letzte
> Token; für kurze Sätze ohne Frageform erscheint das Mittel robuster.

> **ANNAHME:** Die Token-Sets der Metrik sind handverlesen — die Stelle, an der man sich am
> leichtesten selbst belügt. Vor dem Sweep einmal ohne Steering anschauen.

## Erwartung, vorher notiert

Monotone Kurve für d, flache für den Zufallsvektor. Beim Loss ab großem α beide gleich
schlecht, ab da wirkt die Größe des Eingriffs, nicht die Richtung. Layer 10 stärker, aber
eher Logit-Bias als Repräsentationsänderung.

## Abschluss

Befund mit Zahlen (3–5 Sätze) → DETAILS neue Sektion „Steering — Befund GPT-2 small";
Dashboard Schritt 5 auf `done`; Plan nach `plans/done/`.
