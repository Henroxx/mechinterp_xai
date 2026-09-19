#set document(
  title: "Applied Mechanistic Interpretability Methods",
  author: "Henry Brose",
)

#set text(lang: "en", size: 11pt)
#set par(justify: true, leading: 0.7em)
#set heading(numbering: "1.1")

// Every section opens with one of these: what I did and why, so a reader who does not need the
// detail below it can skip to the next box.
#let lead(body) = block(
  fill: luma(95%),
  inset: (x: 9pt, y: 8pt),
  radius: 3pt,
  width: 100%,
  text(size: 10pt, body),
)

#let Alin = $A_"lin"$

// A claim I am willing to defend, as opposed to a number I merely measured.
#let claim(body) = block(
  stroke: (left: 2pt + rgb("#444")),
  inset: (left: 9pt, y: 3pt),
  width: 100%,
  body,
)

// ============================================================
// Title page (no page number)
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
    Reading is not steering: what a probe cannot tell you\
    about a steering vector
  ]

  #v(4cm)

  #text(size: 12pt)[
    Henry Brose
  ]

  #v(3cm)

  #text(size: 11pt)[
    Module: Explainable Artificial Intelligence (Master) \
    Lecturer: Felix Neubürger

    #v(0.8cm)

    Fachhochschule Südwestfalen \
    #datetime.today().display("[month repr:long] [day], [year]")
  ]
]

#pagebreak()

// ============================================================
// Contents and abstract share a page -- at this length a full page of table of
// contents would cost more than it gives.
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
      [Page #counter(page).display() of #counter(page).final().last()],
      [Explainable Artificial Intelligence],
    )
  },
)
#counter(page).update(1)

#outline(title: [Contents], indent: auto, depth: 1)

#v(0.8cm)

#heading(numbering: none, outlined: false, level: 2)[Abstract]

// TODO: written last, five sentences.

#pagebreak()

= Introduction

// TODO

= Background: four ways to look inside

// TODO

= Exploration: one station per method

// TODO

= Choosing the question

// TODO

= Reading versus steering <sec:main>

#lead[
  *What and why.* This is the experiment the report is built around and the only part with
  results of its own. It starts from a claim that is easy to state and expensive to check: you
  can tell in advance, without training anything, whether a steering vector will work in a given
  layer, by applying the model's own unembedding to that layer and counting how often it already
  names the answer @billa2026. @sec:setup gives the setup and @sec:anchor reproduces the claim on
  a model an order of magnitude smaller than the ones it was shown on. @sec:sources is the part I
  added: the anchor never says how *much* it adds, so I compare four sources of a steering
  direction at equal side effect instead of at whatever dose each one happens to have.
  @sec:survives says what survives that comparison, @sec:limits what this setup cannot decide.
  If you read one table, read @tab:dose.
]

== Setup <sec:setup>

The families follow the anchor's design: two answer classes, a shared sentence template, and an
single-token answer --- which matters, because it makes the effect of an intervention a change in
one probability, with no decoding choices entering the measurement. I built six families and
picked them by measuring #Alin beforehand rather than by guessing (@tab:families). Four carry
signal on GPT-2 small; two do not, and they stay in the set for exactly that reason: if a method
reports an effect on `parity`, the method is wrong, not the model. The intervention always pushes
the second class towards the first class's answer, so the direction keeps one sign throughout.

Where possible a family uses several sentence templates, because with a single one a probe can
separate the classes on the subject word alone. `continent` and `parity` have one each, and their
probe numbers should be read with that in mind.

