# DETAILS — Langzeitgedächtnis

Detail-Wissen als Sprungziele, eine Sektion pro Konzept. Alles, was zwischen
Chats nicht verloren gehen soll. Kompakt halten — Substanz, kein Aufblähen.

---

## Themen-Kandidaten & Ranking (Stand 2026-07-10, VORSCHLAG — Henrys Entscheidung steht aus)

Destilliert aus der Themen-Landkarte (Chat 2026-07-10). Kriterien: Passung zu Henrys
Pitch (Steering-Nebeneffekte, methodenkritisch) > Machbarkeit > Methodenkritik-Wert.

**Stand 2026-08-25:** Die Grundform von A+B ist publiziert (SteeringSafety, auf Gemma-2-2B)
→ „Forschungsstand Steering-Nebeneffekte". Das Ranking unten ist damit überholt, wird aber
erst in Fahrplan-Phase 4 (Entscheidung) neu entschieden — bis dahin gelten alle Punkte als Kandidaten.

1. **A+B — Herzstück: Steering-Nebeneffekte am Fall der Refusal Direction.**
   Kontrastive Steering-Vektoren auf gemma-2-2b-it (Refusal nach Arditi 2024 als
   konkreter Fall); Nebeneffekte messen: Perplexity/Qualität neutral, Mini-Benchmark
   vorher/nachher, unbeteiligte Verhaltensweisen, Dosis-Wirkungs-Kurve,
   Random-Vektor-Baseline.
2. **C — Fundament: Activation Patching an Ground Truth** (GPT-2, IOI-Circuit).
   Kalibrierung der Methoden an bekanntem Ergebnis; Lehrbuch-Experiment.
3. **D — Erweiterung: SAE-Feature-Steering vs. kontrastives Vektor-Steering** (Gemma Scope).
   Zwei Herkunftswege für dasselbe Objekt — eine Richtung im Residual Stream: (a) kontrastiv
   direkt aus Aktivierungs-Differenzen gerechnet, ohne SAE (so arbeitet A/B), (b) Decoder-
   Richtung eines SAE-Features (so entstand Golden Gate Claude). Vergleich bei gleicher
   Zielwirkung: dieselbe Richtung? unterschiedliche Nebenwirkungsprofile? Zusatzidee: den
   kontrastiven Vektor in der SAE-Basis zerlegen — dominiert ein Feature oder ist er ein
   Gemisch? Dazu SAE-Kritikpunkte messen (Rekonstruktionsfehler, tote Features).
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

## Modellwahl (Stand 2026-07-10)

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

## GPT-2 small — Befunde aus der Einarbeitung (Stand 2026-09-05)

