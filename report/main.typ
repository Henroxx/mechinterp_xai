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

A steering vector is a direction added to a language model's residual stream, and the natural
assumption behind one is that a direction which reads a concept well will also steer it. I test
that assumption on GPT-2 small across six binary concept families, twelve layers and four sources
of the direction, after one exploratory pass through activation patching, probing, steering and
sparse autoencoders. A training-free predictor --- the model's own unembedding applied at each
layer --- ranks the families in the order their steering effects arrive, while a trained probe
saturates at 1.00 in every layer of two of them and predicts nothing; on one family the concept is
perfectly readable in all twelve layers and steering moves the answer by at most +0.014. The
correlation the anchor paper reports is real and inflated at once, because the dose it never
states tracks its own predictor at +0.76 to +0.91: holding the dose fixed inverts the ranking of
the families, and read at an equal side-effect budget instead the predicted order survives with
one adjacent swap, with the layer and the dose mattering far more than where the direction was
derived from. What each of these measurements is worth therefore depends on a setting chosen
before it: at what dose, and compared at equal what.

#v(0.8cm)

#block(
  stroke: (left: 2pt + luma(70%)),
  inset: (left: 9pt, y: 4pt),
  width: 100%,
  text(size: 9.5pt)[
    *Use of AI.* This project was done with an AI coding assistant: literature search, notebook
    code, figures, drafts of this text, and discussion throughout. I chose the question, designed
    the experiments and did the interpretation. The working method is part of the deliverable rather
    than hidden behind it: the rule file, the context directory with project state and long-lived
    notes, and the plan agreed before each block of work are in the repository and can be inspected
    in full.
  ],
)

#v(0.5cm)

#[
  #set text(size: 9pt)
  #set par(justify: false)
  #table(
    columns: (4.8cm, 1fr),
    align: (left, left),
    inset: (x: 4pt, y: 3.5pt),
    stroke: none,
    table.hline(),
    table.header([*Path in the repository*], [*What is in it*]),
    table.hline(stroke: 0.5pt),
    [`CLAUDE.md`],
    [The rules the collaboration runs under: what I decide, what is delegated, how a finding gets
     documented, and that a plan I did not approve is not a licence to start.],
    [`docs/agentcontext/PROJECT.md`],
    [Project state and the list of decisions, each with the reason it was taken.],
    [`docs/agentcontext/DETAILS.md`],
    [Long-lived notes, one section per method, model or finding; the larger ones live beside it in
     `details/`.],
    [`docs/agentcontext/plans/`],
    [The plan agreed before each larger block of work, finished ones moved to `plans/done/`.],
    [`docs/agentcontext/HISTORY.md`],
    [Dated chronology of what was done and why.],
    [`docs/learning/`, `docs/fahrplan/`],
    [My own explanations of the concepts and the roadmap I worked along --- working documents, in
     German.],
    table.hline(),
  )
]

#pagebreak()

= Introduction <sec:intro>

*Where this sits.* Explainable AI is usually sorted along a few independent axes: whether the
explanation is intrinsic to the model or added after the fact, whether it applies to any model or
only to one kind, and whether it accounts for a single decision or for the behaviour as a whole
@gilpin2018. The methods that carry the field in practice sit on the agnostic side and work from
the outside: a local surrogate fitted around one prediction @ribeiro2016, attention maps, gradient
attributions. They answer one question, which part of the input mattered for this output, and
they treat the computation in between as given. Mechanistic interpretability asks what that
computation is, stated in the model's own internal quantities. On the axes above it is post-hoc
and as model-specific as a method can be: it needs the weights, the layers and the activations of
one particular network. Everything in this report is measured inside GPT-2 small rather than
around it.

*What this report is.* Four methods applied to one model: activation patching, probing, steering,
and sparse autoencoders. I ran each of them once and small to learn what it measures and where it
misleads (@sec:tour), and then took a single question far enough to produce numbers worth
defending (@sec:main): whether a direction that reads a concept well out of a layer also steers
the model when it is written back in. No research question was fixed in advance; the exploration
was the method. The report is therefore ordered the way the work happened: the instruments first,
then one question chosen out of the literature, then one experiment on six concept families,
twelve layers and four sources of a steering direction.