#figure(
  table(
    columns: (auto, auto, auto, auto, auto),
    align: (left, left, right, right, right),
    stroke: none,
    table.hline(),
    table.header([*Family*], [*Answer A / B*], [*Prompts*], [*Templates*], [*Peak #Alin*]),
    table.hline(stroke: 0.5pt),
    [`pronoun`], [she / he], [36 + 36], [3], [0.99],
    [`temperature`], [cold / hot], [36 + 36], [3], [0.68],
    [`daynight`], [day / night], [16 + 16], [16], [0.31],
    [`size`], [small / big], [36 + 36], [3], [0.25],
    [`continent`], [Europe / Asia], [12 + 12], [1], [0.04],
    [`parity`], [odd / even], [18 + 18], [1], [0.00],
    table.hline(),
  ),
  caption: [The six families, ordered by peak #Alin. Answers are single tokens and carry the
    leading space GPT-2 tokenises them with. The last two are floor cases: the model cannot
    answer them at all, so nothing should be steerable there.],
) <tab:families>

Three ways of reading a concept off a layer are measured per layer:

- *#Alin* --- the model's own unembedding applied to the residual stream after each layer, argmax
  compared with the answer token, share correct. This is the logit lens @nostalgebraist2020 used
  as a *predictor* rather than as a description, and it needs no training and one forward pass.
- *A logistic probe* on the same residual stream, fitted per layer, scored on a held-out quarter,
  with a control task on shuffled labels beside it @alain2017 @hewitt2019.
- *AUROC of the difference-of-means direction* --- how well the single direction between the class
  means separates held-out examples.

And one way of writing one in: add a direction at every prompt position of the second class's
prompts. Its *effect* is $Delta P$, the change in probability of the first class's answer token;
its *side effect* is the Kullback--Leibler divergence of the next-token distribution on 50
unrelated prompts. Both are the anchor's measures, so its numbers and mine are comparable. KL on
unrelated prompts is a narrow notion of damage --- it says nothing about generation quality --- but
it is cheap, it means the same thing for every family, and it needs no judge.

Everything runs on GPT-2 small @radford2019 (124M parameters, 12 layers,
#box[$d_"model" = 768$]) through TransformerLens @nanda2022, seed 0, on a laptop GPU. The two
notebooks run top to bottom in about 20 seconds and about three and a half minutes, write their
numbers to `results/`, and reproduced those files byte for byte when re-run for this report.

== The anchor, reproduced <sec:anchor>

The anchor reports its correlations on five models from Pythia-2.8B to Llama-8B. GPT-2 small is
smaller than all of them, so reproducing the *pattern* here tests the claim rather than confirming
it politely: a measure like this could easily be an artifact of scale. It is not. For every family except `pronoun`, #Alin is exactly zero in layers 0 to 7 and rises
only in the last quarter --- the same shape the anchor reports in layers 18 to 24 of a 2B model.
`pronoun` is the exception and jumps to 0.64 at layer 6. Within families, $rho$(#Alin, $Delta P$)
across the twelve layers is +0.48 to +0.90, inside the anchor's band of +0.63 to +0.92.

The probe fails as a layer selector, and it fails worse than "worse than #Alin". For `continent`
and `pronoun` the held-out probe reads 1.00 in *every one of the twelve layers*: it has no
variance left to rank layers with, so its correlation with steering effect is not weak, it is
undefined. Where it is defined it changes sign by family, +0.74 on `daynight` against −0.39 on
`size`. A saturated probe is not a poor predictor of steerability; it is not a predictor.

`continent` is the sharpest case, and the one the subtitle refers to:

#claim[
  On `continent` the probe reads the concept perfectly in all twelve layers, against a control
  task at 0.17 to 0.67 --- so this is not the probe memorising labels. #Alin peaks at 0.042, and
  steering moves the answer by at most +0.014. The concept is present, linearly readable, and
  unsteerable.
]

Two further claims of the anchor hold. The common "use a middle layer" heuristic loses exactly
where #Alin says it should: `temperature` gains +0.092 at layer 11 against +0.008 at layer 6, and
`daynight` +0.035 against +0.007. And the go/no-go threshold survives --- `parity` and `continent`
stay below 0.05 peak #Alin and produce $Delta P <= +0.014$, which is what such a threshold is for.

#figure(
  placement: auto,
  image("figures/07_reading_vs_steering.pdf", width: 100%),
  caption: [Reading against steering per layer, one panel per family. #Alin (circles) rises late;
    the probe (squares) is flat and high wherever the family has one template; the control task
    (triangles) shows the probe is not merely memorising; steering $Delta P$ (diamonds) follows
    #Alin, not the probe. Source: `notebooks/07_reading_vs_steering.ipynb`.],
) <fig:anchor>

Then the crack. The anchor adds the raw difference of means at coefficient 1, and across these six
families and twelve layers that vector's norm ranges from 0.5 to 58.4, while the mean residual
norm of GPT-2 small grows from 76 in layer 0 to 644 in layer 10. Coefficient 1 is therefore not one
dose but 72 of them, and an efficiency measure of $Delta P slash "KL"$ compares concepts at
whatever dose their difference of means happens to have.

== Four sources of a direction, at equal side effect <sec:sources>

#lead[
  *What and why.* Same six families, same seed, same 50 unrelated prompts; three things change.
  The dose is stated and held fixed relative to the layer. Four sources of the direction are
  compared instead of one, and one of them is random. And the comparison is read at equal side
  effect, because a direction that buys its effect with more damage is not a better direction.
  All of it serves one number: how much of the anchor's reported correlation is its dose tracking
  its own predictor.
]

*Dose.* All four directions are scaled to unit norm and added as $alpha$ times the mean residual
norm of that layer. This is the choice the whole comparison rests on, so it is worth one sentence
of justification: the residual stream of GPT-2 small grows by a factor of 8.5 across depth
(76 → 644, then down to 489 in layer 11), so one absolute dose is a heavy intervention early and
a light one late. A relative dose makes "the same amount" mean the same thing in every layer.

*Sources.* The difference of means; the probe's weight vector; one SAE decoder row; and a random
direction as the floor. The random one is the best of five draws rather than a single draw --- one
random vector is a sample, and a floor built from a sample moves. The SAEs are the public
GPT-2 residual-stream set @bloom2024 (24 576 features per layer, 32× expansion). I checked the
hook mapping instead of trusting the folder names: `blocks.{l+1}.hook_resid_pre` is bit-identical
to `blocks.{l}.hook_resid_post`, so folder $l+1$ holds the SAE for layer $l$, and SAEs exist for
layers 0 to 10. *Layer 11 has none, and layer 11 is where #Alin peaks for all four carrying
families.* The SAE arm is blind at the most interesting layer --- a property of the available
weights, not of the method.

The feature is selected on the training half with a criterion fixed before looking: fire on at
least 60% of one class and at most 25% of the other, with the sign fixed to the class the
intervention pushes towards. How often that fails is worth reporting, because the alternative is
to keep searching until something is found. In layer 6 nothing passes for four of six families and
the fallback is the largest mean gap, with held-out AUROC of 0.38 to 0.79 --- two of them below
chance. In layer 10 the criterion is met everywhere except `parity`, with held-out AUROC of 0.88
to 1.00 for five families and `daynight` the exception at 0.40.

*Readouts.* A twelve-layer scan at fixed $alpha = 0.1$, then a ten-point dose sweep ($alpha$ from
0.01 to 0.4) in layer 6 --- the middle-layer heuristic --- and layer 10, the deepest layer with an
SAE. Each sweep yields two numbers, both fixed in advance: $Delta P$ interpolated at
$"KL"^* = 0.1$ nats, and the KL needed to reach $Delta P^* = +0.05$. The first is interpolated in
$log "KL"$ because KL is monotone in dose. The second takes the first crossing on the rising
branch, because $Delta P$ is *not* monotone: past some dose the effect collapses as the model stops
producing a sensible distribution at all.

#figure(
  placement: auto,
  image("figures/08_direction_sources.pdf", width: 100%),
  caption: [Effect against side effect for the four sources, top row layer 6, bottom row layer 10,
    log KL on the x-axis. The dotted lines are the two comparison targets. Each curve is one
    direction through ten doses; the random floor (dashed) is the best of three draws per point.
    Source: `notebooks/08_direction_sources.ipynb`.],
) <fig:sources>

