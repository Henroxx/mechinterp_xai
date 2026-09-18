# Schnuppertour Station 5 — SAE-Blick

> **Abgeschlossen 2026-09-18.** Alle vier Schritte gelaufen. Erwartung zur Loss-Effizienz lag
> falsch: die SAE-Richtung ist bei gleicher Wirkung nicht billiger als d. Befund → DETAILS
> „SAE — Befund GPT-2 small".

Abgestimmt 2026-09-18 (Henry: GPT-2 small, Feature selbst suchen falls einfach — ist es, vorab
geprüft). Letzte Station der Tour, bewusst klein: Notebook `notebooks/06_sae.ipynb`, eine Session,
dann Befund nach DETAILS und dieser Plan nach `done/`. Konzept im Lerndokument, Abschnitt 7 (SAE).

## Frage

Steuert die Decoder-Zeile eines Sentiment-Features aus einem fertig trainierten SAE GPT-2 small
anders als die kontrastiv gebaute Difference-in-Means-Richtung d aus Station 2 — in Wirkung pro
Dosis und in Loss-Kosten? Nebenfrage: ist Sentiment im SAE eine Achse oder zwei getrennte Features?

## Schritte

1. Setup aus `03_steering.ipynb` übernehmen: GPT-2 small, 20 Minimalpaare, d an Layer 6, Logit-
   Differenz-Metrik auf 10 neutralen Prompts, Loss auf 10 sachlichen Sätzen, Dosis c relativ zur
   Residual-Norm, Zufallsvektor. Kontrollwerte müssen Station 2 reproduzieren (Norm 83, Baseline
   +1,89).
2. SAE laden: `jbloom/GPT2-Small-SAEs-Reformatted`, Ordner `blocks.6.hook_resid_pre` (4 Tensoren,
   d_sae 24 576, ~150 MB, `huggingface_hub` + `safetensors` liegen im Lock). Prüfen statt glauben:
   Rekonstruktionsgüte und L0 messen, beide Encoder-Varianten (mit/ohne b_dec-Abzug) gegeneinander.
3. Feature selbst suchen: Encoder über die 40 Sätze, Aktivierung je Satz gemittelt, Ranking nach
   Differenz der Set-Mittel unter einem vorab fixierten Feuer-Kriterium. Ergebnis gegen die
   Neuronpedia-Labels (`6-res-jb`) halten — als Gegenprobe, nicht als Quelle.
4. Dosis-Sweep: Decoder-Zeile des positiven und des negativen Features durch denselben Sweep wie
   d und der Zufallsvektor, Metrik und Loss. Dazu die Kosinus-Matrix der vier Richtungen.

## Gesetzt, nicht hergeleitet

> **ANNAHME:** Layer 6 / `hook_resid_pre`, weil Station 2 und 3 dort messen und das SAE genau auf
> diesen Hook-Point trainiert ist. Keine Herleitung, aber die Vergleichbarkeit ist das Argument.

> **ANNAHME:** Decoder-Zeile als Steering-Richtung, nicht Encoder-Zeile. Der Decoder ist, was das
> Feature in den Residual Stream schreibt; der Encoder ist der Lesekopf. Beide sind nicht parallel.

> **ANNAHME:** Auswahlkriterium vorab fixiert — feuert in ≥ 12 von 20 Sätzen des einen Sets und in
> ≤ 5 des anderen, darunter die größte Differenz. Grund: ein Feature, das überall feuert, trennt
> nur über die Höhe und ist kein Sentiment-Detektor. Nachträgliches Nachjustieren wäre Rosinen.

> **ANNAHME:** n = 20 Paare, 10 Prompts, 10 Sätze wie in Station 2 — Orientierung, keine Statistik.

## Erwartung

Das Feature bewegt die Metrik schwächer pro Dosis als d: d ist auf genau diesen Kontrast gefittet,
das Feature ist eine von 24 576 allgemeinen Richtungen. Kosinus zu d deutlich unter 1. Positives und
negatives Feature nicht antiparallel (SAE-Features sind fast orthogonal gebaut) — falls doch, wäre
das der interessantere Befund. Loss-Kosten pro Dosis ähnlich wie d, deutlich über dem Zufallsvektor
bei kleinem c.

## Abschluss

Befund nach DETAILS („SAE — Befund GPT-2 small"), HISTORY-Zeile, Dashboard-Schritt 8 auf done,
Plan nach `done/`. Danach Phase 3, Forschungsstand mappen.
