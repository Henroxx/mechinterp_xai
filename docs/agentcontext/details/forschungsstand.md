# Forschungsstand — Landkarte (Stand 2026-09-18)

Ausgelagert aus `DETAILS.md`, weil die Sektion für gezieltes Lesen zu groß wurde.
`PROJECT.md` bleibt der Index, `DETAILS.md` verweist hierher.

Zweck: Entscheidungsgrundlage für die Themenwahl (Fahrplan Schritt 10). Eine Zeile pro
Methode — wo steht das Feld, was ist gelöst, was ist offen, und was haben wir selbst
gemessen. Ausdrücklich keine Vollständigkeit.

---

## Wie diese Landkarte entstanden ist

**Scoping Map, kein systematischer Review.** Gesucht wurde LLM-gestützt über Websuche;
es gibt damit keine reproduzierbare Trefferliste und keine Vollständigkeitsgarantie. Was
es gibt, ist ein vor der ersten Suche fixiertes Protokoll (→ `plans/forschungsstand-landkarte.md`):

- **Quellen:** arXiv (cs.LG/cs.CL), Proceedings ICML/NeurIPS/ICLR/ACL, Semantic Scholar für
  Zitationsketten. Blogposts nur als Zeiger auf Arbeiten, nie als Beleg für eine Zahl.
- **Zeitfenster:** Schwerpunkt ab 2024-01; ältere Arbeiten nur als anerkannte Grundlage.
- **Einschluss:** eigene Messung berichtet · Open-Weight-Modell bis ~9B oder GPT-2-Klasse ·
  Methode nachvollziehbar. **Ausschluss:** nur Closed-Model · keine Messung · Compute-Bedarf
  außerhalb „ein Mac, MPS, Inferenz bis 9B, kein Training".
- **Evidenzstufe je Eintrag:** `[V]` Volltext · `[A]` Abstract/Teile · `[S]` sekundär.
  Grund: der Volltext von SteeringSafety hat am 2026-08-25 mehrere abstract-basierte
  Aussagen korrigiert — die Stufe hält fest, wie belastbar eine Zeile ist.
- **Auflösbarkeit:** jede aufgenommene Arbeit muss über ihre arXiv-ID auflösbar sein, Titel
  und Autoren müssen übereinstimmen. Nicht prüfbar → nicht aufgenommen. Erfundene Referenzen
  sind die systematische Fehlerquelle LLM-gestützter Literatursuche.

**Provenienz der Teile.** Steering und SAE wurden am 2026-08-24 recherchiert, also *vor*
diesem Protokoll: dort fehlen Suchprotokoll und Evidenzstufen pro Eintrag; Evidenzstufe ist
`[V]` für SteeringSafety und `[A]` für alle übrigen Einträge. Patching und Probing wurden am
2026-09-18 nach dem Protokoll oben erhoben, mit Suchprotokoll. **Nachgeprüft:** alle 21
arXiv-IDs des August-Materials wurden am 2026-09-18 über die arXiv-API aufgelöst; Titel und
Erstautor stimmen in allen 21 Fällen — keine erfundene Referenz.

---
## Die Landkarte

| Methode | Modelle im Feld | Standard-Messung | gilt als gelöst | erreichbare Lücke | eigener Befund aus der Tour |
|---|---|---|---|---|---|
| **Activation Patching / Circuits** | GPT-2 small, Pythia, Gemma-2-2B, Llama-3.1-8B | Logit-Diff; Faithfulness / Completeness / Minimality; seit MIB CPR+CMD | kanonische Circuits wiederfinden; EAP-Effizienz; *dass* Scores von der Ablation abhängen | die Corrupt-Baseline systematisch durchrastern; Hypothesentests auf publizierte Circuits anwenden | Self-Repair selbst gesehen (25 % Ablation vs. 60 % Patching); Attention-Rang ≠ Wirkungs-Rang |
| **Steering** | Gemma-2-2B-it, Llama-3.1-8B, Qwen-2.5-7B | Refusal-Rate, Capability-Benchmarks, PPL, LLM-Judge; KL nur als *Filter* | Richtung finden, abliterieren, ASR berichten; neue Steering-Methode vorschlagen | dichte Dosis-Wirkungs-Kurve; Metrik-Validierung; ehrliche Kontroll-Buchführung | 17-stufige Dosiskurve mit norm-matched Zufallskontrolle steht; Nebenwirkung als Loss messbar |
| **Probing** | GPT-2 small, Pythia, Gemma-2-2B/9B, Llama-3-8B | Accuracy/AUROC pro Layer; Selectivity; bei Eingriffen completeness + selectivity | „Konzept X ist linear auslesbar"; LEACE; SAE-Probes ohne konsistenten Gewinn | Probe-Güte gegen kausale Wirkung als Matrix; Control Tasks wieder berichten; Deconfounding | Probe ≈ Difference-in-Means auf Minimalpaaren (cos ≥ 0,95); w⊥ wirkt wie ein Zufallsstoß |
| **SAE** | Gemma-2-2B (Gemma Scope), GPT-2 small (res-jb) | Explained Variance + L0; AxBench (Steering), SAEBench (Detection) | „SAEs schlagen Baselines beim Steuern" — Antwort: nein; Absorption dokumentiert | Feature Absorption reproduzieren; SAE-Rekonstruktion gegen norm-matched Random im KL | Feature-Richtung ist bei *gleicher Wirkung* nicht billiger als d |

