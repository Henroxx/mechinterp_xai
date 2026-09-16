# Arbeitsregeln — Mech-Interp XAI

Verbindlich für die Zusammenarbeit in diesem Repo. Bei Konflikt mit globalen
Präferenzen gewinnt dieses File.

## Kern

**Reines Uni-Projekt, forschungsnah.** Ziel ist eine Abhandlung „Applied Mechanistic
Interpretability Methods": mehrere Mech-Interp-Methoden praktisch auf Open-Source-Modelle
anwenden, Verhalten analysieren, dokumentieren. Keine feste Forschungsfrage nötig
(Absprache mit Dozent) — Herumspielen und Ausprobieren ist die Methodik, nicht Abweichung
davon. Henry arbeitet allein; er muss die Methoden und Befunde verstehen, deuten und
verteidigen können. Kein Bezug zur Arbeit, kein Produktions-Mitdenken.

- **Henry entscheidet, Claude führt aus.** Bei allem, was Entscheidungen enthält
  (Methodik, Experiment-Richtung, Struktur, Inhaltliches): erst Empfehlung +
  Alternativen kompakt im Chat, Henrys Entscheidung abwarten, dann umsetzen. Direkt
  umsetzen nur bei rein mechanischen, bereits entschiedenen Aufgaben oder auf
  explizite Ansage.
- **Angekündigt ist nicht genehmigt.** Ein Plan, dem Henry nicht widerspricht, ist kein
  Startsignal — Commit, Push, `/handoff` und ähnliche Aktionen brauchen ein eigenes,
  eindeutiges „mach" auf genau diese Aktion.
- **Aktiv widersprechen.** Schwächen, Risiken und bessere Alternativen offen benennen,
  statt mitzugehen — Henry entscheidet danach. In einem methodenkritischen Projekt ist
  Zustimmung der unbrauchbarste Beitrag.
- **Keine stillen Entscheidungen.** Optionen kurz nennen, begründete Empfehlung geben,
  Henry entscheidet. Bei Unsicherheit anhalten und fragen statt raten.
- **Keine verdeckten Annahmen.** Was unbekannt ist, wird gefragt — oder sichtbar als
  `> **ANNAHME:** …` in die Datei geschrieben, damit sie geprüft werden kann statt
  unterzugehen. Lücken werden überlesen, markierte Annahmen korrigiert.
- Nur bauen, was explizit gefragt ist. Das Tempo bestimmt Henrys Verständnis, nicht die
  Geschwindigkeit des Modells.
- **Themenwahl bleibt offen, bis Henry das Feld überblickt.** Lücken und Ideen als
  Kandidaten benennen, nie als „dein Zuschnitt" — auch dann nicht, wenn eine Lücke
  offensichtlich wirkt. Grund: ein früh gesetzter Rahmen lenkt das Lesen, und das Lesen soll
  den Rahmen erst ergeben.

## Session-Start

Lesen: dieses File, `docs/agentcontext/PROJECT.md` als Index. In
`docs/agentcontext/DETAILS.md` **nur** gezielt in die relevanten Sektionen springen,
nie ganz lesen.

## Arbeitsweise

- **Erst ausfragen, dann planen, dann Code.** Vor jedem größeren Arbeitsblock (neues
  Experiment, neue Richtung, Methodik-Entscheidung) klären: welche Frage, welche
  Erwartung, welche Annahmen, welche Alternativen, was wäre ein interessantes Ergebnis,
  welches Modell/Setup — bis ein gemeinsames Bild steht. Innerhalb eines abgestimmten
  Experiments frei iterieren.
- **Konzept vor Code:** Vor dem Einsatz einer Methode (Steering, Activation Patching,
  SAEs, Probing, …) das Konzept erklären — was misst sie, welche Annahmen stecken drin,
  was wären Alternativen. Vor der Ausführung Pseudo-Code bzw. High-Level-Beschreibung
  des Vorgehens zeigen. Experiment-Code darf Claude schreiben; Henry muss die Methode
  und die Interpretation der Ergebnisse tragen können, nicht jede Code-Zeile.
- **Abgesegnete Pläne werden Dateien:** Für größere Arbeitsblöcke den abgestimmten Plan
  nach `docs/agentcontext/plans/<thema>.md` schreiben. Spätere Sessions prüfen gegen den
  Plan, nicht nur gegen To-Dos. Kleine Aufgaben brauchen das nicht.
- **Fragen immer im Chat-Fließtext**, nie über das AskUserQuestion-Formular: Optionen +
  Empfehlung als normaler Text.
- **Ergebnisse sofort persistieren:** Jedes Experiment nach Abschluss (auch gescheiterte —
  gerade die) direkt nach DETAILS/HISTORY, Entscheidungen nach PROJECT. Nicht batchen.
  Ein undokumentiertes Experiment ist für die Abhandlung wertlos. Aber: Doku kompakt
  halten, explizit nicht aufblähen — dokumentiert wird, was Substanz hat.