*The stance.* One sentence carries the rest. Each of these methods has a setting that must be
chosen before anything can be measured (the corrupted baseline in patching, the control task in
probing, the dose in steering, the sparsity level in a sparse autoencoder), and that setting
co-determines the finding. @sec:main contains an instance of it: the same six concepts, the same
model and the same directions change their ranking depending on whether the comparison is read at
equal coefficient, at equal relative dose, or at equal side effect, and only the last of the three
compares what a direction did at the same cost. A result from any of these methods is a statement
about the model and about the instrument at once; the setting has to be named to keep the two
apart.

*How to read this.* Every section below opens with a grey box saying what it does and why, so a
reader can move from box to box and stop where the detail is needed. Passages marked with a
vertical rule are the claims I am prepared to defend, as opposed to numbers I merely measured.
Everything measured here is in the repository; the appendix gives the link, the tag, and what
lies where.

= Background: four ways to look inside <sec:background>

#lead[
  *What and why.* The four methods in this report read from or write into the same object, and
  they rest on the same assumption. This section defines both: the residual stream (@fig:stream),
  the linear representation hypothesis in three sentences, and @tab:methods, which sets the
  instruments side by side by what each one measures, what it takes for granted, and where it
  breaks. A reader who knows the field needs only the last column of that table.
]

*The workspace.* A transformer of the GPT-2 family keeps one vector per token position --- 768
numbers in GPT-2 small --- and every block adds to it instead of replacing it @elhage2021.
Attention writes into it, the MLP writes into it, and what was written before stays. The state at
layer $ell$ is the embedding plus everything the first $ell$ blocks contributed, and two
consequences of that carry this report. First, the model's own output map is a linear read of
that state, so it can be applied at any depth rather than only at the end: that is the logit lens
@nostalgebraist2020, and #Alin in @sec:main is nothing more than how often this early read already
names the right answer. Second, because the contributions add, a single one can be measured,
removed or amplified without rebuilding anything, and that is what makes all four methods possible
in the first place. The stream is not scale-free, though. Measured on GPT-2 small, the mean
residual norm grows from 76 at layer 0 to 644 at layer 10, a factor of about eight, so adding a
vector of a given length is a different intervention at every depth. That is why @sec:main states
every dose relative to its layer.

#figure(
  image("figures/residual_stream.svg", width: 100%),
  caption: [Own figure, schematic. Every block reads the whole stream and adds its result back
    into it, so the state at a layer is the embedding plus everything written into it so far. The
    four methods of this report are four operations on that one object.],
) <fig:stream>

*The assumption.* Three sentences hold the rest up. A concept is a direction in that space. Reading
it is a projection: how much _day versus night_ a state carries is a single number, its dot product
with the direction. Writing it is an addition: put a multiple of the direction into the stream and
the model continues as if the text had said so. This is the linear representation hypothesis
@park2024, an assumption with enough support to build tools on, not a theorem. The four methods
below do not test it; they use it.

*The four instruments.* @tab:methods is the working definition of each method. The failures in
its last column are not defects of the methods: each is the method's own assumption showing up
as a number, and each is answered by a control rather than by a better tool.

#figure(
  [
  // Same treatment as @tab:tour: ragged right at this column width, justification opens rivers.
  #set text(size: 9pt)
  #set par(justify: false)
  #table(
    columns: (2.1cm, 1fr, 0.95fr, 1.3fr),
    align: (left, left, left, left),
    inset: (x: 4pt, y: 3.5pt),
    stroke: none,
    table.hline(),
    table.header([*Method*], [*What it measures*], [*What it assumes*], [*Where it breaks*]),
    table.hline(stroke: 0.5pt),

    [Activation patching],
    [How much of a behaviour one component causes: replace its activation with the one from a
     different run and read the change in logit difference @heimersheim2024.],
    [That the two runs differ only in the intended way, and that a part can be swapped without
     disturbing what feeds it.],
    [The ranking depends on the corrupted baseline and the metric as much as on the model
     @zhang2024, and later components repair what was removed, so necessity reads low.],

    [Probing],
    [Whether a concept can be read linearly out of one layer: the accuracy of a classifier trained
     on the activations @alain2017.],
    [That what is decodable is also what the model uses.],
    [A probe with enough capacity also fits labels that carry no information; without a control
     task the accuracy means nothing @hewitt2019 @belinkov2022.],

    [Steering],
    [The causal effect of a direction: add a multiple of it to the stream and read what changes in
     the output @turner2024.],
    [That the direction is the concept, and that one coefficient means the same at every layer.],
    [A random vector of the same norm buys much of the same damage, and with the dose unstated the
     effect of the direction cannot be told from the effect of its size.],

    [Sparse autoencoder],
    [A sparse decomposition of the state into features, scored by explained variance and by how
     many features fire @cunningham2023.],
    [That features are sparse and linear, and that a good reconstruction kept what matters.],
    [Explained variance is blind to the concept: 93 to 99% of the state is reconstructed in
     @sec:main while up to 99% of the class separation sits in the discarded error.],
    table.hline(),
  )],
  caption: [The four methods as this report uses them. The last column is each method's own
    assumption, stated as the way it fails.],
) <tab:methods>

