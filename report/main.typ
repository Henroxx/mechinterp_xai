#set document(
  title: "Applied Mechanistic Interpretability Methods",
  author: "Henry Brose",
)

#set text(lang: "de", size: 11pt)
#set par(justify: true, leading: 0.7em)
#set heading(numbering: "1.1")

// ============================================================
// Titelseite (ohne Seitenzahl)
// ============================================================
#set page(paper: "a4", margin: (x: 2.5cm, y: 2.5cm), numbering: none)

#align(center)[
  #image("figures/Fachhochschule_Südwestfalen_20xx_logo.svg.png", width: 6cm)

  #v(3cm)

  #text(size: 18pt, weight: "bold")[
    Applied Mechanistic Interpretability Methods
  ]

  #v(0.4cm)

  #text(size: 13pt)[
    // TODO: Untertitel
  ]

  #v(4cm)

  #text(size: 12pt)[
    Henry Brose
  ]

  #v(3cm)

  #text(size: 11pt)[
    Modul: Explainable Artificial Intelligence (Master) \
    Dozent: Felix Neubürger

    #v(0.8cm)

    Fachhochschule Südwestfalen \
    #datetime.today().display("[day].[month].[year]")
  ]
]

#pagebreak()

// ============================================================
// Inhaltsverzeichnis
// ============================================================
#set page(
  header: context {
    grid(
      columns: (1fr, auto),
      align: (left + bottom, right + bottom),
      text(size: 9pt, fill: gray, emph[Applied Mechanistic Interpretability Methods]),
      image("figures/Logo-Kopfzeile.png", height: 1cm)
    )
    v(-0.3em)
    line(length: 100%, stroke: 0.4pt + gray)
  },
  footer: context {
    set text(size: 9pt, fill: gray)
    grid(
      columns: (1fr, 1fr, 1fr),
      align: (left, center, right),
      [Henry Brose],
      [Seite #counter(page).display() von #counter(page).final().last()],
      [Explainable Artificial Intelligence],
    )
  },
)
#counter(page).update(1)

#outline(title: [Inhaltsverzeichnis], indent: auto)

#pagebreak()

// ============================================================
// Inhalt — Gliederung ist Platzhalter, wird noch gemeinsam festgelegt
// ============================================================

= Einleitung

== Motivation
// TODO

== Aufbau der Arbeit
// TODO

= Hintergrund und Grundlagen
// TODO: Mechanistic Interpretability vs. modellagnostische XAI, Methodenüberblick

= Methodik und Experimente
// TODO: Modell(e), Tooling, Experimente

// Beispiel Abbildung:
// #figure(
//   image("figures/beispiel.png", width: 80%),
//   caption: [Beschreibung.],
// ) <fig:beispiel>
//
// Im Text referenzieren mit: @fig:beispiel

// Beispiel Formel (inline):  $phi_i = dots$
//
// Beispiel Formel (abgesetzt):
// $ phi_i = dots $

= Ergebnisse
// TODO

= Diskussion
// TODO: Limitationen, Implikationen

= Fazit
// TODO

// ============================================================
// Literaturverzeichnis
// ============================================================
#bibliography("refs.bib", style: "ieee", title: [Literaturverzeichnis])