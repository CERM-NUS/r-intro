# Visual identity for the figures in this book.
# NUS Saw Swee Hock School of Public Health / CERM.
#
# The palette is checked, not asserted. Three tests, all in scripts/check_palette.R
# (base R, no packages — run it with Rscript scripts/check_palette.R):
#
#   1. Colourblindness. Simulated for protanopia, deuteranopia and tritanopia
#      (Machado et al. 2009, severity 1.0) and scored by pairwise CIEDE2000.
#      Worst case is dE00 18.9, between blue and teal under deuteranopia.
#   2. Greyscale. Adjacent colours are at least 8 L* apart, so the series stay
#      distinguishable on a photocopy. The closest pair is blue/crimson.
#   3. Thin-line visibility. The first four clear WCAG 1.4.11 (3:1 against
#      white): 10.7, 8.1, 4.8, 3.1. The fifth is 1.7 and is for filled areas
#      only, never for lines or points.
#
# Five is the ceiling. A sixth cannot be added without colliding with an
# existing member under protanopia, so nus_pal() stops rather than recycling
# colours and quietly making two series look identical.

nus_colours <- c(
  blue    = "#003D7C",  # NUS Blue, official
  crimson = "#96233F",
  teal    = "#007E96",  # after the ML & GHN mark, darkened for contrast
  orange  = "#E8720C",  # after NUS Orange, darkened to clear 3:1
  grey    = "#BFC6CE",  # fills only
  ink     = "#1F2933",  # body text: CERM black, softened
  muted   = "#5A6672",
  rule    = "#DDE3EA"
)

nus_pal <- function(n) {
  series <- unname(nus_colours[c("blue", "crimson", "teal", "orange", "grey")])
  if (n > length(series)) {
    stop(
      "The NUS palette carries ", length(series), " colours; you asked for ", n, ".\n",
      "Adding more would put two series too close together to tell apart. ",
      "Use faceting instead of a sixth colour.",
      call. = FALSE
    )
  }
  series[seq_len(n)]
}

scale_colour_nus_d <- function(...) {
  ggplot2::discrete_scale("colour", palette = nus_pal, ...)
}
scale_fill_nus_d <- function(...) {
  ggplot2::discrete_scale("fill", palette = nus_pal, ...)
}

# Half the class learned to spell it the other way.
scale_color_nus_d <- scale_colour_nus_d

# Sequential and diverging ramps, for continuous quantities such as the
# stringency index. The diverging ends are matched in lightness (L* 26 and 27)
# so a rise of ten points reads as visually equal to a fall of ten.
scale_colour_nus_c <- function(...) {
  ggplot2::scale_colour_gradient(low = "#DCE6F1", high = nus_colours[["blue"]], ...)
}
scale_fill_nus_c <- function(...) {
  ggplot2::scale_fill_gradient(low = "#DCE6F1", high = nus_colours[["blue"]], ...)
}
scale_fill_nus_div <- function(...) {
  ggplot2::scale_fill_gradient2(
    low = "#8C3B00", mid = "#F2F4F7", high = nus_colours[["blue"]], midpoint = 0, ...
  )
}

theme_nus <- function(base_size = 12, base_family = "") {
  ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      plot.title      = ggplot2::element_text(face = "bold", size = ggplot2::rel(1.15),
                                              colour = nus_colours[["ink"]]),
      plot.subtitle   = ggplot2::element_text(colour = nus_colours[["muted"]],
                                              margin = ggplot2::margin(b = 10)),
      plot.caption    = ggplot2::element_text(colour = nus_colours[["muted"]],
                                              size = ggplot2::rel(0.8), hjust = 0),
      plot.title.position   = "plot",
      plot.caption.position = "plot",
      axis.title      = ggplot2::element_text(colour = nus_colours[["muted"]]),
      axis.text       = ggplot2::element_text(colour = nus_colours[["muted"]]),
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_line(colour = nus_colours[["rule"]], linewidth = 0.3),
      strip.text      = ggplot2::element_text(face = "bold", colour = nus_colours[["ink"]],
                                              hjust = 0),
      legend.position = "bottom",
      legend.title    = ggplot2::element_text(colour = nus_colours[["muted"]])
    )
}

# So that the shortest possible ggplot call already looks like the rest of the
# book. A student who types ggplot(covid, aes(date, daily_cases)) + geom_line()
# gets a blue line on the house grid without having to know any of this exists.
options(
  ggplot2.discrete.colour = function(...) scale_colour_nus_d(...),
  ggplot2.discrete.fill   = function(...) scale_fill_nus_d(...),
  ggplot2.continuous.colour = function(...) scale_colour_nus_c(...),
  ggplot2.continuous.fill   = function(...) scale_fill_nus_c(...)
)

ggplot2::update_geom_defaults("line",  list(colour = nus_colours[["blue"]], linewidth = 0.7))
ggplot2::update_geom_defaults("point", list(colour = nus_colours[["blue"]]))
ggplot2::update_geom_defaults("col",   list(fill   = nus_colours[["blue"]]))
ggplot2::update_geom_defaults("bar",   list(fill   = nus_colours[["blue"]]))