All four break in the same place: a setting of the instrument decides part of the answer.
@sec:tour is what that looked like when I ran each of them once.

= Exploration: one station per method <sec:tour>

#lead[
  *What and why.* Before choosing a question I ran every method once and small, one notebook per
  station: patching, steering, probing, sparse autoencoders, and one pass over a second model.
  These are single prompts and sample sizes around twenty; the aim was to learn what each
  instrument measures and where it misleads, not to find anything. @tab:tour is the whole tour.
  Three of its lessons became the design of @sec:main, and the final paragraph says why the
  experiment then ran on the smaller of the two models.
]

#figure(
  [
  // Ragged right inside the table: at this column width justification opens rivers.
  #set text(size: 9pt)
  #set par(justify: false)
  #table(
    columns: (2.2cm, 1fr, 1.5fr, 1.25fr),
    align: (left, left, left, left),
    inset: (x: 4pt, y: 3.5pt),
    stroke: none,
    table.hline(),
    table.header([*Station*], [*What I asked*], [*What came out*], [*What it taught*]),
    table.hline(stroke: 0.5pt),

    [Orientation \ `01_explore`],
    [Does the plumbing behave as documented?],
    [Hook names verified against the library version; BOS carries a residual norm near 3100 against
     250 elsewhere; the logit lens is unreadable before layer 6.],
    [Drop position 0 from every mean. Lens probabilities show a direction, not a confidence.],

    [Patching \ `02_patching`],
    [Which heads carry the induction behaviour?],
    [Ablating the five canonical heads destroys 25% of the gap; patching them back restores 60%. No
     single head restores more than 0.13, and the one with the highest attention score restores
     0.05.],
    [Ablation measures necessity, patching sufficiency, and they disagree. The head with the
     highest attention score is not the one that matters most.],

    [Steering \ `03_steering`],
    [What does a difference-of-means direction do, and at what price?],
    [An S-curve that saturates before the loss does: the metric plateau sits where the loss is
     already rising. A random vector of the same size leaves the metric flat and costs most of the
     same loss.],
    [State the dose relative to the layer's residual norm. A random control checks the size of an
     intervention, not the specificity of its direction.],

    [Probing \ `04_probing`],
    [Is the probe direction different from the difference of means?],
    [On 20 minimal pairs, no: #box[cos($hat(w)$, $d$) $>= 0.95$] at every regularisation strength.
     The control task reaches 19.4 of 40 held out at training accuracy 1.00.],
    [Minimal pairs leave the probe nothing to pick up except the concept, so they cannot separate
     reading from steering; that test needs heterogeneous data.],

    [SAE \ `06_sae`],
    [Is a sparse feature a cleaner lever than a difference of means?],
    [At equal dose it looks weaker; read at *equal effect*, both interpolated to +2.00 logits, it is
     a tie of 0.069 nats against 0.077. The opposite feature costs five times as much.],
    [Compare at equal effect rather than at equal dose. The SAE feature is derived differently;
     it is not a better lever.],

    [Second model \ `05_gemma`],
    [Does this depend on the quirks of one small model?],
    [Gemma-2-2B matches its reference implementation to max #box[$|Delta| = 0.375$] at a logit scale
     of 28.6; its BOS sink is in every layer, and the cache costs about 4 MB per token.],
    [The BOS sink and the layer-relative dose are not GPT-2 artifacts. A second model costs memory,
     not correctness.],
    table.hline(),
  )],
  caption: [The exploration tour, one row per notebook in `notebooks/`. The numbers are orientation
    at #box[$n approx 20$], not statistics; what carried into @sec:main is the last column.],
) <tab:tour>

