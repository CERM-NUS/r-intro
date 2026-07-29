# AGENTS.md

## What this is

"An Introduction to R" — a Quarto book for public-health students with no
programming background, built around Singapore's 2020 COVID-19 daily record.
Published to GitHub Pages from the `gh-pages` branch.

## Working on the book

- Render: `quarto render` from the project root (renv activates via
  `.Rprofile`; the library is under `renv/`).
- Publish: `./scripts/publish.sh` — renders, checks, pushes to `gh-pages`,
  then verifies the live site matches `main`. Requires a clean tree on `main`.
- Sources live in `chapters/` and `appendices/`; `index.qmd` stays at the
  project root. The reading order exists only in `_quarto.yml`.
- `_freeze/` is the committed chunk cache. `publish.sh` clears it when
  `_common.R`, `R/`, `data/` or `renv.lock` change; clear it by hand when
  editing any of those outside a publish.
- Three `post-render` hooks run on every render: `scripts/stamp-build.sh`
  (build stamp), `scripts/make-redirects.sh` (stubs at the old flat URLs),
  `scripts/fix-footer-paths.sh` (footer logo paths per page depth). Keep them
  working; `publish.sh` fails without their effects.

## Editorial standards

Apply these to every sentence written or revised in the `.qmd` sources:

1. **Academic register, not jargon.** Formal, precise, direct English. No
   colloquialisms, filler phrases, or convoluted scholarly phrasing ("it
   could be argued that", "it is interesting to note that"). State what the
   code does, why it matters, and how to execute it.
2. **No unsupported claims.** Every claim ties to a demonstrated code output,
   a documented R behaviour, or an established statistical principle. A
   stated best practice ships with the code that implements it; a stated
   result ships with the output that produced it.
3. **No repetition.** Do not restate a point in multiple ways to fill space;
   each paragraph advances the tutorial. Do not summarise in prose what code
   already showed, unless it adds a new nuance.
4. **Tutorial structure.** Sections move explanation → code example →
   interpretation. No essay-style digressions untied to runnable R code.
5. **Precision.** "does", not "seems to"; "produces", not "yields";
   "because", not roundabout causals. Active voice where it aids clarity.
   Delete any sentence whose claim carries no code example, no citation to R
   documentation, and no genuine epidemiological substance.
6. **Minimal forward references.** Cross-reference a later chapter only when
   the pointer is genuinely necessary, such as avoiding a duplicated full
   treatment. Backward references that reinforce earlier material are fine.
7. **House voice.** No fragment one-liner paragraphs, rhetorical questions,
   antithesis one-liners, or rule-of-three dramatics. Practice notes use only
   the existing idioms: a short plain paragraph after a chunk, a bolded
   single-sentence rule, or a `::: {.callout-note}` /
   `::: {.callout-important}` box. Exercise blocks follow the established
   `{#exr-...}` div + collapsed hint + worked-solution link pattern.