Die Gemma-Tour ist keine Methode, sondern die Machbarkeitsprüfung für das zweite Modell: TL rechnet
dasselbe wie HuggingFace, Ladezeit und Cache-Kosten sind bekannt, Induction Heads sind stärker als in
GPT-2. Sie schließt keine Lücke, sie öffnet die Spalte „Modell" für alles oben.

**Was quer über die vier Felder auffällt:**

1. **Alle vier haben dieselbe Kernfrage, nur anders benannt: das Messinstrument bestimmt das Ergebnis
   mit.** Corrupt-Baseline und Ablationsart beim Patching · KL-Filter und ein Dosisraster aus ganzen
   Zahlen beim Steering · fehlende Control Tasks und ungeprüfte Confounds beim Probing · falsch
   gewähltes L0 und als unzuverlässig erwiesene Benchmarks beim SAE. Wer *eine* dieser Stellschrauben
   sauber durchrastert, hat einen Beitrag, ohne eine neue Methode erfinden zu müssen — und das ist
   genau der Zuschnitt einer Abhandlung über *angewandte* Methoden.
2. **Die billigen Lücken sind Kontroll- und Baseline-Arbeit, nicht neue Verfahren.** Jedes Feld hat
   mindestens eine Lücke, die reine Inferenz auf ≤ 2B ist. Was durchweg *nicht* geht: Training,
   eigene SAEs, Modellfamilien über 9B.
3. **Drei der fünf Stationen haben die Kleinform eines publizierten Befunds reproduziert, ohne dass
   wir ihn kannten** — Self-Repair, „Probe findet ≠ Modell benutzt", SAE verliert gegen
   difference-in-means. Das ist der Ankerwert der Tour: die Werkzeuge verhalten sich hier wie in der
   Literatur, und das ist die Voraussetzung dafür, dass eine eigene Messung ernst genommen wird.

**Erwartung vor der Recherche** (aus `plans/forschungsstand-landkarte.md`): bei Patching liegt das
Offene in Faithfulness und Generalisierung, bei Probing in der Kluft zwischen Lesen und Benutzen, und
mehrere Methoden laufen auf dieselbe Kernfrage zu. Alle drei haben sich bestätigt; die Kernfrage ist
allerdings schärfer als gedacht — sie betrifft nicht drei, sondern alle vier Felder, und sie ist in
jedem Feld schon als Kritik publiziert, nicht bloß latent.

---

## Activation Patching & Circuits — Forschungsstand (Stand 2026-09-18)

Recherchiert 2026-09-18 per Subagent nach dem Protokoll oben; die 18 arXiv-IDs selbst gegen die
arXiv-API geprüft, Titel und Erstautor stimmen in allen Fällen. Evidenzstufe `[A]`, wo unten nicht
anders vermerkt.

**Kern des Felds: Circuits findet man. Was ein gefundener Circuit wert ist, hängt an Entscheidungen,
die man beim Messen trifft.**

- **Referenzrahmen:** ACDC (Conmy et al., arXiv:2304.14997, NeurIPS 2023) — iteratives Kantenpruning
  per Patching, 68 von 32.000 Kanten auf GPT-2 small, alle zuvor manuell belegt. Daran misst sich
  alles Spätere. Praxis-Tutorial: Heimersheim & Nanda (arXiv:2404.15255), ohne eigene Messung.