*What carried over.* Three results of the tour became design decisions rather than findings. The
probing station failed in the informative direction: the probe and the difference of means were the
same direction at every setting, because sentence pairs that differ in one word leave a probe
nothing else to separate on, which is why the families in @sec:main vary the template instead of
a single word. The SAE station produced the method of comparison: reading two directions at equal
effect instead of at equal dose turned a clear-looking loss into a tie, and that reading is what
all four sources later get. The steering station produced the dose rule and the reason it is not
optional, since a random vector of the same norm buys most of the same damage while moving nothing.
The patching station produced no ingredient, only the habit of not trusting a ranking that was
never measured causally.

*Which model.* The tour covered Gemma-2-2B, and the experiment still runs on GPT-2 small. That was
decided by a measurement rather than by preference. The anchor's own scaling table reports 5 of 23
concepts steerable at 160M parameters, which is a floor effect large enough to make the whole
comparison vacuous, so before committing I measured #Alin on three candidate families: 0.77, 0.91
and 0.29, each peaking at layer 10 and each exactly zero up to layer 7. Two families well above the
anchor's go/no-go threshold of 0.1 and one in between is enough spread to work with. GPT-2
small also has published sparse autoencoders for its residual stream @bloom2024, and the sweep in
@sec:main uses one of them per layer. This is a budget decision, taken after a pre-measurement
rather than before one.

= Choosing the question <sec:question>

#lead[
  *What and why.* Between the tour and the experiment sits a decision: out of four methods and a
  large literature, one question had to be small enough to finish and specific enough to come out
  wrong. This section says how I surveyed the field, which question I picked and why, which paper I
  use as an anchor, and which two gaps in it became the measurement in @sec:main.
]

*The map.* Before choosing I surveyed the four methods of the tour and wrote one row per method:
what the field measures, what counts as settled, and which gap is reachable on a laptop. The
protocol was fixed before the first search: arXiv and the main proceedings, emphasis on work
since 2024, a paper is only included if it reports its own measurement on open weights of at most
nine billion parameters, and every entry carries an evidence level recording whether I read the
full text, the abstract, or a secondary description. The last rule exists because the search was
assisted by a language model, and fabricated references are the systematic failure mode of that:
each arXiv identifier was resolved against the arXiv API and checked against title and first
author. About 160 titles were screened, 55 arXiv entries kept.

*What stood out.* All four methods have the same core question under different names: the corrupt
baseline in patching, the KL filter and the integer dose grid in steering, the missing control
task in probing @hewitt2019 @belinkov2022, the sparsity level in autoencoders @cunningham2023. And
the gaps reachable without training anything are control and baseline work, not new methods.

*The cut.* Of the candidates that came out of the map I chose the one that asks whether a direction
which *reads* a concept well also *steers* it well, measured across concepts, layers and sources of
the direction. Three reasons. It sits on the core question above, because reading and steering are
two instruments pointed at the same concept, and the interesting case is the one where they
disagree. It needs no tooling I did not already have, since probes, difference-of-means
directions, SAE latents and the steering loop all exist from the tour. And it has an anchor: a
recent paper with a central claim cheap enough to reproduce before extending it. The candidate I
dropped last was a dense dose--response study with capability benchmarks, not because the question
is uninteresting but because most of its work would be harness building. The control-task
candidate fits inside this one as a step, so it was not dropped at all.

*The anchor.* Billa @billa2026 proposes #Alin and reports that it predicts where steering will
work: across 24 controlled binary families it correlates with steering effect at $rho$ = +0.86 to
+0.91 and with the choice of layer at +0.63 to +0.92, while the customary "use a middle layer"
heuristic lands on #Alin = 0 on Gemma-2-2B and does nothing there.

