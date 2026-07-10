# XAI Vorlesung — Slides-Kondensat

> Quelle: `XAI_course/XAI_Slides/main.tex` (F. Neubürger, FH Südwestfalen, 2025).
> Konsolidierte, token-effiziente Reproduktion der Beamer-Slides. Redundante Folien zusammengeführt. Bilder als Kurzbeschreibung `[Bild: ...]` (rein illustrativ, nicht inhaltstragend).

## Organisation der Vorlesung

- **Format**: Theorie mit Folien + Selbststudium (Molnar, *Interpretable ML Book*) + praktisches Gruppenprojekt.
- **Gruppen**: 2–3 Personen; Einzelarbeit möglich bei eigenem Thema.
- **Abgabe**: Ausarbeitung einen Tag vor der Veranstaltung in der Blockwoche; Vorstellung der Ergebnisse in der Blockwoche.
- **Bewertung**: Projektausarbeitung 50 % + Vortrag 50 %.
- **Inhalte/Leitfragen**: Begriffsklärungen, erkenntnistheoretischer Exkurs, XAI-Methoden, quantitative Methoden, Anwendungsbeispiel. Wofür/was ist XAI? Interpretable AI? Trustworthy AI? Wie funktioniert es mathematisch? Wie schaffe ich Transparenz für Stakeholder?

## Begriffe & Grundlagen

- **KI**: Teilgebiet der Informatik, Automatisierung intelligenten Verhaltens. **ML**: Unterbereich der KI, Algorithmen lernen aus Daten. Deep Learning: ML auf Basis künstlicher neuronaler Netze.
- **XAI**: Ansätze zur Verständlichkeit von KI-Entscheidungen; wichtig für Vertrauen, Transparenz (Bsp. medizinische Diagnostik).
- **Interpretierbarkeit**: Fähigkeit, die *internen Mechanismen* eines Modells direkt zu verstehen (lineare Regression, Entscheidungsbäume). Maß, in dem ein Mensch die Ursache einer Modellentscheidung nachvollziehen kann.
- **Erklärbarkeit (Explainability)**: Fähigkeit, *Entscheidungen/Vorhersagen* verständlich zu machen — bei komplexen Modellen meist durch Post-hoc-Methoden (z.B. neuronale Netze + LIME/SHAP).
- **Transparenz**: Ausmaß, in dem die Funktionsweise offenliegt. **Vertrauen**: Maß, in dem Nutzer auf korrekte, faire Entscheidungen vertrauen.
- Warum Interpretierbarkeit: Vertrauensbildung, Fehleranalyse, gesetzliche Vorgaben (Medizin, Finanzen).
- Herausforderungen: keine einheitliche Definition von Interpretierbarkeit; Trade-off Modellkomplexität ↔ Interpretierbarkeit.
- Erkenntnistheoretische Aspekte: Wissenserwerb, Vertrauen durch Nachvollziehbarkeit, Transparenz vs. Komplexität, ethische Verantwortung.

## EU AI Act (Regulation (EU) 2024/1689, in Kraft 1.8.2024)

- Risikobasiertes Klassifizierungssystem: **unzulässiges Risiko** (verboten), **hohes Risiko** (strenge Transparenz-/Sicherheits-/Compliance-Anforderungen), **geringes/minimales Risiko** (kaum Anforderungen).
- Erklärbarkeit als zentrale Anforderung: Transparenzpflichten für Anbieter, Vertrauenswürdigkeit als Akzeptanzfaktor.
- Herausforderungen für Unternehmen: Komplexität der Einstufung, fehlende harmonisierte Standards (Verzögerungen → Unsicherheit), Gefahr von Innovationshemmnissen, internationale Wettbewerbsfähigkeit gegenüber weniger regulierten Regionen.

## Taxonomie der XAI-Methoden

- **Global interpretierbare Modelle**: lineare Regression, Entscheidungsbäume, regelbasierte Modelle.
- **Post-hoc-Erklärungen**: lokale Methoden (LIME, SHAP), Visualisierungen (Feature Importance, PDP, ICE), Counterfactual Explanations.
- **Surrogatmodelle**: vereinfachte Modelle, die komplexe Modelle approximieren (global oder lokal).
- Globale Methoden: Feature Importance, Permutation Feature Importance, PDP, Global Surrogates. Lokale Methoden: LIME, SHAP, Counterfactuals. Visualisierungen: Feature-Importance-Balkendiagramme, PDP, ICE (individuelle Effekte pro Datenpunkt).

## Interpretierbare Modelle

