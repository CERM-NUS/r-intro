# An Introduction to R

A hands-on introduction to R and the tidyverse for public health students, built around one
real dataset: every day of Singapore's 2020 COVID-19 epidemic.

**Read it here: <https://cerm-nus.github.io/r-intro/>**

This is the week-one material for SPH5421, *Fundamentals of Infectious Disease Modelling*, at
the NUS Saw Swee Hock School of Public Health. It assumes no programming background. It does
assume you have seen a mean and a median, and that you know roughly what an epidemic curve is.
It is public because there is no reason for it not to be, and because the same material is
useful to anyone starting out in R with epidemiological data in front of them.

Every code block in the book has been run. The outputs, the plots, the warnings and the place
where R prints `NaN` instead of a number are the real ones, produced by the code shown directly
above them. If a number in the prose disagrees with the number in an output block, the prose is
wrong and I would like to hear about it.

This repository is the source. The rendered site lives on the `gh-pages` branch; see
[Building and publishing](#building-and-publishing) below.

## What it covers

Fourteen chapters in six parts, plus a front page and four appendices. **Parts I to IV are the
spine of the live session**: everything up to and including *Showing it to someone*. Parts V and
VI are follow-up for the week after, and the appendices are reference you come back to rather
than read through. The whole book is about five and a half hours if you type the code rather
than skim it.

The front page, `index.qmd`, sets out the dataset and how to use the book.

**Part I — Before you write any code**

| File | What it does |
|:--|:--|
| `setup.qmd` | Install R, then RStudio, in that order, and check they are talking to each other |

**Part II — The R you cannot avoid**

| File | What it does |
|:--|:--|
| `foundations.qmd` | Objects, vectors and functions: names, types, and why one stray word turns a numeric column into text |
| `rectangles.qmd` | Data frames and tibbles, and why the rectangle is what lets R do epidemiology at all |
| `import.qmd` | `read_csv()`, file paths, and reading the column specification instead of scrolling past it |

**Part III — Working with the data**

| File | What it does |
|:--|:--|
| `transform.qmd` | The dplyr verbs, and turning the cumulative column into daily cases with `lag()` without losing day one |
| `missing.qmd` | Where the `NA`s are, what caused each block of them, and a bug inherited from the old worksheet that returns an answer 27% too large |
| `conditionals.qmd` | `if` versus `case_when()`, and building the severity label the rest of the book leans on |
| `groups.qmd` | `count()`, `group_by()` and `summarise()`, one month at a time |

**Part IV — Showing it to someone**

| File | What it does |
|:--|:--|
| `visualise.qmd` | ggplot2 from the three things you have to supply, through bars, log scales, facets, labels, patchwork and saving |

**Part V — Writing your own code**

| File | What it does |
|:--|:--|
| `functions.qmd` | The rule of three, arguments and defaults, scope, stale globals, guard clauses |
| `iteration.qmd` | `for` and `while`, pre-allocation, the `1:0` trap, `map()`, and the loops you can vectorise away |

**Part VI — Putting it together**

| File | What it does |
|:--|:--|
| `capstone.qmd` | Produce a monthly situation report from the raw file, with no scaffolding |
| `good-practice.qmd` | The working habits gathered in one place, plus the two no chapter covers: Git and renv |
| `next-steps.qmd` | What the rest of the module does with all this, what to read, and how to ask a question that gets answered |

**Appendices**

| File | What it is |
|:--|:--|
| `solutions.qmd` | Appendix A. Every exercise, worked and commented |
| `data.qmd` | Appendix B. The dataset column by column: meaning, units, source, missingness, and the quirks that will bite a plot |
| `build.qmd` | Appendix C. How the book is built, in detail: `_quarto.yml`, renv, freeze, publishing, and how to fork it |
| `colophon.qmd` | Appendix D. Session info, the figure palette and its accessibility tests, licence and citation |

The reading order lives in exactly one place, the `chapters:` list in `_quarto.yml`. Rename a
file without editing that list and the chapter disappears from the book while still sitting in
the repository.

## The data

`data/sg_covid_data.csv`, 23 kB, 345 rows and 13 columns. One row per calendar day, 22 January
to 31 December 2020, Singapore only. No gaps, no duplicates: 345 rows, 345 distinct dates,
every consecutive difference exactly one day. It ends at 58,599 confirmed cases and 29 recorded
deaths.

Three sources are stitched into that one rectangle:

- **Cases and deaths** come from the [COVID-19 Data Hub](https://covid19datahub.io) (Guidotti &
  Ardia, 2020), which collects national reporting into a common schema; for Singapore the chain
  ends at the Ministry of Health.
- **The three index columns** (`stringency_index`, `government_response_index`,
  `containment_health_index`) are the Oxford COVID-19 Government Response Tracker (Hale et al.,
  2021), each a weighted average of coded policy indicators rescaled to 0–100.
- **The six `*_percent_change_from_baseline` columns** are Google's COVID-19 Community Mobility
  Reports, each a percentage change against the median for that day of the week over 3 January
  to 6 February 2020.

Two things about this file cause most of the confusion, so they are worth stating here rather
than leaving to the appendix.

**`confirmed` and `deaths` are cumulative.** They are running totals since the start of the
series, not daily counts. So `max(confirmed)` is the annual total and `sum(confirmed)` is a
number with no meaning at all, which R will compute for you without a murmur. A plot of
`confirmed` against `date` is a line that only ever goes up, for any epidemic anywhere. Getting
daily counts means differencing, and that is what the transform chapter is about.

**The missing values are in two blocks, each with its own cause.** `deaths` has 59 `NA`s at the
start, because the Hub carries no death figure for Singapore until 21 March 2020, and the first
value recorded is 2 rather than 1, so differencing recovers 27 of the 29 deaths rather than all
of them. All six mobility columns are missing on the same 24 days, 22 January to 14 February,
because Google's baseline window had not closed yet and there is no honest way to compare a day
against a period that includes it. Nothing else in the file is missing: the date, the country,
`confirmed` and all three indices are complete.

Appendix B, [The data](https://cerm-nus.github.io/r-intro/data.html), documents every column,
the exact missingness, the citations to use, and the quirks worth knowing before you plot
anything — including the day in August with 908 cases sitting in a month whose median is 91.

The file is a frozen snapshot rather than a live download. Countries revise historical counts,
and a book whose numbers move under it is not a book you can teach from.

## Exercises, hints and solutions

Exercises sit inside the chapters, next to the material they exercise, in `::: {#exr-slug}`
blocks. They state a goal in words and give you no code skeleton with holes in it, because
filling in holes teaches you to fill in holes.

Under most exercises is a collapsed hint. Open it when you are stuck in the sense of not
knowing which function to reach for. Under that is a link to the worked solution in Appendix A.
Every solution carries a link back to its exercise, so you can move in either direction. The
answer is deliberately one click away rather than printed upside down at the bottom of the page;
you will know perfectly well whether you have made a real attempt.

`scripts/publish.sh` checks both directions of those links before anything is published. In a
book that cross-links every exercise to its answer, a dead link is a worse defect than a failed
render, because a failed render tells you.

## Requirements

- **R 4.1 or newer.** The book is built on 4.6.1, which is the version `renv.lock` records.
- **[Quarto](https://quarto.org).** The `_quarto.yml` schema notes were verified against 1.4.554.
- **RStudio**, recommended rather than required. Anything that runs R will do, but the setup
  chapter and the screenshots assume RStudio.

## Running the code yourself

```bash
git clone https://github.com/CERM-NUS/r-intro.git
cd r-intro
```

Open `r-intro.Rproj` in RStudio. The project uses [renv](https://rstudio.github.io/renv/), so
the first thing to run is:

```r
renv::restore()
```

That reads `renv.lock` and installs exactly the package versions the book was built with into
`renv/library`. It takes a few minutes once and nothing thereafter. `renv::status()` tells you
later whether what is installed still matches the lockfile, and `renv::snapshot()` writes the
current state back into it if you add a package.

If you add a package, add it to `_dependencies.R` too. That file is never sourced and never
rendered; it exists only so renv's scanner can see the packages nothing calls by name:
`knitr`, `rmarkdown`, `downlit`, `xml2`, `sessioninfo`. Leave one out and the book renders on
your machine and nowhere else.

You can then work through the chapters in your own script, or open any `.qmd` to see how a page
was made.

### Work from the project root

Whatever you do, run R and Quarto **from the project root**, not from somewhere else pointing
at it:

```bash
cd ~/r-intro
quarto render          # fine

cd ~/some-other-project
quarto render ../r-intro   # not fine
```

This is not fussiness. Quarto decides which renv to activate by reading `.Rprofile` relative to
the directory you invoked it from, not relative to the project you asked it to render. The
second command starts R in the other project, activates that project's library, and builds this
book against whatever versions happen to be sitting there. `execute-dir: project` then moves the
working directory, so `here()` and every relative path still work and the render completes. The
versions are usually close enough that most of it builds, which is exactly what makes it
dangerous. You find out three chapters later, when a deprecation warning appears on a page that
never had one.

`_common.R` checks for this before it does anything else. It walks up from the working directory
to find `_quarto.yml`, works out where that project's library ought to be, compares it against
the library R is actually using, and stops the render with both paths printed when they
disagree. The fix is always the same: `cd` to the project root.

## Repository layout

```
r-intro/
├── _quarto.yml               project and book configuration; the only place the reading order exists
├── _common.R                 sourced by every chapter in a hidden chunk: packages, theme,
│                             read_covid(), covid_daily(), and the wrong-library guard
├── _dependencies.R           never sourced, never rendered; exists so renv's scanner sees everything
├── .Rprofile                 one line, written by renv: source("renv/activate.R")
├── .gitignore                short, and one leading slash in it is load-bearing
├── .gitattributes            keeps _freeze out of diffs and out of GitHub's language stats
├── r-intro.Rproj             RStudio project file
├── LICENSE                   MIT
├── renv.lock                 the exact version of every package, ~250 kB of JSON
├── renv/                     activate.R, settings.json, and the (untracked) library itself
├── index.qmd                 the front page
├── chapters/                 the chapters, one .qmd each, ordered by _quarto.yml
├── appendices/               Appendices A to D: solutions, the data, the build, the colophon
├── R/nus_theme.R             the ggplot2 theme, the five-colour palette, and the scale_*_nus_* helpers
├── scss/nus.scss             site styling, layered on bootswatch litera
├── scripts/                  publish, sync check, build stamp, palette tests, git hook
├── assets/                   favicon.png, favicon-32.png, and logos/ with the three footer marks
├── data/sg_covid_data.csv    the dataset, all 23 kB of it
├── _freeze/                  cached chunk output — generated, and committed on purpose
└── _book/                    the local render. Gitignored; the published site lives on gh-pages
```

`_freeze/` is in version control deliberately. It means a clean checkout can rebuild the site
without R, without renv and without re-running every chunk, and it means a one-word fix to one
chapter does not re-execute all the others.

It also carries a trap worth knowing before it catches you: **freeze watches the `.qmd` file, not
the things it depends on.** Change `_common.R`, the palette in `R/nus_theme.R`, or the CSV
itself, and nothing re-runs. The render succeeds, reports nothing unusual, and every page still
shows the old numbers. When you change something shared, clear the cache:

```bash
rm -rf _freeze/
quarto render
```

`publish.sh` does this for you by fingerprinting `_common.R`, `R/`, `data/` and `renv.lock`, and
clearing the cache when the fingerprint moves.

## Building and publishing

While writing:

```bash
quarto preview
```

That builds the book and opens it with live reload — save a `.qmd` and the page updates.

To look at the whole thing locally:

```bash
quarto render
```

The result lands in `_book/`, which is gitignored, so you can rebuild and reread as often as you
like without git noticing.

To publish:

```bash
./scripts/publish.sh
```

### The branch split

`main` holds the source and nothing else. `gh-pages` holds the rendered HTML and nothing else,
and `gh-pages` is what GitHub Pages serves. Nothing rendered is ever committed to `main`, so a
chapter edit arrives as a one-file diff rather than a one-file diff buried in ninety regenerated
HTML pages. That matters more as soon as a second person edits a chapter, because generated HTML
merges badly and nobody can resolve those conflicts by reading them.

`publish.sh` renders, then runs its checks, then publishes, in that order. `quarto publish`
renders by default, which would put every check after the deploy, and a check that runs after
the deploy is a report rather than a gate. What it checks: the expected page count (19, set as
`EXPECTED_PAGES` at the top of the script — raise it when you add a chapter), that no page was
stranded at the project root, that `search.json` and `build-info.json` exist, and that every
solution link and every back-link resolves to a real anchor. It refuses to start if a
`quarto preview` is running, if you are not on `main`, or if the working tree is dirty.

### Knowing whether the site is stale

The cost of splitting source from output is that staleness becomes invisible. When the site was
committed alongside the source, forgetting to rebuild left the working tree dirty and announced
itself for free. Now `main` is clean whether or not you have ever published: you can edit,
commit, push, watch GitHub show your change, and have the live site still serving last month's
text with nothing anywhere hinting at it.

Three small pieces exist to put that visibility back. `scripts/stamp-build.sh` runs as Quarto's
`post-render` step and writes `build-info.json` into the output, recording the commit, whether
the tree was dirty, the timestamp and the Quarto version. `scripts/check-pages-sync.sh` reads
that file off `gh-pages` and compares it against the tip of `main`:

```bash
./scripts/check-pages-sync.sh           # fetch first, compare against origin
./scripts/check-pages-sync.sh --local   # use the refs you already have
```

Exit 0 means in sync, 1 means stale, 2 means it could not tell. It compares the *files* that
changed since the publish against the list of things the site is actually built from, so a
README edit or a licence tweak does not get reported as stale. A check that cried wolf on every
typo fix would be ignored inside a week.

And `scripts/hooks/pre-push` prints a reminder when the commits you are pushing touch anything on
that list. It is not installed by default:

```bash
git config core.hooksPath scripts/hooks
```

It prints and gets out of the way rather than blocking the push, because pushing source before
publishing is a perfectly normal thing to do, and a hook that refused would be routed around
with `--no-verify` the second time it got in the way.

There is no CI. The book is pinned to one Quarto version and one package library by `renv.lock`,
and any route that renders on a server adds a second Quarto at a second version. A newer Quarto
does not fail loudly on an older book. It produces slightly different HTML from the version the
book was checked against, and you find that weeks later, on one page.

Appendix C, [How this book is built](https://cerm-nus.github.io/r-intro/build.html), goes
through all of this properly, including how to fork the book for another course.

## The scripts

| Script | What it does |
|:--|:--|
| `scripts/publish.sh` | Render, check the render, push it to `gh-pages`, then confirm the live site matches `main` |
| `scripts/check-pages-sync.sh` | Answers "is what is live still what `main` says?" — exit 0 in sync, 1 stale, 2 cannot tell |
| `scripts/stamp-build.sh` | Quarto `post-render` hook; writes `build-info.json` into the output so the site records the commit that produced it |
| `scripts/make-redirects.sh` | Quarto `post-render` hook; writes redirect stubs at the book's old flat page URLs so links made before the subdirectory move keep working |
| `scripts/fix-footer-paths.sh` | Quarto `post-render` hook; rewrites the footer logo `src`s per page depth, because the raw footer HTML's relative path only resolves at the site root |
| `scripts/check_palette.R` | Accessibility tests for the figure palette: colour-vision-deficiency simulation scored by CIEDE2000, greyscale separation, WCAG thin-line contrast. Base R only, so it runs before `renv::restore()` has finished |
| `scripts/hooks/pre-push` | Non-blocking reminder that pushing the source is not the same as publishing the site |

## Contributing, and telling me something is wrong

If a number looks wrong, an explanation does not land, or something does not run, please
[open an issue](https://github.com/CERM-NUS/r-intro/issues). An error in a teaching resource
propagates into every assignment written from it, which makes it worth more attention than an
error in most other places.

Every page carries links in its right-hand margin: **Edit this page** opens that page's source on
GitHub and turns your correction into a pull request, **Report an issue** opens an issue with the
page already identified, and **View source** takes you to the exact revision.

A report I can act on has four things in it: which page and section, the code you ran, the
complete error or warning text pasted rather than described, and the output of
`sessioninfo::session_info()`. The third is the one people trim, and it is the one that matters.

Reports that a paragraph is confusing are as welcome as reports that a number is wrong, and
harder to write. If you read something three times and still had to guess, that is a defect, and
it is mine.

## Licence

MIT — see [LICENSE](LICENSE). Copyright 2026 Swapnil Mishra. Use it, fork it, teach from it,
change it. Attribution is appreciated and not demanded.

Two exceptions.

The logos in `assets/logos/` are the trade marks of the National University of Singapore, the
Saw Swee Hock School of Public Health, the Centre for Epidemic Research and Modelling and the
Machine Learning and Global Health Network. A licence on my writing has no authority over
somebody else's mark. If you fork the book, take them out.

The data is the other. An MIT licence on this repository cannot relicense numbers I did not
produce. The cases and deaths, the government-response indices and the mobility series come from
three separate third parties, each with its own terms of use, and that documentation governs
reuse rather than this file. Appendix B names all three and formats the citations. If you use
the data in coursework or a paper, cite those sources rather than this book.

## Acknowledgement

Written by Swapnil Mishra, working with Claude Code (Anthropic, Opus 5 model), which helped
draft the text, convert the original base-R worksheet to the tidyverse, and check the numbers
against the data. A later revision — the repository reorganisation, the restructuring of the
good-practice material, and the language passes across the chapters — was made with Kimi Code
(Moonshot AI, K3 model). Responsibility for the result is entirely human.
