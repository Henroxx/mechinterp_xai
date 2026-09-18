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
  Messmethodik, Metrik-Kritik, Werkzeugkasten, Richtungen im Residual Stream mit LRH und vier
  Wegen, Sparse Autoencoder mit Rechenbeispiel, Glossar) — wächst iterativ, siehe CLAUDE.md „Doku".
- Einarbeitung abgeschlossen (2026-09-05) → DETAILS „GPT-2 small". Schnuppertour läuft:
  Station Patching erledigt (2026-09-16) → DETAILS „Activation Patching". Noch keine
  Experimente für die Abhandlung. Station Steering erledigt (2026-09-18) → DETAILS „Steering —
  Befund GPT-2 small". Station Probing erledigt (2026-09-18) → DETAILS „Probing — Befund GPT-2
  small". Aktuell: Gemma-2-2B-Tour, vorher TL-Version entscheiden (To-Do unten).

---
# To-Dos & offene Entscheidungen

- [ ] **Fahrplan** (Henry, 2026-08-25; auf sechs Phasen umgebaut 2026-09-16) — Sicht darauf:
      `docs/fahrplan/index.html`. Ein Schritt = ein Arbeitsblock mit eigenem Ergebnis.
      1. **Einarbeitung** — erledigt 2026-09-05 → `notebooks/01_explore.ipynb`, DETAILS „GPT-2 small".
      2. **Schnuppertour** — jede Methode einmal klein, eine Session und ein Notebook pro Station:
         Patching (erledigt 2026-09-16 → DETAILS „Activation Patching"), Steering (erledigt
         2026-09-18 → DETAILS „Steering — Befund GPT-2 small"), Probing (erledigt 2026-09-18 → DETAILS „Probing — Befund GPT-2 small"),
         Gemma-2-2B-Tour (vorher TL-Version entscheiden) ← *hier stehen wir*, SAE-Blick optional.
      3. **Forschungsstand mappen** — eine Seite Methode × Modell × Messung × Lücke, Rohstoff
         DETAILS „Forschungsstand", „SAE-Kritik". Volltext erst für die gewählte Sache.
      4. **Entscheidung** — Kandidaten gegen Kriterien, *eine* Sache: Methode, Modell, Frage,
         Kontrolle, Anker. Bis dahin sind Lücken und Ideen Kandidaten, kein Zuschnitt.
      5. **Vertiefung** — die Papers dazu im Volltext, Plan, Anker reproduzieren, eigenes Experiment.
      6. **Abhandlung & Vortrag** — Struktur abstimmen, Typst auf Englisch, Vortrag.
      Schnuppern vor Lesen ist Claudes Vorschlag (bei Henry bleibt Gemachtes hängen, Gelesenes
      weniger), von Henry mit dem Dashboard angenommen.
- [x] **Umfang: breit schnuppern, eine Sache vertiefen** (Henry, 2026-09-16). Im Notebook
      einmal überall reinschauen, auch Gemma-2-2B; die Vertiefung am Ende ist *eine* simple
      Sache mit Zeit zum Verstehen, keine Masse. Grund: Henry muss alles, was in die
      Abhandlung kommt, nachvollziehen und verteidigen können.
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
- [ ] **Datum der Blockwoche und damit der Abgabe klären** (Henry) — steht nirgends in den Docs,
      ohne Datum ist die Zeitplanung der Phasen 5–6 offen.
- [ ] **Vertiefung** (Henrys Verständnis, für die Verteidigung):
      Grokking-Beispiel (Nanda, Addition mod 113) durcharbeiten; Linear Representation
      Hypothesis sauber durchsprechen (konnte Henry noch nicht frei erklären; Erklärung
      mit Grafik seit 2026-09-18 im Lerndokument, Abschnitt 6)
- [x] Format der Abhandlung: **Typst**, Template aus Big-Data-Projekt adaptiert
      (`report/main.typ`, kompiliert). Umfang und Gliederung noch offen.

---
# Referenzen

- Kurs-Repo (Slides-Quelle, Exercises): `~/Documents/Master/4. Semester/XAI/XAI_course`
- Lerndokument: `docs/learning/index.html`
- Papers (PDF): `~/Documents/Master/4. Semester/XAI/` (u. a. SteeringSafety)
- Notebooks: `notebooks/` — `01_explore.ipynb` ist die Einarbeitung
- Fahrplan-Dashboard: `docs/fahrplan/index.html` — Henrys Sicht auf die Schritte. Nach jedem
  abgeschlossenen Schritt zusammen mit dem Fahrplan hier pflegen: `status` und `STAND` im
  Datenblock der Datei, sonst nichts.
