# DETAILS — Langzeitgedächtnis

Detail-Wissen als Sprungziele, eine Sektion pro Konzept. Alles, was zwischen
Chats nicht verloren gehen soll. Kompakt halten — Substanz, kein Aufblähen.

---

## Themen-Kandidaten & Ranking (Stand 2026-07-10, überholt durch die Entscheidung vom 2026-09-19)

Destilliert aus der Themen-Landkarte (Chat 2026-07-10). Kriterien: Passung zu Henrys
Pitch (Steering-Nebeneffekte, methodenkritisch) > Machbarkeit > Methodenkritik-Wert.

**Stand 2026-08-25:** Die Grundform von A+B ist publiziert (SteeringSafety, auf Gemma-2-2B)
→ `details/forschungsstand.md`. Das Ranking unten ist damit überholt, wird aber
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
  Top-Vorhersagen ändern — vor einer Vertiefung Metrik gegen Generierung oder KL prüfen. Der offene
  Schritt 9 (SAE-Decoder-Zeile im selben Sweep) ist als Station 5 nachgeholt → „SAE — Befund GPT-2 small".

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

## Gemma-2-2B — Befunde aus der Tour (Stand 2026-09-18)

Quelle: `notebooks/05_gemma.ipynb` (TL 3.5.1, bf16 auf MPS, `google/gemma-2-2b`, derselbe
Prosa-Prompt wie in 01, 11 Tokens inkl. BOS). Ein Prompt, eine Zufallssequenz, ein Seed —
Orientierung, keine Statistik. Zahlen dort, hier die Essenz.

