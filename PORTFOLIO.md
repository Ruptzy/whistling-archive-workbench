# Whistling Archive Workbench — Project Summary

Portfolio / résumé material. Written for three audiences: technical recruiters,
data-science interviewers, and academic readers.

## In one sentence

An end-to-end **data pipeline and analysis instrument** that turns ~100,000 unstructured
OCR newspaper pages into a measured, reproducible corpus — with API ingestion, entity
extraction, classification, statistical validation, and interactive visualization, all
running client-side in a single file.

---

## The data science story

This is a full pipeline, not a dashboard. Every stage is built and instrumented:

| Stage | What it does |
|---|---|
| **Ingestion** | REST client against the Library of Congress API — pagination, rate limiting (17 req/min under a 20/min cap), retry with backoff, resumable jobs, `AbortController` timeouts |
| **ETL / cleaning** | OCR text extraction from ALTO XML; character-reference decoding enforced at the **store boundary** so every current and future adapter inherits it (a real bug: encoded entities were silently corrupting both display *and* search recall) |
| **Feature extraction** | Rule-based NER for performer names with strict precision rules; optional local LLM (Qwen2.5-3B via WebGPU) for structured field extraction; geocoding against OpenStreetMap with a cached gazetteer |
| **Classification** | 9-class text categorization over a configurable keyword-rule model, with human-in-the-loop override |
| **Validation** | Random-sample accuracy audit, inter-rater reliability via Cohen's κ, and control-term baselines against the same corpus |
| **Analysis & viz** | 10 chart types + a projected geospatial network view, all hand-built |
| **Reproducibility** | Versioned corpus manifests, run logs, and a citable bundle — anyone can re-run the exact query |

### The parts that matter in an interview

**Statistical honesty as a design constraint.** "Unsure" responses are excluded from
denominators rather than imputed. Trend lines are labelled moving averages with *no*
fabricated confidence bands. Where a measurement doesn't exist, the report prints
**nothing** rather than a placeholder.

**Measurement of the tool's own error.** The audit module produces: *"a uniform random
sample of 50 records was hand-checked; 46 (92%) concerned whistling as sound or
performance, and the automatic category agreed with the human coder in 83% of cases."*
Most projects never quantify their own precision.

**Confounder control.** The Baselines feature answers *"didn't everything rise in the
1890s because more pages got digitized?"* by counting control terms over the identical
corpus and comparing normalized shapes — the objection that kills naive time-series
claims in digital humanities.

**Sampling bias named up front.** Coverage tables by state and decade, plus a standing
limitations section: digitization is uneven, OCR errors depress recall by an unknown
amount, and findings describe *mentions in digitized newspapers* — never "America."

**Custom algorithms, no library.** Fruchterman–Reingold force-directed graph layout on
Canvas; Albers USA projection with pixel-space label collision resolution; a
grammar-of-graphics toolkit with nice-tick generation and label placement that drops a
label rather than overlapping it.

---

## Job roles this maps to

**Primary fit:**

- **Data Engineer** — mostly pipeline work: API ingestion, ETL, data-quality enforcement, schema versioning with tolerant migrations, caching layers
- **Research Engineer / Research Software Engineer** — building instruments for domain experts; the exact role at national labs, university DH centers, and library/archive tech teams
- **Data Scientist (applied / NLP-adjacent)** — entity extraction, text classification, sampling design, inter-rater reliability, confounder analysis
- **Full-Stack / Frontend Engineer** — 5,600 lines of vanilla JS, custom rendering engines, zero dependencies, hard performance constraints

**Also credible:** Data Visualization Engineer (the chart toolkit and map are the
strongest single artifact) · Digital Humanities Technologist (a real, funded job
category — NEH ODH grants fund exactly this) · ML Engineer, edge/on-device (WebGPU
local inference, no server).

**The strongest interview material** is the constraint, not the feature list: *"the user
is non-technical and it must run with zero setup, offline, forever, with no ongoing cost
to me."* That killed frameworks, bundlers, servers and paid APIs, and forced genuinely
interesting engineering — base64-inlined audio, IndexedDB-cached map geometry, on-device
LLM inference, and a single 510 KB file that opens by double-click.

---

## The music side

**Domain:** historical musicology / sound studies — specifically **vernacular performance practice**.

**The research question:** whistling was a *professional* performance art in America
roughly 1880–1930. Performers like Alice Shaw ("La Belle Siffleuse"), Agnes Woodward (who
founded the California School of Artistic Whistling), Margaret McKee and Fred Lowery toured
nationally, recorded commercially, and were reviewed as serious artists. Then it vanished.
The corpus lets you watch both the rise and the disappearance at scale.

**Why it's musicologically substantive, not novelty:**

- **Gender and public sound** — the proverb *"whistling girls and crowing hens never come
  to any good end"* appears in the same papers as admiring reviews of Shaw. The *siffleuse*
  was a woman licensed to make public sound precisely by aestheticizing a forbidden act.
  The vocabulary trajectory (*siffleuse → lady whistler → whistling girl*) is measurable.
- **Race and early recording** — George W. Johnson, arguably the first commercially
  successful Black recording artist, was a whistler. Whistling cut through the acoustic
  recording horn better than most sounds, putting it at the origin of the record industry.
- **Voice vs. instrument** — the body performing *as* instrument, a live question in
  organology and voice studies. Woodward's school shows full professionalization: method
  books, pedagogy, credentialing.
- **Sensory history, quantified** — the 9-category taxonomy measures how often "whistle"
  meant a person, a machine, a bird or a metaphor, decade by decade. A contribution close
  reading structurally cannot make.

**The framing that makes it land:** *whistling is where the American press negotiated who
was allowed to make sound in public — and this corpus lets us watch it happen at scale.*

---

## Positioning by audience

- **Tech recruiter:** "Built a client-side data pipeline that ingests 100k+ historical documents from a federal API, extracts entities, classifies them, and validates its own accuracy statistically. Zero dependencies, runs offline in a single file."
- **Data science interview:** "The interesting problem was measuring the instrument, not building it — random-sample precision auditing, Cohen's κ for inter-rater reliability, and control-term baselines to rule out the digitization confounder."
- **Academic / DH:** "A reproducible corpus tool for vernacular performance history, with versioned manifests, citable bundles, and an honest limitations apparatus."
- **Music world:** "It reconstructs a lost profession — a generation of touring whistling performers — from the newspapers that covered them."
