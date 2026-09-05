# PROJECT — Index & State

Einstiegspunkt für jede Session: High-Level-State mit Verweisen auf `DETAILS.md`,
wo jedes Konzept eine eigene Sektion hat. Chronologie separat in `HISTORY.md`.
Hier bleibt es übersichtlich und menschlich lesbar.

---
# Projektziel & Scope

Abhandlung **„Applied Mechanistic Interpretability Methods"**: mehrere Mech-Interp-
Methoden praktisch auf Open-Source-LLMs anwenden, Modellverhalten analysieren und
dokumentieren. Abgrenzung zu modellagnostischen XAI-Methoden: Untersuchung der
Natur/Interna der Modelle selbst. Beispiel-Interesse: Nebeneffekte von Model-Steering
finden und messen. Explorativ — verschiedene Methoden ausprobieren, verschiedene
Fragen untersuchen, das Ganze dokumentieren.

## Akademischer Rahmen

Modul XAI, FH SWF (F. Neubürger). Einzelprojekt. Keine explizite Forschungsfrage
nötig (Absprache mit Dozent per Mail). Zwischenpräsentation: 11.07.2026.
Abgabe: Ausarbeitung einen Tag vor der Blockwoche, Vortrag in der Blockwoche;
Bewertung 50 % Ausarbeitung / 50 % Vortrag.

---
# Status

- Methodik-Scaffold auf Stand des Methodik-Repos (`6815a2e`, siehe Stempel in `CLAUDE.md`).
- Umgebung verifiziert (TransformerLens-Stack gepinnt, alle 3 Modelle im HF-Cache,
  Smoke-Test bestanden, MPS-Korrektheit gemessen) → DETAILS „Umgebung & Tooling" +
  „Numerik-Policy". Umgebung am 2026-08-24 nach dem Umzug neu gebaut (jetzt über uv),
  Smoke-Test bestanden — einsatzbereit.
- Repo lokal unter `~/dev/private_repos/mechinterp_xai`, auf GitHub `Henroxx/mechinterp_xai`
  (Dozent hat Zugriff; .venv/.claude ignoriert).
- Themen-Kandidaten A–F destilliert, Ranking vorgeschlagen → DETAILS „Themen-Kandidaten".
- **Zwischenpräsentation am 11.07. gehalten und abgeschlossen** — Material liegt in
  `presentation/zwischenpraesi.html`, ist für die weitere Arbeit aber nicht mehr relevant.
- Lerndokument für Henry angelegt: `docs/learning/index.html` (SteeringSafety im Volltext,
  Messmethodik, Metrik-Kritik, Werkzeugkasten, Glossar) — wächst iterativ, siehe CLAUDE.md „Doku".
- Einarbeitung abgeschlossen (2026-09-05) → DETAILS „GPT-2 small — Befunde aus der
  Einarbeitung". Noch keine Experimente für die Abhandlung. Aktuell: Fahrplan Schritt 2.

---
# To-Dos & offene Entscheidungen

- [ ] **Fahrplan** (Henry, 2026-08-25) — vier Schritte, in dieser Reihenfolge:
      1. **Einarbeitung** — erledigt 2026-09-05: TransformerLens auf GPT-2 small, alle
         Werkzeuge einmal angefasst → `notebooks/01_explore.ipynb`, DETAILS „GPT-2 small".
      2. **Forschungsstand mappen** — Überblick gewinnen, Teile davon können in die
         Abhandlung (Methodenkritik). Rohstoff: DETAILS „Forschungsstand", „SAE-Kritik",
         Lerndokument. ← *hier stehen wir*
      3. **Reproduzieren oder Lücke** — Bekanntes auf anderen Modellen nachbauen oder eine
         Lücke strukturiert angehen; 2–3 kleine Experimente, nicht tief.
      4. Themenwahl fällt erst *nach* Schritt 2. Bis dahin sind Lücken und Ideen Kandidaten,
         kein Zuschnitt.
- [x] **Paketverwaltung auf uv umgestellt** (2026-08-24): `pyproject.toml` + committetes
      `uv.lock`, `requirements.txt` und alte venv gelöscht, jupyter und circuitsvis dazu.
      Grund: `requirements.txt` pinnte nur die 8 direkten Pakete, die transitiven kamen
      unkontrolliert dazu — erst das Lockfile macht die Messungen reproduzierbar.
      → DETAILS „Umgebung & Tooling"
- [x] **Web-Recherche 2026-08-24** → DETAILS „Forschungsstand Steering-Nebeneffekte",
      „SAE-Kritik", „Tooling-Realität", „Lehrmaterial"
- [ ] **Beitrag neu zuschneiden** (Henry) — die Grundform „Refusal-Steering anwenden und
      Nebenwirkungen messen" ist publiziert (SteeringSafety, arXiv:2509.13450, auf genau
      Gemma-2-2B). Offene Lücken auf Metrik-, Dosis- und Kontroll-Ebene → DETAILS
      „Forschungsstand", Abschnitt „Offene Lücken"
- [ ] **TransformerLens-Version entscheiden — erst vor der ersten Gemma-Messung.**
      Für die GPT-2-Einarbeitung irrelevant (die `transformers`-v5-Änderung am
      Embedding-Scaling betrifft nur Gemma). Installiert 3.5.1 (verifiziert), aktuell 3.8.0;
      Upgrade verlangt neuen `verify_mps.py`-Lauf. Dazu `enable_compatibility_mode()` bewusst
      setzen oder nicht → DETAILS „Tooling-Realität"
- [x] **Zwischenpräsi 11.07.**: gehalten, Thema abgeschlossen
- [x] Modellwahl: **Gemma-2-2B (base+it)** als Haupt-Modell, GPT-2 small als
      Ground-Truth-Zweitmodell → DETAILS „Modellwahl"
- [x] Smoke-Test + MPS-Verifikation (`scripts/smoke_test.py`, `scripts/verify_mps.py`)
- [x] **Sprache der Abhandlung: Englisch** (2026-08-24). Grund: die gesamte Literatur und
      Terminologie ist englisch, Rückübersetzen von Fachbegriffen erzeugt nur Unschärfe.
      → `report/main.typ` muss noch umgestellt werden
- [ ] **Vertiefung** (Henrys Verständnis, für die Verteidigung):
      Grokking-Beispiel (Nanda, Addition mod 113) durcharbeiten; Linear Representation
      Hypothesis sauber durchsprechen (konnte Henry noch nicht frei erklären)
- [x] Format der Abhandlung: **Typst**, Template aus Big-Data-Projekt adaptiert
      (`report/main.typ`, kompiliert). Umfang und Gliederung noch offen.

---
# Referenzen

- Kurs-Repo (Slides-Quelle, Exercises): `~/Documents/Master/4. Semester/XAI/XAI_course`
- Lerndokument: `docs/learning/index.html`
- Papers (PDF): `~/Documents/Master/4. Semester/XAI/` (u. a. SteeringSafety)
- Notebooks: `notebooks/` — `01_explore.ipynb` ist die Einarbeitung
