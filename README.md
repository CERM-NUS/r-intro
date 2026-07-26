# An Introduction to R

A hands-on introduction to R and the tidyverse for public health students, built around one
real dataset: every day of Singapore's 2020 COVID-19 epidemic.

**Read it here: <https://cerm-nus.github.io/r-intro/>**

This is the week-one material for SPH5421, *Fundamentals of Infectious Disease Modelling*, at
the NUS Saw Swee Hock School of Public Health. It is public because there is no reason for it
not to be, and because the same material is useful to anyone starting out in R with
epidemiological data in front of them.

## What it covers

Getting R and RStudio working, and the project habits worth having before you write any code.
Vectors, data frames and tibbles. Reading a CSV and believing what it tells you. The dplyr
verbs, missing data, conditionals, grouping and summarising. Plotting with ggplot2. Writing
functions, and loops — both the explicit kind and the kind you can avoid. It ends with a
capstone: produce a monthly situation report from the data, with no scaffolding.

Every code block in the book has been run. The outputs, the plots and the warnings on the page
are the real ones.

Exercises are numbered and cross-linked to worked solutions in an appendix at the back, so the
answer is available when you want it and not before.

## The data

`data/sg_covid_data.csv` — 345 daily rows, 22 January to 31 December 2020, Singapore only.
Cumulative case and death counts, the three Oxford government-response indices, and the six
Google Community Mobility series. Assembled from the
[COVID-19 Data Hub](https://covid19datahub.io) (Guidotti & Ardia 2020), which draws on
Singapore's Ministry of Health, the Oxford COVID-19 Government Response Tracker, and Google's
Community Mobility Reports. Appendix B documents every column, including where it is missing
and why.

## Running the code yourself

You need R (4.1 or newer) and RStudio. Then:

```bash
git clone git@github.com:CERM-NUS/r-intro.git
cd r-intro
```

Open `r-intro.Rproj` in RStudio. The project uses [renv](https://rstudio.github.io/renv/), so
the first thing to do is install the exact package versions the book was built with:

```r
renv::restore()
```

That takes a few minutes once and nothing thereafter. You can then work through the chapters in
your own script, or open any `.qmd` file to see how a page was made.

To rebuild the book and read it locally:

```bash
quarto render      # run this from the project root, not from anywhere else
```

The "from the project root" is not fussiness. Quarto works out which renv to activate by
reading `.Rprofile` relative to the directory you launched it from, so rendering from inside
another R project silently builds the book against that project's packages. `_common.R` checks
for this and stops the render if it happens.

That render lands in `_book/`, which is not committed. The published site lives on the
`gh-pages` branch and gets there through:

```bash
./scripts/publish.sh
```

which renders, publishes, and then checks what it sent. It refuses to run from a dirty tree or
from any branch but `main`. Pushing to `main` no longer updates the live site, so
`./scripts/check-pages-sync.sh` exists to tell you whether what is published still matches
`main`. Appendix C explains the whole arrangement.

## Contributing, or telling me something is wrong

If a number looks wrong, an explanation does not land, or something simply does not run, please
[open an issue](https://github.com/CERM-NUS/r-intro/issues). Corrections are welcome and errors
in a teaching resource are worth more attention than errors in most places. Every page has an
"Edit this page" link that goes straight to its source.

## Licence

MIT — see [LICENSE](LICENSE). Use it, fork it, teach from it. Attribution is appreciated but
not demanded.

The logos in `assets/logos/` are the trade marks of NUS, the Saw Swee Hock School of Public
Health, CERM and the ML & GHN network. They are not covered by the MIT licence and should not
be reused without permission from their owners.

## Acknowledgements

Written by Swapnil Mishra, working with Claude Code (Anthropic, Opus 5 model), which helped
draft the text, convert the original base-R worksheet to the tidyverse, and check the numbers
against the data. Responsibility for the result is entirely human.