- **Die Messwahl dreht das Ergebnis:** Zhang & Nanda (arXiv:2309.16042, ICLR 2024) — dieselbe Aufgabe
  macht je nach Metrik (Logit-Diff, Prob, KL) und Korruptionsart andere Komponenten „wichtig";
  empfohlen wird Symmetric Token Replacement.
- **Billiger als Brute Force:** EAP (Syed et al., arXiv:2310.10348) — lineare Näherung pro Kante, zwei
  Forward- plus ein Backward-Pass. AtP\* (Kramár et al., arXiv:2403.00745) benennt zwei Ausfallklassen
  (Attention-Sättigung, Cancellation) und gibt eine Schranke für verbleibende False Negatives.
  EAP-IG (Hanna et al., arXiv:2403.17806, COLM 2024): EAP-Circuits überlappen stark mit
  Patching-Circuits, sind aber deutlich unfaithfuller — **Overlap ist kein Gütemaß**. Zhang & Wang
  (arXiv:2606.09899): der dominante Fehler kommt aus Nichtlinearität *stromabwärts*, korrigierbar
  mit einem Hessian-Vector-Product-Pass.
- **Die Kritiklinie:** Miller et al. (arXiv:2407.08734, COLM 2024) — Faithfulness-Scores kippen bei
  kosmetischen Änderungen der Ablationsmethodik; der Score misst die Methodenwahl mindestens so stark
  wie den Circuit. Shi et al. (arXiv:2410.13032, NeurIPS 2024) — Mechanism Preservation, Localization
  und Minimality als echte Hypothesentests: synthetisch eingebaute Circuits bestehen sie, die aus der
  Literatur nur teilweise. Li & Subramani (arXiv:2605.08348) — Komponenten-Circuits sind konsistent,
  aber unspezifisch (Ablation schadet fremden Aufgaben gleich stark). Bayat Makou et al.
  (arXiv:2606.06267, TMLR 2026) — strukturell verschiedene Circuits sind funktional identisch;
  Source-Level-Evaluation bläht Faithfulness auf, Edge-Level deckt die Vieldeutigkeit auf.
- **Benchmark:** MIB (Mueller et al., arXiv:2504.13151, ICML 2025) — GPT-2 small, Qwen-2.5-0.5B,
  **Gemma-2-2B**, Llama-3.1-8B; CPR und CMD als Flächenmaße über die ganze Faithfulness-Kurve statt
  eines Punktwerts, AUROC gegen die synthetische Ground Truth von InterpBench. Nebenbefund:
  SAE-Features schlagen rohe Neuronen beim Lokalisieren kausaler Variablen **nicht**.
- **Transcoder und Attribution-Graphen:** Dunefsky et al. (arXiv:2406.11944, NeurIPS 2024) — MLPs durch
  breite sparse MLPs ersetzen, dadurch gewichtsbasierte statt rein aktivierungsbasierte Analyse.
  `circuit-tracer` (Hanna et al., ACL Anthology 2025.blackboxnlp-1.14) ist die offene
  Referenzimplementierung, Gemma-2-2B first class.
- **Störfaktor, den man mitmessen muss:** Self-Repair / Hydra-Effekt (Rushing & Nanda,
  arXiv:2402.15390, ICML 2024) — nach einer Ablation kompensieren spätere Komponenten, unvollständig
  und prompt-abhängig. Verzerrt jede Einzelkomponenten-Ablation nach unten. Dazu Circuit Component
  Reuse (Merullo et al., arXiv:2310.08744, ICLR 2024).

**Standard-Messungen.** Logit-Difference (Standard bei IOI/Greater-Than), Probability-Difference,
KL zum vollen Modell. Gütemaße: Faithfulness, Completeness, Minimality; seit MIB zusätzlich CPR/CMD
als Flächenmaße. Ablationsarten: Zero, Mean, Resample, Symmetric Token Replacement; Knoten gegen
Kante; Source- gegen Edge-Level. Kontrollen: Random-Circuit gleicher Größe, synthetische Ground Truth
(InterpBench), Cross-Task-Transfer. Aufgaben: IOI, Greater-Than, Docstring, MCQA, Arithmetic, ARC.

