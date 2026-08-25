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
- **Classify the passage, not the page (AD-016/017).** `suggestCategory` scores each whistle anchor's
  ±`CLASSIFY_CTX`-token window SEPARATELY (a Chronicling America "page" is a whole broadsheet). The
  mechanisms, all pinned by self-checks: anchor-stem tokens never vote for themselves; distinct words 1 pt
  (2 near the anchor, repeats never add — OCR triplets); phrases 3 pts, **phrases containing the
  whistle-word 5 pts** (they predicate the sound itself); a matched phrase consumes its span and yields to
  a longer matched phrase it prefixes; embedded ALL-CAPS headline runs cannot vote; a verdict needs
  score ≥`SCORE_MIN` and margin ≥`SCORE_MARGIN`, else honest abstention — ties are *unsure* by definition;
  if a window contains `matchedTerm`, only such windows may label the page. `whistlerIsProperNoun` guards
  the surname (titles, given names incl. ALL-CAPS, painter context, Whistler Ala.) while billing epithets
  ("the Champion Whistler") stay anchors. **No anchor or no earned verdict ⇒ `null`** — an honest Unsure
  beats a confident wrong label. Tune it as DATA (`DEFAULT_CAT_RULES`, `TERM_CATEGORY`, `NAME_TITLES`,
  `NAME_STOP`, `ART_CONTEXT`, the constants), not as new branches; changed defaults need a matching entry
  in `LEGACY_CAT_RULES` so `upgradeCatRules()` re-seeds untouched installs.
- **`classifyCore()` returns the verdict AND why (`WHY` map); `suggestCategory()` is the thin wrapper.**
  When a record stays Unsure the user must be able to tell a careful classifier from a page that simply is
  not about whistling — Classify reports the breakdown (`no-text` / `no-whistle-word` / `name-only` / `weak`
  / `split`). Keep new abstention paths named there rather than returning a bare `null`.
- **A store change must leave no stale view.** `Store.notify()` re-renders the Library, dashboard and the
  open analysis view; every other view rebuilds from `activeRecords()` in `showView()`. The exception is the
  **report**, which keeps generated output on screen — `markReportStale()` banners it, and generating again
  clears the banner. Any future view that caches rendered output owes the same treatment.
- **Re-classify through `planReclassify()`/`applyReclassify()`, never by hand.** `categoryFor(r)` is the one
  rule (text verdict → term seed → `unsure`), and it must be able to return `unsure`: a `null` verdict has to
  CLEAR a stale label, or improving the engine can never repair a library harvested under the old one — the
  bug that left ~500 records mislabelled after AD-017. Anything that writes `r.category` in bulk goes through
  the plan so Classify, Settings → *Re-suggest*, and the pipeline stay identical and idempotent. Never touch
  `categoryUserSet` records, and confirm before a run that would clear labels.
- **Measure before you ship classifier changes.** Settings → About has BOTH *Run self-checks* (35, incl.
  every AD-017 mechanism) and *Run classifier eval* — 62 labelled period passages (`CLASSIFIER_EVAL`) with
  misfires reported separately from honest abstentions. Baseline for context: the pre-AD-017 classifier
  scored 22/62 with 32 misfires; the rebuild scores 61/62 with 1 (a mixed boy-whistler/locomotive page).
  Extend the eval with every newly discovered failure; never delete cases to make the numbers look better.
- **Timeouts and outages (AD-018).** The loc.gov **search** API measured 35–55 s under load — it gets
  `JSON_TIMEOUT` (90 s, floored by a self-check), NOT the 20 s `FETCH_TIMEOUT` that suits tile.loc.gov file
  downloads; shrinking it back reports a working server as an unexplained abort. A long timeout is safe only
  because `inFlight`/`abortAll()` let `CA.stop()` cancel requests immediately — keep that invariant. Classify
  failures by *whose* fault they are: 429 = `err.rateLimited` (slow down), 502/503/504 = `err.serverBusy`
  (their outage — say so, the user must not go hunting for a mistake), `AbortError` = name the timeout, never
  pass "signal is aborted without reason" to a user. Keep requests small: `at=results,pagination` and a page
  cap of 100 — a payload that never arrives is a failure no retry ladder can fix.
- **No network failure may be silent (AD-016).** `getJSON` ends every path in a value or a `throw` — it once
  fell off its retry loop and returned `undefined`, so a rate-limited run died on `data.results` with no
  message. A throttled exhaustion throws `err.rateLimited`; callers must surface that distinctly, `fetchText`
  breaks out after `RL_GIVE_UP` consecutive 429s instead of grinding, and no in-app wait exceeds
  `RL_WAIT_CAP_S`. New network loops copy that shape. **Long pauses must narrate** — politeness sleeps count
  down through `onProgress` and the text stage names the paper it is reading, because a still UI reads as a
  crash and the user starts guessing.
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