- **Lineare Regression**: $Y = \beta_0 + \beta_1 X_1 + \dots + \beta_p X_p + \epsilon$ ($\beta_0$ Achsenabschnitt, $\beta_i$ Koeffizienten, $\epsilon$ Fehlerterm).
- **GAMs**: $Y = \beta_0 + f_1(X_1) + \dots + f_p(X_p) + \epsilon$ mit glatten Funktionen $f_i$ für nichtlineare Beziehungen.
- **Entscheidungsbäume**: rekursive Partitionierung des Merkmalsraums; jeder Knoten entscheidet über Merkmal + Schwellenwert; Ziel: maximale Homogenität in den Blättern. [Bild: Beispielbaum mit binären Splits.]

## Modellagnostische Methoden

### Permutation Feature Importance
- Idee: Permutation eines Merkmals zerstört dessen Beziehung zur Zielvariable; steigt der Fehler stark, war das Merkmal wichtig.
- Berechnung mit Modell $f$, Testdaten $D=\{(x_i,y_i)\}_{i=1}^n$, Fehlerfunktion $L$:
  1. $E_{\text{orig}} = \frac{1}{n}\sum_i L(y_i, f(x_i))$
  2. Merkmal $j$ permutieren → $x^{\text{perm}}$
  3. $E_{\text{perm}} = \frac{1}{n}\sum_i L(y_i, f(x_i^{\text{perm}}))$
  4. Importance: $I_j = E_{\text{perm}} - E_{\text{orig}}$

### Partial Dependence Plots (PDP)
- Durchschnittlicher Einfluss eines Merkmals $X_S$ auf die Vorhersage, gemittelt über alle anderen Merkmale $X_C$:
  $\hat{f}_{X_S}(x_S) = \mathbb{E}_{X_C}[f(x_S, X_C)] \approx \frac{1}{n}\sum_{i=1}^n f(x_S, x_{C,i})$
- Plot von $\hat{f}_{X_S}(x_S)$ gegen $x_S$; globale Analyse, zeigt nichtlineare Beziehungen.

### Accumulated Local Effects (ALE)
- Wie PDP, aber berücksichtigt Merkmalsabhängigkeiten → robuster bei korrelierten Features, lokaler.
- $ALE_j(x) = \int_{x_{\min}}^{x} \mathbb{E}\left[\frac{\partial f(x)}{\partial x_j} \,\middle|\, x_j = z\right] dz$, anschließend Mittelwert subtrahieren (zentrierte Effekte).

### SHAP
- Basis: kooperative Spieltheorie (Shapley-Werte) — durchschnittlicher marginaler Beitrag eines Merkmals (Spielers) zur Vorhersage (Spiel).
- $\phi_i = \sum_{S \subseteq N \setminus \{i\}} \frac{|S|!\,(|N|-|S|-1)!}{|N|!}\left[f(S \cup \{i\}) - f(S)\right]$
  - $N$: alle Merkmale; $S$: Teilmenge ohne $i$; $f(S)$: Vorhersage nur mit Merkmalen in $S$; Bruch = Gewichtung über mögliche Reihenfolgen.
  - $\phi_i > 0$: Merkmal erhöht die Vorhersage; $\phi_i < 0$: verringert sie.
- Eigenschaften: **Effizienz** (Summe der Beiträge = Gesamtvorhersage), **Symmetrie** (gleiche Merkmale → gleiche Beiträge), **Dummy** (einflusslose Merkmale → 0), **Additivität** (über Modelle kombinierbar).
- Vorteile: konsistent/fair, modellagnostisch, global + lokal interpretierbar, theoretisch fundiert, gut visualisierbar (Summary/Force Plots). [Bild: SHAP-Summary-Plot — Features vertikal, SHAP-Werte horizontal, Punktfarbe = Featurewert.]

