# Plan — Schnuppertour Station 3: Probing auf GPT-2 small

> **Abgeschlossen 2026-09-18.** Schritte 1–6 gelaufen, Schritt 5 als Variante B (w, w⊥ und
> Zufallsvektor neben d). Befund → DETAILS „Probing — Befund GPT-2 small".

Abgestimmt 2026-09-18 (Henry: „Mach ruhig scikit learn"; Umfang siehe erste Annahme).
Notebook `notebooks/04_probing.ipynb`, leer angelegt. Eine Session, dann Befund nach DETAILS
und dieser Plan nach `done/`. Konzept im Lerndokument Abschnitt 6 (LRH, Probe als Normale
der Trennebene). Material aus `03_steering.ipynb`: die 20 Minimalpaare, `sentence_resid`,
`direction`, `logit_diff`, `add_direction`, `sweep_logit_diff`, `sweep_loss`, `plot_curves`.

## Frage

Liest eine lineare Probe Sentiment an Layer 6 von GPT-2 small so gut wie die
Difference-in-Means-Richtung d aus Station 2, zeigt ihre Richtung w woandershin, und
steuert w anders als d bei gleichem Loss?

## Schritte

1. Setup wie in 03: Modell, die 20 Paare, Satzmittel an `blocks.6.hook_resid_pre` ohne BOS
   → 40 Vektoren; d und `resid_norm` neu berechnet, kein Import aus 03. Das Notebook läuft
   allein top-to-bottom.
2. Probe: `sklearn.linear_model.LogisticRegression`, L2, Features roh — Standardisieren
   würde w in einen skalierten Raum legen, der nicht mit d vergleichbar ist. Leave-one-pair-out,
   20 Folds, beide Sätze eines Paares raus. Pro Fold Held-out-Treffer und Margin wie in 03:
   (x_pos − x_neg)·ŵ mit ŵ auf Länge 1, so ist sie mit d vergleichbar (dort mean 5.64, min 3.29).
3. Control Task (Hewitt & Liang): gleiches Protokoll, Vorzeichen je Paar zufällig getauscht
   (hält Balance 20/20 und Paarstruktur, ein Shuffle über 40 Labels täte beides nicht),
   10 Seeds, Held-out-Trefferquote gemittelt.
4. w gegen d: Probe auf allen 40 Punkten, C logarithmisch von 1e-5 bis 1e2, ŵ je C,
   cos(ŵ, d) und Held-out-Treffer je C nebeneinander.
5. Steuern mit w: das ŵ mit dem kleinsten cos zu d, das im Held-out noch 20/20 hält, durch
   denselben Dosis-Sweep wie d (gleiche `coefficients`, Dosis in Einheiten von `resid_norm`,
   Layer 6, alle Positionen außer BOS). Adjektiv-Logit-Differenz und Loss auf den neutralen
   Sätzen aus 03, d als Vergleichskurve im selben Plot.
6. Optional: Layer-Scan, Schritte 1–2 an jedem `hook_resid_pre` 0–11, Held-out-Treffer und
   Margin gegen Layer.

## Gesetzt, nicht hergeleitet

> **ANNAHME:** Umfang 1–5 als Kern, 6 optional — Claudes Vorschlag, Henry hat das Werkzeug
> entschieden, den Umfang nicht widersprochen.

> **ANNAHME:** Wieder Layer 6, damit w und d am selben Ort verglichen werden. Ob Layer 6 der
> beste Probing-Layer ist, klärt erst Schritt 6.

> **ANNAHME:** Satzmittel als Feature wie in 03. Letztes Token wäre näher am üblichen
> Probing; hier zählt die Vergleichbarkeit mit d mehr.

> **ANNAHME:** C als Raster, nicht per Cross-Validation gewählt. Bei 40 Punkten ist CV über
> C eine zweite Overfitting-Quelle; das Raster zeigt die Abhängigkeit, statt einen „besten"
> Wert zu behaupten.

## Erwartung, vorher notiert

Held-out 20 von 20 für jedes C im Raster, wie d — Treffer allein unterscheiden w und d
nicht. Control Task um 50 %, breite Streuung bei 20 Folds, Training trotzdem fehlerfrei
(Kapazität, nicht Information). cos(ŵ, d) nahe 1 bei kleinem C (Gradient am Nullpunkt ist
∝ mean(pos) − mean(neg)), fallend auf 0.5–0.8 bei großem C (Max-Margin-Richtung, hängt an
Randpunkten). Sweep: w verschiebt die Metrik weniger als d bei gleicher Dosis, kostet
ähnlich Loss (Marks & Tegmark: Proben trennen, DiM steuert). Unsicher: bleibt cos hoch,
verschwindet der Unterschied im Rauschen der zehn Prompts.

## Abschluss

Befund mit Zahlen (3–5 Sätze) → DETAILS neue Sektion „Probing — Befund GPT-2 small",
scikit-learn in „Umgebung & Tooling"; Dashboard Probing auf `done`, Gemma-Tour auf
`current`; Plan nach `plans/done/`.
