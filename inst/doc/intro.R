## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  message = FALSE,
  warning = FALSE,
  collapse = TRUE,
  comment = "#>",
  out.width = "100%"
)

## -----------------------------------------------------------------------------
library(headliner)
library(dplyr)
demo_data()

## ----echo=FALSE---------------------------------------------------------------
dates <- 
  demo_data() |>
  add_date_columns(date) |> 
  slice(2) |> 
  mutate(dplyr::across(day:month, abs))

## ---- echo=FALSE--------------------------------------------------------------
demo_data() |>
  add_date_columns(date) |> 
  compare_conditions(
    x = month == 0,
    y = month == -12,
    .cols = sales
  ) |> 
  headline_list(
    headline = 
    "We have seen {article_delta_p}% {trend} compared to the same time last year ({orig_values})."
  )

## -----------------------------------------------------------------------------
headline(
  x = 101, 
  y = 107
)

## -----------------------------------------------------------------------------
headline(101, 107, return_data = TRUE) |> 
  view_list()

## -----------------------------------------------------------------------------
headline(
  x = 101, 
  y = 107, 
  headline = "We have seen {article_delta_p}% {trend} compared to the same time last year ({orig_values})."
)

## -----------------------------------------------------------------------------
demo_data() |>
  add_date_columns(date_col = date)

## -----------------------------------------------------------------------------
yoy <- # year over year
  demo_data() |>
  add_date_columns(date) |> 
  compare_conditions(
    x = (month == 0),   # this month
    y = (month == -12), # vs 12 months ago
    .cols = sales,   # the column(s) to aggregate
    .fns = lst(mean)    # the list of functions passed to summarise(across(...))
  )

yoy

## -----------------------------------------------------------------------------
yoy |> 
  headline_list(
    headline = "We have seen {article_delta_p}% {trend} compared to the same time last year ({orig_values})."
  ) 

## -----------------------------------------------------------------------------
car_stats <-
  mtcars |> 
  compare_conditions(
    x = cyl == 4,
    y = cyl > 4,
    .cols = starts_with("d"),
    .fns = list(avg = mean, min = min)
  )

view_list(car_stats)

car_stats |>
  headline_list(
    x = avg_disp_x,
    y = avg_disp_y,
    headline = "Difference in avg. displacement of {delta}cu.in. ({orig_values})"
  )

car_stats |>
  headline_list(
    x = avg_drat_x,
    y = avg_drat_y,
    headline = "Difference in avg. rear axle ratio of {delta} ({orig_values})"
  )

## -----------------------------------------------------------------------------
pixar_films |> 
  compare_conditions(
    rating == "G", 
    rating == "PG", 
    .cols = rotten_tomatoes
  ) |> 
  headline_list(
    headline = 
      "Metacritic has an avg. rating of {x} for G-rated films and {y} for PG-rated films \\
    ({delta} points {trend})",
    trend_phrases = trend_terms(more = "higher",  less = "lower"),
    n_decimal = 0
  )


demo_data() |>
  compare_conditions(
    x = group == "a",
    y = group == "c",
    .cols = c(sales),
    .fns = sum
  ) |> 
  headline_list(
    headline = "Group A is ${delta} {trend} Group C (${x} vs ${y})",
    trend_phrases = trend_terms(more = "ahead",  less = "behind")
  )

## -----------------------------------------------------------------------------
pixar_films |> 
  select(film, rotten_tomatoes, metacritic) |> 
  add_headline_column(
    x = rotten_tomatoes, 
    y = metacritic,
    headline = "{film} had a difference of {delta} points",
    return_cols = c(delta)
  ) |> 
  arrange(desc(delta))


## -----------------------------------------------------------------------------
headline(
  x = 9,
  y = 10,
  headline = "{delta_p}% {trend} ({delta} {people})",
  plural_phrases = list(  
    people = plural_phrasing(single = "person", multi = "people")
  )
)

## -----------------------------------------------------------------------------
# lists to use
more_less <- 
  list(
    an_increase = trend_terms("an increase", "a decrease"), 
    more = trend_terms(more = "more", less = "less")
  )

are_people <-
  list(
    are = plural_phrasing(single = "is", multi = "are"),
    people = plural_phrasing(single = "person", multi = "people")
  )

# notice the difference in these two outputs
headline(
  x = 25, 
  y = 23,
  headline = "There {are} {delta} {more} {people} ({an_increase} of {delta_p}%)",
  trend_phrases = more_less,
  plural_phrases = are_people
)

headline(
  x = 25, 
  y = 26,
  headline = "There {are} {delta} {more} {people} ({an_increase} of {delta_p}%)",
  trend_phrases = more_less,
  plural_phrases = are_people
)

## -----------------------------------------------------------------------------
headline(3, 3)

headline(3, 3, if_match = "There were no additional applicants ({x} total)")

## ----eval=FALSE---------------------------------------------------------------
#  show <- compare_values(101, 107)
#  box_color <- ifelse(show$sign == -1, "red", "blue")
#  
#  valueBox(
#    value =
#      headline(
#        show$x,
#        show$y,
#        headline = "{delta_p}% {trend}"
#      ),
#    subtitle = "vs. the same time last year",
#    color = box_color
#  )

## ----echo=FALSE, eval=FALSE---------------------------------------------------
#  library(shiny)
#  library(shinydashboard)
#  
#  show <- compare_values(101, 107)
#  box_color <- ifelse(show$sign == -1, "red", "blue")
#  
#  shinyApp(
#    ui = dashboardPage(
#     dashboardHeader(title = "Value boxes"),
#      dashboardSidebar(),
#      dashboardBody(
#        fluidRow(
#          valueBox(
#            value =  headline(show$x, show$y, headline = '{delta_p}% {trend}'),
#            subtitle = "vs. the same time last year",
#            color = box_color,
#            width = 5
#          )
#        )
#      )
#    ),
#    server = function(input, output) {}
#  )