Quelle: `notebooks/01_explore.ipynb` (TransformerLens 3.5.1, float32 auf MPS; Prosa-Prompt
„The capital of France is Paris. Interpretability researchers", 11 Tokens inkl. BOS). Alles
an einem Prompt gemessen — Orientierung, keine Statistik. Zahlen dort, hier die Essenz.

- **Hook-Namen, gegen 3.5.1 verifiziert:** `blocks.{l}.hook_resid_{pre,mid,post}`,
  `blocks.{l}.attn.hook_{q,k,v,z,attn_scores,pattern}`, `blocks.{l}.hook_attn_out`,
  `blocks.{l}.mlp.hook_{pre,post}`, `blocks.{l}.hook_mlp_out`; außerhalb der Blöcke
  `hook_embed`, `hook_pos_embed`, `ln_final.hook_{scale,normalized}`, `unembed.hook_{in,out}`.
  Nur mit cfg-Flag im Cache (Speicher): `attn.hook_result` (`use_attn_result`),
  `hook_attn_in`, `hook_{q,k,v}_input` (`use_split_qkv_input`), `hook_mlp_in`
  (`use_hook_mlp_in`); einschalten über `model.set_use_*`.
- **`from_pretrained` schreibt die Gewichte um** (Defaults: fold_ln, center_writing_weights,
  center_unembed, fold_value_biases): Logits identisch, einzelne Matrizen nicht mit dem
  HF-Checkpoint vergleichbar, `normalization_type` wird `LNPre`, W_E/W_U getrennt statt tied.
  Rohgewichte: `from_pretrained_no_processing`. Das cfg-Feld `layer_norm_folding` sagt dazu
  nichts aus (liest nur der Bridge-Pfad).
- **BOS als Attention-Senke / massive activation:** Norm des Residual Streams an Position 0
  steigt in Layer 0–2 auf ~3100 und bleibt dort; die übrigen Positionen wachsen von 61
  (nach Layer 0, der mit Abstand am meisten schreibt) auf 254 vor Layer 11; der letzte Layer
  baut BOS auf ~420 ab. Auf dem Prosa-Prompt legen ab Layer 5 alle 12 Heads > 50 % ihres
  Gewichts auf BOS (Layer 7–10 im Mittel > 0,85). Folgen: Position 0 aus jeder Mittelung
  raus; Steering-Stärken nur relativ zur Layer-Norm vergleichbar; Attention-Plots später
  Layer ohne BOS-Spalte lesen.
- **Logit Lens an der letzten Position:** Layer 0–2 geben das aktuelle Token zurück, Layer
  3–5 sind unlesbar („paces", „hips"), Layer 6–10 stabil „ specializing", vor Layer 11
  komplett auf Verben gekippt („ estimate", „ suggest", „ predict"), Layer 11 flacht ab
  (Top-1 von 0,30 auf 0,02). Lens-Wahrscheinlichkeiten zeigen Richtungen, keine kalibrierte
  Konfidenz — nie als Modell-Konfidenz zitieren.
- **Induction Heads reproduziert:** Zufallssequenz (L=20, Seed 0) zweimal hintereinander,
  Score = mittlere Attention auf Offset −(L−1). Top 5: L5H5 0,84 · L7H10 0,83 · L5H1 0,81 ·
  L6H9 0,79 · L7H2 0,74 — exakt die aus der Literatur bekannten Heads. Layer 0–4 durchweg
  < 0,06; Layer 9–10 mehrere unscharfe Heads 0,3–0,6. Loss pro Token: erste Hälfte 12,4
  (schlechter als uniform ≈ 10,8 — das Modell erwartet Englisch), zweite Hälfte 1,10.
- **Erste Ablation (Zero-Ablation auf `attn.hook_z` via `run_with_hooks`):** die 5 Heads
  genullt → Loss zweite Hälfte 1,10 → 3,86; Kontrolle mit 5 Zufalls-Heads aus denselben
  Layern → 1,12. Effekt kausal und spezifisch, aber weit unter 12,4: Redundanz durch die
  unscharfen Heads in Layer 9–11 (per Patching bestätigt → „Activation Patching"). Merksatz: Ablation misst, was ohne ein Bauteil fehlt,
  nicht, was es leistet. Mean-Ablation wäre der sauberere Standard; Zero-Ablation hat hier
  laut Kontrolle keinen Kollateralschaden.

## Activation Patching — Befund am Induction-Setup (Stand 2026-09-16)

Quelle: `notebooks/02_patching.ipynb`. Denoising: corrupt-Lauf [BOS, B, A] (nichts zu kopieren),
an den Positionen der zweiten Hälfte Aktivierungen aus dem clean-Lauf [BOS, A, A] eingesetzt
(A = dieselbe Folge wie in 01, Seed 0). Maß: Restoration = (corrupt − gepatcht) / (corrupt − clean)
auf dem Loss der zweiten Hälfte; clean 1,10, corrupt 12,01. Eine Sequenz, n = 1.

- **Layer-Scan (`hook_resid_pre`):** Layer 0–5 ≤ 0,10; nach Layer 5/6/7 auf 0,28/0,46/0,70 —
  die drei Layer der bekannten Induction Heads; danach Rampe 0,75/0,93/0,99 bis Layer 11,
  `resid_post` 11 = 1,00 (Konstruktionskontrolle). Erwartung „nahe eins ab Layer 8" war falsch:
  30 % der Lücke schließen sich erst in Layer 8–10.
- **Head-Scan (`attn.hook_z`, 144 Einzel-Patches):** kein Head allein über 0,13. Top: L7H2 0,13,
  L6H9 0,12, L9H6 0,11, L9H9 0,11, L7H10 0,09, L10H6 0,09, L5H1 0,08, L11H9 0,08. Die unscharfen
  Heads in Layer 9–11 kopieren also mit, kausal so wirksam wie die kanonischen. Rauschboden
  (Layer 0–4) ±0,03. Negativ: L10H7 −0,13, L11H10 −0,07 — clean-Output schadet im
  corrupt-Kontext; ungeklärt, nicht gedeutet.
- **Rang nach Attention ≠ Rang nach Wirkung:** L5H5 hat den höchsten Induction-Score (0,84),
  aber nur 0,05 Restoration; L7H2 den niedrigsten der fünf (0,74) und die höchste. Head-Auswahl
  über Attention-Muster sortiert anders als die kausale Messung.
- **Gemeinsame Patches:** 5 kanonische Heads 0,60 bei Summe der Einzeleffekte 0,47 (überadditiv);
  dieselben 5 Zufallsheads wie bei der Ablation 0,05; 5 + 4 späte Heads (L9H6, L9H9, L10H6,
  L11H9) 0,86, dort exakt additiv. Rest 14 %: viele kleine Heads, MLPs, Störung durch die
  corrupt-erste Hälfte.
- **Ablation vs. Patching:** die 5 Heads entfernt zerstört 25 % der Lücke (1,10 → 3,86 bei
  Boden 12), eingesetzt stellen sie 60 % wieder her — hinlänglicher als notwendig, weil
  Backup-Heads beim Entfernen kompensieren. Merksätze: Ablation misst Notwendigkeit, Patching
  Hinlänglichkeit; Einzeleffekte addieren sich nicht, Restoration 0,13 heißt nicht „13 % der
  Arbeit". Offen: Loss vs. Logit des richtigen Tokens als Maß (Literatur-Standard: Logit-Diff).

## Steering — Befund GPT-2 small (Stand 2026-09-18)

Quelle: `notebooks/03_steering.ipynb`, Plan `plans/schnuppertour-steering.md`. Richtung d =
Difference-in-Means aus 20 Minimalpaaren (gleicher Satz, nur Stimmungswörter getauscht, Token-Länge
paarweise gleich), Aktivierungen an `hook_resid_pre`, Mittel über Positionen ohne BOS, Einheitslänge.
Dosis c = α / mittlere Residual-Norm des Layers (L2 59, L6 83, L10 165), addiert auf alle Positionen
außer BOS. Zielmetrik: 10 neutrale Prompts („The movie was", …), am letzten Token mittlerer Logit von
8 positiven minus 8 negativen Adjektiven, absichtlich nicht die Wörter der Paare. Nebenwirkung: Loss
auf 10 sachlichen Sätzen. n = 10/10, ein Zufallsvektor — Orientierung, keine Statistik.

- **Lesen:** leave-one-pair-out 20/20 richtig geordnet an Layer 2, 6 und 10. Layer 6: Abstand der
  Set-Mittel 6,2, held-out-Rand im Mittel 5,6 (min 3,3), Streuung innerhalb eines Sets ≈ 4,5 —
  d trägt viel Nicht-Sentiment. cos(d_2, d_6) = 0,79, cos(d_10, d_6) = 0,75: gleiches Konzept,
  nicht derselbe Vektor.
- **Baseline schief:** ohne Eingriff Logit-Differenz +1,89 (0,46 bis 3,90, Hotels oben) — „good",
  „great" sind häufige Tokens. Alle Effekte als Änderung gegen diese Baseline gelesen.
- **Dosis an Layer 6:** S-Kurve, um null ≈ 0,8 Logits pro 0,05 c, Sättigung ab |c| ≈ 0,5; +5,35 bei
  c = 1, −2,75 bei c = −1 (asymmetrisch). Top-5 für „The movie was" bleiben über alle Dosen
  „released, directed, …", kein Adjektiv rückt hinein: die Metrik läuft, die Vorhersage nicht.
- **Loss an Layer 6:** Parabel mit Minimum bei c ≈ −0,12 (−0,02 nats, anekdotisch); +0,19 bei 0,25,
  +0,69 bei 0,5, +2,00 bei 1; negativ +0,29 bei −0,5, +1,36 bei −1. Das Metrik-Plateau liegt dort,
  wo der Loss steigt. Nutzfenster grob |c| < 0,25 (drei Logits für 0,2 nats).
- **Kontrollen:** Zufallsvektor (cos zu d 0,003) auf der Metrik flach (|Δ| ≤ 0,3), Loss +0,34 bei
  0,5 und +1,51/+1,77 bei ±1 — bei voller Dosis erklärt die Norm den Großteil des Schadens, bei 0,5
  zählt die Richtung noch (d: +0,69 bzw. +0,29). Layer 10: +8,40 bei 0,5, +12,82 bei 1, Loss wie
  Layer 6 (+0,63/+1,81), im Bereich keine Sättigung. Layer 2: +2,07 bei 0,5, zurück auf +1,48 bei 1
  (nicht monoton), Loss am höchsten (+0,93/+2,46).
- **Erwartung vs. Befund:** monotone Kurve, flacher Zufallsvektor und stärkerer Layer 10 wie
  erwartet; „Zufall und d bei großem α gleich schlecht" gilt bei |c| = 1, nicht bei 0,5; falsch
  lagen die Norm-Schätzung (100–200 statt 83) und die Baseline-Annahme (≈ 0 statt +1,9).
- **Merksätze:** Dosis nur relativ zur Layer-Norm vergleichbar, und selbst dann ist der Wechselkurs
  Metrik/Loss layerabhängig. Ein Zufallsvektor kontrolliert die Größe des Eingriffs, nicht die
  Spezifität der Richtung. Eine Wortlisten-Metrik kann um 13 Logits laufen, ohne dass sich die
  Top-Vorhersagen ändern — vor einer Vertiefung Metrik gegen Generierung oder KL prüfen. Offen:
  Schritt 9 des Plans (SAE-Decoder-Zeile im selben Sweep) nicht gelaufen.

## Probing — Befund GPT-2 small (Stand 2026-09-18)

Quelle: `notebooks/04_probing.ipynb`, Plan `plans/done/schnuppertour-probing.md`. Dieselben 40
Satzvektoren wie im Steering (20 Minimalpaare, `hook_resid_pre` Layer 6, Mittel ohne BOS). Probe:
`LogisticRegression` (scikit-learn), L2 mit Regler C, Features roh — Standardisieren würde w aus dem
Raum von d nehmen —, leave-one-pair-out (beide Sätze eines Paares raus). Margin = (x_pos − x_neg)·ŵ
mit ŵ auf Länge 1, dieselbe Größe wie beim Steering-Lesecheck. Metrik, Loss, Dosis und Zufallsvektor
wörtlich aus 03. n = 40, ein Seed — Orientierung, keine Statistik.

- **Lesen (C = 1):** held-out 40/40 Sätze, Margin im Mittel 5,56 (min 3,27) gegen 5,64/3,29 für d.
  Control Task (Vorzeichen je Paar gewürfelt, 10 Ziehungen): held-out 19,4/40 (15–25) bei
  Trainingsgenauigkeit 1,0 — die Probe trennt 38 Punkte in 768 Dimensionen immer, Information ist
  nur der Held-out-Abstand dazu.
- **w gegen d über C:** cos(ŵ, d) von 1,000 (C = 1e-5, |w| = 0,0006, linearer Bereich der Sigmoid,
  w ∝ Σ y·x = Mitteldifferenz) über 0,965 (C = 1) bis minimal 0,954 (C = 10), nie unter 0,95.
  Held-out 39–40/40 und Margin 5,5–5,65 bei jedem C — Treffer und Margin können w und d nicht
  unterscheiden. Erwartet war ein Abfall auf 0,5–0,8 bei großem C; die Max-Margin-Richtung dieser
  40 Punkte liegt fast auf d, weil die Paardifferenzen per Konstruktion alle gleich zeigen.
- **Steuern:** w (C = 1) liegt in Metrik und Loss auf d (c = 1: 7,02 vs. 7,24 Logits, 5,81 vs.
  5,99 nats). w⊥ (Anteil von w senkrecht zu d, Länge 0,263 vor Normierung, dann Einheitslänge):
  Metrik −0,5 bei beiden Vorzeichen (Zufallsvektor −0,9/−0,03), Loss +1,88/+1,77 bei ∓1 (Zufall
  +1,78/+1,51). Was die Probe über die Mitteldifferenz hinaus aufnimmt, wirkt wie ein Stoß gleicher
  Größe ohne Richtung.
- **Layer-Scan (C = 1 überall):** Layer 0 held-out 39/40 mit Margin 0,17 — die Embeddings der
  Stimmungswörter reichen zum Lesen. Margin wächst monoton bis 11,71 (min 4,43) an Layer 11,
  relativ zur Residual-Norm an Layer 6 und 10 gleich (0,067 bzw. 0,065). Held-out fällt dagegen von
  40/40 (L6) auf 35/40 (L11): jedes Paar bleibt entlang w geordnet, aber ganze Paare rutschen über
  die Schwelle — die Paardifferenz kürzt den Satzinhalt heraus, der Einzelsatz nicht. cos(ŵ, d)
  fällt von 0,998 (L0) auf 0,86 (L11). Vorbehalt: C fest bei dreifacher Norm, späte Layer effektiv
  schwächer regularisiert; erklärt einen Teil des Kosinus-Abfalls.
- **Erwartung vs. Befund:** Control Task, kleines-C-Ende (cos = 1) und w⊥ ≈ Zufall wie erwartet;
  falsch lag der erwartete Kosinus-Abfall bei großem C; nicht erwartet der Held-out-Abfall in
  späten Layern bei wachsender Margin.
- **Merksätze:** Auf Minimalpaaren sind Probe und Difference-in-Means dieselbe Richtung — der
  Marks-Tegmark-Unterschied (Probe trennt, DiM steuert) ist hier nicht messbar, weil die Paare der
  Probe nichts anderes zum Aufsammeln lassen; ein Test dafür braucht heterogene Daten.
  Held-out-Treffer (Lage der Ebene) und Paar-Margin (Richtung) beantworten verschiedene Fragen,
  nur die Richtung überträgt sich aufs Steuern. Bei Layer-Vergleichen C an die Feature-Skala
  koppeln, sonst vergleicht man Regularisierungsregime.

## Umgebung & Tooling (Stand 2026-08-24)

- Paketverwaltung: **uv** (seit 2026-08-24). `pyproject.toml` deklariert, `uv.lock` pinnt
  den vollständigen Abhängigkeitsbaum und ist committet — das ist die eigentliche
  Reproduzierbarkeitsgarantie, `requirements.txt` hatte nur die 8 direkten Pakete gepinnt.
  `uv sync` baut die Umgebung in `.venv`, alles läuft über `uv run …`.
- **Python 3.13** (`.python-version`); 3.14/3.15 sind Henrys Default, aber zu neu für den
  ML-Stack. Kern-Pins exakt, weil Smoke-Test und MPS-Verifikation dagegen liefen:
  transformer_lens 3.5.1, torch 2.13.0, transformers 5.13.0. Ein Wechsel bei einem davon
  entwertet die Verifikation und verlangt einen neuen Durchlauf von `verify_mps.py`.
- Explorations-Tooling: **jupyter** (Notebooks — bei ~5 min Gemma-Ladezeit gehört das
  Modell in einen laufenden Kernel, nicht in Skript-Starts), **circuitsvis 1.43.3**
  (interaktive Attention-Darstellung in der Notebook-Zelle) und **matplotlib 3.11.2** (seit 2026-09-18, Dosis-Kurven im Steering-Notebook) und
  **scikit-learn 1.9.1** mit scipy 1.18.1 (seit 2026-09-18, logistische Regression für Proben). Bewusst noch nicht drin:
  SAELens — kommt erst mit Kandidat D dazu, bis dahin bläht es nur den Lock auf.
- **TransformerLens** als Kern-Library (Hooks auf alle internen Aktivierungen; festes
  Modell-Set). Alternative für Modelle außerhalb der Liste: nnsight.
- Projekt-Repo: `~/dev/private_repos/mechinterp_xai`. Kursunterlagen und Slides-Quelle
  in iCloud unter `~/Documents/Master/4. Semester/XAI`. Der alte OneDrive-Ordner wird
  nicht mehr angefasst (existiert noch, wird gelöscht).
- Modelle liegen im Standard-HF-Cache (`~/.cache/huggingface/hub`), nicht im Projektordner —
  re-downloadbare Artefakte, gehören weder ins Repo noch in einen Sync-Ordner.
- HF-Account: `henroxx`, Gemma-Lizenz akzeptiert, CLI `hf` (in `~/.local/bin`).
- Papers lesen: `pdftotext -layout` (Homebrew) ist da — Volltext als Text extrahieren,
  dann gezielt Abschnitte lesen. Deutlich billiger als Seitenbilder.
- Gemma-Chat-Format: Prompts für `-it` brauchen `<start_of_turn>user ... <end_of_turn>`-Marker.
- Smoke-Test: `scripts/smoke_test.py` (Laden auf MPS, Generation, run_with_cache). Bestanden
  2026-07-10, nach dem Repo-Umzug erneut 2026-08-24. Gemma-Ladezeit in TransformerLens
  ~4-5 min (Gewichts-Konvertierung, einmal pro Session), GPT-2 ~8 s; Generation auf MPS
  ~2,7 Token/s bei Gemma. Aktivierungs-Cache eines kurzen Prompts: 0,07 GB (629 Tensoren)
  bei Gemma — unkritisch, wächst aber linear mit der Prompt-Länge.
- TransformerLens 3.5.1 warnt beim Laden weiterhin pauschal vor MPS ("silently incorrect
  results", Issue #1178) — die Warnung hängt an der torch-Version, nicht an einer Messung,
  und ist durch `verify_mps.py` widerlegt (→ Numerik-Policy). `TRANSFORMERLENS_ALLOW_MPS=1`
  würde sie unterdrücken; bewusst stehen gelassen.

## Steering — Messprotokoll für Nebeneffekte (Stand 2026-07-11, Planung, Kandidat A/B)

Im Chat erarbeitet 2026-07-11, noch nicht erprobt. Logik: erst die Zielwirkung
quantifizieren, dann Nebenwirkungen auf drei Ebenen — jeweils über die Dosis α
aufgelöst und gegen Kontrollen gerechnet.

- **Zielwirkung:** Refusal-Rate auf festem Prompt-Set (Marker-Phrasen oder kleiner
  Klassifikator). Ohne Zahl für die Wirkung lässt sich kein Preis dagegen abwägen.
- **Ebene 1 — globale Textqualität:** Perplexity auf neutralem Text (z. B. WikiText),
  dazu Degenerationssymptome (Wiederholungen, Inkohärenz).
- **Ebene 2 — unbeteiligte Fähigkeiten:** Mini-Benchmark vorher/nachher (ARC, HellaSwag,
  MMLU-Subset). Auswertung über Logit-Vergleich der Antwortoptionen statt freier
  Generierung — ein Forward-Pass pro Frage; Generieren wäre auf MPS mit ~1 Token/s zäh.
- **Ebene 3 — benachbarte Verhaltensweisen:** Over-/Under-Refusal auf harmlosen Prompts,
  Tonfall, Hedging, Antwortlänge. Hier zeigt sich, ob die Richtung wirklich nur Refusal
  kodiert oder ein ganzes Verhaltensbündel mitzieht.
- **Dosis:** α durchsweepen, Ziel- und Nebenwirkungsmetriken gegen α plotten. Kernfrage:
  Sättigt die Zielwirkung, bevor die Nebenwirkungen anziehen, oder skaliert beides zusammen?
- **Kontrollen:** Zufallsvektor gleicher Norm am selben Layer (wie viel Schaden richtet
  irgendein Eingriff dieser Größe an?), unverwandter Steering-Vektor als zweite Kontrolle,
  derselbe Vektor an verschiedenen Layern.
- **Judge-Skalen (Henrys Einwand, 2026-08-25):** LLM-as-Judge auf 0–100-Skalen täuscht
  Genauigkeit vor — ob eine 65 besser ist als eine 58 aus einem anderen Lauf, ist nicht
  belegt. Wenn wir einen Judge einsetzen: grobe Skala (5–10 Stufen) oder binär, und
  Übereinstimmung mit Menschen als Cohen's κ berichten, wie SteeringSafety es tut.

## Numerik-Policy (Stand 2026-07-10, MPS vs. CPU, bf16)

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

## Forschungsstand Steering-Nebeneffekte (Stand 2026-08-24)

Recherche per Subagent. **Kernbefund: die Grundform des geplanten Experiments ist
publiziert.** Ein eigener Beitrag muss auf der Metrik-, Dosis- und Kontroll-Ebene liegen,
nicht in der Idee „Nebenwirkungen messen".

- **SteeringSafety** (Siu et al., arXiv:2509.13450v3, ICML 2026, PMLR 306) — **im Volltext
  gelesen 2026-08-25**, PDF liegt in den Kursunterlagen. Gemma-2-2B-IT, Llama-3.1-8B,
  Qwen-2.5-7B; 5 Methoden (DIM, ACE, CAA, PCA, LAT); gesteuert wird auf **drei** Perspektiven
  (Refusal, Halluzination, Bias), gemessen wird auf **allen neun** / 18 Datensätzen.
  Zwei Metriken: *Effectiveness* (Verbesserung auf der Ziel-Perspektive, normiert auf den
  verbleibenden Headroom 1−y) und *Entanglement* (RMS der **absoluten**, bewusst
  un-normierten Drift auf allen anderen Perspektiven).
  **Befunde:** Entanglement ist am höchsten bei Social Behaviors (Sycophancy, Brand Bias,
  Anthropomorphismus, User Retention — bis 76 % Degradation) und Normative Judgment
  (Moral bis 26 %); **Reasoning bleibt robust (<2 %)**. Alles hängt am Tripel
  (Methode, Modell, Perspektive), nicht an einem der drei. Kontraintuitiv: Jailbreaking
  macht Modelle *nicht* durchgehend toxischer — bei Llama schwer, bei Qwen kaum.
  Conditional Steering (CAST-Gating) ist meist eine Pareto-Verbesserung, beseitigt
  Entanglement aber nicht.
  **Fünf Punkte, die für dieses Projekt entscheidend sind:**
  1. Die Refusal-Intervention ist **Unterdrückung** von Refusal („adversarial refusal
     ablation", Orthogonalisierung gegen den Refusal-Vektor), nicht additives Steering.
     Die umgekehrte Richtung wird **bewusst nicht** untersucht: Refusal-Induktion sättigt
     in pauschales Verweigern, und die Baseline-ASR liegt schon unter 0,05.
  2. **Gemma-2-2B ist beim Refusal-Steering das schwächste der drei Modelle** — „ACE und DIM
     überschreiten 50 % Effectiveness auf jedem Modell außer Gemma-2-2B"; DIM/Refusal/Gemma
     hat in Tabelle 2 gar keinen Wert.
  3. **Die Dosis-Achse ist grob und wird nie als Kurve berichtet:** Suchraster ist
     Layer (25.–80. Perzentil der Tiefe, Schritt 2) × Koeffizient (**ganze Zahlen −3…3**),
     daraus wird *ein* bestes Paar per Validierung gewählt. Es gibt im Paper **keine
     Dosis-Wirkungs-Kurve**.
  4. **Ein KL-Filter entscheidet mit, was überhaupt gemessen wird:** jedes (Layer,
     Koeffizient)-Paar mit durchschnittlicher KL-Divergenz > 0,1 auf den Last-Token-Logits
     (auf Alpaca) wird verworfen. Ohne den Filter („NoKL") verdoppelt sich Entanglement
     „oft mehr als". Der Filter siebt also genau die Konfigurationen aus, die das Modell
     kaputtmachen — eine Schwellenwert-Entscheidung, die das Ergebnis mitbestimmt.
  5. **Keine Textqualitäts- oder Kohärenz-Metrik.** Alle Capability-Messungen sind
     Benchmark-Aufgaben (ARC-C, GPQA, LongBench, TruthfulQA), per Substring-Matching oder
     LLM-Judge ausgewertet. KL-Divergenz wird nur als *Filter* benutzt, nicht als Ergebnis
     berichtet.
  **Explizite Einladung zur Anschlussarbeit** (Abschnitt 5): sie führen Entanglement
  hypothetisch auf Superposition zurück, markieren das ausdrücklich als *nicht* etabliert
  und schreiben, dass „future work with sparse autoencoders or related circuit-level tools
  could investigate individual cases, and our benchmark is designed to make those targeted
  follow-ups tractable". Das trifft Kandidat D.
- **Style Modulation Heads** (Izawa et al., arXiv:2603.13249) — der methodisch wichtigste
  Befund: **MMLU bleibt innerhalb 0,5 % stabil, auch wenn die Textkohärenz schon zerfallen
  ist**; Perplexity sagt den Qualitätsverfall nicht vorher (fällt teils in beide
  Steering-Richtungen). Kohärenz gemessen per LLM-as-Judge (0–100: Klarheit, Halluzination,
  Konfusion) auf Held-out-Set. Außerdem: Degradation ist graduell zu häufigen Verhaltens-
  weisen, **abrupter Kollaps** zu OOD-Richtungen; Verstärkung und Suppression asymmetrisch.
  Gemessen auf 7–8B für Persona-Traits — für 2B und Refusal offen.
- **Forecasting Side Effects** (Ong et al., arXiv:2608.11227) — Cross-Effect-Matrix über 67
  Verhaltensweisen: Nebeneffekte sind häufig, strukturiert und **asymmetrisch** (A→B ≠ B→A),
  nicht über Similarity-Heuristiken erklärbar, aber aus ungesteuerten Repräsentationen
  vorhersagbar.
- **Steering Safely or Off a Cliff?** (Goyal & Daumé, arXiv:2602.06256) — zerlegt Spezifität
  in *general* (Fluency), *control* (verwandte Eigenschaften), *robustness*. Steering hält
  die ersten zwei, **scheitert konsistent an robustness**: Over-Refusal-Reduktion erhöht
  Jailbreak-Anfälligkeit.
- **Refusal-Geometrie** (Joad et al., arXiv:2602.02132) — 11 Refusal-Kategorien liegen auf
  geometrisch verschiedenen Richtungen, aber Steering entlang *jeder* erzeugt nahezu
  identische Refusal↔Over-Refusal-Trade-offs. Ein gemeinsamer 1D-Regler; die Richtungen
  unterscheiden *wie*, nicht *ob* verweigert wird.
- **Perfect Detection, Failed Control** (Galeone et al., arXiv:2606.24952) — primär
  **Gemma-2-2b-it**: Cosine-Similarity sagt Steerability nicht vorher (Detektionsrichtung
  steht 83° zur Refusal-Richtung, trotzdem steuerbar nach Rotation).
- **Layer-Wahl** (Billa, arXiv:2604.15557) — trainingsfreies Logit-Lens-Kriterium prognostiziert
  Steering-Wirksamkeit (ρ ≈ 0,9) und Layer-Wahl; die übliche „mittlere Schicht"-Heuristik ist
  **unterlegen**. Auf Gemma-2-2B demonstriert.
- **Mechanismus** (Cheng et al., arXiv:2604.08524) — Steering-Vektoren wirken fast nur über
  den OV-Circuit, kaum über QK; sie lassen sich um 90–99 % sparsifizieren, und die Zerlegung
  ist semantisch lesbar, auch wenn der Vektor selbst es nicht ist.
- **Abliteration-Nebeneffekte** (Young, arXiv:2512.13655) — **GSM8K ist die empfindlichste
  Metrik** (bis −18,8 pp), deutet auf Overlap von Refusal-Repräsentation und mathematischem
  Reasoning. Fafuła (arXiv:2607.17427): Off-Target-Effekte gehen bei verschiedenen
  Modellfamilien teils in **gegensätzliche** Richtungen.
- **Vorgeschichte, weiter gültig:** Tan et al. (arXiv:2407.12404) — Steerability ist
  überwiegend eine Eigenschaft des *Datensatzes*, nicht des Modells, und OOD brittle.
  Braun et al. (arXiv:2505.24859) — bei freier Generierung statt Multiple Choice erzeugt hohe
  Steering-Stärke degenerative Repetition und Halluzinationen.

**Keine Standard-Evaluation existiert.** Am nächsten dran: SteeringSafety als Suite,
AxBench für Effektivität, die Spezifitäts-Taxonomie aus 2602.06256 als Rahmen. Übliche
Instrumente: Refusal-Rate (AdvBench/HarmBench/JailbreakBench) · Over-Refusal (XSTest,
OR-Bench) · Capability (MMLU, GSM8K, HellaSwag, IFEval) · Qualität (PPL, Distinct-2,
LLM-as-Judge) · Kontrollen (norm-matched Random-Vektoren, pro Layer neu skaliert, typisch
~5 Ziehungen pro echtem Vektor).

**Offene Lücken, die mit diesem Compute erreichbar sind:**
1. **Metrik-Validierung statt Metrik-Anwendung** — hält der „MMLU/PPL sehen den Kollaps
   nicht"-Befund auf 2B und für Refusal? Mehrere Metriken auf derselben Dosis-Achse,
   kreuzkorreliert.
2. **Dichte Dosis-Auflösung** (15–20 Stufen statt der üblichen 3–5) — gibt es eine
   Bruchstelle, und liegt sie vor oder nach dem Erreichen der Zielwirkung?
3. **Ehrliche Kontroll-Buchführung** — Refusal-Richtung / norm-matched random /
   orthogonalisierte Richtung als drei parallele Dosis-Kurven. Trennt „direction-specific"
   von „irgendein großer Vektor schüttelt das Modell".
4. **Entanglement auf kleinem Maßstab** — ist ein 2B-Modell überhaupt entangled genug, dass
   man Nachbarverhalten sieht, oder ist die Repräsentation zu grob?

Nicht als Beitrag geeignet (gelöst): Refusal-Richtung finden, abliterieren und ASR berichten,
eine neue Steering-Methode vorschlagen.

## SAE-Kritik — Stand 2026-08-24

- **AxBench** (Wu et al., arXiv:2501.17148, ICML 2025) — auf **Gemma-2-2B**, ~500 Konzepte:
  beim Steering schlägt **Prompting alles**, SAEs sind nicht konkurrenzfähig; bei Concept
  Detection gewinnt **difference-in-means**. Gegenposition (arXiv:2605.31183): mit
  aufwendiger supervidierter Feature-Selektion erreichen SAEs LoRA-Nähe. Faire Formulierung:
  out-of-the-box verlieren SAEs, mit erheblichem Zusatzaufwand nicht mehr.
- **Sparse Probing** (Kantamneni et al., arXiv:2502.16681) — kein Ensemble aus SAE+Baselines
  schlägt konsistent ein Ensemble nur aus Baselines.
- **Feature Absorption** (Chanin et al., arXiv:2409.14507, NeurIPS 2025) — auf **Gemma-2-2b
  mit Gemma-Scope-SAEs**: ein Latent für „beginnt mit E" feuert bei „Elephant" nicht, die
  Information ist in ein spezifischeres Latent absorbiert. **Absorption steigt mit Sparsity
  und Breite** — größere SAEs lösen es nicht. Bester Reproduktions-Kandidat mit kleinem Compute.
- **L0 ist kein freier Parameter** (Chanin & Garriga-Alonso, arXiv:2508.16560) — zu niedriges
  L0 mischt korrelierte Features, zu hohes erzeugt degenerierte Lösungen. Die meisten
  gebräuchlichen SAEs haben zu niedriges L0 — betrifft die Gemma-Scope-„canonical"-Wahl (L0≈100).
- **Seed-Instabilität** (arXiv:2606.12138) — differenzierter als oft behauptet: stabile
  Features tragen fast das ganze Signal, instabile sind Low-Frequency-Surface-Form-Trigger in
  reproduzierbaren Unterräumen. Also Basis-Ambiguität, nicht Rauschen.
- **Benchmarks selbst unzuverlässig** (Chanin, arXiv:2605.18229) — SAEBench-Metriken TPP und
  SCR sollten nicht mehr zur SAE-Evaluation verwendet werden.
- **Position, die am meisten trägt** (arXiv:2506.23845): SAEs zur *Entdeckung unbekannter*
  Konzepte einsetzen, nicht zum Handeln auf bekannten. Bei bekanntem Zielkonzept verlieren
  sie gegen Baselines — genau der Fall bei Steering auf ein spezifiziertes Verhalten.
- **Rahmen für Methodenkritik allgemein:** „The Dead Salmons of AI Interpretability"
  (arXiv:2512.18792) — Identifizierbarkeit, False-Discovery-Rates, fehlende
  Unsicherheitsquantifizierung über Feature Attribution, Probing, SAEs und Causal Analysis
  hinweg; Vorschlag, Erklärungen gegen explizite Alternativhypothesen zu testen.

Mit kleinem Compute reproduzierbar (fertige Gemma-Scope-SAEs, kein Training): Feature
Absorption · SAE-Steering vs. difference-in-means auf einem Konzept · **SAE-Rekonstruktion
vs. norm-matched Random-Perturbation im KL** (billig, aussagekräftig, und methodisch
identisch zur Random-Vektor-Kontrolle beim Steering — verbindet beide Projektteile).
Nicht machbar: Seed-Instabilität (braucht mehrere SAE-Trainingsläufe), L0-Studien über
SAE-Familien.

## Tooling-Realität (Stand 2026-08-24)

Recherchiert und teils lokal verifiziert. Korrigiert mehrere ältere Annahmen.

- **TransformerLens: aktuell 3.8.0** (installiert: 3.5.1). Hohe Release-Kadenz.
  **Gemma-3 wird unterstützt** (Architektur-Adapter im Quellcode, Configs für 270m–27b) —
  die alte Annahme „Support offen" ist überholt.
- **`transformers` v5 hat das Gemma-Embedding-Scaling geändert.** TransformerLens bietet
  `enable_compatibility_mode()` für die alte `HookedTransformer`-Numerik. Echter
  Reproduzierbarkeits-Stolperstein: Tutorials und Papers auf TL 1.x/2.x liefern ohne diesen
  Schalter andere Zahlen. Muss bewusst entschieden und dokumentiert werden.
- **MPS**: lokal geprüft — macOS 26.6.1, torch 2.13.0, bf16-Matmul auf MPS funktioniert.
  Die bekannte „bf16 nicht auf MPS"-Fehlerklasse betrifft M1/Intel, nicht diesen Stack.
  Es gibt aber eine gemeldete „MPS gebaut, aber nicht verfügbar"-Klasse auf macOS 26 mit
  torch 2.9–2.12 (pytorch#167679, #177819). **Nicht auf eine andere torch-Version wechseln,
  ohne neu zu messen.**
- **SAELens 6.51.1** (Stand 2026-09-18, nicht installiert) — Pins `transformer-lens>=2.16.1`,
  `transformers<6`: mit unserem TL 3.5.1 verträglich, `uv add` würde vermutlich nichts
  hochziehen (nicht ausprobiert). 6.x hat Breaking Changes gegenüber der 3.x/4.x-API in vielen
  Tutorials. Gemma-2-2b-Releases: `gemma-scope-2b-pt-res{,-canonical}`, `-mlp`, `-att`,
  `-transcoders`. Laden über
  `SAE.from_pretrained(release="gemma-scope-2b-pt-res-canonical", sae_id="layer_12/width_16k/canonical")`.
- **Fertige SAE-Gewichte ohne SAELens** (Stand 2026-09-18) — ein SAE sind vier Tensoren
  (W_enc, b_enc, W_dec, b_dec); die Feature-Richtung zum Steern ist eine Zeile von W_dec.
  GPT-2 small: `jbloom/GPT2-Small-SAEs-Reformatted` auf HF, pro Layer ein Ordner
  `blocks.{l}.hook_resid_pre/` mit `cfg.json` + `sae_weights.safetensors`; d_sae 24 576 (32×),
  ReLU + L1 (λ 8e-5), OpenWebText, Kontext 128. Zum Laden reichen `huggingface_hub` +
  `safetensors`, beide schon im Lock. Neuronpedia-ID für Layer 6: `6-res-jb`. SAELens braucht
  man erst, um den Encoder auf Aktivierungen laufen zu lassen (welche Features feuern).
- **Gemma-Scope-Downloadgrößen** (pro einzelner SAE): 16k ≈ 302 MB · 65k ≈ 1,21 GB ·
  1M ≈ 19,3 GB. **Gesamtrepo ≈ 657 GB — nie klonen, immer einzelne Pfade.** „canonical"
  = L0 am nächsten zu 100 (Layer 12/16k → L0 82). Nachfolge-Architekturen für Gemma-2-2b
  verfügbar: Transcoder, Matryoshka-SAEs (32k, L0 40), Cross-Layer-Transcoder. Crosscoder
  nicht gefunden.
- **Gemma Scope 2** (DeepMind 12/2025) deckt **nur Gemma 3** ab, nicht Gemma 2. Die
  Gemma-2-Wahl bleibt vertretbar, muss aber als „eine Generation zurück, dafür besser
  dokumentiert" begründet werden.
- **Neuronpedia**: öffentliche Lese-API ohne Key (`/api/feature/{model}/{sae}/{idx}`),
  Volldaten-Exports über S3, Python-Paket `neuronpedia`. Im Browser ohne eigenes Compute:
  Feature-Dashboards für gemma-2-2b, semantische Suche, **Steering** (100/Stunde) und
  **Attribution-Graphen für Gemma-2-2B**.
- **circuit-tracer** (Anthropic, open source seit 05/2025): Gemma-2-2B ist first-class
  supported. **Zwei harte Einschränkungen:** pinnt `transformers<=4.57.3` (hier: 5.13.0) →
  zwingend eigenes venv; und die Device-Wahl ist hart auf cuda/cpu verdrahtet, **kein
  MPS-Pfad** → läuft hier auf CPU, Machbarkeit unbelegt. Pragmatischer Weg für
  Attribution-Graphen: die Neuronpedia-UI.
- **uv**: für diesen Stack unproblematisch (die bekannten Probleme betreffen CUDA-Indizes
  unter Linux/Windows; auf macOS kommt torch schlicht von PyPI). Bug-Klasse zum Vormerken:
  gelegentlich falsche Plattformerkennung (uv#13512), `uv add torch` scheitert wo
  `uv pip install torch` läuft (uv#5182).

## Lehrmaterial (Stand 2026-08-24)

- **ARENA, Chapter 1** — https://learn.arena.education/chapter1_transformer_interp/
  (die alte Streamlit-URL leitet dorthin um). 12 Übungssätze; nach 1.1/1.2 sind die
  übrigen prerequisite-frei. Direkt relevant: **1.2 Intro to Mech Interp (TransformerLens,
  Hooks)**, **1.4.1 IOI & Causal Interventions**, **1.3.2 Function Vectors & Model Steering**.
  Neuer als ARENA 3.0: 1.3.4 Activation Oracles, 1.4.2 SAE Circuits.
- **Nanda, „How To Become A Mechanistic Interpretability Researcher"** (09/2025,
  Alignment Forum) — drei Stufen: Grundlagen breadth-first ≤1 Monat → Mini-Projekte 1–5 Tage
  → Sprints 1–2 Wochen. Nennt ARENA 1.2 und 1.4.1 als essenziell und empfiehlt ausdrücklich,
  **mit GPT-2 small anzufangen**.
- **Nandas annotierte Paper-Liste** („An Extremely Opinionated Annotated List…", v2) — sagt
  pro Paper, was tief zu lesen und was zu überfliegen ist.
- **TransformerLens `demos/Main_Demo.ipynb`** plus die Doku, insbesondere
  `migrating_to_v3.html` — praktisch alle älteren Tutorials nutzen die 1.x/2.x-API.
- **„200 Concrete Open Problems"** (Nanda 12/2022): als Ideengeber teilweise brauchbar,
  **als Projektquelle veraltet** — vor SAE-Welle, Gemma Scope, Circuit Tracing und der
  aktuellen Kritik-Literatur.
