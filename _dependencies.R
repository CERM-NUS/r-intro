# This file is never sourced and never rendered.
#
# renv finds dependencies by scanning source files for library() calls, but its
# scanner only adds rmarkdown automatically for .Rmd files, not .qmd. Without
# this file, renv::snapshot() would leave knitr and rmarkdown out of the
# lockfile and a clean checkout would fail to render with an error that points
# nowhere near the cause.
#
# If you add a package to a chapter, add it here too.

library(tidyverse)   # dplyr, ggplot2, readr, tidyr, purrr, stringr, tibble, forcats
library(lubridate)   # floor_date(), ym()
library(here)        # here() — not a tidyverse dependency, must be declared
library(glue)        # glue() in the reporting examples
library(scales)      # label_comma(), date formatting on axes
library(patchwork)   # multi-panel figures, replacing par(mfrow=)

library(knitr)       # the rendering engine Quarto drives
library(rmarkdown)   # ditto
library(downlit)     # code-link: turns function calls into links to their docs
library(xml2)        # downlit needs it
library(sessioninfo) # colophon