*Its limits, by its own account.* Much of that correlation comes from families sitting at the
floor, and restricted to #Alin > 0.1 it drops to about +0.5 on the smaller models; the tasks are
single-token throughout; and steering means a difference of means and nothing else.

*The two gaps.* Two things the paper does not settle were within my reach. It never states the
dose at which it steers, and it reports $rho$(#box[$||d||$], KL) = +0.96, so its side-effect axis
is very nearly just the norm of the vector it added. And its expectation that SAE features should
help where a concept is encoded non-linearly is marked explicitly as untested.

*The second work.* Tiwari et al. @tiwari2026 separate decodability from causality: on Gemma-2-9B-it
the features geometrically closest to a probe overlap only 11 to 14% with the features that
gradients mark as behaviourally relevant. They ablate rather than steer, have no difference-of-means
source, and compare at equal set size rather than at equal effect, so what follows is not a rebuild
of their study. What I take from them is one check: in their Qwen3-8B experiment 74% of the
probe's margin lived in the reconstruction error of the SAE, and where that happens an SAE
intervention mostly measures itself. I report that share per family rather than assume it away.

#claim[
  The contribution in one sentence: measure the anchor's diagnosis at equal effect and equal side
  effect instead of at whatever dose the norm of a difference of means happens to produce, and test
  its own untested prediction about SAE features while doing so.
]

Both gaps are cheap to close: a stated dose axis, a random control and two further sources of the
direction, no new method.

= Reading versus steering <sec:main>

#lead[
  *What and why.* This is the experiment the report is built around and the only part with
  results of its own. It starts from the anchor's claim @billa2026 that #Alin, the logit-lens hit
  rate of @sec:background, tells in advance where a steering vector will work. @sec:setup gives
  the setup and @sec:anchor reproduces the claim on a model more than an order of magnitude
  smaller than the ones it was shown on. @sec:sources is the part I added: the anchor never says
  how much it adds, so I compare four sources of a steering direction at equal side effect
  instead of at whatever dose each one happens to have. @sec:survives says what survives that
  comparison, @sec:limits what this setup cannot decide. If you read one table, read @tab:dose.
]

== Setup <sec:setup>

The families follow the anchor's design: two answer classes, a shared sentence template, and a
single-token answer, which matters because it makes the effect of an intervention a change in
one probability, with no decoding choices entering the measurement. I built six families and
picked them by measuring #Alin beforehand (@tab:families). Four carry
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
  as a predictor rather than as a description; it needs no training and one forward pass.
- *A logistic probe* on the same residual stream, fitted per layer, scored on a held-out quarter,
  with a control task on shuffled labels beside it @alain2017 @hewitt2019.
- *AUROC of the difference-of-means direction*: how well the single direction between the class
  means separates held-out examples.

And one way of writing one in: add a direction at every prompt position of the second class's
prompts. Its *effect* is $Delta P$, the change in probability of the first class's answer token;
its *side effect* is the Kullback--Leibler divergence of the next-token distribution on 50
unrelated prompts. Both are the anchor's measures, so its numbers and mine are comparable. KL on
unrelated prompts is a narrow notion of damage, since it says nothing about generation quality,
but it is cheap, it means the same thing for every family, and it needs no judge.

