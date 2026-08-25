# CLAUDE.md — instructions for future sessions

Durable notes for working on the **Whistling Archive Workbench**. Read `SPEC.md` first —
it is the source of truth for *what* we're building and *why*. This file is *how* to work on it.

## What this project is

A single-file, client-side research tool for a non-technical musicologist (Prof. Clark) to
import, search, annotate, and visualize historical newspaper mentions of whistling. See `SPEC.md`.

## Prime directives (do not violate without updating SPEC.md)

1. **Must run with zero setup on her laptop.** Default = one `index.html`, client-side only,
   no account, no server dependency for core features. If you think a build step or local server
   is unavoidable, justify it in `SPEC.md` (AD + Q3) and keep the run command to one line.
2. **Never lose her data.** Single-JSON export/import is the canonical backup. IndexedDB is a
   convenience copy only. Any destructive action needs undo or confirmation.
3. **AI is optional.** Every feature except the AI panel must work with no API key. Never hardcode
   a key; never include the key in exports.
4. **No scraping, no subscription logins.** Only ingest files the user already exported. See SPEC §5.
5. **Optimize for change.** Small modules behind clear interfaces. Adapters for sources, OCR, AI,
   charts, geocoding. Leave `// EXTEND:` comments where features hook in.

## Architecture & conventions

- **Stack:** vanilla JS (ES modules) + HTML + CSS, no framework, no bundler (AD-002). Third-party
  libs vendored locally (AD-004): Tesseract.js (OCR), PDF.js (PDF text), a chart lib, map/SVG.
- **Single source of state:** one record store module. All views/visualizations *read from it*;
  mutations go through the store so persistence + undo are centralized.
- **Classification is load-bearing — keep the self-checks green.** `SELF_CHECKS`/`runSelfChecks()`
  (Settings → About → "Run self-checks"; auto-runs on localhost) pin the fundamentals: records seed a
  category from the search term that found them (`TERM_CATEGORY`/`categoryFromTerm`, ambiguous terms
  like "whistling" are NEVER guessed), no-text records show "No text yet" instead of a fake Unsure
  verdict (`needsText`/`catChip`), and `matchedTerm` survives `CA.recFromResult`. If you touch the
  classifier, chips, term map or text hygiene: run the checks, keep them green, and EXTEND the list —
  never delete cases to make it pass.