#figure(
  table(
    columns: (auto, auto, auto, auto, auto, auto),
    align: (left, center, right, right, right, right),
    stroke: none,
    table.hline(),
    table.header([*Family*], [*Layer*], [*diff-of-means*], [*probe*], [*SAE*], [*random*]),
    table.hline(stroke: 0.5pt),
    [`pronoun`], [6], [*+0.263*], [+0.260], [+0.245], [+0.008],
    [`pronoun`], [10], [+0.306], [*+0.307*], [+0.285], [+0.011],
    [`temperature`], [6], [+0.023], [*+0.109*], [+0.014], [+0.015],
    [`temperature`], [10], [+0.130], [+0.156], [*+0.175*], [+0.017],
    [`size`], [6], [*+0.075*], [+0.022], [+0.002], [+0.039],
    [`size`], [10], [*+0.015*], [−0.015], [−0.028], [−0.013],
    [`daynight`], [6], [+0.021], [+0.005], [−0.038], [*+0.051*],
    [`daynight`], [10], [*+0.040*], [+0.032], [+0.023], [+0.024],
    table.hline(),
  ),
  caption: [Effect $Delta P$ at the same side effect ($"KL" = 0.1$ nats), best per row in bold.
    The two floor families are omitted: `parity` is exactly 0.000 in every cell, `continent` at
    most +0.023.],
) <tab:equal>