**Gilt als gelöst.** Die kanonischen GPT-2-small-Circuits wiederfinden (taugt nur noch als
Sanity-Check) · „Attribution ist billiger und konkurrenzfähig" · „EAP ohne integrierte Gradienten ist
unfaithful" · *dass* Faithfulness von Ablationsart und Metrik abhängt (aufgezeigt — systematisch
durchgerastert ist es nicht, siehe Lücke 1) · noch eine Circuit-Bibliothek bauen · Path Patching
beschleunigen.

**Offene Lücken:**
1. **Die Corrupt-Baseline als eigene Versuchsvariable.** Die Sensitivität ist gezeigt, aber niemand
   rastert eine Aufgabe systematisch über Counterfactual-Familien × Ablationsarten × Edge-vs.-Source
   und berichtet, wie weit die Circuit-Urteile auseinanderlaufen. Erreichbar — GPT-2 small, reine
   Inferenz, MIB-Code öffentlich.
2. **Die Hypothesentests von Shi et al. auf publizierte Circuits anwenden**, gegengelesen mit
   MIB-Metriken. Beide Instrumentarien existieren, werden aber nie zusammen benutzt; interessant ist
   der Fall, wo CPR/CMD einen Circuit gut aussehen lassen und Minimality ihn durchfallen lässt.
   Erreichbar; das Risiko ist Code-Integration, nicht Compute.
3. **Attribution-Graphen gegen Patching-Ground-Truth** auf Gemma-2-2B. Grenzwertig: kein Training
   nötig, aber die Transcoder-Gewichte sind speicherhungrig und der MPS-Pfad von `circuit-tracer`
   ungeprüft. Fallback: GPT-2 small mit Single-Layer-Transcodern.
4. **Wann darf man EAP glauben?** Es fehlt ein billiger Vorab-Test pro Aufgabe. Erreichbar und sauber
   abgegrenzt: EAP gegen EAP-IG gegen echtes Patching auf zwei Aufgaben.
5. **Generalisierung über die Prompt-Oberfläche hinaus** (Sprache, Format, instruction-tuned). Nur mit
   hartem Vorabzuschnitt auf ein Modell und zwei Variationsachsen machbar.

**Vorbehalte des Kondensats.** Bei arXiv:2309.16042, 2403.00745, 2310.10348, 2407.08734 und 2403.17806
steht die genaue Modellliste nicht im Abstract — „GPT-2 small/Pythia" ist dort `[S]`. Venue-Status
mehrerer 2026er Preprints ungeprüft. Die MIB-Metrikdefinitionen stammen von der Projektseite, nicht
aus dem Volltext: Vorzeichen und Normierung vor eigener Verwendung nachlesen.

**Anschluss an die eigene Station** (→ DETAILS „Activation Patching — Befund am Induction-Setup"):
unsere 25 % bei Ablation gegen 60 % bei Patching auf denselben fünf Heads sind genau der Self-Repair-
Effekt aus arXiv:2402.15390. Dass der Rang nach Attention-Muster (L5H5) nicht dem Rang nach Wirkung
(L7H2) folgt, ist die Kleinform von „Struktur sagt Funktion nicht" bei Bayat Makou et al. Unser Maß
war Loss, Literatur-Standard ist Logit-Diff — für jeden Vergleich müsste das umgestellt werden.

---

## Steering-Nebeneffekte — Forschungsstand (Stand 2026-08-24)

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
- **Layer-Wahl** (Billa, arXiv:2604.15557) — **[V], Volltext gelesen 2026-09-19.** Das Maß ist
  `A_lin`: Unembedding auf den Zwischenzustand jeder Schicht, argmax gegen das Zieltoken, also
  Logit-Lens-Trefferquote — trainingsfrei, ein Forward-Pass. Sie prognostiziert Steering-Wirkung
  über 24 kontrollierte Binärfamilien mit ρ = +0,86 bis +0,91 und die Schichtwahl mit ρ = +0,63
  bis +0,92; die übliche „mittlere Schicht"-Heuristik liegt auf Gemma-2-2B bei `A_lin` = 0 und wirkt
  dort gar nicht. Drei Regime: `A_mlp` niedrig → kein Verfahren steuert; `A_mlp` hoch und `A_lin`
  niedrig → nichtlinear kodiert, Mittelwertdifferenz versagt; `A_lin` hoch → Mittelwertdifferenz
  reicht. Wirkung = ΔP auf dem Zieltoken, Nebenwirkung = KL auf 50 fremden Prompts, Effizienz =
  ΔP/KL. Selbst benannte Grenzen: Bodeneffekt (oberhalb `A_lin` > 0,1 fällt ρ auf +0,50 bis +0,52
  auf den kleinen Modellen), nur Einzeltoken-Aufgaben, Steering nur als Mittelwertdifferenz.
  Eigener Kritikpunkt: die Dosis wird nirgends angegeben, und ρ(‖d‖, KL) = +0,96 — die gemessene
  Nebenwirkung ist fast nur die Norm des addierten Vektors. Drei der fünf Kernfamilien beziehen
  ihre Richtung aus ≤ 10 Zielbeispielen, obwohl der Anhang genau das als Fehlerquelle nennt.
  **Die SAE-Vorhersage des Papers ist ausdrücklich ungetästet** (future work): SAE-Features sollen
  in Regime 2 helfen und in Regime 3 wenig beitragen.
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

---

## Probing — Forschungsstand (Stand 2026-09-18)

Recherchiert 2026-09-18 per Subagent nach dem Protokoll oben; die 16 arXiv-IDs selbst gegen
die arXiv-API geprüft, Titel und Erstautor stimmen in allen Fällen. Evidenzstufe durchgehend `[A]`.

**Kern des Felds: das Lesen ist gelöst, der Schluss aufs Benutzen nicht.**

- **Grundlage:** Hewitt & Liang (arXiv:1909.03368, EMNLP 2019) — Control Task und Selectivity,
  bis heute die Referenz für „die Probe misst auch sich selbst"; Belinkov (arXiv:2102.12452,
  CL 2022) sammelt die kanonischen Einwände (Kapazität, Korrelation vs. Kausalität, Baseline).
