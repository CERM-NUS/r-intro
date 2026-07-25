# Shared setup, sourced by every chapter in a hidden chunk.
#
# Chapters render in independent R sessions (that is how Quarto's freeze works),
# so anything more than one chapter needs has to live here rather than being
# built once in the first chapter and relied on later.

# ---- Guard: are we using this project's library? -----------------------------
# Quarto decides which renv to activate by reading ./.Rprofile relative to the
# shell you invoked it from, NOT relative to the project. Render this book from
# a directory that has its own .Rprofile — the course repo, for instance — and
# it will quietly build against that project's packages instead. The versions
# would be close enough that most of it would work, which is exactly what makes
# it dangerous. Fail loudly here instead.
local({
  proj <- getwd()
  while (!file.exists(file.path(proj, "_quarto.yml")) && dirname(proj) != proj) {
    proj <- dirname(proj)
  }
  expected <- normalizePath(file.path(proj, "renv", "library"), mustWork = FALSE)
  active   <- normalizePath(.libPaths()[1], mustWork = FALSE)

  if (!startsWith(active, expected)) {
    stop(
      "Wrong package library.\n",
      "  active:   ", active, "\n",
      "  expected: ", expected, "/...\n",
      "Run `quarto render` from the project root (", proj, ").",
      call. = FALSE
    )
  }
})

# ---- Packages ----------------------------------------------------------------
# The only place in the book where startup messages are suppressed. Everywhere
# else, messages and warnings are output the reader is meant to see.
suppressPackageStartupMessages({
  library(tidyverse)
  library(here)
  library(patchwork)
  library(scales)
})

# ---- House style for figures -------------------------------------------------
source(here::here("R", "nus_theme.R"))
theme_set(theme_nus())

# ---- The data ----------------------------------------------------------------
# read_covid() gives the file exactly as it ships: cumulative counts, missing
# values intact, nothing repaired. Chapters that teach a repair do it in view.
read_covid <- function() {
  readr::read_csv(here::here("data", "sg_covid_data.csv"), show_col_types = FALSE)
}

# covid_daily() is the state the book reaches at the end of the conditionals
# chapter. Later chapters open with it so they don't re-teach earlier chapters.
#
# lag(default = 0) rather than a bare lag(): `confirmed` starts at 0 on
# 2020-01-22, so day one genuinely had zero new cases. It is not missing, and
# recording it as missing would drop a real day from every count downstream.
covid_daily <- function() {
  read_covid() %>%
    arrange(date) %>%
    mutate(
      daily_cases  = confirmed - lag(confirmed, default = 0),
      daily_deaths = deaths - lag(deaths, default = 0),
      severity = case_when(
        daily_cases <  100 ~ "Low",
        daily_cases <= 300 ~ "Medium",
        daily_cases >  300 ~ "High"
      ),
      severity = factor(severity, levels = c("Low", "Medium", "High")),
      month = floor_date(date, "month")
    )
}
