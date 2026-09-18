# Plan — Schnuppertour Station 4: Gemma-2-2B-Tour

> **Abgeschlossen 2026-09-18.** Alle fünf Schritte gelaufen. Erwartung zu den Induction Heads lag
> falsch (stärker als GPT-2, über den ganzen Stack verteilt). Befund → DETAILS „Gemma-2-2B —
> Befunde aus der Tour".

Abgestimmt 2026-09-18 (Henry: TL bleibt 3.5.1, fünf Schritte, alles kompakt). Notebook
`notebooks/05_gemma.ipynb`. Bestandsaufnahme wie `01_explore.ipynb` für GPT-2, kein Experiment.
Eine Session, dann Befund nach DETAILS und dieser Plan nach `done/`.

## Frage

Was ist bei Gemma-2-2B anders als bei GPT-2 small, und was davon muss jede spätere Messung
berücksichtigen?

## Schritte

1. Laden und Parity-Check: `google/gemma-2-2b` einmal über transformers, Logits am letzten Token
   als Referenz, dann dasselbe HF-Modell an `HookedTransformer.from_pretrained(hf_model=…)`.
   Ladezeit und MPS-Speicher mitschreiben.
2. Architektur-Steckbrief aus `cfg` und Cache-Keys: Layer, GQA, Norm vor/nach, Softcaps,
   attn_types; genau ein `<bos>` beim Tokenisieren; Cache-Größe eines kurzen Prompts.
3. Residual-Norm-Profil über die Layer, BOS gegen Rest, plus Attention-Anteil auf BOS pro Layer.
4. Induction Heads mit dem Rezept aus 01 (Zufallssequenz L=20, Seed 0, zweimal): Score pro Head
   als Heatmap, Top 5, Loss erste gegen zweite Hälfte.
5. `gemma-2-2b-it` nach `del model`: Chat-Marker prüfen, eine harmlose und eine Refusal-Anfrage
   greedy generieren, n=1.

Aus 01 läuft als Vergleich mit: Norm-Profil (BOS ~3100, Rest 61→254) und Induction-Top-5
(L5H5 0,84 …) als Zahlen in der Prosa, nicht neu gerechnet.

## Gesetzt, nicht hergeleitet

> **ANNAHME:** bf16 auf MPS (Numerik-Policy: Rauschgrenze ~0,4 Logits). fp32 nur, wenn Schritt 1
> überrascht.

> **ANNAHME:** Base für Schritte 1–4, `-it` nur in Schritt 5. Induction ist auf Base sauberer,
> die Architektur ist identisch.

> **ANNAHME:** Zufalls-Token-IDs 1000–10000 wie in 01, obwohl Gemmas Vokabular 256k groß ist —
> gleiches Rezept vor optimalem Rezept.

## Erwartung, vorher notiert

Parity: max |Δ| < 0,4, Top-1 gleich. 26 Layer, 8 Heads auf 4 KV-Heads, ~600 Cache-Tensoren.
BOS-Senke wie GPT-2, Normen eine Größenordnung höher (bis ~4000). Induction Heads vorhanden,
eher in der ersten Hälfte des Stacks, Spitzen unter 0,84. `-it` antwortet flüssig und
verweigert die Lockpicking-Anfrage.

## Abschluss

Befund mit Zahlen (3–5 Sätze) → DETAILS neue Sektion „Gemma-2-2B — Befunde aus der Tour";
Dashboard Schritt 7 auf `done`; Plan nach `plans/done/`.
