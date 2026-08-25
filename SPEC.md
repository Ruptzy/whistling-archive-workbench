# Whistling Archive Workbench — Living Spec

> **This file is the source of truth, not the kickoff prompt.** When scope or a
> decision changes, update this file in the same change. Date format: ISO (YYYY-MM-DD).
> Created 2026-06-22.

## 1. Purpose

A digital-humanities research tool for **Prof. Clark**, a musicologist studying the
history of **whistling and whistling performers** as documented in historical
newspapers. The thesis driving the tool: *large-scale data reveals trends that
individual articles do not.* The tool helps her import archival clippings, search and
annotate them, categorize the kind of "sound" each mention refers to, and visualize
patterns across time, place, performer, and theme.

## 2. Prime directive & constraints

- **Runs on her own laptop, no developer help.** Strong preference: a single
  self-contained `index.html`, opened in a browser, running entirely client-side. No
  server, no account, no network dependency for core features. Data stays on her machine.
- **Forgiving UX.** Clear empty states, undo where feasible, never silently lose data.
- **Portability.** The whole dataset exports/imports as **one JSON file** for backup and
  moving between machines. Local persistence (IndexedDB) is a convenience, never the only copy.
- **No scraping / no subscription logins.** The tool only ingests files the researcher has
  *already legitimately exported* (e.g. newspapers.com print/export, Chronicling America
  bulk/API which is public domain). See §5.
- **AI is an enhancement, never a dependency.** Every non-AI feature works fully with no API key.
- **Optimize for change.** Small well-named modules, clear seams, adapter interfaces anywhere a
  choice may change later (data source, OCR engine, AI provider, chart lib, geocoding).
  Leave `// EXTEND:` comments at natural extension points.

## 3. Architecture decisions (ADRs — append, don't rewrite)

- **AD-001 (2026-06-22): Single-file, client-side, no build step.** Default target is one
  `index.html` runnable by double-click. Rationale: prime directive (zero setup, portability,
  data locality). *Revisit only if a hard requirement makes it impossible; justify here.*
- **AD-002 (2026-06-22, revised): Vanilla JS, no framework, no bundler, NO ES modules / NO web
  workers in core.** Resolves Q3 = single self-contained `index.html` opened via `file://`
  (double-click). ES modules and workers fail under `file://`, so all code is inlined in one
  `<script>`, organized into clearly-commented sections (store / adapters / search / ui) that act
  as logical modules. Rationale: prime directive, zero setup. *Caveat:* Tesseract.js OCR (Phase 2)
  uses workers and may not run under `file://`; handle in Phase 2 (inline worker via blob URL, or
  document a one-line server fallback for OCR only).
- **AD-003 (2026-06-22): Adapter-based import pipeline.** `detectType(file) → extractText(file)
  → normalizeRecord(extracted)`. Each source = one adapter module. Documented seam for new ones.
- **AD-004 (2026-06-22): Vendor third-party libs locally** (Tesseract.js, PDF.js, chart lib,
  map/SVG lib) so the tool works offline and is not pinned to a CDN's uptime. Pending Q3.
- **AD-005 (2026-06-22): AI behind one `askAI()` function**, direct Anthropic Messages API from
  the browser with `anthropic-dangerous-direct-browser-access: true`, user-pasted key stored
  locally only. Provider/model swap = one file.
- **AD-006 (2026-06-22): Word-form expansion via an editable rules map**, not a hardcoded list.
- **AD-007 (2026-06-22): Offline-friendly geocoding** — built-in gazetteer of common cities +
  manual lat/long per record. No hard dependency on a live geocoding API; leave a seam to add one.
- **AD-008 (2026-06-22): Tiered dependencies.** Core data layer, search, categories, editing, export,
  AND all visualizations are **dependency-free and fully offline**. Only *optional enhancers* load
  on-demand from a CDN, each with graceful offline fallback: **PDF.js** (PDF text layer), **Tesseract.js**
  (image/scanned-PDF OCR), the **world map outline** (fetched once, then cached in IndexedDB), and the
  **Anthropic API** (AI). ZIP is handled natively via `DecompressionStream` (offline). If an enhancer
  can't load, the feature degrades with a clear message; nothing core breaks. `loadScript()` /
  `loadCachedAsset()` are the single seams for this.
- **AD-010 (2026-06-22): Visual identity = "Cyber-Folk Archive."** Old oral tradition meets machine
  learning — an ancient music machine, archival/ritual, warm and lamplit. All color/font/space/radius/
  texture values are CSS custom properties in one `:root` block (retune from one place). Two themes from
  the same tokens: dark **archive** (default) + light **parchment**, swapped by one persisted toggle; no
  component hardcodes a color outside the tokens. **Fonts:** EB Garamond (display serif — old-manuscript,
  scholarly, carries the personality), Inter (UI sans — disciplined, legible for long sessions), IBM Plex
  Mono (metadata/catalog numbers — "scanned record" feel). **Palette tokens** (brand names): `--ink-blue`,
  `--charcoal-brown`, `--blackened-red`, `--ivory`, `--copper`, `--oxidized-bronze`, `--muted-teal`,
  `--dusty-rust`; copper + teal are the two signals, blackened-red is emphasis, derived shades only.
  **Signature element:** a whistle-tone **waveform** reused as a system — masthead, active-tab indicator,
  section dividers, and the import-progress scan. It breathes/scans subtly and holds as a still image under
  `prefers-reduced-motion`. Material cues: faint scan-noise + lamp glow, copper registration ticks on
  panels, mono catalog chips. Body-text/background pairs target WCAG-AA.
  **Background art:** a fixed, behind-content `.bg-art` SVG layer of musicology motifs — five-line
  staves, a beamed melodic phrase, sweeping whistle-waveforms, radiating "sound" arcs, a tuning fork,
  and notation glyphs — all token-coloured (theme-adaptive) at `--art-opacity`; the relationship-graph
  surface adds a tiled five-line `--staff` texture so the graph floats over sheet music. Faint enough to
  preserve legibility, `pointer-events:none`, scaled from one opacity token.
  **Whistle cue (2026-06-22):** a short whistle-melody MP3 (~99 KB) is inlined as a base64 data URI (keeps
  the single-file portability) and plays on the Search action and the Fetch "Search hits" action. A 🔊/🔈
  toggle in the top bar mutes it (persisted in `localStorage`); the `Sound` module is the seam.
