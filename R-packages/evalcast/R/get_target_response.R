# Get data frame with column names `forecast_date`, `location`, `target_start`,
# `target_end`, `actual`
get_target_response <- function(signals,
                                forecast_dates,
                                incidence_period,
                                ahead,
                                geo_type,
                                geo_values) {
  response <- signals[1, ]
  target_periods <- forecast_dates %>%
    enframe(name = NULL, value = "forecast_date") %>%
    mutate(incidence_period = incidence_period, ahead = ahead) %>%
    pmap_dfr(get_target_period)

  # Compute the actual values that the forecaster is trying to
  # predict. In particular,
  # - get most recent data available from covidcast for these target periods
  # - sum up the response over the target incidence period
  target_periods <- target_periods %>%
    mutate(available = .data$end <= Sys.Date()) 
  bad_dates <- forecast_dates[!target_periods$available]
  
  # Altered to return results for any available forecasts
  if (length(bad_dates) > 0) {
    # we try not to crash everything here. Instead, issue a warning.
    warning(paste0("When `ahead` is ", ahead, ", it is too soon to evaluate ",
                   "forecasts on these forecast dates: ",
                   paste(bad_dates, collapse=", "),
                   "."))
    if (length(bad_dates) == length(forecast_dates)) return(empty_actual())
    forecast_dates <- forecast_dates[target_periods$available]
  }
  target_periods <- target_periods %>% filter(.data$available) %>%
    mutate(available = NULL)
  
  if (length(geo_values) > 30) geo_values = "*"
  out <- target_periods %>%
    rename(start_day = .data$start, end_day = .data$end) %>%
    mutate(data_source = response$data_source,
           signal = response$signal,
           geo_type = geo_type) %>%
    pmap(download_signal, geo_values = geo_values) # apply_corrections would need to run here,
  # but can only use part of response
  # we don't allow this for now.
  
  problem_dates <- out %>% map_lgl(~ nrow(.x) == 0)
  if (any(problem_dates)) {
    warning(paste0("No data available for the target periods of these ",
                   "forecast dates: ",
                   paste(forecast_dates[problem_dates], collapse = ", "),
                   "."))
    if (length(problem_dates) == length(forecast_dates)) return(empty_actual())
    out <- out[!problem_dates]
    forecast_dates <- forecast_dates[!problem_dates]
  }
  names(out) <- forecast_dates
  target_periods$forecast_date = lubridate::ymd(forecast_dates)
  out <- out %>%
    bind_rows(.id = "forecast_date") %>%
    mutate(forecast_date = lubridate::ymd(.data$forecast_date)) %>%
    group_by(.data$geo_value, .data$forecast_date) %>%
    summarize(actual = sum(.data$value)) %>%
    #    mutate(forecast_date = forecast_dates[as.numeric(.data$forecast_date)]) %>%
    left_join(target_periods, by = "forecast_date")
  # record date that this function was run for reproducibility
  attr(out, "as_of") <- Sys.Date()
  out
}
