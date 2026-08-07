# Making the case: whistling as serious musicology

A strategy document for Prof. Clark. Written from the position of a senior reviewer:
what a corpus like this has to survive, how the topic earns its place in the field,
and where the tool helps versus where only a person can act.

**Legend** — 🔧 *the Workbench does this* · 👤 *human action, the tool cannot do it for you*

---

## 1. What a senior scholar will demand before taking the data seriously

The charts will not be attacked. The **method** will be.

1. **A corpus manifest.** 🔧 Every claim must trace to: which search terms, which date
   bounds, which archive, retrieved when, how many records. *Settings → Corpus & method →
   Freeze corpus version* writes exactly that, and *Export citable bundle* packages it with
   the data and a README. Reviewers forgive a small corpus; they never forgive an
   undocumented one.
2. **An error audit, stated in numbers.** 🔧 *Library → Audit…* draws a uniform random
   sample, walks you through it, and produces a sentence like *"a uniform random sample of
   50 records was hand-checked; 46 (92%) concerned whistling as sound or performance, and
   the automatic sound-type category agreed with the human coder in 83% of cases."* This
   single paragraph converts the tool from a toy into an instrument. It is the highest-value
   hour you will spend on the project.
3. **Named biases of the source.** 🔧 Chronicling America's digitisation is uneven by state,
   era and paper type. The Report prints a coverage table (records by state and by decade)
   and a standing limitations list, so the boundary of the evidence is stated *before* a
   critic states it.
4. **Inter-coder reliability.** 🔧 *Export audit packet* → two students code it blind →
   *Compare two codings* reports percent agreement and Cohen's κ with the conventional band.
   Standard in content analysis, almost unheard-of in musicology — doing it quietly makes the
   work bulletproof and methodologically novel at once.
5. **Control terms.** 🔧 "Whistling rose in the 1890s" means nothing if *all* newsprint rose
   in the 1890s. The **Baselines** lens counts comparison terms (banjo, yodeling, cornet)
   over the same archive so you compare shapes, not raw levels. The Vocabulary lens's
   *% of records* toggle does the same job inside your own corpus.
6. **Triangulation roadmap.** 👤 Newspapers alone give you reception history. Name the next
   legs even before you walk them: the trade press (*New York Clipper*, *Variety*),
   sheet-music covers, and the UCSB Discography of American Historical Recordings.

---

## 2. The intellectual framing — how whistling stops being a novelty

Never argue "whistling matters." Argue that whistling is a **tractable index of questions the
field already cares about**, and that this corpus makes them measurable.

### Gender and the sounding body
The corpus contains the proverb *"whistling girls and crowing hens never come to any good
end"* printed in the same era as admiring coverage of Alice Shaw. That tension *is* the
article: the *siffleuse* as a woman licensed to make public sound precisely by aestheticising
a forbidden act. 🔧 Track the billing vocabulary (*siffleuse* → *lady whistler* → *whistling
girl*) in the Vocabulary lens; the share view shows displacement rather than mere growth.

### Race and the birth of the record industry
George W. Johnson — arguably the first commercially successful Black recording artist — was a
**whistler**. Whistling cut through the acoustic recording horn better than almost any sound,
so it is disproportionately present at the origin of recorded popular music, with all the
racial politics of that catalogue. 👤 This connects the corpus to Sterne's *The Audible Past*
and de-trivialises the topic in one move.

### The voice/instrument boundary
Whistling is the body performing as instrument — a live problem in voice studies and
organology. Agnes Woodward's California School of Artistic Whistling shows **institutionalisation**:
method books, pedagogy, credentialing. The professionalisation of a "natural" act is a classic
musicological story. 🔧 The Performers lens shows her career span and reach.

### Sensory history, quantified
🔧 The sound-type taxonomy (person / wind / train / bird / metaphor…) measures how often
"whistle" meant a body, a machine, or a figure of speech, decade by decade — a contribution to
sound studies (Thompson, Smith) that no close reading can make, because only a corpus can
count. The Category-mix lens is that argument in one figure.

### A decline with a cause
Mentions peak in the 1910s and fall as radio-era crooning and electrical recording arrive.
👤 Whistling becomes a lens on *why particular sounds exit professional performance* — a
repertoire-extinction study, which is a more interesting paper than a survey.

---

## 3. Publication strategy — the deliverable pyramid

1. **Flagship article.** 👤 *Journal of the Society for American Music* or *American Music*
   (both friendlier to vernacular topics than *JAMS*; SAM is the right society). Pair **one
   distant-reading figure set** (timeline, vocabulary displacement, tour map) with **two
   close-read case studies** (Shaw; Woodward's school). Macro pattern plus micro texture is
   the combination reviewers reward.
2. **A separate data paper.** 🔧 The citable bundle is built for this. 👤 Deposit it on
   Zenodo for a DOI (the README walks through it) and publish a short dataset description.
   Datasets get cited by people who never cite arguments — influence compounds quietly.
3. **A tool review.** 👤 Submit the Workbench to *Reviews in Digital Humanities*. A favourable
   review credentials the method, and that credential transfers to every paper built on it.
4. **Figures travel.** 🔧 Every chart exports print-clean SVG and 2× PNG. Figures are the
   argument's advance guard through peer review, slides and social media.

---

## 4. Community strategy — how to move the field

- **Demo live; never show slides of the tool.** 👤 At SAM/AMS, run a query in the session,
  click a map arc, open the 1887 article behind it. 🔧 Provenance-on-click is theatre that
  doubles as epistemology: the audience watches a claim become checkable.
- **Propose a panel, not a paper.** 👤 *"Distant Listening: Corpus Methods for Vernacular
  Performance"* — you, a DH scholar, a sound-studies respondent. Framing the **method**
  recruits allies far beyond whistling.
- **Make the tool a teaching vector.** 🔧 Each cohort audits and annotates a fresh decade;
  verified records roll into Corpus v2, v3 with class acknowledgement. Adoption in other
  people's classrooms is the quietest and most durable form of academic influence.
- **Grants.** 👤 NEH Office of Digital Humanities (Digital Humanities Advancement Grants) and
  ACLS fund exactly this shape of project. A funded project acquires seriousness by
  institutional osmosis.
- **Public musicology as a flank.** 👤 One well-placed piece — a *99% Invisible* pitch, a
  *Smithsonian* essay on the siffleuse — creates external demand that colleagues notice.

---

## 5. Answering the skeptics

> **"It's a novelty topic."**
> So were jazz, film music and video-game sound — each canonised by one generation of scholars
> who arrived with new evidence. The evidence class here is a hundred thousand-plus searchable
> newspaper pages nobody has systematically read.

> **"You're anecdote-hunting."**
> 🔧 The corpus is falsifiable: the manifest records the exact queries, and *Reproduce from
> manifest* re-runs them on anyone else's machine. Offer it. Almost no musicological claim
> invites replication; this one does.

> **"The OCR is dirty."**
> Agreed — and quantified. 🔧 See the audit. Dirty data honestly bounded beats clean anecdote
> every time.

> **"Digitisation bias makes the trend meaningless."**
> 🔧 That is what the Baselines lens is for: control terms over the identical archive, compared
> as shapes rather than levels.

**The discipline that matters most:** say *"mentions in digitised newspapers,"* never
*"whistling in America."* Repeated consistently, that one habit separates a scholar using
digital methods from an enthusiast misusing them. The tool's own prose follows the same rule.

---

## The one-sentence thesis

> **Whistling is where the American press negotiated who was allowed to make sound in public —
> and this corpus lets us watch it happen at scale.**