- **AD-011 (2026-06-22): Scope is the United States; map = US tour/relationship view.** The project
  focuses exclusively on the USA. The map uses **Albers USA** (handles AK/HI insets, no distortion) via
  `d3` (`geoAlbersUsa` + `geoPath`) + **us-atlas** `states-10m` (TopoJSON, geographic coords, projected
  client-side; geometry decimated ~3× for a light SVG) + `topojson-client`, all on-demand & cached per
  AD-008; a linear continental-US fallback projection is used if offline & uncached. It renders city
  markers (sized by mentions), performer **tour routes** (cities in date order), performer/city focus,
  and an insights panel. *Note:* map overlay panels avoid `backdrop-filter` over the large SVG (it was a
  severe rasterization cost) — solid panels instead. Supersedes the earlier world-map approach.
- **AD-012 (2026-06-22): In-app Chronicling America harvester (open, public-domain, no server).**
  A `Fetch` tab lets the user search the Library of Congress Chronicling America corpus (US, 1836–1922,
  public domain) and import hits directly — confirmed by Prof. Clark's own survey as the free standard;
  commercial databases (Newspapers.com, GenealogyBank, ProQuest, NewspaperARCHIVE) are excluded (paid
  logins). Works fully client-side because **loc.gov sends `Access-Control-Allow-Origin: *`** on both the
  JSON API and the `/storage-services/` OCR host. **Two steps:** (1) search `www.loc.gov/search/?q="<term>"
  &fa=partof:chronicling+america&fo=json&c=1000&sp=N` (quoted for true full-text matches), paginate,
  store page-level hits with metadata (date, paper, city, state, `sourceUrl`, derived `altoUrl`); (2)
  resumable OCR fetch — the ALTO file URL is derived from each result's `image_url` (the word-coordinates
  service link carries the exact `/storage-services/.../NNNN.xml` path, so **no per-record JSON call**),
  fetched and stripped (`CONTENT="…"`) to `fullText`, then auto-categorized + geocoded. **Rate limits
  respected:** JSON ≤ ~17/min (LoC cap 20/min, 1-hr block), storage ≤ ~120/min (cap 150/min); the
  full-text step is resumable and skips pages already fetched. Terms default to the whistling vocabulary
  incl. *siffleur/siffleuse, "king/queen of whistlers," "whistling girl(s)," "lady whistler."* `CA`
  module is the seam; DPLA / state portals can be added later.
  **Enrichment passes (2026-06-22):** OCR pages lack coordinates and performer names, so two optional
  passes populate Map/Network/Performers: (1) **Geocode online** (`Geo` module) — resolves record cities
  via free OpenStreetMap/Nominatim (CORS-open, ≤1/sec, cached into the gazetteer, resumable) → Map; (2)
  **Enrich with AI** (`AIExtract` module) — sends a wide (~1,300-char) snippet around each whistling hit
  to `askAI` and parses JSON `{performer, composer, ensemble, venue, genre, sponsorship, audience,
  category, summary}`, filling **only empty fields** (never overwrites user edits; category only when
  still `unsure`; summary → notes). Throttled & resumable, needs the API key → enriches Network
  (Performer connections), Performers, and the rest. `fetchText` also backfills the OCR URL from
  `sourceUrl` for records gathered by older builds, so step 2 always works.
  **Cost controls + free option (2026-06-23):** the AI pass forces the cheapest model (Haiku), **batches
  ~8 snippets per request**, and offers a "performer-likely pages only" pre-filter — so hundreds of
  records cost cents. A separate **free, no-key heuristic extractor** (`HeuExtract`) pulls performer
  names/epithets from the text with strict capitalised-name rules (conservative, no false-positive
  garbage) so Network/Performers work with **no API key and no billing** — keeping the app fully
  standalone; AI remains an optional upgrade.
  **Selectable AI engine (2026-06-23):** Settings → **Engine** = *Local* (default) or *Anthropic*.
  **Local** runs an open model **in the browser via WebLLM + WebGPU** (`LocalAI` module, dynamic
  `import("https://esm.run/@mlc-ai/web-llm")`): **Qwen2.5-3B** (default — verified reliable for this
  extraction; Llama-3.2-3B alt; Llama-3.2-1B is fast but too weak for structured JSON) downloads once
  (~2 GB, cached, then offline) and runs on the user's machine — **no key, no per-pull cost, ongoing**
  for every future search. The local path enriches **one record at a time with a single-object prompt**
  (small models can't do batched arrays); the cloud path batches. Extracted values are validated
  (junk/"not specified"/city-as-venue dropped). Verified end-to-end: free local run found
  "Sibyl Sanderson Fagan · The Siffleuse" and populated Performers + Network. **Anthropic** = highest quality, paid key. `askAI(messages, system, opts)` routes by
  engine; `aiReady()` gates UI (local needs WebGPU, cloud needs a key). This is the answer to "she does
  many pulls, so AI must be free & ongoing": the local engine makes per-pull enrichment free forever.
  *Handoff:* ship the single `index.html`; with the Local engine + the free heuristic, the professor runs
  unlimited searches and enrichment with no key, no billing, no server, no upkeep. Trends/Heatmap/Clusters/Search work directly off date/category/text.
- **AD-013 (2026-08-07): One-click pipeline orchestrates the existing steps; it does not replace them.**
  Prof. Clark had to know that Fetch was three buttons *in a fixed order*. `runPipeline()` now chains the
  **unchanged** step functions — `CA.search` → `CA.fetchText` → `classifyAll` (rule-based) → `HeuExtract.run`
  (free, no key) → `Geo.run` — behind a single **“Build my corpus”** button, with one combined 5-stage progress
  bar and the same Stop/resume semantics (a `_pipeCancel` flag guards each stage boundary; every underlying step
  was already resumable). The individual buttons survive verbatim under an **“Advanced: run steps individually”**
  disclosure, so nothing was lost and each step is still independently testable. *Deliberately excluded from the
  pipeline:* the AI enrichment pass (`AIExtract`), which stays opt-in under Advanced — the default path must never
  require a key, a model download, or a bill. **Search presets** (`Settings.searchPresets`; three built-ins re-seeded
  on upgrade via `mergePresets()`, user presets preserved) remove the need to re-type vocabulary. A plain-language
  **finish card** reports what was added and links to Library/Map/Network/Trends.
- **AD-014 (2026-08-07): One chart kit, not eight hand-tuned charts.** The analytic views had drifted —
  each carried its own axis code, tick maths, colour list and tooltip, so they read as eight cousins rather
  than one instrument. `Kit` is a small **grammar-of-graphics toolkit** (~230 lines) that every lens now
  composes from, which is what actually produces a ggplot2-grade look: consistency is the aesthetic.
  It provides **scales** (`lin`, `band`), **honest tick generation** (`ticksCount` never emits "2.5 records"
  and expands the axis to a round number; `ticksYears` prefers 10/20/50-year gaps so labels read as periods),
  a **quiet grid** (horizontal rules only — no chart borders, no axis spines), **mono axis text / serif titles /
  sans annotations**, `smooth()` for moving averages, **one shared tooltip** (a single body-level node that
  follows the pointer, flips at the viewport edge, and works on touch), and `mount()` figure chrome.
  **Direct labelling replaces legends** wherever series ≤ ~6 (the eye shouldn't have to travel to a key).
  **Colour comes only from the AD-010 tokens**, resolved with `getComputedStyle` at render time and *inlined
  as concrete values* — one decision that solves three problems at once: both themes stay correct, sequential
  ramps are computed in JS (`Kit.mix`) rather than depending on CSS `color-mix()`, and **exports stand alone**.
  **Export is a headline feature, not a nicety:** every figure carries SVG + PNG(2×) buttons. `serialize()`
  deep-inlines computed styles (so class-driven art like the map survives), strips classes, adds a white
  ground, and **remaps light-on-dark text and strokes to ink** so a chart drawn for the dark UI is legible on
  white paper. Charts Prof. Clark can drop straight into a paper were the point.
  *Statistical honesty:* the timeline's trend line is a labelled moving average with no fabricated confidence
  band; the vocabulary lens offers raw counts **and** share-of-records, because displacement only shows in share.
- **AD-015 (2026-08-07): A scholarly apparatus — the corpus must be able to defend itself.**
  This work is going into peer review, where nobody attacks the charts and everybody attacks the *method*:
  where did the corpus come from, how wrong is it, what are the source's biases, can anyone reproduce it?
  Five features answer those questions **in the data, not in prose the author has to remember to write**:
  **(1) Fetch run log** — every `CA.search`/`CA.fetchText` run appends terms, year bounds, target and yield to
  `Settings.fetchLog` (capped at 200). Silent, and the foundation for everything else: with it the manifest
  writes itself. **(2) Corpus manifest + freeze** — `buildManifest()` snapshots counts, provenance split, date
  span, distinct newspapers/cities/states, category counts, hand-verified count, the fetch log and any audits;
  *Export citable bundle* emits dataset + manifest + a README carrying a dataset citation, the reproduction
  recipe, the limits paragraph and Zenodo deposit steps. *Reproduce from manifest* loads another scholar's exact
  query into Fetch — the falsifiability feature. **(3) Accuracy audit** — a uniform random sample, hand-checked
  on relevance and category, producing precision and category-accuracy plus a copyable methods sentence;
  corrections write back through the Store, so the audit improves the corpus while measuring it. **(4) Inter-coder
  reliability** — blind packets (category stripped, excerpt embedded so they code on a machine with no corpus),
  and Cohen's κ with the conventional band reported *alongside* raw agreement, since κ depends on category
  prevalence. **(5) Baselines** — control-term counts over the same archive, answering "didn't everything rise
  in the 1890s?"; cached per term×decade, throttled to the harvester's polite rate, and **bounded by a 15s abort**
  because a stalled request must never freeze the run.
  **Statistical honesty is the governing rule:** *unsure* answers are excluded from denominators rather than
  guessed; sections print **nothing** where no measurement exists (the Report never fakes rigour); and all
  user-facing prose says *"mentions in digitised newspapers,"* never *"whistling in America."*
  All apparatus state lives under `settings` and rides the existing Export JSON envelope — no `schemaVersion`
  bump, because the record model did not change.
- **AD-009 (2026-06-22): Bespoke visualizations, no chart/graph library.** Timeline, heatmap, keyword
  clusters, map, and the **relationship graph** are hand-built in SVG/Canvas. Rationale: (1) offline
  guarantee per AD-008, (2) cohesive archival visual identity (brief: avoid generic templated looks),
  (3) full control over the centerpiece relationship graph, which uses a custom force-directed Canvas
  engine (Fruchterman–Reingold, percentile `fitView`, drag/zoom/pan/focus/filter). EXTEND seam: each viz
  is a self-contained render module reading from the store.
  **Relationship graph — two modes (2026-06-22):** default **Performer connections** projects the data
  onto a whistler-to-whistler network — two performers are linked when they shared a city, newspaper, or
  venue; node size = mentions, node colour = home city (scene), edge thickness = number of shared contexts,
  and an edge's panel says *exactly* what links them ("both appear in: New York, The New York Times, …")
  with the supporting articles. **People & places** keeps the full bipartite web (performers ↔ cities ↔
  newspapers ↔ venues ↔ composers ↔ ensembles). Soft node glow + scene colours give visual weight.
  **Provenance & polish:** every node and edge carries its **source records**; the focus panel lists those source articles (date · newspaper · city · performer), each
  click **opens the underlying article** (record drawer), and edges expose the co-occurrence articles
  that link two entities — so a researcher can always trace a connection back to the newspaper evidence.
  Visual finish: framed "lens" surface (inner vignette, no page bleed), readable label pills over the
  textured ground, paper rings on nodes, hub-only labels with focus-aware dimming, connection chips that
  navigate, type filters, min-connections, and node search.
  **Controls placement (2026-06-22):** Network & Map menus live in a compact `.viz-toolbar` *above* the
  canvas (not floating over it), so the visualization is unobstructed; the details/insights overlay panel
  has a "Hide panel" toggle for a full-bleed view.
  *Import fix (2026-06-22):* CSV header alias for the text column now maps to the `fullText` field
  (was `fulltext`), so imported article text is clean (no metadata prefix).

## 4. Data model

A **record** is one ingested newspaper item. Stored fields (all metadata user-editable;
auto-fill what we can parse, leave the rest blank, never fabricate):

| field | type | source | notes |
|---|---|---|---|
| `id` | string | generated | stable unique id |
| `sourceFile` | string | import | original filename |
| `fullText` | string | extract | OCR/text-layer/CSV cell |
| `date` | string (ISO, partial OK) | parse | e.g. `1897`, `1897-03`, `1897-03-14` |
| `year` | number | derived | for binning |
| `city` | string | parse/edit | |
| `state` | string | parse/edit | region/state/country |
| `newspaper` | string | parse/edit | |
| `performer` | string | parse/edit | |
| `composer` | string | parse/edit | |
| `ensemble` | string | parse/edit | |
| `venue` | string | parse/edit | |
| `audience` | string | parse/edit | |
| `genre` | string | parse/edit | |
| `sponsorship` | string | parse/edit | |
| `mentions` | number | derived/edit | count of matched terms in this record |
| `category` | enum (see §6) | rule-suggest/edit | sound-type |
| `notes` | string | user | freeform |
| `lat` | number\|null | gazetteer/edit | |
| `lng` | number\|null | gazetteer/edit | |

**Dataset envelope** (the single JSON export) — **schemaVersion 2** (2026-08-07):
```json
{ "schemaVersion": 2, "exportedAt": "<ISO>",
  "dataset": { "title": "...", "description": "..." },        // OPTIONAL — class-dataset label
  "records": [ ... ],
  "settings": { "expansionRules": {...}, "categoryRules": {...}, "gazetteer": {...},
                "searchPresets": [...], "presentationMode": false, "tourSeen": true } }
```
`schemaVersion` exists so future imports can migrate older files. **Migration v1 → v2 is
tolerant and non-destructive:** v1 files simply have no `dataset` key and import unchanged
(`migrateDataset()` returns a null label); no record field moved. When `dataset` is present the
title/description are shown on the Home "Class dataset" card after import. **The API key is
never included in the export** (verified: `serializable()` strips it).

## 5. Import layer (adapter pipeline)

Pipeline: `detectType → extractText → normalizeRecord`. Adapters planned:

- **PDF** — text layer first (PDF.js), OCR fallback (Tesseract.js) when no/low text.
- **Image** (PNG/JPG) — OCR.
- **CSV/TSV** — map columns to fields; user confirms column mapping.
- **Plain text** — one record, or split on a delimiter.
- **Chronicling America JSON** — public-domain LoC bulk/API records → normalized fields.
- **ZIP** — unpack, route each entry through `detectType`.

OCR runs client-side with a **visible progress indicator**, behind one swappable function.
**Seam:** adding a source = add `adapters/<name>.js` exporting `{ detect, extract, normalize }`
and register it; no importer rewrite.

## 6. Sound-type categories

Enum: `person-whistling`, `wind-weather`, `train-machine`, `bird-animal`,
`music-performance`, `object-sound`, `motion-violence`, `not-about-sound`, `unsure`.

**Why records used to pile up in `unsure` (fixed 2026-08-20).** `suggestCategory()` reads
`fullText`, so it returns `null` for any record whose OCR text has not arrived — and the record
then displayed as **Unsure**, which reads as *"the classifier judged this and gave up"* when in
fact nothing had been judged at all. After a search run whose *Fetch full text* step was
interrupted (the Library of Congress rate-limits long runs), an entire library could show
`UNSURE` end to end. Two changes:
- **Seed from the search term.** `TERM_CATEGORY` maps *unambiguous* terms to a category —
  `siffleur`/`siffleuse`/`lady whistler`/`king of whistlers` can only describe a person;
  `artistic whistling`/`whistling recital` are performance. `CA.search` records the term that
  matched (`record.matchedTerm`) and seeds the category at creation, so those records are
  classified **before any OCR text exists**. Ambiguous terms — `whistling` alone could be a
  train — are deliberately left unclassified rather than guessed.
- **Stop claiming a verdict that was never reached.** A record with no text now shows a dashed
  **"No text yet"** chip instead of "Unsure" (`needsText()` / `catChip()`); the stored value is
  still `unsure`, so no data model change. *Unsure* is reserved for records that were actually
  examined. **Classify** reports how many records are blocked on missing text and offers a
  button to go and fetch it.

`matchedTerm` is a new optional record field; absent on older data, which is handled, so no
`schemaVersion` bump was needed. **Regression guard (2026-08-25):** 16 in-app self-checks
(`runSelfChecks()`, Settings → About; auto-run on localhost) pin these fundamentals against the real
functions — classifier verdicts, term seeding via `CA.recFromResult`, the never-guess rule for
ambiguous terms, chip states, and entity hygiene at the store boundary.
Rule-based **auto-suggestion** from nearby words, **one-click manual override**, rules the
user can view/edit. Override always wins and is marked as user-set.

## 7. Search

- Keyword + exact phrase across `fullText` (and optionally metadata).
- **Word-form expansion** via editable rules map (whistle → whistles, whistled, whistling,
  whistler, whistlers). User can add/edit stems.
- **Adjustable context window:** 10 / 30 / 50 / 100 words around each hit, matched term
  highlighted, source metadata shown with each snippet.
- Export current results → CSV. Whole dataset → JSON.

## 8. Visualizations (all read the same record store)

*All nine Trends lenses are composed from the `Kit` toolkit (AD-014) and carry SVG/PNG export.*

- **Mentions over time** — bars per year/decade with a labelled **moving-average trend line**, ★ outliers,
  y-axis anchored at 0; click a bar to list those records.
- **Vocabulary trajectory** — multi-line with **direct end labels** (no legend), optional smoothing, a
  **raw-counts ↔ % of records** toggle, and a ringed **peak-decade annotation** per term.
- **Sound-theme heatmap** — categories × decades as an SVG matrix with a **sequential copper ramp**
  (sqrt-scaled so mid values stay readable), **row and column totals in the margins**, and click-through
  to exactly those records.
- **Category mix** — 100% stacked proportions by decade, **direct labels on bands wide enough to hold
  them**, hover isolates one category across every decade.
- **Reach over time** — **small multiples**: distinct cities / newspapers / performers as three panels on a
  shared scale, which compares more honestly than three lines on one axis.
- **Top sources** — sorted **lollipops** for cities and newspapers, value at the tip, click-to-filter.
- **Performer activity** — a **Gantt** of career spans with per-year dots **sized by mentions that year**
  (so bursts separate from steady presence), epithet under the name, click for the profile.
- **Keyword clusters** — sound-world word grid plus a **per-cluster sparkline** of that world's trajectory.
- **Compare** *(new)* — overlay any two performers, cities, newspapers **or terms** on one decade axis.
- **US tour & relationship map (AD-011, extended 2026-08-07)** — United States only. Albers USA outline
  (d3 + us-atlas, decimated, cached; linear fallback offline). Now a full instrument: **wheel-zoom to the
  cursor, drag-pan, double-click reset, pinch**; **collision-aware labels** resolved in pixel space with the
  busiest cities claiming their label first; **dot area ∝ mentions**; a **Connections mode** drawing weighted
  curved arcs between cities that share a performer (copper) or a newspaper (teal), where **hovering names
  the shared people and clicking lists the underlying articles** — the same provenance standard as the
  Network, so no line is ever decorative; **tour playback** animating a performer's route in date order with
  a ticking year (reduced-motion instead numbers the stops 1…n statically); a **decade brush** filtering
  dots, arcs and tours live; and SVG export.
  *Architecture:* only the state paths sit in a transformed `<g>`; dots, arcs and labels are drawn in
  **screen space**, which keeps them a constant size at any zoom and makes label collision solvable in pixels.

## 9. AI assistant (v1, optional)

- Chat panel + quick actions: *explain this snippet*, *suggest a category*, *recommend related
  search terms*, *summarize these results*.
- Direct Anthropic Messages API from browser; user pastes key into settings (stored locally,
  never hardcoded, never exported). `anthropic-dangerous-direct-browser-access: true` header,
  current model string. All calls via `askAI()`.
- Graceful absence: with no key, AI UI shows a clear "add a key in Settings" state; nothing else breaks.

## 10. Design / quality bar

- Scholarly, archival, distinctive visual identity (not a generic template). Legible for long
  sessions. Responsive down to a laptop screen. Visible keyboard focus. Respect reduced-motion.
- Small functions, comment the non-obvious. **No fake/placeholder features** — unbuilt things go
  in §13, not into the UI.

## 11. Phased build plan

> Detailed and revised as we go. Each phase ends with a "what to test" note.

- **Phase 0 — Skeleton & store. ✅ DONE (2026-06-22).** `index.html` shell, layout, record store
  (in-memory + IndexedDB persistence w/ graceful fallback + JSON import/export), settings (API key,
  model, expansion rules) with the key excluded from exports.
- **Phase 1 — Thin vertical slice. ✅ DONE (2026-06-22).** Import *plain text + CSV/TSV* via
  drag-drop → record library list w/ filter → word-form search ("phrase" + keyword, editable rules)
  → context-window snippets (10/30/50/100) → CSV (library & results) + JSON export. No OCR yet.
- **Phase 2 — Full import layer. ✅ DONE (2026-06-22).** PDF text layer (PDF.js on-demand), image +
  scanned-PDF OCR (Tesseract.js on-demand, progress), ZIP (native `DecompressionStream`), Chronicling
  America / generic JSON adapter, CSV column-mapping confirm UI.
- **Phase 3 — Editing & categories. ✅ DONE (2026-06-22).** Record edit drawer (all fields + lat/lng w/
  gazetteer auto-fill); rule-based category suggestion + one-click override + editable category rules.
- **Phase 4 — Visualizations. ✅ DONE (2026-06-22; expanded 2026-06-23).** Timeline (mentions/
  term-trends/outliers), Map (US Albers tours), Heatmap (category × decade), Keyword clusters,
  Performer/tour tracking + usefulness scoring. **Trends now has 8 lenses** — added **Category mix**
  (100%-stacked sound-type proportion by decade), **Reach over time** (distinct cities/newspapers/
  performers per decade = diffusion), **Top sources** (ranked city & newspaper bars, click-to-filter),
  and **Performer activity** (career-span timeline, first→last mention, click→profile). All bespoke SVG (AD-009).
- **Phase 5 — AI assistant. ✅ DONE (2026-06-22).** `askAI()` + chat panel + quick actions; degrades
  cleanly with no key.
- **Phase 6 — Polish. ✅ DONE (2026-06-22).** Empty states, undo, a11y, reduced-motion, visual identity.
- **Extras. ✅ DONE (2026-06-22):** Relationship graph (centerpiece, custom Canvas force engine),
  reusable collections, vocabulary-trajectory/term trends, outlier detection, performer usefulness score.
- **Home / landing. ✅ DONE (2026-06-22; reworked 2026-08-07):** A `Home` tab (default view) — hero with the
  waveform signature, a short scope statement, the Whistle-of-the-day and Class-dataset cards, and a 6-card
  feature grid. **The grid is now navigational, not decorative:** each card is a `<button>` with a token-coloured
  inline SVG icon that opens the feature it describes, copy trimmed to 7–11 words, and an explicit
  1 / 2 / 3-column grid at 620 px / 980 px so six cards always form clean rows (the old `auto-fit` left an
  orphan row of two). Hover lift + "OPEN →" affordance, `:focus-visible` ring, and `prefers-reduced-motion`
  disables the transform. Hero CTAs now lead with **Start here — read the guide**.
- **Teaching / classroom. ✅ DONE (2026-06-23; Guide promoted 2026-08-07):** Prof. Clark plans to teach undergrads
  with it, so: a **Guide tab** — now the **second tab, immediately after Home** (it was buried beside Settings at the
  end of a 12-tab row, the wrong place for the thing you read *before* starting). Restructured as **Start here**
  (what this is → four numbered steps end-to-end → "export JSON before you close"), followed immediately by a
  highlighted **"Why some of the text looks like gibberish"** callout, because OCR noise is the single most likely
  thing to make a new user think the tool is broken.
  **Split into quick vs. full (2026-08-07):** the detail was accurate but a wall of ~1,400 words is itself a barrier —
  it risks scaring people off before they ever click anything. The tab now opens on a **~165-word quick start**: four
  one-line numbered step cards (2×2), "then Export JSON", and a two-sentence version of the OCR note. Two buttons —
  **Open the full guide →** and **Replay the guided tour** — plus a *Why this happens →* link that jumps straight to
  the OCR section of the full document. **Nothing was cut:** the complete guide (start here · OCR explained with a
  side-by-side *what the scanner produced* vs *what this workbench shows you* demo · for students · for instructors ·
  assignment sheets · discussion questions · glossary) lives in `#guideFullDoc`, toggled by `showGuideFull()`, with
  Back links top and bottom. Re-entering the tab always resets to the short version, so the first thing seen is never
  the wall. **Styled in the AD-010 vocabulary** rather than as plain boxes: the animated **waveform signature** beside an
  EB Garamond small-caps `Guide`, a **wave-divider** under the intro, and step cards as *archival catalog cards* —
  zero-padded IBM Plex Mono numbers (`01`–`04`) in engraved copper medallions (translucent fill, copper ring, soft
  outer glow), EB Garamond small-caps titles, the faint five-line `--staff` ground reused from the graph surface, a
  copper **registration tick** in the bottom-right echoing the panel corners, and a mono footer rule for the
  export-your-work line. Corner ticks on the callout come from `.panel::before/::after`, so `.callout` never overrides
  them; the step cards are not panels and use their own `::before`/`::after` freely.
  Also a **Library "Classify"** button to (re)run the sound-type classifier on demand;
  and **"Cite this"** on each record (newspaper citation + LoC link, copy to clipboard). Instructor
  workflow = prepare a curated dataset once (fetch→text→geocode→enrich), **Export JSON**, share the file +
  `index.html`; students Import and work offline, no key/cost. *Roadmap (suggested, not yet built):*
  "reset to class dataset," per-assignment locked collections.
- **Session report. ✅ DONE (2026-06-23):** A `Report` tab compiles the records in scope into a
  musicology-style write-up (`Report` module) — Overview, Sources & method, a Performers table,
  Geographic distribution + tours, Sound-types, Selected mentions with citations, and a Chicago-style
  **Works Cited** (via `citationFor`, with LoC links). Optional **AI-drafted Discussion** (uses the
  Settings engine — free local or cloud). Output: **Print / Save as PDF** (a `@media print` stylesheet
  prints only the report, black-on-white) and **Download Markdown** (paste into Word). Reads
  `activeRecords()`, so a collection scopes the report.
- **Whistle of the day (2026-06-23):** Home shows a rotating "fun fact" card — a **curated, accurate**
  set of ~22 facts about whistling in music/performance (chosen over AI to avoid hallucinated history).
  It's deterministic by **day-of-year** (same fact all day, new one each day); a ↻ button cycles others
  for the session. `FACTS` array + `renderFact()`.
- **Dashboard chrome (2026-06-23):** to use the empty margins/space, a pinned **bottom status bar**
  (scope · records · decade span · % with text · performers/cities/papers, live via `scopeStats()`/
  `updateDashboard()`, subscribed to the store) and a **wide-screen side-rail** (≥1800px) with an
  at-a-glance summary (incl. top performer/city) + quick actions (Fetch, Report, Export). Both respect
  the active collection scope.
- **Streamlining & classroom pass. ✅ DONE (2026-08-07).** An incremental polish pass on the finished tool,
  aimed at (a) making the daily workflow one decision instead of five, and (b) undergraduate teaching. Built:
  1. **One-click “Build my corpus”** (AD-013) + **Advanced** disclosure keeping the four original step buttons.
  2. **Search presets** — *Whistling performers (broad)*, *Lady whistlers / siffleuses 1885–1915*,
     *Whistling schools & instruction 1900–1922*, plus “Save as preset…” / “Delete preset” for the user's own.
     Built-ins are re-seeded on upgrade; user presets are kept and ride along in Export JSON (never the key).
  3. **Finish summary card** — records added, newspapers, year span, music/performance count, performers named,
     and buttons into Library / Map / Network / Trends.
  4. **Library excerpts pick the most READABLE window** — the cell used to show the top of the OCR page
     (masthead + ads). It now scores every whistling-term window on the page and shows the clearest one, with the
     term `<mark>`-highlighted, reusing the editable word-form expansion (AD-006) compiled to one cached regex.
     See "Coping with OCR noise" below.
  5. **Review mode** — Library → **Review…** steps through the filtered records one at a time (large excerpt,
     source line, category chip) with **Keep / Not about whistling / Unsure**, keyboard **K / N / U / ← / → / Esc**,
     and a "12 of 87" counter. All writes go through the Store; closing offers a **single Undo for the whole
     session's re-categorisations** (restores both `category` and `categoryUserSet`).
  6. **Empty states with an exit** — Network, Map, Trends (all lenses), Performers and Report now say specifically
     what is missing and carry a button that navigates there (`emptyState()` + one delegated `[data-goto]` handler).
  7. **First-run tour** — a dismissable 4-step overlay (Fetch → Library → Map/Network → Report) that switches the
     view behind it as it goes; keyboard and click, shown once (`Settings.tourSeen`), replayable from the Guide.
     No animation, so `prefers-reduced-motion` is honoured by construction.
  8. **Class datasets** — Settings → **Save as class dataset…** (title + description embedded, schemaVersion 2),
     a Home **“Open a class dataset”** card that reports the imported set's own title, **Export my findings**
     (Markdown of every record with a user note + its `citationFor()` citation), and a Guide section with three
     ready-to-hand-out **assignment sheets** (tour tracing, category analysis, citation practice).
  9. **Classroom / presentation mode** — Settings toggle, persisted, adds `body.presentation` which hides
     “Clear all”, per-record delete and dataset import. *Deviation (intentional):* the Home “Open a class dataset”
     card stays visible in this mode — it is the sanctioned student entry point; only the overwrite-style import
     controls are hidden. `clearAllRecords()` also refuses in code, not just in CSS.
  10. **Small polish** — “Clear all” now names the exact count and offers **Export backup first**; a once-per-session
      nudge to export JSON after a run adds 50+ records (via a new `toast(..., {action})` option); the whistle plays
      when a long fetch finishes (respecting the mute toggle).
  *Fixed in passing:*
  - **OCR text was storing raw character references.** LoC ALTO files carry **numeric** refs (`&#x0027;` `&#x2014;`
    `&#x201E;`), and some are double-escaped (`&amp;#x00FC;`), but `altoToText` decoded only five *named* entities —
    so the literal entity strings landed in `fullText`. That corrupted the display **and search** (a word split by
    `&#x0027;` could never be matched). A shared `decodeEntities()` (named + decimal + hex, two passes for
    double-encoding, control chars dropped, malformed refs left untouched) now runs inside `altoToText`, and a
    **`repairEntities()` migration** cleans archives built by earlier versions — it runs on load and after every
    import, is idempotent and additive (nothing is ever deleted), and reports how many records it tidied.
    Rendering still escapes everywhere, so decoded markup shows as text (verified: no HTML injection).
    **Guaranteed at the Store boundary, not per-adapter.** Fixing `altoToText` alone would only close one door —
    CSV, PDF, OCR, ZIP and JSON imports could all carry encoded text. So `normalizeRecordText()` (over `TEXT_FIELDS`;
    `notes` is excluded as the user's own writing) is applied in **`Store.add` / `Store.update` / `Store.replaceAll`** —
    the choke point every record must pass through per CLAUDE.md — plus the two in-place writers (`CA.fetchText`,
    `AIExtract.applyTo`, whose model output is untrusted) and a `repairEntities()` sweep after each harvest.
    **Any future adapter inherits this for free.** Verified against a live LoC file whose raw ALTO contains
    `CONTENT="Royaf&#x0027;"` → stored as `Royaf' Leads`.
  - `d3.geoPath` returns `null` for geometry outside the Albers USA composite (Puerto Rico is in
    `states-10m`), which emitted `<path d="null">` and console errors on every map render — those paths are now filtered.
- **Publication-quality analytics pass. ✅ DONE (2026-08-07).** The charts worked but read as eight separate
  hand-tuned drawings; these will end up in Prof. Clark's papers and lectures, so the bar is ggplot2 /
  *Economist*, not "a chart appeared". Built:
  1. **`Kit` chart toolkit (AD-014)** — the foundation everything else rides on: nice ticks, quiet grids,
     shared tooltip, direct labelling, token-resolved colour, and **SVG + PNG(2×) export on every figure**,
     print-clean on white regardless of the app theme.
  2. **All 8 lenses rebuilt on Kit and upgraded statistically**, plus a new **Compare** lens — see §8.
  3. **The map became an instrument** — zoom/pan, collision-aware labels, area-scaled dots, **Connections
     arcs with article-level provenance**, tour playback (with a static numbered fallback under
     reduced-motion), a decade brush, and export — see §8.
  4. **Light-touch linked views** — one `libraryFilterBy({label, test})` entry point. Clicking a timeline bar,
     a heatmap cell, a mix band, a lollipop, a map city or a map arc filters the Library to exactly those
     records and shows a **“filtered: X ✕” chip** to clear it. No crossfilter framework; charts stay pure
     readers of `activeRecords()` and mutate nothing.
  5. **Legibility sweep (2026-08-07).** Polish is not decoration — overlapping ink is unreadable ink:
     - `Kit.placer()` reserves label boxes and finds the nearest free vertical slot, **dropping a label
       rather than printing two on top of each other**. Used for the vocabulary end labels + peak
       annotations and the Compare end labels; both reserve the x-axis strip so a series ending at zero
       can never land on a tick label.
     - **Timeline:** the trend line is now **dashed and thin** so it reads as an annotation layer rather
       than a second data series, the floating "smoothed" text is gone, and its key sits in a
       **guaranteed headroom band** (the y-axis gains a step whenever the tallest bar exceeds 86% of the
       top tick) so the legend can never collide with a bar.
     - **Vocabulary:** peaks are annotated only when the series is actually visible (≥15% of chart max)
       *and* genuinely spikes (≥1.6× its own mean) — annotating flat noise was clutter.
     - **Category mix:** the category name's home band is chosen *first*, so the percentage is never
       printed underneath it. A name is only placed inside a band when it **measurably fits**
       (`Kit.textW` vs. band width) — one line if it fits, **wrapped to two balanced lines** if that fits
       (“Person whistling” → “Person / whistling”), and otherwise it drops to a **legend strip** beneath
       the axis so every category stays identifiable. Line height is 13.5px, above the cap height, so
       wrapped lines never touch. Percentages are likewise suppressed when they would overflow their band.
     - **Map:** arcs are the big one. They are now **trimmed to the dot edge** (no lines spearing through
       markers), **painted weakest-first** so strong links sit on top, drawn much fainter
       (opacity 0.10–0.52, width 0.7–3.0), and **capped to the strongest 18** unless you focus a city or a
       performer — at which point you see all of that entity's links. Same-city-cluster pairs too short to
       read are skipped, and city labels gained a heavier paper halo so arcs passing behind stay legible.
       The status line states honestly when it is showing "strongest 18 of 51".
  *Also fixed:* `prefersReduced` was read once at load, so a mid-session OS change was ignored — it is now a
  live `matchMedia` listener, which is both more correct and what let the reduced-motion path be verified.
  *Verified against a real 99-record corpus* (70 fetched from Chronicling America + the sample tour CSV):
  filtered row counts cross-check exactly against heatmap cell and column totals.
- **Pipeline speed pass. ✅ DONE (2026-08-25).** "Build my corpus" was serial end to end; three changes,
  none of which touch the politeness promises:
  1. **Pooled text fetch.** ALTO pages are 1–5 MB, so download latency dominated (~0.3–0.7 pages/s
     serial). `CA.fetchText` now runs `TEXT_POOL=5` downloads in flight with request *starts* spaced
     `TEXT_SPACING=450 ms` on a shared reserved-slot clock — a hard ≤133 starts/min, under the LoC
     storage cap of 150/min. Sustained ceiling ≈2.2 pages/s (**~3–6× real-world**). A single 429 brakes
     *all* workers for 8 s. Mocked-network test: 20 pages in 12 s vs 34 s serial, ≤5 in flight.
  2. **Timeouts everywhere.** 20 s `AbortController` on the search JSON and every ALTO fetch, 15 s on
     Nominatim — a stalled request now costs one timeout, never the run (the previous serial fetch could
     hang forever on a blackholed host, observed live under LoC throttling). `getJSON` also consults a
     `stopped` predicate between retries, so **Stop answers within ≤20 s** on a dead host (measured
     18.7 s; was ~90 s worst case) and instantly on a healthy one.
  3. **Geocoding overlaps the text fetch.** Places come from *search metadata*, not OCR text, so
     `Geo.run` (Nominatim, its own 1 req/1.1 s host) starts right after the search and runs alongside
     stage 2 — its entire duration disappears into the text window. On pipeline error `Geo.stop()` is
     called so nothing runs on unnoticed.
  Progress now reports live rate and ETA ("2.1/s · ~3 min left"). The politeness floors are **pinned by
  two self-checks** (`TEXT_SPACING≥420 ∧ pool≤6 ∧ ≤150/min`; `JSON_SPACING≥3400`) so a future speed pass
  cannot quietly break the rate-limit promise. Self-check total: 18.
- **Scholarly apparatus. ✅ DONE (2026-08-07).** Built so the corpus survives peer review (AD-015):
  1. **Fetch run log** — silent provenance for every harvest run.
  2. **Corpus manifest, freeze & citable bundle** — Settings → *Corpus & method*. Freeze a version; export
     dataset + manifest + README (citation, reproduction recipe, limits, Zenodo steps); *Reproduce from manifest*
     loads someone else's exact query into Fetch.
  3. **Accuracy audit** — Library → *Audit…*: random sample, two questions per record, keyboard-first, Back
     restores previous answers; produces precision + category accuracy and a copyable methods sentence.
  4. **Inter-coder reliability** — blind packets, per-coder coding files, and Cohen's κ with the conventional
     band, a confusion list, and a prevalence caution.
  5. **Report apparatus** — provenance split, measured method sentences, a coverage table by state and decade,
     and a standing limitations list; carried identically into the Markdown export and the bundle README.
     Byline gains the frozen corpus version; Works Cited gains the dataset citation.
  6. **Baselines lens** — control terms counted over the same archive, peak-indexed for shape comparison.
  7. **`STRATEGY.md`** + a Guide *For scholars* panel (each feature mapped to the objection it answers) and a
     fourth assignment sheet built on paired coding and κ.
  *Fixed while building:* the baseline counter had no request timeout, so a stalled Library of Congress response
  froze the run indefinitely — reproduced live under rate-limiting, then bounded with a 15-second abort that
  resolves cleanly at 15,001 ms, keeps every count already cached, and tells the user to resume later. Concurrent
  runs are also now refused rather than interleaved.
- **Performance (2026-06-23):** Library table caps rendered rows at 300 ("filter to narrow") and the
  filter input is debounced — keeps the list snappy at thousands of records. Graph layout is capped/
  settled; bulk ops batch persistence/redraw; on-demand engines load lazily.

## 12. Open questions

- **Q1.** CSV column mapping: auto-detect by header name with a confirm step, or always ask? (Leaning auto + confirm.)
- **Q2.** Default starter gazetteer beyond London / New York / San Francisco / Sydney — which other cities?
- **Q3. RESOLVED (2026-06-22):** Single self-contained `index.html`, opened via `file://`. See AD-002.
- **Q4.** Default Anthropic model string for `askAI()` (recommend `claude-haiku-4-5` for cost on
  research tasks, switchable in settings).
- **Q5. RESOLVED (2026-06-22):** Design for **thousands** (~1k–20k) of records. In-memory store with
  light indexing; mind OCR/import time. Leave a seam to scale to tens of thousands.
- **Q6. RESOLVED (2026-06-22):** Background folded into §14 from both planning PDFs.
- **Q7.** "Mentions" — the brief wants *count **and where they appeared***, not just a number. Keep the
  numeric `mentions` field and add provenance later, or model mentions as their own list? (Leaning: keep
  numeric for now; revisit when relationship graphs land.)
- **Q8.** Priority of the doc-emphasized extras (relationship graphs, reusable collections,
  term-influence/vocabulary-trajectory, outlier detection, performer "usefulness" score) relative to the
  baseline Phase 4 visualizations — which matter most to Prof. Clark first?
- **Q9. RESOLVED (2026-06-22): United States only.** The entire project focuses on the USA. The map is
  US-only (Albers USA), the gazetteer ships ~60 US cities, and non-US points are dropped. See AD-011.
- ~~**Q9 (original).** Geographic scope: confirm "English-speaking world" vs. USA-primary.~~ (Resolved: USA.)

## 13. Not yet built

*This list tracks deferred/known-missing features so the UI never fakes them. **Updated 2026-08-07.**
Phases 0–6, the doc-emphasized extras, the report, the teaching layer and the streamlining pass in §11 are
all shipped; the items below are genuinely absent and are not advertised anywhere in the UI.*

- **Mentions as provenance (Q7).** `mentions` is still a single number. The brief wants *count **and where***.
  A per-mention list (record + offset + surrounding term) is not modelled.
- **Non-LoC sources.** Only Chronicling America is harvested. DPLA, state portals and university archives
  are noted as future adapters (AD-012 seam) but not implemented. Commercial databases remain out of scope
  by policy (paid logins) — the supported path is importing files the researcher exported herself.
- **Per-assignment locked collections.** Collections exist and can scope every view, but a collection can't be
  made read-only for a student, and there is no "reset to the class dataset" command.
- **Student work merge.** Each student works on their own imported copy; there is no way to merge several
  students' annotations back into one master file.
- **Review mode is single-pass.** It walks the currently filtered records once and offers one bulk undo; it does
  not track "already reviewed" across sessions, and there is no reviewer-agreement/second-pass mode.
- **Free performer extraction is deliberately conservative.** `HeuExtract` only fires on clearly capitalised,
  titled or role-adjacent names, so it returns nothing on many pages (it says so plainly rather than guessing).
  Better recall needs the optional AI pass — which stays opt-in so the default path is free and key-less.
- **OCR quality is what the Library of Congress provides.** No re-OCR or text-correction pass; excerpts can
  contain scanning noise. Categories derived from such text inherit that noise, which is why Review mode exists.
- **Full accessibility audit.** Focus is visible, the modals set `role="dialog"`/`aria-modal` and are Esc-closable,
  and reduced-motion is honoured — but no screen-reader pass or focus-trap has been formally tested.

## 14. Background (from planning docs)

*Folded in 2026-06-22 from two source docs by Harold Gonzalez: "Whistling History Visualization
Project — Project Brief & Working Notes" (for Prof. Clark, June 2026) and "Sound Archive Search
Assistant — Summer Project Proposal." This prompt/spec remains the operative brief; the below is
context.*

### Thesis & motivation
- **Thesis (verbatim):** *"Most stuff I look at is individualized; looking at large sets of data we
  can see bigger trends or patterns."* The tool exists to surface trends invisible in single articles.
- **Replaces manual Excel tracking.** Prof. Clark currently logs this by hand; the tool must enforce
  **consistency** and reduce manual workload. (Implication: import/auto-fill + editable fields + export
  back to spreadsheet are core, not nice-to-have.)
- **Track the trajectory of vocabulary/terminology about whistling** — how terms arise, spread, and
  influence one another over time (newspapers give a clear start/terminal point per term or person).
- Themes named in the brief: **"survivability through sound"** (people making do with whistling); and
  **bird imitation** appears closely tied to whistling.
- Build evidence that **whistling is a serious historical topic.**

### Scope
- **Geographic reach: United States only** (confirmed by the user 2026-06-22; supersedes the earlier
  "English-speaking world" leaning). The gazetteer ships ~60 US cities; the map is US-only (AD-011);
  non-US points are dropped. Key anchor cities include New York, Chicago, San Francisco, New Orleans,
  Boston, Los Angeles.
- **Source medium:** newspapers. Free: **Chronicling America / Library of Congress** bulk OCR + the
  loc.gov API (public domain, computational access). Paid: only **approved batch/ZIP/CSV/text exports**
  — never article-by-article scraping or logins. (Confirms SPEC §5.)

### Data variables (confirm §4)
The brief's variable list maps 1:1 onto §4: Performer (incl. *siffleuse* = female whistler; *"King of
whistlers"* = male), Composer, Ensemble, Venue/location, Audience, Genre (popular vs. art; crossover),
Date, Sponsorship (sponsors/companies seeking performances), Mentions (count **and where they appeared**).
> Note: "Mentions" is intended as *count + where*, slightly richer than the current numeric field. See §12 Q7.

### Sound-type categories (confirm §6)
The proposal's category list matches §6 exactly: person whistling, wind/weather, train/machine,
bird/animal, music/performance, object sound, motion/violence, not-about-sound, unsure. Interpretive
aim stated as deciding whether a word means *actual sound, metaphor, performer, a name, or other* — these
fold into the existing enum (metaphor/name → not-about-sound or unsure).

### Features the docs emphasize (beyond current phases — candidates)
Already planned: adjustable context (10/30/50/100), word-form expansion, categories, mentions-over-time,
performer tour map, tour timeline, sound-theme heatmap, keyword clusters, AI assistant.
**New/expanded scope to consider (logged in §12/§13):**
- **Relationship graphs** between performers, cities, newspapers, venues, sound terms, and themes (richer
  than the "simple performer connections" already in §8).
- **Reusable collections** — save/open named subsets of the dataset and reuse without re-importing.
- **Vocabulary-trajectory / term-influence** view — when terms appear and how they spread/influence
  each other over time (distinct from raw mentions-over-time).
- **Outlier / "noise" detection** — flag outliers, including ones that resurface years later.
- **Performer "usefulness" score** — rank individuals by how likely they are to lead to further findings.
- **Map-maker from spreadsheet** — plot newspaper coordinates at the press of a button (covered by §8 map
  + gazetteer; emphasized as a headline feature).

### References named by Prof. Clark
- *"Whistling as an Art"* (archive.org), p. 134, 1938 edition.
- Songs: *"Listen to the Mockingbird"*, *"In Poppy Land."*
- Female whistler = Fr. *siffleuse* / *siffleur*; male star billed *"King of whistlers."*

### Commercial context (proposal)
Summer research tool; proposed rate $40/hr; recommended scope ~90 hours / $3,600. (Context only — does
not change the technical build.)