Everything runs on GPT-2 small @radford2019 (124M parameters, 12 layers,
#box[$d_"model" = 768$]) through TransformerLens @nanda2022, seed 0, on a laptop GPU. The two
notebooks run top to bottom in about 20 seconds and about three and a half minutes and write
their numbers to `results/`.

== The anchor, reproduced <sec:anchor>

The anchor reports its correlations on five models from Pythia-2.8B to Llama-8B. GPT-2 small is
smaller than all of them, so reproducing the pattern here is a test rather than a confirmation: a
measure like this could be an artifact of scale. It is not. For every family except `pronoun`,
#Alin is exactly zero in layers 0 to 7 and rises only from layer 8 on, the same shape the anchor
reports in layers 18 to 24 of a 2B model.
`pronoun` is the exception and jumps to 0.64 at layer 6. Within families, $rho$(#Alin, $Delta P$)
across the twelve layers is +0.48 to +0.90, inside the anchor's band of +0.63 to +0.92.

The probe fails as a layer selector, and "worse than #Alin" understates how. For `continent` and
`pronoun` the held-out probe reads 1.00 in every one of the twelve layers: it has no variance
left to rank layers with, so its correlation with steering effect is not weak, it is undefined.
Where it is defined it changes sign by family, +0.74 on `daynight` against −0.39 on `size`.

`continent` is the sharpest case, and the one the subtitle refers to:

#claim[
  On `continent` the probe reads the concept perfectly in all twelve layers, against a control
  task at 0.17 to 0.67, so this is not the probe memorising labels. #Alin peaks at 0.042, and
  steering moves the answer by at most +0.014. The concept is present, linearly readable, and
  unsteerable.
]

Two further claims of the anchor hold. The common "use a middle layer" heuristic loses exactly
where #Alin says it should: `temperature` gains +0.092 at layer 11 against +0.008 at layer 6, and
`daynight` +0.035 against +0.007. And the go/no-go threshold survives: `parity` and `continent`
stay below 0.05 peak #Alin and produce $Delta P <= +0.014$.

#figure(
  placement: auto,
  image("figures/07_reading_vs_steering.pdf", width: 100%),
  caption: [Reading against steering per layer, one panel per family. #Alin (circles) rises late;
    the probe (squares) is flat and high wherever the family has one template; the control task
    (triangles) shows the probe is not merely memorising; steering $Delta P$ (diamonds) follows
    #Alin, not the probe. Source: `notebooks/07_reading_vs_steering.ipynb`.],
) <fig:anchor>

Then the dose. The anchor adds the raw difference of means at coefficient 1, and across these six
families and twelve layers that vector's norm ranges from 0.5 to 58.4, while the residual norm
grows by a factor of eight across depth (@sec:background). Coefficient 1 is therefore a different
dose in each of the 72 cells, and an efficiency measure of $Delta P slash "KL"$ compares concepts
at whatever dose their difference of means happens to have.

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
norm of that layer. The whole comparison rests on this choice. The residual stream of GPT-2 small
grows by a factor of 8.5 across depth (76 → 644, then down to 489 in layer 11), so one absolute
dose is a heavy intervention early and a light one late; a relative dose makes "the same amount"
mean the same thing in every layer.

*Sources.* The difference of means; the probe's weight vector; one SAE decoder row; and a random
direction as the floor. The random one is the best of five draws in the layer scan and of three
per dose point in the sweeps, not a single draw: one random vector is a sample, and a floor built
from a sample moves. The SAEs are the public GPT-2 residual-stream set @bloom2024 (24 576 features
per layer, 32× expansion), and they exist for layers 0 to 10.#footnote[The folder names are off
by one: `blocks.{l+1}.hook_resid_pre` is bit-identical to `blocks.{l}.hook_resid_post`, so folder
$l+1$ holds the SAE for layer $l$. I checked this instead of trusting the names.] Layer 11 has
none, and layer 11 is where #Alin peaks for all four carrying families, so the SAE arm is blind at
the most interesting layer. That is a property of the available weights, not of the method.

The feature is selected on the training half with a criterion fixed before looking: fire on at
least 60% of one class and at most 25% of the other, with the sign fixed to the class the
intervention pushes towards. How often that fails belongs in the report, because the alternative
is to keep searching until something is found. In layer 6 nothing passes for four of six families and
the fallback is the largest mean gap, with held-out AUROC of 0.38 to 0.79 --- two of them below
chance. In layer 10 the criterion is met everywhere except `parity`, with held-out AUROC of 0.88
to 1.00 for five families and `daynight` the exception at 0.40.

*Readouts.* A twelve-layer scan at fixed $alpha = 0.1$, then a ten-point dose sweep ($alpha$ from
0.01 to 0.4) in layer 6, the middle-layer heuristic, and in layer 10, the deepest layer with an
SAE. Each sweep is read at one point fixed in advance: $Delta P$ at $"KL"^* = 0.1$ nats,
interpolated in $log "KL"$ because KL is monotone in dose. $Delta P$ itself is not: past some
dose the effect collapses as the model stops producing a sensible distribution at all, so a
comparison at a fixed dose can land on either side of that collapse. @fig:modes shows the three
ways of reading the same two curves, and why only the third compares at equal cost.