### LIME (lokale Surrogatmodelle)
- Idee: komplexes Modell in der Umgebung eines Datenpunkts durch einfaches Modell (z.B. lineare Regression) approximieren; Erklärung nur lokal gültig. Modellagnostisch, für Tabellen/Text/Bilder. [Bild: nichtlineare Entscheidungsgrenze mit lokal angepasster Geraden um den erklärten Punkt.]
- Vorgehen:
  1. **Nachbardatenpunkte generieren**: $Z = \{(x'_i, f(x'_i))\}$ durch leichte Variation des Originalpunkts.
  2. **Gewichten** nach Ähnlichkeit via Kernel: $\pi(x, x') = \exp\left(-\frac{d(x,x')^2}{\sigma^2}\right)$
  3. **Lokales Modell trainieren**: $\text{Loss}(g,\pi) = \sum_i \pi(x, x'_i)\,(f(x'_i) - g(x'_i))^2$ minimieren.
  4. **Interpretieren**: Koeffizienten von $g$ = lokale Merkmalsbedeutung.
- Beispiel Kreditwürdigkeit (Einkommen 50k€, Alter 35, Schulden 10k€, Vorhersage 85% kreditwürdig): $g(x) = 0.3\cdot\text{Einkommen} - 0.2\cdot\text{Schulden} + 0.1\cdot\text{Alter}$ → Einkommen größter positiver, Schulden negativer Einfluss.
- Einschränkungen: nur lokal gültig; Parameterwahl ($\sigma$) beeinflusst Ergebnis.

### Vergleich modellagnostischer Methoden

| Methode | Vorteile | Nachteile |
|---|---|---|
| Permutation FI | einfach, modellagnostisch | verzerrt bei korrelierten Merkmalen |
| PDP | global, visualisiert Nichtlinearität | ignoriert Merkmalsabhängigkeiten |
| ALE | robust bei Korrelation, lokal | schwerer zu interpretieren als PDP |
| SHAP | global+lokal, theoretisch fundiert | hoher Rechenaufwand bei vielen Merkmalen |
| LIME | flexibel, modellagnostisch, lokal | nur lokal gültig, parameterabhängig |

## Modellabhängige Methoden (v.a. neuronale Netze)

- Nutzen die spezifische Modellstruktur → präziser/effizienter als agnostische Methoden, aber auf Modelltyp beschränkt. Beispiele: Grad-CAM, Integrated Gradients, LRP, Feature Visualization.

### Feature Visualization
- Ziel: welche Muster maximieren die Aktivierung eines Neurons/einer Schicht?
- Optimierungsproblem: $x^* = \arg\max_x A(x) - \lambda R(x)$ — $A(x)$ Aktivierung, $R(x)$ Regularisierung (z.B. Total Variation, L2; ohne sie verrauschte Bilder), $\lambda$ Gewichtung.
- Lösung per Gradient Ascent: $x \leftarrow x + \eta\,\frac{\partial}{\partial x}(A(x) - \lambda R(x))$
- Nutzen: Muster verstehen, Debugging (Neuronen auf irrelevante Muster), Vertrauen.

### Saliency Maps
- Gradient der Vorhersage bzgl. der Eingabe: $S(x) = \left|\frac{\partial f(x)}{\partial x}\right|$ → Heatmap der wichtigsten Pixel/Merkmale. [Bild: Eingabebild neben Gradienten-Heatmap, Objekt hell hervorgehoben.]

### Layer-wise Relevance Propagation (LRP)
- Rückverfolgung der Vorhersage schichtweise auf die Eingabe; Start: $R_j = f(x)$ in der Ausgangsschicht.
- Verteilungsregel: $R_i = \sum_j \frac{z_{ij}}{\sum_k z_{kj}} R_j$ — $z_{ij}$ Beitrag von Neuron $i$ zu $j$.
- Schichtweise Analyse: welche Filter/Neuronen tragen am meisten bei (Conv: wichtigste Filter, FC: wichtigste Neuronen); Nutzen für Architektur-Debugging und Stakeholder-Transparenz.

### Grad-CAM
- Für CNNs: Heatmap relevanter Bildbereiche für Zielklasse $c$.
  1. Gradienten: $\frac{\partial y^c}{\partial A_{ij}^k}$ (Zielklassen-Score bzgl. Feature-Map $A^k$)
  2. Gewichte: $\alpha_k^c = \frac{1}{Z}\sum_i\sum_j \frac{\partial y^c}{\partial A_{ij}^k}$ ($Z$ = Anzahl räumlicher Positionen)
  3. Heatmap: $L^c_{\text{Grad-CAM}} = \text{ReLU}\left(\sum_k \alpha_k^c A^k\right)$
- Anwendungen: Bildklassifikation, medizinische Bildanalyse, CNN-Debugging.
- Herausforderung: nicht durchgängig differenzierbare Modelle (z.B. RCNN mit ROI-Pooling) → ungenaue/fehlende Gradienten; Abhilfe: Approximationen/Varianten.

### Integrated Gradients (IG)
- Gradienten entlang eines geraden Pfads von Baseline $x'$ (z.B. Nullvektor) zur Eingabe $x$ integrieren:
  - Pfad: $x(\alpha) = x' + \alpha(x - x')$, $\alpha \in [0,1]$
  - $\text{IG}_i(x) = (x_i - x'_i)\int_0^1 \frac{\partial f(x(\alpha))}{\partial x_i}\,d\alpha \approx (x_i - x'_i)\cdot\frac{1}{m}\sum_{k=1}^m \frac{\partial f(x(\alpha_k))}{\partial x_i}$
