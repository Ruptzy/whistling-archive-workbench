# Whistling Archive Workbench

**A single-file, offline-first research instrument for digital humanities — built for a musicologist studying the history of whistling performers in American newspapers.**

One `index.html`. No build step, no server, no account, no API key, no dependencies to install. Double-click it and it runs — including the force-directed graph engine, the projected US map, ten publication-quality chart types, and a full corpus-methodology apparatus.

```
510 KB · one file · vanilla JS · zero npm dependencies · runs from file://
```

---

## The problem

Prof. Clark researches whistling as a serious performance practice in 19th–20th century America. Her workflow was a hand-maintained spreadsheet: no search, no visualization, no way to see patterns across thousands of newspaper mentions — and any tool built for her had to run on her laptop with **zero setup**, work offline, and never hold her data hostage.

That constraint drove every decision in this project.

## What it does

| | |
|---|---|
| **Harvest** | Searches the Library of Congress *Chronicling America* API directly from the browser (CORS-open, public domain) and pulls OCR text. One button runs the whole pipeline: search → fetch text → classify → extract performers → geocode. |
| **Ingest** | Adapter pipeline for PDF (PDF.js), images (Tesseract OCR), CSV/TSV with column mapping, JSON, ZIP (native `DecompressionStream`). |
| **Read** | Phrase search with editable word-form expansion (*whistle → siffleuse, warbling…*) and a 10–100 word context window. |
| **Interpret** | Nine-category sound-type taxonomy (person / wind / train / bird / performance / metaphor…), rule-based auto-classification with one-click override, plus a keyboard-driven triage mode. |
| **Visualize** | Ten chart lenses and an interactive US relationship map — see below. |
| **Write up** | Generates a scholarly report with a Chicago-style Works Cited, coverage tables and a limitations section; prints to PDF or exports Markdown. |
| **Teach** | Class-dataset packaging, assignment sheets, presentation mode, and blind inter-coder reliability packets. |

## Screenshots

> _Add images to a `docs/` folder and reference them here._

| Relationship map | Trends |
|---|---|
| `docs/map.png` | `docs/trends.png` |

---

## Built with

**No framework. No bundler. No npm.** Everything below is either hand-written or loaded on demand from a CDN and cached.

| Layer | Choice | Why |
|---|---|---|
| Core | **Vanilla JS (ES5-compatible scope, no modules)** | ES modules and web workers fail under `file://` — the zero-setup requirement ruled them out |
| Styling | **CSS custom properties**, two themes from one token set | Retune the whole visual identity from one `:root` block |
| Charts | **Hand-built SVG** via a custom grammar-of-graphics toolkit | Offline guarantee + a cohesive archival look no chart library gives you |
| Graph | **Custom Fruchterman–Reingold force layout on Canvas** | Full control over the centerpiece visualization |
| Map | **d3-geo + us-atlas** (`geoAlbersUsa`), loaded once and cached in IndexedDB | Correct AK/HI insets; decimated geometry for speed |
| Storage | **IndexedDB** (convenience) + **single-JSON export** (canonical) | Her data is never trapped in the tool |
| OCR / PDF | **Tesseract.js / PDF.js**, on demand | Only downloaded if actually used |
| AI *(optional)* | **WebLLM + WebGPU** (Qwen2.5-3B) or the Anthropic API | Runs locally so there's no ongoing cost — see below |

## Engineering highlights

**The single-file constraint.** No modules means no import graph, so the app is organized into commented sections that behave like modules (`Store`, `Settings`, `Persist`, `CA`, `Geo`, `Kit`, `Net`, `MapView`, `Report`, `Audit`). The whistle sound effect is a base64 data URI; the map outline is fetched once and cached.

**A chart toolkit, not eight charts.** `Kit` provides scales, honest tick generation (never `2.5 records`; decade-aware year ticks), quiet grids, one shared tooltip, direct labelling instead of legends, and a label-placement engine that *drops* a label rather than printing two on top of each other. Colours resolve from CSS tokens at render time and are inlined — which makes both themes correct **and** makes every exported SVG standalone.

