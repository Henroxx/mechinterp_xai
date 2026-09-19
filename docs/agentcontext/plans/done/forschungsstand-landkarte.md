# Plan — Forschungsstand als Landkarte (Fahrplan Schritt 9)

## Frage

Für jede Methode der Schnuppertour: auf welchen Modellen wird sie in der Literatur
angewandt, womit wird gemessen, was gilt als gelöst, welche Lücke ist mit unserem
Compute erreichbar — und wie verhält sich der eigene Befund dazu? Ziel ist eine
Entscheidungsgrundlage für Phase 4, ausdrücklich nicht Vollständigkeit.

## Methodik — Scoping Map, kein systematischer Review

Die Etikettierung ist Absicht: gesucht wird LLM-gestützt über Websuche, damit gibt es
keine Vollständigkeitsgarantie und keine reproduzierbare Trefferliste. Was stattdessen
geht, ist ein vorab fixiertes Protokoll, gegen das man das Ergebnis prüfen kann.

**Vorab festgelegt (vor der ersten Suche):**

- **Quellen:** arXiv (cs.LG, cs.CL), Proceedings von ICML/NeurIPS/ICLR/ACL,
  Semantic Scholar für Zitationsketten. Blogposts und LessWrong nur als Zeiger auf
  Arbeiten, nie als Beleg für eine Zahl.
- **Zeitfenster:** Schwerpunkt 2024-01 bis heute. Ältere Arbeiten nur, wo sie als
  Grundlage anerkannt sind (IOI, ROME, Control Tasks).
- **Einschluss:** berichtet eine eigene Messung · Open-Weight-Modell bis ~9B oder
  GPT-2-Klasse · Methode nachvollziehbar beschrieben.
- **Ausschluss:** nur Closed-Model-Experimente · reine Position Papers ohne Messung ·
  Arbeiten, deren Compute-Bedarf außerhalb unserer Klasse liegt (SAE-Training,
  Modelle > 9B, Multi-GPU).
- **Evidenzstufe je Eintrag:** `[V]` Volltext gelesen · `[A]` Abstract/Teile ·
  `[S]` sekundär, über eine andere Arbeit referiert. Begründung: am 2026-08-25 hat der
  Volltext von SteeringSafety mehrere abstract-basierte Aussagen korrigiert — die Stufe
  hält fest, wie belastbar eine Zeile ist.
- **Auflösbarkeit:** jede aufgenommene Arbeit muss über ihre arXiv-ID auflösbar sein,
  Titel und Autoren müssen übereinstimmen. Nicht prüfbar → nicht aufgenommen. Grund:
  erfundene Referenzen sind die systematische Fehlerquelle LLM-gestützter Literatursuche.
- **Protokollpflicht:** Suchstrings, Quellen, grobe Trefferzahl und die Gründe fürs
  Aussortieren werden mitgeliefert und in der Datei festgehalten.

> **ANNAHME:** Die Landkarte deckt die fünf Methoden der Tour ab (Patching, Steering,
> Probing, SAE, Modellvergleich), nicht das Feld Mech-Interp insgesamt.

> **ANNAHME:** Compute-Grenze ist der M-Mac: Inferenz bis ~9B auf MPS, kein Training,
> keine eigenen SAEs. Eine Lücke, die das überschreitet, wird als "nicht erreichbar"
> notiert statt weggelassen.

> **ANNAHME:** Evidenzstufe `[A]` reicht für die Landkarte. Volltext wird erst in
> Phase 5 für die gewählte Sache gelesen.

## Schritte

1. **Vorhandenes umziehen.** DETAILS „Forschungsstand Steering-Nebeneffekte" (~105 Zeilen)
   und „SAE-Kritik" nach `docs/agentcontext/details/forschungsstand.md`, in DETAILS bleibt
   der Verweis. Provenienz nachtragen: recherchiert 2026-08-24 ohne dieses Protokoll,
   Evidenzstufen nachgezogen.
2. **Blinde Flecken schließen.** Zwei Subagenten mit dem Protokoll oben: Activation
   Patching / Circuit-Analyse und Linear Probing. Beide liefern nur ein Kondensat.
3. **Verifikation.** Stichprobe der zurückgemeldeten arXiv-IDs selbst prüfen, bevor
   etwas in die Datei wandert.
4. **Landkarte bauen.** Eine Zeile pro Methode: Modelle · Standard-Messung · gilt als
   gelöst · offene Lücke · eigener Befund aus der Tour. Darunter je Methode die Lücken
   ausformuliert, mit Erreichbarkeits-Urteil.
5. **Grenzen der Suche** als eigener Abschnitt am Ende der Datei.

## Erwartung

Patching gilt als gelöst für „Circuit auf einer Spielzeugaufgabe finden", offen ist die
Frage, ob ein gefundener Circuit über die Aufgabe hinaus trägt und wie man Faithfulness
ehrlich misst. Bei Probing erwarte ich, dass die Lücke nicht im Finden linearer Konzepte
liegt, sondern im Schluss von „Probe findet es" auf „Modell benutzt es" — also genau die
Kluft, die unsere eigene Station zwischen `w` und `d` gesehen hat. Wenn beide Erwartungen
zutreffen, laufen drei der fünf Methoden auf dieselbe Kernfrage zu, und das wäre der
interessantere Befund als jede einzelne Lücke.

> **Abgeschlossen 2026-09-18.** Alle fünf Schritte gelaufen, Ergebnis in
> `details/forschungsstand.md`. Die Erwartung traf zu und war noch zu vorsichtig: die Kernfrage
> „das Messinstrument bestimmt das Ergebnis mit" betrifft alle vier Felder, nicht drei, und ist in
> jedem bereits als Kritik publiziert. Protokoll-Nachtrag: alle 55 arXiv-IDs der Datei wurden über
> die arXiv-API aufgelöst, keine erfundene Referenz — auch nicht im ungeprüften August-Material.
