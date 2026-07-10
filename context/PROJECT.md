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

- Projekt-Setup: Methodik (`CLAUDE.md`), Context-Struktur, `/handoff`-Skill,
  Typst-Template (2026-07-10).
- Vorlesungs-Slides als Kondensat verfügbar: `xai_slides.md`.
- Umgebung steht und ist verifiziert: venv (Python 3.13), TransformerLens-Stack gepinnt,
  alle 3 Modelle im HF-Cache, Smoke-Test bestanden, MPS-Korrektheit gemessen.
  → DETAILS „Umgebung & Tooling" + „Numerik-Policy"
- Repo auf GitHub: `Henroxx/mechinterp_xai` (Dozent hat Zugriff; .venv/.claude ignoriert).
- Themen-Kandidaten A–F destilliert, Ranking vorgeschlagen → DETAILS „Themen-Kandidaten".
- Noch keine Experimente.

---
# To-Dos & offene Entscheidungen

- [ ] **Themen-Ranking entscheiden** (Henry) — Vorschlag liegt vor → DETAILS
      „Themen-Kandidaten & Ranking"
- [ ] Web-Recherche: Stand 2025/26 zu Steering-Nebeneffekten + SAE-Kritik verifizieren
      (wo docken wir an, was ist schon gemacht?); TransformerLens-Support für Gemma-3 prüfen
- [ ] **Zwischenpräsi 11.07.**: Material zusammenstellen (Setup + geplante Experimente
      + MPS-Verifikation als Teaser)
- [x] Modellwahl: **Gemma-2-2B (base+it)** als Haupt-Modell, GPT-2 small als
      Ground-Truth-Zweitmodell → DETAILS „Modellwahl"
- [x] Smoke-Test + MPS-Verifikation (`scripts/smoke_test.py`, `scripts/verify_mps.py`)
- [ ] Sprache der Abhandlung festlegen (Deutsch/Englisch — Template steht aktuell auf Deutsch)
- [x] Format der Abhandlung: **Typst**, Template aus Big-Data-Projekt adaptiert
      (`report/main.typ`, kompiliert). Umfang und Gliederung noch offen.

---
# Referenzen

- Vorlesungsstoff: `context/xai_slides.md`
- Kurs-Repo: `../XAI_course/` (Slides-Quelle, Exercises)