**Publication-ready export.** Every figure exports SVG and 2× PNG. The serializer deep-inlines computed styles, strips classes, adds a white ground and remaps light-on-dark text to ink — so a chart drawn for the dark UI is legible on paper.

**Provenance on every line.** The map's relationship arcs connect cities sharing a performer or newspaper. Hovering names them; clicking lists the underlying articles. No line is decorative — every visual claim traces back to a scanned newspaper page.

**Free forever.** The professor runs unlimited searches with no key and no billing: a rule-based extractor handles the default path, and an optional 3B-parameter model runs *in her browser* via WebGPU for higher-quality extraction. Nothing in the tool requires the developer to stay in the loop.

**Text hygiene at the store boundary.** Library of Congress OCR contains numeric character references (`&#x0027;`) that corrupt both display *and* search. Rather than patching one importer, normalization runs inside `Store.add/update/replaceAll` — so every current and future adapter inherits it.

## The scholarly apparatus

The part that makes this a research instrument rather than a data viewer. Reviewers don't attack charts; they attack method. Five features answer the five questions a referee asks:

- **Corpus manifest & freeze** — snapshots exactly what the corpus contained on a given day, with every search run that built it. Exports a citable bundle (dataset + manifest + README with a dataset citation and Zenodo deposit steps).
- **Reproduce from manifest** — loads another scholar's exact query into the Fetch tab. The corpus is genuinely falsifiable.
- **Accuracy audit** — a uniform random sample, hand-checked, producing *"a uniform random sample of 50 records was hand-checked; 46 (92%) concerned whistling as sound or performance…"* Corrections write back, so the audit improves the corpus while measuring it.
- **Inter-coder reliability** — blind coding packets and **Cohen's κ** with the conventional band, reported alongside raw agreement.
- **Baselines** — control terms counted over the same archive, answering *"didn't everything rise in the 1890s?"*

Governing rule: **where a number wasn't measured, nothing is printed.** The report never fakes rigour.

---

## Running it

```
Double-click index.html
```

That's the whole procedure. To make it feel like an installed program on Windows: **extract the ZIP
first**, then double-click **`Install Whistling Archive.bat`** once — it puts a **Whistling Archive**
icon on the Desktop that opens the tool in its own window (Edge/Chrome app mode; nothing installed,
nothing copied). Windows shows its standard unsigned-file prompt on the first run only — the installer
clears the downloaded-file mark from the folder so it never appears again. (Removing even the first
prompt would require a paid code-signing certificate.) If it's run from inside the ZIP by mistake, it
explains what to do instead of failing. For development, any static server avoids `file://` quirks:

```bash
python -m http.server 8777
# then open http://localhost:8777/index.html
```

**Internet is needed once** for: fetching newspapers, the map outline (then cached), OCR/PDF engines, and the optional local AI model. Everything else — search, categories, all charts, reports, export — works fully offline.

## Project structure

```
index.html      the entire application
SPEC.md         living spec: data model, 15 architecture decisions, phase log
CLAUDE.md       engineering conventions and extension seams
STRATEGY.md     positioning the work academically
samples/        demo data, including a multi-city performer tour CSV
```

`SPEC.md` is the interesting one if you want the reasoning: every non-obvious decision is recorded as a dated AD with its rationale, including the ones that were revised.

## Not yet built

Tracked honestly in `SPEC.md` §13 so the UI never advertises what doesn't exist — including per-mention provenance, non-LoC archive adapters, and a formal accessibility audit.

---

## Credits

Built by **[Harold Gonzalez](https://github.com/Ruptzy)** for Prof. Clark's whistling history research project.

Newspaper data: [Chronicling America](https://chroniclingamerica.loc.gov/), Library of Congress — public domain.
Commercial newspaper databases are deliberately **not** used; the tool only ingests public-domain sources and files the researcher exported herself.