- **Decodability is Not Causality** (Tiwari et al., arXiv:2609.18080) — **[V], Volltext gelesen
  2026-09-19.** Gemma-2-9B-it, Layer 20, GemmaScope-SAE: die geometrisch probe-nächsten Features
  überlappen nur zu 11–14 % mit den gradienten-relevanten (Spearman ρ = 0,10). Ablation bei
  gleicher Mengengröße von 16 Features ändert das Verhalten: gemeinsame 0,12 · probe-only 0,06 ·
  random 0,01; die ganze Probe-Richtung zu ablieren bringt 0,18. Umgekehrt bewegen die
  probe-only-Features den *Readout* am stärksten (0,24 gegen 0,05) — die Dissoziation existiert
  nur als dieser Gegensatz. **Korrektur unserer Notiz (2026-09-19):** die Arbeit ist kein
  unbegutachteter Preprint, die Kopfzeile sagt „Published at COLM 2026 Workshop on Agent
  Behavior" — Workshop-Review. Zweite Korrektur: die früher notierten 27 % gehören zum 54er-Set,
  nicht zum 16er; das Abstract mischt die Mengengrößen. Verglichen wird bei **gleicher Dosis**
  (gleiche Set-Größe), nicht bei gleicher Wirkung; der Dosis-Confound wird nur nachträglich
  entkräftet. Eigener Kritikpunkt: die gemeinsame Menge ist doppelt gefiltert, die probe-only-Menge
  einfach — getestet wird damit Konjunktion gegen Einzelkriterium, nicht Geometrie gegen Kausalität.
  Übertragbar ist die **Substrat-Prüfung**: im Qwen3-8B-Versuch lagen 74 % des Probe-Margins im
  Rekonstruktionsfehler der SAE, Ablationen wirkten nur im Rekonstruktionsraum (32,7 % gegen 2,1 %).
  Code: `github.com/cam1lled/causal-validation-sae`.
- **Predicting Where Steering Vectors Succeed** (Billa, arXiv:2604.15557, → auch im Steering-Teil)
  — **[V]** eine trainierte logistische Probe erreicht auf Gemma-2-2B in *jeder* Schicht L0–L25
  über 93 %, während Steering in den frühen Schichten ΔP = 0 erzeugt. Die Aussage ist also nicht
  „gut gelesen heißt schlecht gesteuert", sondern: die Probe ist über die Tiefe gesättigt und hat
  keine Varianz mehr, mit der sie die Schichtwahl leiten könnte. Das korrigiert unsere
  abstract-basierte Notiz (2026-09-19).