== What survives the fairer comparison <sec:survives>

@tab:dose is the answer to the question this experiment was built for. The anchor's *implicit*
dose --- the norm of its difference of means divided by the residual norm of the layer --- ranges
from 0.003 to 0.119 across families and depth, and within each carrying family it correlates with
#Alin at +0.76 to +0.91. Its dose rises exactly where its predictor rises. Holding the dose fixed,
the within-family correlation between #Alin and steering effect drops from +0.80, +0.57, +0.48,
+0.90 to +0.56, −0.10, +0.54, +0.24.

#figure(
  table(
    columns: (auto, auto, auto, auto, auto, auto),
    align: (left, right, center, right, right, right),
    stroke: none,
    table.hline(),
    table.header(
      [*Family*], [*Peak #Alin*], [*Implicit dose*], [$rho$(#Alin, dose)],
      [$rho$ at coeff. 1], [$rho$ at $alpha = 0.1$],
    ),
    table.hline(stroke: 0.5pt),
    [`temperature`], [0.68], [0.004 -- 0.085], [+0.84], [+0.80], [+0.56],
    [`size`], [0.25], [0.006 -- 0.117], [+0.76], [+0.57], [−0.10],
    [`pronoun`], [0.99], [0.005 -- 0.086], [+0.91], [+0.90], [+0.54],
    [`daynight`], [0.31], [0.005 -- 0.067], [+0.76], [+0.76], [+0.24],
    [`continent`], [0.04], [0.005 -- 0.119], [+0.31], [+0.48], [−0.22],
    [`parity`], [0.00], [0.003 -- 0.013], [flat], [flat], [flat],
    table.hline(),
  ),
  caption: [The dose confound, in numbers. Column 3 is the dose the anchor applies without
    stating it; column 4 shows it tracking the anchor's own predictor. Columns 5 and 6 are the
    same correlation at the anchor's dose and at a fixed relative dose. `parity` has #Alin = 0 in
    every layer, so there is no rank order to correlate.],
) <tab:dose>