- **Parity gegen HuggingFace gemessen:** max |Δ| 0,375 bei Logit-Skala 28,6 (Mittel 0,055),
  Top-1 identisch, Tokenisierung identisch. TL rechnet dasselbe. Aber: bei bf16 warnt TL zu
  Recht vor `from_pretrained`, weil das Einfalten der Normen in float32 rechnet und danach nach
  bf16 zurückrundet — ein Teil der 0,375 ist Verarbeitung, nicht Backend. Messungen nah an der
  Rauschgrenze (→ „Numerik-Policy") brauchen fp32 oder `from_pretrained_no_processing`.
- **Architektur:** 26 Layer, d_model 2304, 8 Query- auf 4 KV-Heads (GQA), d_head 256, d_mlp 9216,
  Vokabular 256k. RMSNorm **vor und nach** beiden Sublayern → zusätzliche Hooks `ln1_post.*`,
  `ln2_post.*`; Gated MLP → `mlp.hook_pre_linear`; Rotary → `attn.hook_rot_{q,k}`. Softcap 50 auf
  Attention-Scores, 30 auf Logits. Wegen des Logit-Softcaps schaltet TL `center_unembed` selbst
  ab (nicht verschiebungsinvariant) — Warnung beim Laden ist erwartet.
- **Cache-Kosten:** 629 Tensoren, 44 MB für 11 Tokens ≈ **4 MB pro Token**. Ein Prompt von ein
  paar hundert Tokens ist ein Gigabyte Cache; bei Sweeps einplanen.
- **BOS-Senke anders als bei GPT-2:** Norm an Position 0 wächst **stetig über den ganzen Stack**
  (199 → 3039) statt früh auf ein Plateau zu springen; übrige Positionen 86 → 563. Attention auf
  BOS liegt in **jedem** Layer bei 0,5–0,9, auch in Layer 0 (GPT-2 erst ab Layer 5). Folge wie
  dort: Position 0 aus Mittelungen raus, Steering-Dosis pro Layer an der Norm skalieren.
- **Induction Heads stärker als in GPT-2:** L6H2 0,89 · L15H0 0,85 · L18H6 0,77 · L6H3 0,72 ·
  L21H5 0,58. Loss auf der Zufallssequenz 16,29 (erste Hälfte) → 0,76 (zweite). Die erste Hälfte
  liegt über dem Blindwert ln(256000) = 12,45 — dasselbe Muster wie bei GPT-2 (12,4 vs. 10,8).
- **Erwartung vs. Befund:** falsch lag die Erwartung, GQA würde die Scores drücken und die Heads
  in die erste Stack-Hälfte legen. Tatsächlich übertrifft der beste Head GPT-2s 0,84, und starke
  Heads sitzen auch bei Layer 15, 18 und 21 — ein Paar früh, Nachzügler über die zweite Hälfte.
- **`-it` (n = 1, Anekdote):** Chat-Marker `<start_of_turn>`/`<end_of_turn>` sind Einzel-Tokens,
  Refusal-Verhalten vorhanden. Die harmlose Frage nach „what a transformer is" beantwortete das
  Modell über **elektrische** Transformatoren — ohne Kontext gewinnt die Grundbedeutung. Warnung
  für jede Prompt-Formulierung in späteren Messungen.
- **Speicher:** Laden dauert 128 s (Base) bzw. 174 s (`-it`); nach dem zweiten Laden standen
  24 GB auf MPS, weit mehr als zwei bf16-Kopien brauchen — entweder hielt ein Traceback das erste
  Modell fest oder die float32-Puffer der Gewichtsverarbeitung. **Zwischen zwei Modellen den
  Kernel neu starten**, `del` + `empty_cache()` genügt nicht verlässlich.

## SAE — Befund GPT-2 small (Stand 2026-09-18)

Quelle: `notebooks/06_sae.ipynb`, Plan `plans/done/schnuppertour-sae.md`. SAE aus
`jbloom/GPT2-Small-SAEs-Reformatted`, Ordner `blocks.6.hook_resid_pre` (d_sae 24 576, 32×,
OpenWebText, Kontext 128), geladen mit `huggingface_hub` + `safetensors`, ohne SAELens.
Das Release deckt **alle zwölf Schichten** ab (`blocks.0`–`blocks.11` je `hook_resid_pre`, dazu
`blocks.11.hook_resid_post`), 144 MiB pro Schicht, je mit `cfg.json` und `sparsity.safetensors`;
ein Schichtwechsel ist nur ein anderer `HOOK`-String (geprüft 2026-09-19 gegen die HF-API).
Haken: die Feature-Indizes sind pro Schicht unabhängig trainiert, also nicht über Schichten
hinweg identifizierbar — eine Feature-Suche läuft pro Schicht neu. Setup,
Metrik, Dosis und Zufallskontrolle unverändert aus Station 2 (Norm 83, Baseline +1,89 exakt
reproduziert).

- **Encoder-Konvention gemessen statt geraten:** `cfg.json` sagt nichts dazu. Mit b_dec-Abzug
  (`relu((x − b_dec) @ W_enc + b_enc)`) erklärte Varianz 0,950 bei L0 44,2; ohne Abzug −43,1 bei
  L0 1622. Decoder-Zeilen haben Norm 1,0000 — eine Zeile ist ohne Umrechnung eine Steering-Richtung.
- **Feature selbst gefunden, Label extern bestätigt:** Kriterium vorab (feuert in ≥ 12/20 Sätzen des
  einen Sets, ≤ 5/20 des anderen, darunter größte Differenz) → Feature 986 (18/20 pos, 2/20 neg) und
  15262 (13/20 neg, 0/20 pos). Neuronpedia `6-res-jb`: „positive feedback or compliments" bzw.
  „negative words or phrases describing … undesirable situations". Ohne Feuer-Kriterium gewinnt
  Feature 787, das in allen 40 Sätzen feuert und nur über die Höhe trennt — die Auswahlregel ist
  hier der eigentliche Befund.
- **Sentiment ist im SAE keine Achse:** cos(986, 15262) = 0,049, praktisch orthogonal. cos zu d
  +0,360 bzw. −0,507; die Projektion von d (Einheitslänge) auf die von beiden Zeilen aufgespannte
  Ebene hat Länge 0,637 — zwei von 24 576 Features tragen rund 40 % von d im Quadrat.
- **Dosis-Wirkung:** d ist pro Dosis stärker und sättigt früher (+4,74 bei c = 0,5, +5,35 bei c = 1),
  Feature 986 steigt noch (+3,23 bzw. +4,21), Feature 15262 wirkt spiegelbildlich (−2,71 bei c = 0,5).
- **Gleiche Wirkung statt gleicher Dosis** (interpoliert auf +2,00 Logits): d bei c = 0,139 für
  +0,077 nats, Feature 986 bei c = 0,250 für +0,069 nats — bei n = 10 Sätzen ein Gleichstand.
  Feature 15262 braucht +0,421 nats, das Fünffache. Der Zufallsvektor erreicht +2,00 nie.
- **Erwartung vs. Befund:** richtig lagen schwächere Wirkung pro Dosis, alle Kosinus deutlich unter 1
  und die nicht-antiparallelen Features. **Falsch** lag die Erwartung, die sparse „monosemantische"
  Richtung sei der sauberere Eingriff — bei gleicher Wirkung ist sie einmal gleichauf und einmal
  klar teurer. Ein SAE-Feature ist hier kein besserer Hebel, nur ein anders hergeleiteter.
- **Grenzen:** n = 20 Paare / 10 Prompts / 10 Sätze, ein Layer, ein SAE, eine Wortlisten-Metrik —
  Orientierung, keine Statistik. Der Gleichstand 0,069 vs. 0,077 nats liegt innerhalb dessen, was
  dieses n auflösen kann.

## Lesen gegen Steuern — Anker-Reproduktion (Stand 2026-09-19)

`notebooks/07_reading_vs_steering.ipynb`, läuft top-to-bottom in ~20 s, Seed 0, Zahlen zusätzlich
in `results/07_anchor.json`. Reproduziert Billa (arXiv:2604.15557) auf GPT-2 small.

**Aufbau.** Sechs kontrollierte Binärfamilien nach seiner Bauart (zwei Antwortklassen, gleiche
Vorlage, Einzeltoken-Antwort): `temperature`, `size`, `pronoun` (je 36+36, drei Satzvorlagen),
`daynight` (16+16), `parity` und `continent` als Bodenfälle. Gemessen pro Schicht: `A_lin`
(Unembedding auf `resid_post`, argmax gegen das Zieltoken), eine logistische Probe held-out
samt Kontrollaufgabe mit vertauschten Labels, sowie Steering über die Mittelwertdifferenz
(Koeffizient 1,0, Addition an allen Positionen) mit ΔP auf dem Zieltoken und KL auf 50 fremden
Prompts.

**Befunde.**
- **Emergenzmuster bestätigt sich auf 124M:** `A_lin` ist bis L7 exakt null und steigt erst im
  letzten Viertel — dieselbe Form wie bei ihm auf Gemma-2-2B in L18–L24. Ausnahme `pronoun`,
  dort ab L6 (0,64) und am Ende 0,99.
- **Die Probe kann keine Schicht wählen.** Bei `continent` liegt sie held-out in *jeder* Schicht
  L0–L11 bei 1,00, während `A_lin` mit 0,04 gipfelt und Steering nichts bewegt: überall lesbar,
  nirgends steuerbar. ρ(Probe, ΔP) wechselt familär das Vorzeichen (+0,74 bis −0,39), ρ(`A_lin`,
  ΔP) liegt bei +0,48 bis +0,90 und damit in seinem Band (+0,63 bis +0,92).
- **Mittlere Schicht verliert, wo `A_lin` es ansagt:** `temperature` +0,092 in L11 gegen +0,008 in
  L6, `daynight` +0,035 gegen +0,007. Wo `A_lin` mittig schon hoch ist (`pronoun`), funktioniert
  die Heuristik — das ist seine Erklärung, kein Gegenbeispiel.
- **Go/no-go-Schwelle trägt:** `parity` und `continent` bleiben unter 0,05 Spitzen-`A_lin` und
  erzeugen ΔP ≤ +0,014.
- **Dosis-Konfundierung im eigenen Material sichtbar:** ‖d‖ reicht von 0,5 bis 58,4 über Familien
  und Schichten, die KL-Nebenwirkung folgt dem. Billas Effizienz ΔP/KL vergleicht damit Konzepte
  bei der Dosis, die ihre Mittelwertdifferenz zufällig hat — das ist die Lücke für Schritt 13.

**Grenzen, selbst benannt.** Die Kreuzfamilien-Korrelation ist +1,00 auf sechs Punkten, das ist
eine Illustration und kein Beleg. Die Probe-Zahlen sind von den Daten geschmeichelt: Familien mit
nur einer Satzvorlage (`continent`, `parity`, `daynight`) lassen die Probe das Subjektwort lesen,
die Drei-Vorlagen-Familien liegen niedriger (`temperature` 0,84). Held-out-Mengen sind 4 bis 18
Prompts groß. Genau deshalb braucht der eigene Teil heterogene Prompts.

## Umgebung & Tooling (Stand 2026-09-18)

- Paketverwaltung: **uv** (seit 2026-08-24). `pyproject.toml` deklariert, `uv.lock` pinnt
  den vollständigen Abhängigkeitsbaum und ist committet — das ist die eigentliche
  Reproduzierbarkeitsgarantie, `requirements.txt` hatte nur die 8 direkten Pakete gepinnt.
  `uv sync` baut die Umgebung in `.venv`, alles läuft über `uv run …`.
- **Python 3.13** (`.python-version`); 3.14/3.15 sind Henrys Default, aber zu neu für den
  ML-Stack. Kern-Pins exakt, weil Smoke-Test und MPS-Verifikation dagegen liefen:
  transformer_lens 3.5.1, torch 2.13.0, transformers 5.13.0. Ein Wechsel bei einem davon
  entwertet die Verifikation und verlangt einen neuen Durchlauf von `verify_mps.py`.
- Explorations-Tooling: **jupyter** (Notebooks — bei 2-3 min Gemma-Ladezeit gehört das
  Modell in einen laufenden Kernel, nicht in Skript-Starts), **circuitsvis 1.43.3**
  (interaktive Attention-Darstellung in der Notebook-Zelle) und **matplotlib 3.11.2** (seit 2026-09-18, Dosis-Kurven im Steering-Notebook) und
  **scikit-learn 1.9.1** mit scipy 1.18.1 (seit 2026-09-18, logistische Regression für Proben).
  Bewusst weiter nicht drin: **SAELens** — Station 5 kam mit `huggingface_hub` + `safetensors`
  aus (vier Tensoren laden, Encoder ist eine Zeile Code → „SAE — Befund GPT-2 small"). Nötig
  würde es erst, um den Encoder über große Textmengen laufen zu lassen (welche Features feuern
  wo im Korpus).
- **Notebooks programmatisch bauen:** in der `.ipynb` muss jede Zeile im `source`-Array ihr
  `\n` behalten. Ohne das klebt die ganze Zelle zu *einer* Zeile zusammen, und weil Zellen hier
  mit einem Kommentar beginnen, ist der komplette Code auskommentiert — `nbconvert` läuft dann
  fehlerfrei in zwei Sekunden durch und schreibt null Outputs. Erst dieses Symptom verrät es.
  Weiter: `transformer_lens.__version__` existiert nicht, Versionen über
  `importlib.metadata.version("transformer-lens")`.
- **Messzahlen neben dem Notebook:** `results/<nb>.json` (seit 2026-09-19). Grund: die Zahlen
  für die Abhandlung sollen ohne Neu-Durchlauf greifbar sein, und ein Notebook-Output ist als
  Quelle unhandlich.
- **Paper-Volltexte:** `pdftotext -layout` liegt über Homebrew vor (`~/homebrew/bin`) und ist
  für das Lesen deutlich billiger als das PDF selbst — 19 Seiten wurden zu 9 300 Wörtern Text,
  aus denen sich Abschnitte gezielt schneiden lassen. PDFs nach
  `~/Documents/Master/4. Semester/XAI/`.
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
  2-3 min (Gewichts-Konvertierung, einmal pro Session), GPT-2 ~8 s; Generation auf MPS
  ~2,7 Token/s bei Gemma. Cache-Kosten und Speicherfallen → „Gemma-2-2B — Befunde aus der Tour".
- **Notebooks kann Claude selbst ausführen**, statt auf Henrys VS-Code-Lauf zu warten:
  `uv run jupyter nbconvert --to notebook --execute --inplace <nb>` schreibt Outputs und Plots
  direkt in die Datei (GPT-2-Station: 50 s). Sinnvoll, wenn Henry „mach alles" sagt; läuft er
  selbst, gilt weiter der mtime-Abgleich vor jeder Bearbeitung. Stolperstein: in diesem Kernel
  hat Python kein eigenes CA-Bundle, `urllib` scheitert an HTTPS — `ssl.create_default_context(
  cafile=certifi.where())` übergeben (z. B. für die Neuronpedia-API).
- TransformerLens 3.5.1 warnt beim Laden weiterhin pauschal vor MPS ("silently incorrect
  results", Issue #1178) — die Warnung hängt an der torch-Version, nicht an einer Messung,
  und ist durch `verify_mps.py` widerlegt (→ Numerik-Policy). `TRANSFORMERLENS_ALLOW_MPS=1`
  würde sie unterdrücken; bewusst stehen gelassen.
- **Was Messungen teuer macht, ist Generierung, nicht der Benchmark** (abgeschätzt 2026-09-19 für
  Kandidat B, nicht gemessen): Vorwärtspass-Metriken (Loss, KL, Multiple-Choice über Logits) kosten
  auf Gemma-2-2B Minuten für einige hundert Items, freie Generierung liegt bei 2,7 Token/s im
  Einzelstrom. Über einen Dosis-Sweep multipliziert sich das mit Dosen × Bedingungen (17 × 3 ≈ 50
  Durchläufe): grob 4–8 h nur mit Vorwärtspässen, mit Generierung ein Vielfaches. Gebündelte
  Generierung auf MPS ist ungemessen und wäre der erste Hebel.

## Steering — Messprotokoll für Nebeneffekte (Stand 2026-07-11, Planung)

Die Kandidaten A/B sind nicht gewählt worden (2026-09-19). Die Sektion bleibt, weil Dosis-Achse
und Kontroll-Logik daraus im gewählten Zuschnitt weiterbenutzt werden.
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
4. Bei bf16 kommt die Rundung von TLs Gewichtsverarbeitung (fold_ln rechnet float32 und rundet
   zurück) auf das Backend-Rauschen obendrauf — für knappe Effekte fp32 oder
   `from_pretrained_no_processing` → „Gemma-2-2B — Befunde aus der Tour".
5. Gemma-2-Eigenheit: sehr große Residual-Aktivierungen (bis ~4000, wächst über Layer) —
   relevant für alles, was absolute Schwellwerte benutzt.

## Forschungsstand & SAE-Kritik → `details/forschungsstand.md` (Stand 2026-09-18)

Ausgelagert, weil die Sektion für gezieltes Springen zu groß wurde. Dort steht die
Landkarte über alle Methoden der Schnuppertour: wie recherchiert wurde (fixiertes
Protokoll, Evidenzstufen, Auflösbarkeits-Check), Steering-Nebeneffekte, SAE-Kritik,
Activation Patching, Probing — je mit Standard-Messungen, „gilt als gelöst" und den
offenen Lücken samt Urteil, ob sie mit unserem Compute erreichbar sind.

## Tooling-Realität (Stand 2026-09-18)

Recherchiert und teils lokal verifiziert. Korrigiert mehrere ältere Annahmen.

- **TransformerLens: aktuell 3.9.0, installiert und entschieden 3.5.1** (Henry, 2026-09-18).
  Grund: Quelltext-Diff 3.5.1 → 3.9.0 des Gemma-2-Pfads (Gewichtskonvertierung, Config-Block,
  RMSNorm, Grouped-Query-Attention) zeigt genau einen Fix: 3.5.1 hat die Reihenfolge
  global/local der Attention-Layer vertauscht (Layer 0 global statt sliding wie in HF), ohne
  Wirkung unter 4096 Tokens. Alle anderen Attention-Änderungen betreffen fremde Architekturen.
  Ab 3.7.0 wirft `HookedTransformer.from_pretrained` eine DeprecationWarning, 4.0 (Beta seit
  07/2026) entfernt HookedTransformer zugunsten `TransformerBridge`. Upgrade erst, wenn ein
  Modell außerhalb der HookedTransformer-Liste oder die Bridge gebraucht wird; dann
  `verify_mps.py` und Smoke-Test neu. Gemma-3 wird unterstützt (Configs 270m–27b).
- **Gemma-Embedding-Scaling und `enable_compatibility_mode()` betreffen nur `TransformerBridge`.**
  transformers 4.x skalierte die Embeddings mit √d_model im Model-Forward, 5.x im
  Embedding-Modul; das gespeicherte Gewicht ist in beiden roh, und `HookedTransformer` liest
  das rohe Gewicht und skaliert selbst (`convert_gemma_weights`) — für unseren Pfad hat sich
  nichts geändert. Die Bridge wickelt das HF-Modell direkt, ihr Embedding-Hook sieht in v5
  skalierte Werte; `enable_compatibility_mode()` ist ihre Methode, um fold_ln, Zentrierung und
  die alten Hook-Namen nachzurüsten, damit Bridge-Zahlen zu HookedTransformer-Tutorials passen.
  Für HookedTransformer gegenstandslos. Bei Gemma schaltet HookedTransformer `center_unembed`
  selbst ab (Logit-Softcap ist nicht verschiebungsinvariant), Logits bleiben so direkt mit HF
  vergleichbar; Parity-Check → `notebooks/05_gemma.ipynb`.
- **TL-Bug `to_str_tokens` mit Gemma-Tokenizern** (3.5.1, in 3.9.0 unverändert drin): bei
  String-Eingabe hängt die Funktion für Gemma eine Batch-Dimension an, die darunterliegende
  v5-Kompatibilitätsschicht eine zweite → `TypeError`. Workaround: den Token-Tensor übergeben,
  `model.to_str_tokens(model.to_tokens(text)[0])`.
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