- **Confounds:** Sahoo et al. (arXiv:2606.02907) — 100 % CV-Accuracy fällt nach Residualisierung
  gegen Quelle, Optionenzahl und Antwortlänge auf Zufallsniveau (Qwen3-14B, über unserer
  Modellgrenze, vom Subagenten als bewusste Ausnahme aufgenommen). Boxo et al. (arXiv:2509.21344) —
  filtert man Tokens mit explizitem Verhaltensbeleg, fällt AUROC von 0,94 auf 0,57: die Probe liest
  oft den Text, nicht den Zustand.
- **Interventionsseite:** Canby et al. (arXiv:2408.15510) — *completeness* gegen *selectivity* als
  zwei Achsen mit durchgängigem Trade-off, nichtlineare Eingriffe schlagen lineare. LEACE
  (Belrose et al., arXiv:2306.03819, NeurIPS 2023) — lineare Konzept-Löschung in geschlossener
  Form, macht INLP überflüssig; Dobrzeniecka et al. (arXiv:2506.11673) bestätigt das für Amnesic Probing.
- **Geometrie der Konzepte:** Arditi et al. (arXiv:2406.11717, NeurIPS 2024) — Refusal als *eine*
  Richtung über 13 Modelle; dagegen Joad et al. (arXiv:2602.02132) — mehrere Richtungen, nahezu
  identischer Trade-off. Bürger et al. (arXiv:2407.12831) — Wahrheit ist zweidimensional (generell +
  polaritätssensitiv), erklärt Generalisierungsbrüche bei Negation. Engels et al. (arXiv:2405.14860,
  ICLR 2025) — irreduzibel mehrdimensionale, kreisförmige Features, die nachweislich benutzt werden:
  die harte Gegenevidenz zur starken LRH. Poulis et al. (arXiv:2604.03754) — Wahrheitsrichtungen sind
  stark layer-, task- und prompt-abhängig; Orgad et al. (arXiv:2410.02707, ICLR 2025) — Fehlerdetektoren
  generalisieren nicht über Datensätze.
- **SAE-Latents als Probe-Features:** Kantamneni et al. (arXiv:2502.16681) — kein konsistenter Gewinn
  gegenüber einfachen Baselines, auch nicht im Ensemble.

**Standard-Messungen.** Accuracy/F1/AUROC pro Layer · Selectivity gegen Control Task · bei Eingriffen
completeness + selectivity · KL oder Loss nach Ablation. Baselines sind zugleich Richtungsquellen:
difference-in-means (trainingsfrei), L2-LogReg mit C per CV, k-sparse auf SAE-Latents, PCA;
Untergrenze ist die Random-Richtung bzw. die Shuffled-Label-Probe. Modelle: GPT-2 small, Pythia,
Gemma-2-2B/9B, Llama-3-8B, Mistral-7B — das Feld arbeitet überwiegend in unserer Compute-Klasse.

**Gilt als gelöst.** „Konzept X ist linear auslesbar" (Wahrheit, Refusal, Sentiment, Sprache, Zeit) ·
Refusal über eine diff-in-means-Richtung steuern · lineare Löschung in geschlossener Form (LEACE) ·
„SAE-Probes schlagen LogReg" (Antwort: nicht konsistent) · die starke LRH (widerlegt, revidierte
zweiteilige Fassung ist Konsens).

**Offene Lücken:**
1. **Probe-Güte gegen kausale Wirksamkeit derselben Richtung**, als Matrix Konzept × Layer ×
   Richtungsmethode statt als Einzelanekdote. Erreichbar — Probes kosten Sekunden, der Rest ist Inferenz.
2. **Selectivity ist praktisch verschwunden:** Control Tasks werden für Residual-Stream-Probes auf
   Wahrheit oder Refusal kaum noch berichtet. Billigste unbequeme Messung der Liste, Aufwand liegt im
   Datensatz-Design. Vorbehalt: der Subagent konnte das Fehlen nicht belegen, nur nicht widerlegen.
3. **Deconfounding als Routineschritt** (Länge, Quelle, Token-Overlap, Positions-Baseline) quer über
   mehrere bekannte Probing-Aufgaben. Erreichbar, reine Statistik auf gecachten Aktivierungen.
4. **Erasure gegen Verhalten:** LEACE macht jede lineare Probe blind — ändert sich das Verhalten?
   Eingeschränkt erreichbar: ein bis zwei Layer ja, volles concept scrubbing plus Perplexity auf großem
   Korpus nein.