That looks like a refutation, and my first reading of it was exactly that, because at a fixed dose
the ranking of the families does not merely weaken --- it inverts, with `size` moving from last
place to first. I held that reading back, for one reason: at a fixed dose the four families do not
pay the same side effect, so the fixed-dose ranking is no fairer than the anchor's. Read at an
equal KL budget instead, the order comes out as `pronoun` > `temperature` > `size` > `daynight`
against the predicted `pronoun` > `temperature` > `daynight` > `size` --- one adjacent swap.

#claim[
  The apparent collapse of the ranking is itself a dose artifact. The weakening of the
  correlation is not. The anchor's predictor is real and its reported strength is inflated by a
  dose it never states.
]

Four further findings, all from @fig:sources and @tab:equal.

*The unstated dose is not even the best one.* With the same direction in layer 10, `pronoun`
reaches $Delta P = +0.495$ at $alpha = 0.2$, against +0.246 at the anchor's coefficient 1. The
dose is not only unreported, it is left on the table.

*Where the direction comes from matters less than which layer and how much.* In layer 10 the three
principled sources land within 0.03 of each other on `pronoun` and within 0.05 on `temperature`.
The large differences in the grid are between layers, not between derivations --- awkward for a
literature that mostly compares methods of extraction.

*The anchor's untested SAE prediction does not hold uniformly.* Its third regime --- high #Alin,
so the concept is already output-aligned and an SAE feature should add little --- holds for
`pronoun` (+0.285 against +0.306) and fails for `temperature` in layer 10, where the SAE direction
wins outright (+0.175 against +0.130).

*Explained variance is blind to the concept.* The SAE reconstruction explains 92 to 99% of the
variance of the residual stream, while 35 to 99% of the class separation along the reading
direction sits in the reconstruction *error* --- the share Tiwari et al. measure at 74% on another
model, another SAE and other concepts @tiwari2026. Replacing one layer by its own reconstruction
costs the model its answer: accuracy on `temperature` falls from 0.68 to 0.35, on `size` from 0.25
to 0.07, on `daynight` from 0.31 to 0.09 (`pronoun` holds, 0.99 to 0.86). A number that high and a
loss that large in the same object is this report's clearest argument for reading a quality metric
as a claim about what it measures, not about what one hopes it measures.

Finally, the controls earn their place. The random floor is not zero and it wins once: on
`daynight` in layer 6 it beats all three principled sources at equal side effect (+0.051 against
+0.021, +0.005 and −0.038). And `parity` stays at exactly 0.000 across four sources, twelve layers
and ten doses --- any pipeline reporting an effect there would have been reporting its own noise.
@galeone2026 find the same dissociation from the other side on a larger model, where a perfectly
separating detection direction stands at 83° to the direction that actually steers.

== What this setup cannot decide <sec:limits>

The directions are fitted on the same prompts that are then steered, as in the anchor; there is no
held-out steering set, so the effect sizes are upper bounds. The families have 24 to 72 examples
against 768 dimensions, so the held-out quarter is 4 to 18 prompts --- which is why no probe number
here is quoted to three digits. The cross-family correlation rests on six points and is an
illustration, not evidence; the anchor uses 24. I also left out the anchor's second measure,
$A_"mlp"$, so its middle regime --- present but not linearly readable --- rests on the probe alone
here, and a failing probe never proves absence @belinkov2022. The random floor is the best of five
draws, not a distribution, and the SAE arm cannot see layer 11, where four of six families peak.

None of this is fatal to the conclusion, which is a comparison between directions measured the
same way rather than an absolute claim about steerability. It does mean that every number in this
section is a statement about GPT-2 small with these six families; the anchor's own result across
five larger models is the reason to think the pattern is more than that.

= What I take from this

// TODO

= Working method and use of AI

// TODO

// ============================================================
// References
// ============================================================
#bibliography("refs.bib", style: "ieee", title: [References])

// ============================================================
// Appendix
// ============================================================
#set heading(numbering: "A.1")
#counter(heading).update(0)

= Appendix

// TODO: table "path in the repository -> what is there".
