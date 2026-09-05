# DETAILS — Langzeitgedächtnis

Detail-Wissen als Sprungziele, eine Sektion pro Konzept. Alles, was zwischen
Chats nicht verloren gehen soll. Kompakt halten — Substanz, kein Aufblähen.

---

## Themen-Kandidaten & Ranking (VORSCHLAG — Henrys Entscheidung steht aus)

Destilliert aus der Themen-Landkarte (Chat 2026-07-10). Kriterien: Passung zu Henrys
Pitch (Steering-Nebeneffekte, methodenkritisch) > Machbarkeit > Methodenkritik-Wert.

1. **A+B — Herzstück: Steering-Nebeneffekte am Fall der Refusal Direction.**
   Kontrastive Steering-Vektoren auf gemma-2-2b-it (Refusal nach Arditi 2024 als
   konkreter Fall); Nebeneffekte messen: Perplexity/Qualität neutral, Mini-Benchmark
   vorher/nachher, unbeteiligte Verhaltensweisen, Dosis-Wirkungs-Kurve,
   Random-Vektor-Baseline.
2. **C — Fundament: Activation Patching an Ground Truth** (GPT-2, IOI-Circuit).
   Kalibrierung der Methoden an bekanntem Ergebnis; Lehrbuch-Experiment.
3. **D — Erweiterung: SAE-Feature-Steering vs. Vektor-Steering** (Gemma Scope) +
   SAE-Kritikpunkte messen (Rekonstruktionsfehler, tote Features).
4. **E — Bonus: Base-vs-IT-Diffing** (existiert die Refusal-Richtung im Base-Modell?).
5. **F — nur Ausblick: Attribution Graphs / Circuit Tracing** (Tooling-Aufwand zu hoch).

Roter Faden der Abhandlung (Vorschlag): „Wie verlässlich sind Mech-Interp-Methoden?
Kalibrierung an Ground Truth (C) → offene Frage (A/B) → Methodenvergleich (D)",
MPS-Verifikation als Prolog.

Themen-Landkarte dahinter (7 Blöcke): Theorie (Superposition, Linear Representation
Hypothesis, Circuits) / beobachtende Methoden (Probing, Logit Lens, Attention-Analyse) /
SAEs + SAE-Skepsis seit 2025 / kausale Interventionen (Patching, Ablation, Steering,
Model Editing) / Circuit-Analyse (IOI, ACDC, Attribution Graphs) / Safety-Anwendungen
(Persona Vectors, Emergent Misalignment, Introspection) / Tooling (TransformerLens,
nnsight, SAELens, Neuronpedia).

## Modellwahl

**Haupt-Modell: `google/gemma-2-2b` + `google/gemma-2-2b-it`** (entschieden 2026-07-10).
Begründung: öffentliche SAE-Suite (Gemma Scope, alle Layer) + beste Neuronpedia-Abdeckung
+ TransformerLens/SAELens-Support + Chat-Variante für Steering-Experimente + läuft
komfortabel auf Henrys Hardware (MacBook Air M4, 24 GB RAM — bf16 ≈ 5 GB pro Variante).
Steering-/Refusal-Literatur nutzt Gemma-2 ebenfalls → direkte Vergleichbarkeit.
`it` = instruction-tuned (Chat-Verhalten, Refusals); Base als Vergleichsobjekt
(Model-Diffing: was hat das Finetuning intern verändert?).

**Zweitmodell: `openai-community/gpt2`** (GPT-2 small, ~0,5 GB): klassische
handverifizierte Circuits (IOI, Induction Heads) als Ground Truth, um Methoden
kritisch zu testen.

Optional später: Gemma-3-4B-it als Transfer-Test („replizieren Befunde auf dem
Nachfolger?"). Achtung: kein Gemma Scope für Gemma 3; TransformerLens-Support verifizieren.

Größere Modelle (9B-Klasse) verworfen: bf16-Gewichte ≈ 18 GB → beim Aktivierungs-Caching
(run_with_cache hält alle Zwischenaktivierungen) permanent am RAM-Limit, zähes Arbeiten.

## Umgebung & Tooling

- venv: `mechinterp_xai/.venv`, **Python 3.13** (3.14 ist Broses Default, aber zu neu
  für den ML-Stack). Versionen gepinnt in `requirements.txt`: transformer_lens 3.5.1,
  torch 2.13.0, transformers 5.13.0.
- **TransformerLens** als Kern-Library (Hooks auf alle internen Aktivierungen; festes
  Modell-Set). Alternative für Modelle außerhalb der Liste: nnsight.
- Modelle liegen im Standard-HF-Cache (`~/.cache/huggingface/hub`) — bewusst NICHT im
  OneDrive-Projektordner (Sync/Auslagerungs-Risiko; Modelle sind re-downloadbare Artefakte).
- HF-Account: `henroxx`, Gemma-Lizenz akzeptiert, CLI `hf` (in `~/.local/bin`).
- Gemma-Chat-Format: Prompts für `-it` brauchen `<start_of_turn>user ... <end_of_turn>`-Marker.
- Smoke-Test: `scripts/smoke_test.py` (Laden auf MPS, Generation, run_with_cache). Bestanden
  2026-07-10. Gemma-Ladezeit in TransformerLens ~3,5 min (Gewichts-Konvertierung, einmal
  pro Session); Generation auf MPS ~1 Token/s — für Interp-Workloads (einzelne Forward-
  Passes) okay.

## Numerik-Policy (MPS vs. CPU, bf16)

Anlass: TransformerLens warnt vor "silently incorrect results" auf MPS
(Issue #1178: IOI-Logit-Diff kippte auf PyTorch 2.8 das Vorzeichen).
Selbst gemessen 2026-07-10 mit `scripts/verify_mps.py` (torch 2.13):

- **GPT-2, fp32: CPU und MPS exakt identisch** (Logit-Diff 0.0000, IOI-Diff beide +3.172,
  kein Sign-Flip) → der Issue-Bug ist in torch 2.13 behoben, **MPS ist freigegeben**.
- **Gemma-2-2b-it, bf16: Abweichungen ~1-2 % der Logit-Skala** (0.19–0.38 bei Skala 20–26),
  Residual-Diffs 4–12 bei Aktivierungsmagnituden 330–3900 (= 0,3–1 % relativ) → reines
  bf16-Rundungsrauschen, kein Backend-Bug. Alle Top-1-Vorhersagen identisch.

Konsequenzen:
1. Arbeiten auf MPS ist okay.
2. **bf16-Rauschgrenze: Effekte < ~0,4 Logits bei Gemma sind nicht interpretierbar** —
   sensible Messungen brauchen Baselines/Wiederholungen oder gezielt fp32.
3. Befunde vor Aufnahme in die Abhandlung einmal auf CPU gegenchecken (`verify_mps.py`
   als Vorlage).
4. Gemma-2-Eigenheit: sehr große Residual-Aktivierungen (bis ~4000, wächst über Layer) —
   relevant für alles, was absolute Schwellwerte benutzt.
