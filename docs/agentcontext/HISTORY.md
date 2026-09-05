# HISTORY — Chronologie

Datum | was | warum. Schlank und schnell überblickbar. Material für die Abhandlung.
Details gehören nach DETAILS, hier steht nur, was wann passiert ist und weshalb.

---

- **2026-07-10** | Projekt-Setup: Methodik, Context-Struktur, `/handoff`-Skill; Typst als
  Format der Abhandlung (Template aus dem Big-Data-Projekt adaptiert) | Arbeitsgrundlage
  vor der Zwischenpräsentation.
- **2026-07-10** | Themen-Landkarte Mech-Interp in 7 Blöcken erstellt, daraus Kandidaten
  A–F destilliert und ein Ranking vorgeschlagen | Basis für die Themenwahl; Henrys Fokus:
  methodenkritisch, Steering-Nebeneffekte. → DETAILS „Themen-Kandidaten".
- **2026-07-10** | Modellwahl Gemma-2-2B base+it (Haupt) und GPT-2 small (Ground Truth);
  venv Python 3.13 + TransformerLens 3.5.1 | Begründung → DETAILS „Modellwahl". Smoke-Test
  bestanden, Stack einsatzbereit.
- **2026-07-10** | MPS-Korrektheit selbst verifiziert (`verify_mps.py`), nachdem
  TransformerLens vor "silently incorrect results" warnte | Warnung entkräftet, Rauschgrenze
  bestimmt → DETAILS „Numerik-Policy". Nebenbefund fürs Narrativ der Abhandlung:
  Messinstrument-Verifikation als gelebte Methodenkritik.
- **2026-07-10** | Repo auf GitHub veröffentlicht (`Henroxx/mechinterp_xai`, Dozent hat
  Zugriff) | Setup-Stand gesichert.
- **2026-07-11** | Zwischenpräsentation gebaut und gehalten: `presentation/zwischenpraesi.html`,
  13 Scroll-Folien von der XAI-Einordnung über Mech-Interp-Grundlagen bis zum Experiment-Plan,
  Diagramme als eigenes Inline-SVG | HTML statt Slides, um offline und ohne Dependencies
  eigene Visualisierungen zu zeigen. Thema danach abgeschlossen.
- **2026-07-11** | Nebenwirkungs-Messprotokoll für Steering ausgearbeitet und die zwei
  Herkunftswege einer Steering-Richtung getrennt (kontrastiv vs. SAE-Feature) | → DETAILS
  „Steering — Messprotokoll"; die Trennung präzisiert Kandidat D.
- **2026-08-09** | Projekt von OneDrive nach `~/dev/private_repos/mechinterp_xai` umgezogen,
  Kursunterlagen nach iCloud | OneDrive wird nicht mehr benutzt und bald gelöscht.
- **2026-08-24** | Umgebung im neuen Pfad neu gebaut, Smoke-Test bestanden | nach dem Umzug
  bestätigt; Generierungstempo mit ~2,7 Token/s gemessen, vorher zu pessimistisch mit
  ~1 Token/s notiert.
- **2026-08-24** | Methodik-Scaffold auf den Stand des Methodik-Repos gebracht (`6815a2e`):
  `context/` → `docs/agentcontext/`, `plans/` eingeführt, CLAUDE.md um Code-, Git- und
  Aufräumregeln erweitert, Handoff-Skill mit Aufräum-Schritt, Versionsstempel | Projekt war
  vor dem Methodik-Repo aufgesetzt und hatte keinen Stempel — `/update-project` läuft jetzt.
- **2026-08-24** | Paketverwaltung von venv+`requirements.txt` auf **uv** umgestellt
  (`pyproject.toml` + committetes `uv.lock`), jupyter und circuitsvis aufgenommen;
  Abhandlungssprache auf **Englisch** festgelegt | Lockfile pinnt den ganzen
  Abhängigkeitsbaum statt nur der 8 direkten Pakete — Reproduzierbarkeit statt Behauptung.
- **2026-08-24** | Entschieden: vor dem Kernexperiment eine spielerische Einarbeitungsphase
  auf GPT-2 small (schneller Loop: 8 s Ladezeit gegen 5 min bei Gemma) | Henry will die
  Werkzeuge einmal selbst angefasst haben, bevor A/B als Experiment aufgesetzt wird.
- **2026-08-24** | Literatur- und Tooling-Recherche zum Stand 2025/26 (Subagent) | Befund:
  die Grundform des geplanten Kernexperiments ist publiziert (SteeringSafety, auf genau
  Gemma-2-2B) — der eigene Beitrag muss auf Metrik-, Dosis- und Kontroll-Ebene liegen.
  → DETAILS „Forschungsstand Steering-Nebeneffekte", „SAE-Kritik", „Tooling-Realität".
- **2026-08-25** | SteeringSafety im Volltext gelesen, Lerndokument `docs/learning/index.html`
  angelegt | Der Volltext korrigierte mehrere Abstract-basierte Aussagen → DETAILS
  „Forschungsstand". Lesen aus zweiter Hand reicht für Orientierung, nicht für Aussagen.
- **2026-08-25** | Fahrplan: Einarbeitung (GPT-2) → Forschungsstand → reproduzieren/Lücke →
  2–3 kleine Experimente; Themenwahl erst nach Schritt 2 | Henry will das Feld überblicken,
  bevor er sich festlegt → PROJECT „Fahrplan", CLAUDE.md-Regel „Themenwahl bleibt offen".