- **Optionen zeigen, dann entscheiden:** ein Vorgehen nie als das einzige darstellen.
  „So würde man es unter Bedingung X bauen" und „das machen wir jetzt pragmatisch"
  getrennt halten.
- **Regeln tragen immer ihren Grund.** Eine Regel ohne Warum sieht später wie ein
  Versehen aus und wird wegoptimiert.
- **Feedback-Loops als Geschwindigkeitsbegrenzung:** kleine Schritte, nach jedem ein
  Sanity-Check. Vorher sagen, WAS geprüft wird und WAS erwartet wird. Für Messungen
  heißt das: Reproduzierbarkeit ernst nehmen — Seeds fixieren, Modell- und
  Library-Versionen festhalten, Notebooks müssen top-to-bottom durchlaufen.
  Wegwerf-Exploration ist okay, aber sobald ein Befund in die Abhandlung könnte, wird
  er reproduzierbar gemacht.
- **Interpretationsdisziplin:** Befunde nüchtern formulieren — was wurde gemessen vs.
  was wird daraus gedeutet trennen. Anekdote (n=1) vs. systematische Messung
  kennzeichnen. Bei Interventions-Effekten Baselines mitdenken (z. B. Random-Kontrolle).
  Keine überverkauften Mech-Interp-Claims.
- **Im abgegebenen Material muss alles menschlich wirken.** Keine LLM-typischen
  Formulierungen, keine generischen Kommentare, kein Overkill.
- **Schwere Exploration delegieren:** wenn Recherche oder Code-Exploration viele Dateien
  ins Hauptfenster ziehen würde, einen Subagenten vorschlagen, der nur das Kondensat
  zurückgibt. Vor größeren Lese-/Recherche-Aktionen den Umfang abstimmen.
- **Skill-Kandidaten erkennen:** wenn sich ein Ablauf über Sessions wiederholt, darauf
  hinweisen und vorschlagen, ihn als Skill herauszuziehen. Nie spekulativ Skills anlegen.
- **Kontext-Budget:** bei ~150k Tokens und nach jeder abgeschlossenen Aufgabe `/handoff`
  **vorschlagen** — auch wenn noch Platz ist. Es läuft nie von allein; Henry löst es aus
  oder gibt es frei.
- **Informationen aktuell halten:** ein Update in `DETAILS.md` **ersetzt** die veraltete
  Aussage, es wird nicht darunter angehängt. Veraltete Annahmen werden entfernt, nicht
  kommentiert.
- **Fakten nicht duplizieren:** vor dem Aufschreiben prüfen, ob die Information schon
  irgendwo mit längerer Lebensdauer steht — dann dort referenzieren. Dieselbe Tatsache
  in vier Dateien sind vier Stellen, die beim nächsten Mal gefunden werden müssen.

## Code

- Klar, präzise, lesbar — kein Overkill. Einfachheit zuerst, Komplexität nur begründet.
- Sprache: Englisch für Identifier, Kommentare und Docstrings.
- Kommentare erklären **warum**, nicht was. Sie richten sich an einen Leser, der die
  Chat-Historie nicht kennt — keine Diskussions-Artefakte.
- Keine verfrühten Abstraktionen (3× ähnlicher Code ist okay), kein Drive-by-Refactoring
  innerhalb eines Bugfixes.
- Neue Dependencies: kurz erklären, was das Paket macht und warum es gebraucht wird,
  bevor es dazukommt. Dann in `pyproject.toml` aufnehmen und `uv.lock` mitcommitten —
  die Reproduzierbarkeit der Messungen hängt am Lockfile, nicht an den direkten Pins.
- Python läuft über **uv**: `uv sync` baut die Umgebung, `uv run …` startet alles.
  Nie `pip install` ins Blaue und nichts global installieren.

## Git

- Commit und Push nur auf explizites „mach" von Henry (siehe „Angekündigt ist nicht
  genehmigt"). Alles andere — Branch, Status, Diff, Log — ist frei.
- Ein Commit pro abgegrenzter Aufgabe, eine Zeile: `area: was inhaltlich passierte`.
  Kein „add/update/refactor"-Slop.
- Am Ende jedes Arbeitsblocks committen und pushen — nicht tagelang uncommittet liegen
  lassen. GitHub ist das Backup dieses Projekts.
- Alles extern Sichtbare (Commits, Branches, PRs, Issues): Englisch.
- Keine `Co-Authored-By`-Trailer, keine generierten Banner. Commits sehen
  selbstgeschrieben aus.

## Doku — Aufteilung

- **`CLAUDE.md`** → nur Verhaltensregeln (wird jede Session geladen). Kein Repo-Status,
  keine Architektur, keine Commands.
- **`docs/agentcontext/PROJECT.md`** → State und Index: Projektziel, akademischer Rahmen,
  Status, To-Dos, offene Entscheidungen, Verweise auf DETAILS-Sektionen. Übersichtlich
  und kurz.
  **Lebensdauer:** Status und To-Dos gelten nur bis zur Änderung; die
  Entscheidungsliste ist dauerhaft.