- **Text hygiene is enforced at the store, not per-adapter.** `normalizeRecordText()` runs inside
  `Store.add/update/replaceAll`, so harvested text can never keep raw character references
  (`&#x0027;` etc. — they corrupt display *and* search). New adapters get this for free; if you ever
  write a record field outside the Store, call `normalizeRecordText(rec)` yourself. `notes` is
  deliberately exempt (the user's own writing). Use `decodeEntities()` for any new harvested source.
- **Import pipeline:** `detectType → extractText → normalizeRecord`. One adapter per source in
  `adapters/`, each exporting `{ detect, extract, normalize }`, registered in a registry. Adding a
  source must not require editing the importer core.
- **Swappable seams (one-file changes):** OCR engine behind one function; `askAI()` for all AI;
  word-form expansion + category rules + gazetteer are data (editable), not code.
- **Data model & enums:** defined in `SPEC.md` §4/§6 — keep code and spec in sync. Bump
  `schemaVersion` and add a migration when the model changes.
- **Style:** small functions, comment the non-obvious only, match surrounding code. Scholarly/archival
  visual identity (SPEC §10): legible, responsive to laptop width, visible focus, honor `prefers-reduced-motion`.

## How to run / build

- **For the professor:** open `index.html` in a browser (double-click). No build, no server.
- **For development/preview only:** a static server avoids any `file://` quirks and lets the
  preview tooling drive the page: `python -m http.server 8777` then open `http://localhost:8777/index.html`.
  (`.claude/launch.json` defines this as the `static` preview config — dev-only, not shipped behavior.)
- **Tiered deps (AD-008):** core + all visualizations are offline. PDF.js, Tesseract OCR, the world-map
  outline, and the Anthropic API load on demand from a CDN; the first use of each needs internet, then the
  map outline is cached in IndexedDB. ZIP is native (`DecompressionStream`).
- **Fetch pipeline seam (AD-013):** `runPipeline()` chains the *unchanged* step functions
  (`CA.search → CA.fetchText → classifyAll → HeuExtract.run → Geo.run`) behind "Build my corpus".
  Add a step by inserting a stage there and bumping `STAGES` — don't rewrite the step functions; they
  still power the "Advanced: run steps individually" buttons. Keep `AIExtract` **out** of the default
  path (it must never require a key). Presets live in `Settings.searchPresets`.
  **Speed vs politeness (2026-08-25):** `CA.fetchText` is a 5-worker pool whose request starts share a
  reserved-slot clock (`TEXT_SPACING=450ms` ⇒ ≤133/min, under LoC's 150/min); one 429 brakes all workers.
  `Geo.run` overlaps the text stage (different host; places come from search metadata, not OCR). All
  network loops carry `AbortController` timeouts, and `getJSON` takes a `stopped` predicate so Stop
  answers within one timeout. The politeness constants are pinned by self-checks — make it faster only
  by raising concurrency *behind the same start-rate*, never by shrinking the spacing floors.
- **Charts go through `Kit` (AD-014).** Never hand-roll axes, ticks, tooltips or colours in a new chart —
  compose from `Kit` (`ticksCount`/`ticksYears`, `gridY`, `txt`, `band`/`lin`, `interact`, `mount`) so every
  figure keeps one grammar and inherits SVG/PNG export for free. Colours come from `Kit.palette()` (AD-010
  tokens resolved at render time and inlined), never hardcoded — that is what makes exports stand alone.
  Charts are pure readers of `activeRecords()`; to link a chart click to the Library call
  `libraryFilterBy({label, test})`.
- **Scholarly apparatus (AD-015).** `Settings.fetchLog / corpusManifests / audits / baselineCache` hold the
  method record; they live under `settings` so they ride Export JSON with no `schemaVersion` bump. Two rules when
  extending: **report only what was measured** (`methodSentences()` returns an empty array rather than a
  placeholder, and the Report prints nothing for absent measurements), and **exclude "unsure" from denominators**
  rather than guessing. Keep the wording discipline — *"mentions in digitised newspapers"*, never
  *"whistling in America"*. `LIMITS_TEXT` is the single source for the limitations paragraph (Report, Markdown
  and bundle README all read it). Any new network loop needs an `AbortController` timeout like `Baselines.count()`.
- **Map interaction model:** only the state paths live in a transformed `<g>`; dots, arcs and labels are drawn
  in **screen space** so they stay a constant size at any zoom and collisions can be resolved in pixels.
- **Network graph engine:** custom Fruchterman–Reingold force layout on Canvas in the `Net` module
  (temperature-capped displacement, `fitView()` framing, theme-aware colors). Settles synchronously then
  draws; interaction (drag/zoom/pan/focus) reheats it.

## How to add a feature

1. Check `SPEC.md` — is it already specced? Update spec **in the same change** as the code.
2. Find the seam (adapter registry, store, `askAI()`, rules maps, chart module). Extend there.
3. Build a thin vertical slice first; keep non-AI features working without a key.
4. Update SPEC §11 (phases) / §13 (Not yet built) so the UI never advertises unbuilt features.
5. Tell the user what to test.

## What NOT to do

- Don't add a framework, bundler, or required backend without a new AD in `SPEC.md` and user sign-off.
- Don't fake/stub UI for unbuilt features — list them in SPEC §13 instead.
- Don't make any core feature depend on the network or the AI key.
- Don't hardcode or export the API key.
- Don't scrape sites or build subscription-login flows.
- Don't start large coding phases without the user's go-ahead (per the kickoff working agreement).

## Working agreement

Plan before building. Keep `SPEC.md` in sync. Ask before assuming anything that changes data shape
or the professor's workflow; otherwise pick a reasonable default, record it in `SPEC.md`, and keep moving.
