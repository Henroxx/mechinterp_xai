# HISTORY — Chronologie

Datum | was | warum. Schlank und schnell überblickbar. Material für die Abhandlung.

---

- **2026-07-10** | Projekt-Setup: Methodik (CLAUDE.md), Context-Struktur, /handoff-Skill
  aus Big-Data-Projekt adaptiert; Vorlesungs-Slides als Kondensat (`xai_slides.md`)
  angelegt | Arbeitsgrundlage vor der Zwischenpräsentation am 11.07.
- **2026-07-10** | Typst-Template aus Big-Data-Projekt nach `report/` adaptiert
  (kompiliert) | Abhandlungs-Format entschieden: Typst.
- **2026-07-10** | Themen-Landkarte Mech-Interp (7 Blöcke: Theorie, Beobachtung, SAEs,
  Interventionen, Circuits, Safety-Anwendungen, Tooling) | Überblick als Basis für
  Themenwahl; Henrys Fokus: methodenkritisch, Steering-Nebeneffekte.
- **2026-07-10** | Modellwahl: Gemma-2-2B base+it (Haupt), GPT-2 small (Ground Truth);
  venv Python 3.13 + TransformerLens 3.5.1; Downloads in HF-Cache | Begründung → DETAILS.
- **2026-07-10** | Smoke-Test bestanden (beide Modelle laden auf MPS, Generation kohärent,
  run_with_cache funktioniert) | Stack für Experimente einsatzbereit.
- **2026-07-10** | MPS-Korrektheit selbst verifiziert (`verify_mps.py`), nachdem
  TransformerLens vor "silently incorrect results" warnte: Issue-Bug in torch 2.13
  behoben (GPT-2 fp32 exakt identisch CPU/MPS); Gemma-bf16-Abweichungen = normales
  Rundungsrauschen | Numerik-Policy festgelegt → DETAILS. Nebenbefund fürs
  Abhandlungs-Narrativ: Messinstrument-Verifikation als gelebte Methodenkritik.
- **2026-07-10** | Repo auf GitHub veröffentlicht (Henroxx/mechinterp_xai, Dozent hat
  Zugriff); README (EN), .gitignore (.venv/.claude), context/ klein geschrieben |
  Setup-Stand gesichert vor der Zwischenpräsi.
- **2026-07-10** | Themen-Kandidaten A–F destilliert und Ranking vorgeschlagen
  (Herzstück: Steering-Nebeneffekte an der Refusal Direction) | Entscheidung von
  Henry steht aus → DETAILS „Themen-Kandidaten".
- **2026-07-11** | Zwischenpräsentation gebaut: `presentation/zwischenpraesi.html` —
  selbst-enthaltene HTML-Seite, 13 Scroll-Folien (XAI-Einordnung → Mech-Interp-Grundlagen
  mit eigenen SVG-Diagrammen: Residual Stream, Polysemantizität, Superposition,
  Features-als-Richtungen, Activation Patching → Setup → Experiment-Plan). Vorher
  inhaltliche Vorbereitung im Chat (Logit Lens, Feature Attribution, Patching-Folie
  durchgesprochen) | Format-Entscheidung: HTML statt Slides (freies Scrollen + eigene
  Visualisierungen, offline, keine Dependencies). Bewusst weggelassen: MPS-Verifikation,
  Repo-Details, Grokking, LRH im Detail, eigene Take-away-Folie. Quellen als Fußzeilen
  pro Folie.