#figure(
  image("figures/comparison_modes.svg", width: 100%),
  caption: [Own figure, schematic. The same two directions read three ways. At the anchor's
    coefficient 1 each vector is added at its own norm, so the two are read at different doses;
    at a fixed relative dose both get the same amount; at equal side effect each is read where
    its KL reaches the budget. The curves are illustrative; the pattern is the one @tab:dose and
    @tab:equal show for the real families.],
) <fig:modes>

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

The anchor's implicit dose, the norm of its difference of means divided by the residual norm of
the layer, ranges from 0.003 to 0.119 across families and depth, and within each carrying family
it correlates with #Alin at +0.76 to +0.91 (@tab:dose). @fig:dose shows what that number means:
the dose rises in the same layers as the predictor. Holding the dose fixed, the within-family
correlation between #Alin and steering effect drops in every family, in one of them below zero
(last two columns of @tab:dose).

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

#figure(
  placement: auto,
  image("figures/dose_confound.pdf", width: 100%),
  caption: [The dose confound per layer, for the four carrying families. Top: #Alin. Bottom: the
    dose the anchor applies at coefficient 1, the norm of the difference of means divided by the
    mean residual norm of the layer. Both rise from layer 8 on; the $rho$ in each panel title is
    the fourth column of @tab:dose. Drawn from `results/` by `scripts/fig_dose_confound.py`.],
) <fig:dose>

That looks like a refutation, and my first reading of it was exactly that: at a fixed dose the
ranking of the families does not merely weaken, it inverts, with `size` moving from last place to
first. I held that reading back for one reason. At a fixed dose the four families do not pay the
same side effect, so the fixed-dose ranking is no fairer than the anchor's (@fig:modes, middle
panel). Read at an equal KL budget instead, the order comes out as `pronoun` > `temperature` >
`size` > `daynight` against the predicted `pronoun` > `temperature` > `daynight` > `size`, one
adjacent swap.

#claim[
  The apparent collapse of the ranking is itself a dose artifact. The weakening of the
  correlation is not. The anchor's predictor is real and its reported strength is inflated by a
  dose it never states.
]

Four further findings, all from @fig:sources and @tab:equal.

*The unstated dose is also not the best one.* With the same direction in layer 10, `pronoun`
reaches $Delta P = +0.495$ at $alpha = 0.2$, against +0.246 at the anchor's coefficient 1.

*Where the direction comes from matters less than which layer and how much.* In layer 10 the three
principled sources land within 0.03 of each other on `pronoun` and within 0.05 on `temperature`.
The large differences in the grid are between layers, not between derivations, which is awkward
for a literature that mostly compares methods of extraction.

*The anchor's untested SAE prediction does not hold uniformly.* Its third regime (high #Alin, so
the concept is already output-aligned and an SAE feature should add little) holds for
`pronoun` (+0.285 against +0.306) and fails for `temperature` in layer 10, where the SAE direction
wins outright (+0.175 against +0.130).

*Explained variance is blind to the concept.* On the four carrying families the SAE reconstruction
explains 93 to 99% of the variance of the residual stream, while 35 to 99% of the class separation
along the reading direction sits in the reconstruction error, the share Tiwari et al. measure at
74% on another model, another SAE and other concepts @tiwari2026. Replacing one layer by its own
reconstruction costs the model its answer: accuracy on `temperature` falls from 0.68 to 0.35, on
`size` from 0.25 to 0.07, on `daynight` from 0.31 to 0.09 (`pronoun` holds, 0.99 to 0.86). The
metric measures reconstruction, and reconstruction is not the concept.

Two things the controls caught. The random floor is not zero and it wins once: on `daynight` in
layer 6 it beats all three principled sources at equal side effect (+0.051 against +0.021, +0.005
and −0.038). And `parity` stays at exactly 0.000 across four sources, twelve layers and ten doses;
a pipeline reporting an effect there would be reporting its own noise. @galeone2026 find the
dissociation of @sec:anchor from the other side on a larger model, where a perfectly separating
detection direction stands at 83° to the direction that actually steers.

== What this setup cannot decide <sec:limits>

