#' Add column of headlines
#'
#' @description This works similar to `headline()` but acts on and returns a
#' data frame.

#' @return Returns the original data frame with columns appended.
#'
#' @details What is nice about this function is you can return some of the
#' "talking points" used in the headline calculation. For example, if you want
#' to find the most extreme headlines, you can use
#' `add_headline_column(..., return_cols = delta)` This will bring back a
#' `headline` column as well as the `delta` talking point (the absolute
#' difference between `x` and `y`). With this result, you can sort in descending
#' order and filter for the biggest difference.
#'
#' @param df data frame, must be a single row
#' @param .name string value for the name of the new column to create
#' @param return_cols arguments that can be passed to
#' \code{\link[dplyr]{select}}, ex: c("a", "b"),
#' \code{\link[dplyr]{starts_with}}, etc.
#' @inheritParams compare_values
#' @inheritParams headline
#' @export
#' @importFrom glue glue
#' @importFrom dplyr pull mutate transmute select one_of bind_cols rowwise ungroup
#' @importFrom tidyr unnest_wider
#' @importFrom rlang := .data abort warn
#' @importFrom purrr pmap map_dfr flatten
#' @examples
#'
#' # You can use 'add_headline_column()' to reference values in an existing data set.
#' # Here is an example comparing the box office sales of different Pixar films
#' head(pixar_films) |>
#'   dplyr::select(film, bo_domestic, bo_intl) |>
#'   add_headline_column(
#'     x = bo_domestic,
#'     y = bo_intl,
#'     headline = "{film} was ${delta}M higher {trend} (${x}M vs ${y}M)",
#'     trend_phrases = trend_terms(more = "domestically", less = "internationally")
#'   ) |>
#'   knitr::kable("pandoc")
#'
#' # You can also use 'return_cols' to return any and all "talking points".
#' # You can use tidyselect helpers like 'starts_with("delta")' or
#' # 'everything()'. In this example, I returned the 'raw_delta' & 'trend' columns
#' # and then identified the records at the extremes
#' pixar_films |>
#'   dplyr::select(film, bo_domestic, bo_intl) |>
#'   add_headline_column(
#'     x = bo_domestic,
#'     y = bo_intl,
#'     headline = "${delta}M {trend} (${x}M vs ${y}M)",
#'     trend_phrases = trend_terms(more = "higher", less = "lower"),
#'     return_cols = c(raw_delta, trend)
#'   ) |>
#'   dplyr::filter(raw_delta %in% range(raw_delta)) |>
#'   knitr::kable("pandoc")
#'
add_headline_column <- function(df,
                                x,
                                y,
                                headline = "{trend} of {delta} ({orig_values})",
                                ...,
                                .name = "headline",
                                if_match = "There was no difference",
                                trend_phrases = headliner::trend_terms(),
                                plural_phrases = NULL,
                                orig_values = "{x} vs. {y}",
                                n_decimal = 1,
                                round_all = TRUE,
                                multiplier = 1,
                                return_cols = .name) {
  # df <- mtcars; x = as.symbol("gear"); y = as.symbol("carb")

  # inform that headline can be renamed
  if (.name %in% names(df)) {
    glue(
      "The column '{.name}' was replaced. Use the '.name' argument \\
      to change the new column name."
    ) |>
    warn()
  }

  df_vals <-
    df |>
    mutate(# give unique name in case user passes x = y
      use_x = {{x}},
      use_y = {{y}}
    ) |>
    transmute(
      x = .data$use_x,
      y = .data$use_y,
      headline = {{headline}},
      trend_phrases = list(trend_phrases),
      plural_phrases = list(plural_phrases),
      orig_values = orig_values,
      n_decimal = n_decimal,
      round_all = round_all,
      multiplier = multiplier,
      check_rounding = FALSE # done separately to limit # of warnings
    )

  # check rounding
  check_rounding(
    pull(df, {{x}}),
    pull(df, {{y}}),
    n_decimal
  )

  prep_results <-
    df_vals |>
    select(-.data$headline) |>
    pmap(compare_values) |>
    map_dfr(flatten)

  headline_results <-
    prep_results |>
    bind_cols(
      df |>
        select(-one_of(names(prep_results))) |>
        suppressWarnings()
    ) |>
    mutate(headline = df_vals$headline) |>
    rowwise() |>
    mutate(headline = glue(.data$headline, ...)) |>
    ungroup() |>
    mutate(
      {{.name}} :=
        ifelse(
          test = .data$x == .data$y,
          yes = if_match,
          no = .data$headline
        )
    ) |>
    select({{.name}}, {{return_cols}})

  bind_cols(
    df,
    headline_results,
    .name_repair = "unique"
  )
}