5. **1D-Richtung gegen k-dimensionalen Unterraum bei gleichem Parameterbudget.** Erreichbar; die
   Kapazitätskontrolle ist die eigentliche Arbeit, nicht das Compute.

Nicht erreichbar: alles mit Training (Model Organisms, eigene SAEs, Obfuscation-Angriffe), Skalierung
über 9B, proprietäre Modelle.

**Anschluss an die eigene Station** (→ DETAILS „Probing — Befund GPT-2 small"): Probe und d waren auf
den Minimalpaaren nicht unterscheidbar (cos ≥ 0,95 über alle C), und w⊥ wirkte wie ein Zufallsstoß —
das ist Lücke 1 im Kleinen, mit der Datenkonstruktion als Ursache. Heterogene Daten sind die Bedingung
dafür, dass Lesen und Steuern überhaupt auseinanderfallen können.

---

## SAE — Kritik und Forschungsstand (Stand 2026-08-24)

- **AxBench** (Wu et al., arXiv:2501.17148, ICML 2025) — auf **Gemma-2-2B**, ~500 Konzepte:
  beim Steering schlägt **Prompting alles**, SAEs sind nicht konkurrenzfähig; bei Concept
  Detection gewinnt **difference-in-means**. Gegenposition (Jørgensen et al., arXiv:2605.31183): mit
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
- **Seed-Instabilität** (Gerasimov et al., arXiv:2606.12138) — differenzierter als oft behauptet: stabile
  Features tragen fast das ganze Signal, instabile sind Low-Frequency-Surface-Form-Trigger in
  reproduzierbaren Unterräumen. Also Basis-Ambiguität, nicht Rauschen.
- **Benchmarks selbst unzuverlässig** (Chanin, arXiv:2605.18229) — SAEBench-Metriken TPP und
  SCR sollten nicht mehr zur SAE-Evaluation verwendet werden.
- **Position, die am meisten trägt** (Peng et al., arXiv:2506.23845): SAEs zur *Entdeckung unbekannter*
  Konzepte einsetzen, nicht zum Handeln auf bekannten. Bei bekanntem Zielkonzept verlieren
  sie gegen Baselines — genau der Fall bei Steering auf ein spezifiziertes Verhalten.
- **Rahmen für Methodenkritik allgemein:** „The Dead Salmons of AI Interpretability"
  (Méloux et al., arXiv:2512.18792) — Identifizierbarkeit, False-Discovery-Rates, fehlende
  Unsicherheitsquantifizierung über Feature Attribution, Probing, SAEs und Causal Analysis
  hinweg; Vorschlag, Erklärungen gegen explizite Alternativhypothesen zu testen.

Mit kleinem Compute reproduzierbar (fertige Gemma-Scope-SAEs, kein Training): Feature
Absorption · SAE-Steering vs. difference-in-means auf einem Konzept · **SAE-Rekonstruktion
vs. norm-matched Random-Perturbation im KL** (billig, aussagekräftig, und methodisch
identisch zur Random-Vektor-Kontrolle beim Steering — verbindet beide Projektteile).
Nicht machbar: Seed-Instabilität (braucht mehrere SAE-Trainingsläufe), L0-Studien über
SAE-Familien.

---

## Grenzen dieser Suche

- **Keine Vollständigkeit.** Zwei Subagenten, je eine Sitzung, zusammen ~160 gesichtete Titel. Was mit
  anderem Vokabular publiziert wurde, fehlt hier systematisch.
- **Verifiziert ist die Existenz, nicht der Inhalt.** Alle 55 arXiv-IDs dieser Datei wurden am
  2026-09-18 über die arXiv-API aufgelöst, Titel und Erstautor stimmen. Das schützt gegen erfundene
  Referenzen, nicht gegen falsch referierte Befunde: die Zahlen stammen mit einer Ausnahme
  (SteeringSafety, Volltext) aus Abstracts.
- **Keine Zitationsketten gelaufen** — Semantic Scholar wurde nicht benutzt, die Auswahl ist rein
  suchbasiert.
- **Bewusst nicht durchsucht:** nicht-englische und multimodale Settings, Causal Abstraction / DAS,
  die Grokking-Linie.
- **Einzelvorbehalte** stehen jeweils am Ende der Methoden-Sektionen und sind nicht hierher dupliziert.
