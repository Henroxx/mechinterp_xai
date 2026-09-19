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
nötig (Absprache mit Dozent per Mail). Zwischenpräsentation: 11.07.2026 — damit ist der
Vortragsanteil abgegolten (Henry, 2026-09-18). **Eine Blockwoche gibt es nicht** — die Annahme
war veraltet, es hängt kein Termin daran (Henry, 2026-09-19). Bewertung 50 % Ausarbeitung /
50 % Vortrag; der Vortragsteil ist gehalten, offen ist nur noch die Ausarbeitung, ohne fixes Datum.

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
  small". Station Gemma-2-2B-Tour erledigt (2026-09-18) → DETAILS „Gemma-2-2B — Befunde aus der Tour".
  Station SAE-Blick erledigt (2026-09-18) → DETAILS „SAE — Befund GPT-2 small"; **Schnuppertour damit
  abgeschlossen**. Forschungsstand als Landkarte gemappt (2026-09-18) →
  `details/forschungsstand.md`. **Entscheidung gefallen (Henry, 2026-09-19): Kandidat D, „Lesen
  gegen Steuern"**. Beide Anker-Arbeiten am 2026-09-19 im Volltext
  gelesen und der ausgearbeitete Plan geschrieben; `A_lin` auf GPT-2 small vorgemessen, um die
  Modellwahl zu entscheiden. Anker reproduziert (2026-09-19) → DETAILS „Lesen gegen Steuern — Anker-Reproduktion",
  `notebooks/07_reading_vs_steering.ipynb`. Eigenes Experiment durchgeführt (2026-09-19) →
  DETAILS „Lesen gegen Steuern — Richtungsquellen bei gleicher Wirkung",
  `notebooks/08_direction_sources.ipynb`. **Phase 5 damit abgeschlossen.** Struktur und Eckdaten der
  Abhandlung entschieden (2026-09-19) → `plans/abhandlung.md`. Aktuell: **Phase 7, Schreiben** —
  Vorarbeit erledigt (`report/main.typ` englisch und neu gegliedert, `refs.bib` angelegt, Figuren
  als Vektor exportiert) und **alle Abschnitte geschrieben, keine TODOs mehr im Text** (2026-09-19):
  Abstract, 1 „Introduction" (¾ Seite), 2 „Background" (eigene SVG-Grafik, LRH, Methodentabelle),
  3 „Exploration" (Tour als Tabelle plus Modellwahl), 4 „Choosing the question", 5 „Reading versus
  steering" (Hauptteil, vier Figuren, drei Tabellen — darunter neu die Dosis-Konfundierung pro
  Schicht und das Schema der drei Vergleichsarten), 6 „Conclusion", Kasten „Use of AI" mit Pfadtabelle
  unter dem Abstract, Anhang mit Repo-Link, Tag und Mess-Pfaden. Ein Review-Durchgang ist durch
  (Zahlen-Inkonsistenzen, Redundanzen, LLM-Klang → HISTORY). Hauptteil ~10,5 Seiten inkl. gut 1,5
  Seiten Grafiken, **nicht gekürzt** → `plans/abhandlung.md` „Entschieden im Review-Durchgang".
  **Offen: Henrys Leserunde (Schritt 22), drei Literatureinträge ohne `note`-Feld, „5 of 23" beim
  Anker prüfen, Untertitel, Tag `v1.0-submission`.** Fortschritt → `docs/fahrplan/index.html`, Phase 7.

---
# To-Dos & offene Entscheidungen

