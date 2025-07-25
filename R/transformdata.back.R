#' @title Data transformation
#'
#' @description
#' Function \code{transformdata.back} transforms data from week,rate1,...,rateN to year,week,rate
#' format.
#'
#' @name transformdata.back
#'
#' @param i.data Data frame of input data.
#' @param i.name Name of the column that contains the values.
#' @param i.cutoff.original Cutoff point between seasons when they have two years
#' @param i.range.x.final Range of the surveillance period in the output dataset
#' @param i.fun sumarize function
#'
#' @return
#' \code{transformdata.back} returns a data.frame with three columns, year, week and rate.
#'
#' @details
#' Transforms data from the season in each column format (the one that uses \link{mem})
#' to the format year, week, rate in a 3 columns data.frame.
#'
#' Allows to set the cutoff point to separate between two seasons when one season has
#' two different years.
#'
#' @examples
#' # Castilla y Leon Influenza Rates data
#' data(flucyl)
#' # Transform data
#' newdata <- transformdata.back(flucyl)$data
#' @author Jose E. Lozano \email{lozalojo@@gmail.com}
#'
#' @references
#' Vega T, Lozano JE, Ortiz de Lejarazu R, Gutierrez Perez M. Modelling influenza epidemic - can we
#' detect the beginning and predict the intensity and duration? Int Congr Ser. 2004 Jun;1263:281-3.
#'
#' Vega T, Lozano JE, Meerhoff T, Snacken R, Mott J, Ortiz de Lejarazu R, et al. Influenza surveillance
#' in Europe: establishing epidemic thresholds by the moving epidemic method. Influenza Other Respir
#' Viruses. 2013 Jul;7(4):546-58. DOI:10.1111/j.1750-2659.2012.00422.x.
#'
#' Vega T, Lozano JE, Meerhoff T, Snacken R, Beaute J, Jorgensen P, et al. Influenza surveillance in
#' Europe: comparing intensity levels calculated using the moving epidemic method. Influenza Other
#' Respir Viruses. 2015 Sep;9(5):234-46. DOI:10.1111/irv.12330.
#'
#' Lozano JE. lozalojo/mem: Second release of the MEM R library. Zenodo [Internet]. [cited 2017 Feb 1];
#' Available from: \url{https://zenodo.org/record/165983}. DOI:10.5281/zenodo.165983
#'
#' @keywords influenza
#'
#' @export
# @importFrom stats aggregate
#' @importFrom tidyr extract gather
#' @importFrom dplyr %>% filter group_by summarise arrange
transformdata.back <- function(i.data, i.name = "rates", i.cutoff.original = NA, i.range.x.final = NA, i.fun = mean) {
  if (is.na(i.cutoff.original)) i.cutoff.original <- min(as.numeric(rownames(i.data)[1:(min(3, NROW(i.data)))]))
  if (i.cutoff.original < 1) i.cutoff.original <- 1
  if (i.cutoff.original > 53) i.cutoff.original <- 53
  if (any(is.na(i.range.x.final)) || !is.numeric(i.range.x.final) || length(i.range.x.final) != 2) {
    i.range.x.final <- c(min(as.numeric(rownames(i.data)[1:(min(3, NROW(i.data)))])), max(as.numeric(rownames(i.data)[(max(1, NROW(i.data) - 2)):NROW(i.data)])))
  }
  if (i.range.x.final[1] < 1) i.range.x.final[1] <- 1
  if (i.range.x.final[1] > 53) i.range.x.final[1] <- 53
  if (i.range.x.final[2] < 1) i.range.x.final[2] <- 1
  if (i.range.x.final[2] > 53) i.range.x.final[2] <- 53
  if (i.range.x.final[1] == i.range.x.final[2]) i.range.x.final[2] <- i.range.x.final[2] - 1
  if (i.range.x.final[2] == 0) i.range.x.final[2] <- 53
  # First: analize names of seasons and seasons with week 53
  # Changed dependency of stringr for tydir builtin function extract
  column <- NULL
  seasons <- data.frame(column = names(i.data), stringsAsFactors = FALSE) %>%
    extract(column, into = c("anioi", "aniof", "aniow"), regex = "^[^\\d]*(\\d{4})(?:[^\\d]*(\\d{4}))?(?:[^\\d]*(\\d{1,}))?[^\\d]*$", remove = FALSE)
  seasons[is.na(seasons)] <- ""
  seasons$aniof[seasons$aniof == ""] <- seasons$anioi[seasons$aniof == ""]
  seasonsname <- seasons$anioi
  seasonsname[seasons$aniof != ""] <- paste(seasonsname[seasons$aniof != ""], seasons$aniof[seasons$aniof != ""], sep = "/")
  seasonsname[seasons$aniow != ""] <- paste(seasonsname[seasons$aniow != ""], "(", seasons$aniow[seasons$aniow != ""], ")", sep = "")
  seasons$season <- seasonsname
  rm("seasonsname")
  names(i.data) <- seasons$season
  i.data$week <- as.numeric(row.names(i.data))
  # Second: Transform the data, summarize (to avoid duplicates) and remove na's
  # replace melt with gather
  season <- data <- week <- NULL
  data.out <- i.data %>%
    gather(season, data, -week, na.rm = TRUE)
  # adds year, based in the i.cutoff.original value
  data.out$year <- NA
  data.out$year[data.out$week < i.cutoff.original] <- as.numeric(substr(data.out$season, 6, 9))[data.out$week < i.cutoff.original]
  data.out$year[data.out$week >= i.cutoff.original] <- as.numeric(substr(data.out$season, 1, 4))[data.out$week >= i.cutoff.original]
  data.out$season <- NULL
  # we aggregate in case data comes from two sources, for example when there are two parts of the same epidemic, notated as (1) and (2)
  year <- week <- NULL
  data.out <- data.out %>%
    filter(!is.na(year) & !is.na(week)) %>%
    group_by(year, week) %>%
    summarise(data = i.fun(data, na.rm = TRUE)) %>%
    arrange(year, week)
  # Third: create the structure of the final dataset, considering the i.range.x.final
  week.f <- i.range.x.final[1]
  week.l <- i.range.x.final[2]
  if (week.f > week.l) {
    i.range.x.values.52 <- data.frame(week = c(week.f:52, 1:week.l), week.no = 1:(52 - week.f + 1 + week.l))
    i.range.x.values.53 <- data.frame(week = c(week.f:53, 1:week.l), week.no = 1:(53 - week.f + 1 + week.l))
    data.out$season <- ""
    data.out$season[data.out$week < week.f] <- paste(data.out$year - 1, data.out$year, sep = "/")[data.out$week < week.f]
    data.out$season[data.out$week >= week.f] <- paste(data.out$year, data.out$year + 1, sep = "/")[data.out$week >= week.f]
    seasons.all <- unique(data.out$season)
    seasons.53 <- unique(subset(data.out, data.out$week == 53 & !is.na(data.out$data))$season)
    seasons.52 <- seasons.all[!(seasons.all %in% seasons.53)]
    data.scheme <- rbind(
      merge(data.frame(season = seasons.52, stringsAsFactors = FALSE), i.range.x.values.52, stringsAsFactors = FALSE),
      merge(data.frame(season = seasons.53, stringsAsFactors = FALSE), i.range.x.values.53, stringsAsFactors = FALSE)
    )
    data.scheme$year <- NA
    data.scheme$year[data.scheme$week < week.f] <- as.numeric(substr(data.scheme$season, 6, 9))[data.scheme$week < week.f]
    data.scheme$year[data.scheme$week >= week.f] <- as.numeric(substr(data.scheme$season, 1, 4))[data.scheme$week >= week.f]
  } else {
    i.range.x.values.52 <- data.frame(week = week.f:min(52, week.l), week.no = 1:(min(52, week.l) - week.f + 1))
    i.range.x.values.53 <- data.frame(week = week.f:week.l, week.no = 1:(week.l - week.f + 1))
    data.out$season <- ""
    data.out$season <- paste(data.out$year, data.out$year, sep = "/")
    seasons.all <- unique(data.out$season)
    seasons.53 <- unique(subset(data.out, data.out$week == 53 & !is.na(data.out$data))$season)
    seasons.52 <- seasons.all[!(seasons.all %in% seasons.53)]
    data.scheme <- rbind(
      merge(data.frame(season = seasons.52, stringsAsFactors = FALSE), i.range.x.values.52, stringsAsFactors = FALSE),
      merge(data.frame(season = seasons.53, stringsAsFactors = FALSE), i.range.x.values.53, stringsAsFactors = FALSE)
    )
    data.scheme$year <- NA
    data.scheme$year <- as.numeric(substr(data.scheme$season, 1, 4))
  }
  data.final <- merge(data.scheme, data.out, by = c("season", "year", "week"), all.x = TRUE)
  data.final$yrweek <- data.final$year * 100 + data.final$week
  data.final$week.no <- NULL
  data.final <- data.final[order(data.final$yrweek), ]
  names(data.final)[names(data.final) == "data"] <- i.name
  transformdata.back.output <- list(data = data.final)
  transformdata.back.output$call <- match.call()
  return(transformdata.back.output)
}