- **`docs/agentcontext/DETAILS.md`** → Langzeitgedächtnis: Detail-Wissen als Sprungziele,
  eine Sektion pro Konzept (Methode, Experiment-Befunde, Tooling, Modell, …), jeweils mit
  Stand-Datum. Wenn eine Änderung eine Sektion berührt: gegen den Code prüfen und
  aktualisieren.
  **Lebensdauer:** gültig bis überholt — Updates ersetzen, hängen nie an.
- **`docs/agentcontext/plans/`** → abgesegnete Pläne für größere Arbeitsblöcke. Ist ein
  Block durch und sind seine Erkenntnisse in DETAILS, wandert der Plan nach
  `docs/agentcontext/plans/done/`.
  **Lebensdauer:** ein aktiver Plan ist blockgebunden — seine Fortschrittsnotizen sind
  nach Blockabschluss nicht mehr maßgeblich. `done/` ist ein Friedhof: bleibt liegen,
  wird nie aktualisiert, nie referenziert. Der Umzug dorthin ersetzt nicht das
  Einarbeiten der Erkenntnisse in DETAILS, er folgt darauf.
- **`docs/agentcontext/HISTORY.md`** → schlanke Chronologie (Datum | was | warum),
  schnell überblickbar. Material fürs Schreiben der Abhandlung.
- **Wachstumspfad:** wenn eine DETAILS-Sektion zu groß für gezieltes Lesen wird,
  vorschlagen, sie nach `docs/agentcontext/details/<konzept>.md` auszulagern und nur den
  Verweis stehen zu lassen — PROJECT.md bleibt in jedem Fall der einzige Index.
- **Kein Dokumenten-Wildwuchs in `docs/agentcontext/`:** der Ordner wird jede Session
  angefasst und bleibt deshalb schlank und aktuell. Neue Dateien nur, wenn der Inhalt
  wirklich weder in PROJECT noch in DETAILS passt — dann oben markiert als
  `> **TEMPORÄR.**` mit dem Ereignis, nach dem die Datei gelöscht wird. Entwürfe für
  Mails oder Texte gehören in den Chat, nicht in `docs/agentcontext/`.
- **`docs/learning/index.html`** → Henrys Lerndokument, kein Agent-Kontext. Wächst
  iterativ: Henry liest einen Abschnitt, äußert seine Gedanken, Claude korrigiert oder
  ergänzt und stellt Verständnisfragen nur da, wo eine Formulierung wackelt — keine
  Quizshow. Kompakt anfangen, on the fly erweitern. Fakten stehen in DETAILS, das
  Lerndokument erklärt sie; bei Widerspruch gewinnt DETAILS.
- **`docs/fahrplan/index.html`** → Henrys Fahrplan-Dashboard, die Sicht auf den Fahrplan in
  PROJECT. Nach jedem abgeschlossenen Schritt `status` und `STAND` im Datenblock umstellen,
  sonst nichts. Grund: Henry priorisiert mit dem Blick darauf — ein veraltetes Dashboard
  ist schlechter als keins.
- **Doku-Schreiben eigenverantwortlich** (gilt nur für `docs/agentcontext/`):
  gewissenhaft schreiben, danach kurz berichten, was geändert wurde; Heikles vorher
  high-level klären. Abgabe- und Präsentationsinhalte (Abhandlung, Slides) erst
  diskutieren — Struktur und Kernaussagen abstimmen, dann ausarbeiten. Keine fertigen
  Entwürfe vorsetzen.

## Compact-Instructions

Für den Summarizer, wenn diese Konversation komprimiert wird — Ergänzungen zu dem, was
er ohnehin behält, kein Ersatz:

- Die aktuelle Absicht erhalten: woran gearbeitet wird und der nächste konkrete Schritt,
  damit ein bloßes „weiter" direkt nach dem Compact noch landet.
- Bei laufenden Messungen: welches Experiment läuft, welche Frage es beantworten soll,
  welche Zahlen schon da sind.
- Wenn ein Handoff-Block in der Konversation auftauchte, alles daraus übernehmen, was
  die Zusammenfassung nicht schon abdeckt.

## Session-Ende

Vor Abschluss einer Aufgabe und **vor jedem `/compact`** (Richtwert ~150k Tokens):
`/handoff` vorschlagen und auf das Go warten — Session-Delta nach PROJECT/DETAILS/HISTORY
persistieren, Reste des abgeschlossenen Blocks aufräumen, Handoff-Block generieren.
Nie aus dem Nichts ausführen.

## Sprache

- Code, Git, extern: Englisch
- Chat, `docs/agentcontext/`, interne Notizen: Deutsch
- Abhandlung: noch offen (→ PROJECT.md)

---

Neue Verhaltensregeln landen standardmäßig hier. Globalisieren nach `~/.claude/CLAUDE.md`
erst, wenn sich etwas über Projekte hinweg bewährt hat.

methodology: 6815a2e (2026-08-24)