- Eigenschaften: **Vollständigkeit** (Summe der Beiträge = $f(x) - f(x')$); Baseline-Wahl beeinflusst Ergebnis.
- Modellagnostisch für alle differenzierbaren Modelle; Bilder, Text (Token-Beiträge), Tabellen. [Bild: Beispiel-Attributions-Heatmap auf Eingabebild.]

### Vergleich modellabhängiger Methoden

| Methode | Vorteile | Nachteile | Anwendung |
|---|---|---|---|
| Grad-CAM | intuitive Bild-Heatmaps | nur CNNs, Probleme bei Nicht-Differenzierbarkeit | Bildklassifikation, Medizin |
| Integrated Gradients | robust, für alle differenzierbaren Modelle | Baseline-abhängig | Bilder, Text, Tabellen |
| LRP | schichtweise Rückverfolgbarkeit | architekturabhängig | neuronale Netze |

## Interpretation von LLMs

- Herausforderungen: enorme Parameterzahl, nichtlineare Token-Beziehungen.
- **Attention-Visualisierung**: Attention-Matrix zeigt, wie stark Tokens aufeinander achten. $\text{Attention}(Q,K,V) = \text{softmax}\left(\frac{QK^T}{\sqrt{d_k}}\right)V$; Scores als Heatmap (Bsp.: „cat" attendet stark auf „sat", „mat"). Tool: **BertViz**.
- **Feature Attribution**: Token-Beiträge zur Vorhersage via Integrated Gradients (Baseline = leere Tokens) oder SHAP. Bsp.: „The movie was absolutely fantastic" → „fantastic" größter Beitrag zum positiven Sentiment. Tools: **Captum**, **SHAP**, **Transformers Interpret**. [Bild: Balkendiagramm der Token-Wichtigkeit für Sentiment-Beispiel.]
- **Neuronale Aktivierungen**: Aktivierungsmuster einzelner Neuronen analysieren, spezialisierte Neuronen finden (z.B. Neuron reagiert auf Adjektive). $a(x) = \text{ReLU}(Wx + b)$; Aktivierungen über viele Eingaben vergleichen. Tool: **Neuroscope**.

## Quantitative Evaluation von Erklärungen

Bibliothek: **Quantus** (35+ Metriken; github.com/understandable-machine-intelligence-lab/Quantus).

| Metrik | Definition | Formel |
|---|---|---|
| **Faithfulness** | Repräsentiert die Erklärung das Modellverhalten? Merkmal entfernen → starke Vorhersageänderung = wichtiges Merkmal | $\frac{1}{n}\sum_i \|f(x) - f(x \setminus x_i)\|$ |
| **Robustness** | Stabilität bei kleinen Eingabestörungen $\delta$ | $\frac{1}{n}\sum_i \|E(x) - E(x+\delta)\|_2$ (klein = robust) |
| **Plausibility** | Übereinstimmung mit menschlichen Annotationen $A(x)$ | $\frac{1}{n}\sum_i \text{Sim}(E(x), A(x))$ |
| **Complexity** | Verständlichkeit — kürzer = besser | $\text{Length}(E(x))$ |

## Werkzeuge (Gesamtübersicht)

- **SHAP** — Shapley-Werte, alle Modelltypen inkl. Transformer (github.com/slundberg/shap)
- **Captum** — PyTorch: IG, DeepLIFT, Layer Conductance (captum.ai)
- **ELI5** — Sklearn, XGBoost, Keras
- **BertViz** — Attention-Visualisierung (github.com/jessevig/bertviz)
- **Transformers Interpret** — LIME/IG für HuggingFace-Modelle (github.com/cdpierse/transformers-interpret)
- **Quantus** — Erklärungs-Evaluation (JMLR-Paper)
- **AI Explainability 360** (IBM) — ProtoDash, CEM

## Literatur

- Molnar, *Interpretable ML Book*: christophm.github.io/interpretable-ml-book (Kursbegleitbuch)
- *Explainable AI* (Springer 2019), DOI 10.1007/978-3-030-28954-6
- Gilpin 2018, „Explainable AI: A Review" (arxiv 1801.00631)
- Ribeiro 2016, LIME-Paper (arxiv 1602.04938)
- Hedström 2023, „Sanity Checks Revisited" (MPRT-Metriken)
- xkcd 1450 („AI-Box Experiment") als Intro-Illustration