- [ ] **Fahrplan** (Henry, 2026-08-25; auf sechs Phasen umgebaut 2026-09-16) — Sicht darauf:
      `docs/fahrplan/index.html`. Ein Schritt = ein Arbeitsblock mit eigenem Ergebnis.
      1. **Einarbeitung** — erledigt 2026-09-05 → `notebooks/01_explore.ipynb`, DETAILS „GPT-2 small".
      2. **Schnuppertour** — jede Methode einmal klein, eine Session und ein Notebook pro Station:
         Patching (erledigt 2026-09-16 → DETAILS „Activation Patching"), Steering (erledigt
         2026-09-18 → DETAILS „Steering — Befund GPT-2 small"), Probing (erledigt 2026-09-18 → DETAILS „Probing — Befund GPT-2 small"),
         Gemma-2-2B-Tour (erledigt 2026-09-18 → DETAILS „Gemma-2-2B — Befunde aus der Tour"),
         SAE-Blick (erledigt 2026-09-18 → DETAILS „SAE — Befund GPT-2 small"). Tour abgeschlossen.
      3. **Forschungsstand mappen** — erledigt 2026-09-18 → `details/forschungsstand.md`:
         Tabelle über vier Methoden, dazu Patching und Probing neu recherchiert. Volltext erst
         für die gewählte Sache.
      4. **Entscheidung** — erledigt 2026-09-19: Kandidat D, „Lesen gegen Steuern".
      5. **Vertiefung** — erledigt 2026-09-19: Volltexte gelesen, Plan geschrieben, Anker
         reproduziert (Schritte 11–12), eigenes Experiment mit
         Kontrolle durchgeführt (Schritt 13 → DETAILS „Richtungsquellen bei gleicher Wirkung").
      6. **Abhandlung** — erledigt 2026-09-19: Struktur, Seitenbudget und Kernaussagen abgestimmt
         → `plans/abhandlung.md`.
      7. **Schreiben** ← *hier stehen wir* — ein Schritt pro Abschnitt in der Schreibreihenfolge
         5 → 4 → 3 → 2 → 6 → 7 → 1 → Abstract, je mit den Konzepten, die Henry dafür verstehen
         muss. Sicht darauf: `docs/fahrplan/index.html`, Phase 7. Kein Vortrag mehr nötig.
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
- [x] **Web-Recherche 2026-08-24** (Steering, SAE) und **2026-09-18** (Patching, Probing)
      → `details/forschungsstand.md`; dazu DETAILS „Tooling-Realität", „Lehrmaterial"
- [x] **Beitrag zugeschnitten: Kandidat D, „Lesen gegen Steuern"** (Henry, 2026-09-19).
      Drei Richtungsquellen (Mittelwertdifferenz, Probe, SAE-Feature) auf beiden Achsen messen:
      Lesegüte gegen Steuerwirkung. Grund für D gegen die Alternativen: zieht die Stationen 2, 3
      und 5 zusammen, braucht kein neues Tooling und keinen fremden Benchmark-Code, hat mit
      Billa (arXiv:2604.15557) einen Anker zum Reproduzieren, und sitzt auf der Kernfrage der
      Landkarte. Kandidat C (Control Task) ist als Schritt 3 darin enthalten; Kandidat B
      (Steering-Dosisachse mit Benchmarks) wurde wegen Bauaufwand verworfen, nicht wegen
      Laufzeit. Umfang bewusst klein gehalten — Uni-Projekt, keine Masterarbeit.
      → DETAILS „Lesen gegen Steuern — Anker-Reproduktion" und „… Richtungsquellen bei gleicher
      Wirkung"; Plan abgearbeitet in `plans/done/`.
- [x] **TransformerLens bleibt auf 3.5.1** (Henry, 2026-09-18). Grund: der Gemma-2-Pfad ist bis
      3.9.0 bis auf einen für uns wirkungslosen Sliding-Window-Fix unverändert, ein Upgrade
      kostete Neu-Verifikation und Deprecation-Warnungen. `enable_compatibility_mode()` betrifft
      nur `TransformerBridge`, nicht unseren Pfad → DETAILS „Tooling-Realität"
- [x] **Zwischenpräsi 11.07.**: gehalten, Thema abgeschlossen
- [x] Modellwahl: **Gemma-2-2B (base+it)** als Haupt-Modell, GPT-2 small als
      Ground-Truth-Zweitmodell → DETAILS „Modellwahl"
- [x] Smoke-Test + MPS-Verifikation (`scripts/smoke_test.py`, `scripts/verify_mps.py`)
- [x] **Sprache der Abhandlung: Englisch** (2026-08-24). Grund: die gesamte Literatur und
      Terminologie ist englisch, Rückübersetzen von Fachbegriffen erzeugt nur Unschärfe.
      `report/main.typ` am 2026-09-19 umgestellt.
- [x] **Zuschnitt der Abhandlung entschieden** (Henry, 2026-09-19) → `plans/abhandlung.md`:
      Technical Report auf Englisch, unter 10 Seiten Hauptteil, jeder Abschnitt beginnt mit „was und
      warum" vor dem Detail. Grund für die Skip-Ebene: die Zeit des Dozenten wertschätzen, er soll
      überspringen können, was er nicht braucht. Erste Person für Entscheidungen; KI-Nutzung als
      **ein Kasten „Use of AI" unter dem Abstract plus Pfadtabelle** (Henry, 2026-09-19: der
      geplante Abschnitt 7 war „viel zu viel Text", der Satz in der Introduction entfällt damit
      auch), keine Zuschreibung pro Schritt. Selbstzitate zeigen
      auf den Tag `v1.0-submission`, nicht auf `main` — Branch-Links brechen beim nächsten Push.
      Schreibreihenfolge 5 → 4 → 3 → 2 → 6 → 1 → Abstract. **Ablauf pro Abschnitt geändert
      (Henry, 2026-09-19):** erst schreiben, dann verstehen — die ursprünglich geplanten fünf
      Lückenfragen vorab setzten Kenntnis voraus, die der Abschnitt erst herstellt, und waren bei
      Abschnitt 5 unbeantwortbar. Henry liest den fertigen Abschnitt und fragt; am Ende geht es für
      die Verständnisrunde zu Abschnitt 5 zurück.
- [x] **Repo wird öffentlich** (Henry, 2026-09-19). Vorher geprüft: keine Secrets, keine
      Mailadressen in Dateiinhalten, keine Mailzitate in der History, `.claude/` ignoriert.
      Zwei Funde, beide von Henry als unkritisch entschieden: das Slides-Kondensat
      `context/xai_slides.md` liegt noch in der History (Commit `261000b`) — die Folien des
      Dozenten sind selbst öffentlich auf GitHub —, und vier Commits tragen `hbrose@neuland.ai`
      statt der GitHub-Noreply-Adresse. Kein History-Rewrite. Offen bleibt nur: der Tag
      `v1.0-submission`, auf den die Selbstzitate zeigen, existiert noch nicht.
- [ ] **Vertiefung** (Henrys Verständnis, für die Verteidigung):
      Grokking-Beispiel (Nanda, Addition mod 113) durcharbeiten; Linear Representation
      Hypothesis sauber durchsprechen (konnte Henry noch nicht frei erklären; Erklärung
      mit Grafik seit 2026-09-18 im Lerndokument, Abschnitt 6)
- [x] Format der Abhandlung: **Typst**, Template aus Big-Data-Projekt adaptiert
      (`report/main.typ`, kompiliert). Gliederung steht seit 2026-09-19, Literatur in
      `report/refs.bib` (IEEE), Figuren als Vektor-PDF in `report/figures/`.

---
# Referenzen

- Kurs-Repo (Slides-Quelle, Exercises): `~/Documents/Master/4. Semester/XAI/XAI_course`
- Lerndokument: `docs/learning/index.html`
- Papers (PDF): `~/Documents/Master/4. Semester/XAI/` (u. a. SteeringSafety)
- Notebooks: `notebooks/` — `01_explore.ipynb` ist die Einarbeitung
- Fahrplan-Dashboard: `docs/fahrplan/index.html` — Henrys Sicht auf die Schritte. Nach jedem
  abgeschlossenen Schritt zusammen mit dem Fahrplan hier pflegen: `status` und `STAND` im
  Datenblock der Datei, sonst nichts.