The directions are fitted on the same prompts that are then steered, as in the anchor; there is no
held-out steering set, so the effect sizes are upper bounds. The families have 24 to 72 examples
against 768 dimensions, so the held-out quarter is 4 to 18 prompts, which is why no probe number
here is quoted to three digits. The cross-family correlation rests on six points and is an
illustration, not evidence; the anchor uses 24. I also left out the anchor's second measure,
$A_"mlp"$, so its middle regime (present but not linearly readable) rests on the probe alone
here, and a failing probe never proves absence @belinkov2022. The random floor is the best of a
few draws, not a distribution, and the SAE arm cannot see layer 11, where four of six families
peak.

None of this is fatal to the conclusion, which is a comparison between directions measured the
same way rather than an absolute claim about steerability. It does mean that every number in this
section is a statement about GPT-2 small with these six families; the anchor's own result across
five larger models is the reason to think the pattern is more than that.

= Conclusion <sec:conclusion>

The question was whether a training-free predictor beats a trained one at saying where steering
will work, and whether it matters where the steering direction comes from. The probe cannot answer
the first one: it saturates at 1.00 across all twelve layers on two families, which leaves nothing
to correlate, while #Alin ranks the families in the order their steering effects arrive. The
anchor's correlation holds and is overstated: the dose it never states tracks its own predictor at
+0.76 to +0.91, and at a fixed dose its ranking inverts. Read at an equal side-effect budget
instead, which is the comparison I would defend, the predicted order survives with one adjacent
swap. On the second question the answer is that the
derivation matters least: in layer 10 the difference of means, the probe and the sparse-autoencoder
feature land within 0.03 to 0.05 of one another, while the same source read in layer 6 instead of
layer 10 moves `temperature` from +0.023 to +0.130. The controls decided what all of it means: a
random vector of the same norm won one cell outright, and the family the model cannot answer
stayed at exactly 0.000 everywhere.

Two questions remain, and I would put them to any steering result including my own: at what dose,
and compared at equal what?

#bibliography("refs.bib", style: "ieee", title: [References])

// ============================================================
// Appendix
// ============================================================
#pagebreak()

#set heading(numbering: "A.1")
#counter(heading).update(0)

= Appendix <sec:appendix>

Everything measured for this report is in #link("https://github.com/Henroxx/mechinterp_xai")[`github.com/Henroxx/mechinterp_xai`],
at the tag `v1.0-submission` --- the state this text describes. The paths that document how the
work was done are listed under the abstract; the table below is the measurement.

#v(0.3cm)

#[
  #set text(size: 9pt)
  #set par(justify: false)
  #table(
    columns: (5.4cm, 1fr),
    align: (left, left),
    inset: (x: 4pt, y: 3.5pt),
    stroke: none,
    table.hline(),
    table.header([*Path in the repository*], [*What is in it*]),
    table.hline(stroke: 0.5pt),
    [`notebooks/01_explore` ... `06_sae`],
    [The exploration of @sec:tour, one notebook per station: orientation, patching, steering,
     probing, a second model, sparse autoencoders. Single prompts and samples around twenty
     throughout.],
    [`notebooks/07_reading_vs_steering`],
    [@sec:anchor: #Alin, the probe, its control task, difference-of-means AUROC and steering
     $Delta P$ for six families across twelve layers. Runs top to bottom in about 20 seconds.],
    [`notebooks/08_direction_sources`],
    [@sec:sources: four sources of a direction over a ten-point dose sweep in layers 6 and 10,
     with the random floor and the reconstruction checks. About three and a half minutes.],
    [`results/*.json`],
    [The numbers behind @tab:families, @tab:equal, @tab:dose and both figures, as the notebooks
     wrote them. Re-running for this report reproduced the files byte for byte.],
    [`report/`],
    [This document: `main.typ`, `refs.bib`, and `figures/` with the notebook figures as vector
     PDF and the two schematics as SVG. `scripts/fig_dose_confound.py` draws @fig:dose from
     `results/`.],
    [`pyproject.toml`, `uv.lock`],
    [The pinned environment --- `uv sync` rebuilds it, `uv run` starts the notebooks. Seed 0
     throughout; `scripts/` holds the smoke test and the numerics check the setup was verified
     with.],
    table.hline(),
  )
]
