#' adjust a mixed model of two normal distributions
#'
#' @keywords internal
#'
#' @importFrom mclust densityMclust cdensE cdensV
#' @importFrom ggplot2 ggplot ggsave geom_area geom_line geom_vline theme_light aes labs %+%
#' @importFrom dplyr %>% mutate lag
#' @importFrom utils head
#' @importFrom stats dnorm
transformseries.twowaves <- function(i.data,
                                     i.scale = 10000,
                                     i.model = "V",
                                     i.output = NA,
                                     i.prefix = "two waves",
                                     i.proportion = 0.15) {
  if (is.na(i.proportion) || is.null(i.proportion)) i.proportion <- 0.15
  if (is.na(i.scale) || is.null(i.scale)) i.scale <- 10000
  if (is.na(i.model) || is.null(i.model)) i.model <- "V"
  seasons <- names(i.data)
  n.seasons <- dim(i.data)[2]
  weeks <- rownames(i.data)
  n.weeks <- dim(i.data)[1]
  resultados.1 <- i.data
  resultados.2 <- i.data
  inicios <- data.frame(dummy = NA)
  detalles <- list()
  for (i in 1:n.seasons) {
    resultados.i <- data.frame(rates = i.data[, i])
    rownames(resultados.i) <- weeks
    resultados.i$rates.no.miss <- fill.missing(resultados.i$rates)
    total.rates <- sum(resultados.i$rates.no.miss, na.rm = TRUE)
    x1 <- 1:n.weeks
    y1 <- round(resultados.i$rates.no.miss * i.scale / total.rates, 0)
    x2 <- x1[!is.na(y1)]
    y2 <- y1[!is.na(y1)]
    data.rep <- rep(x2, times = y2)
    # Sometimes densityMClust return errors, I have to check it
    mixmdl.normal.v <- try(
      {
        setTimeLimit(cpu = 5, elapsed = Inf)
        densityMclust(data.rep, G = 2, modelNames = "V", verbose = FALSE)
      },
      silent = TRUE
    )
    mixmdl.normal.e <- try(
      {
        setTimeLimit(cpu = 5, elapsed = Inf)
        densityMclust(data.rep, G = 2, modelNames = "E", verbose = FALSE)
      },
      silent = TRUE
    )
    if (i.model != "V") {
      if (!("try-error" %in% class(mixmdl.normal.e))) {
        mixmdl.normal <- mixmdl.normal.e
        temp1 <- as.data.frame(cdensE(x1, parameters = mixmdl.normal$parameters))
      } else if (!("try-error" %in% class(mixmdl.normal.v))) {
        mixmdl.normal <- mixmdl.normal.v
        temp1 <- as.data.frame(cdensV(x1, parameters = mixmdl.normal$parameters))
      } else {
        # these parameters forces later to fit 1 normal only
        mixmdl.normal <- list()
        mixmdl.normal$classification <- rep(1, length(data.rep))
        mixmdl.normal$parameters$pro <- rep(0.5, 2)
        mixmdl.normal$parameters$mean <- rep(1, 2)
        temp1 <- NULL
      }
    } else {
      if (!("try-error" %in% class(mixmdl.normal.v))) {
        mixmdl.normal <- mixmdl.normal.v
        temp1 <- as.data.frame(cdensV(x1, parameters = mixmdl.normal$parameters))
      } else if (!("try-error" %in% class(mixmdl.normal.e))) {
        mixmdl.normal <- mixmdl.normal.e
        temp1 <- as.data.frame(cdensE(x1, parameters = mixmdl.normal$parameters))
      } else {
        # these parameters forces later to fit 1 normal only
        mixmdl.normal <- list()
        mixmdl.normal$classification <- rep(1, length(data.rep))
        mixmdl.normal$parameters$pro <- rep(0.5, 2)
        mixmdl.normal$parameters$mean <- rep(1, 2)
        temp1 <- NULL
      }
    }
    temp2 <- merge(data.frame(week = 1:n.weeks, stringsAsFactors = FALSE),
      unique(data.frame(week = data.rep, classification = mixmdl.normal$classification, stringsAsFactors = FALSE)),
      by = "week", all.x = TRUE
    )
    for (j in 2:NROW(temp2)) if (is.na(temp2$classification[j])) temp2$classification[j] <- temp2$classification[j - 1]
    for (j in (NROW(temp2) - 1):1) if (is.na(temp2$classification[j])) temp2$classification[j] <- temp2$classification[j + 1]
    # If the proportion of one of the normals is less than the param i.proportion then there is only one normal
    if (mixmdl.normal$parameters$pro[1] < i.proportion) {
      temp2$classification <- 2
    } else if (mixmdl.normal$parameters$pro[2] < i.proportion) {
      temp2$classification <- 1
    }
    # number of changes from 1 to 2 (2 to 1 doesnt count since normal means are order from lowest to highest, in
    # case 22221111 and mean1<mean2, means second normal is way higher than first one, and we treat it as if it were
    # only one normal)
    temp2$clasequ <- temp2$classification > dplyr::lag(temp2$classification)
    temp2$clasequ[1] <- FALSE
    inicio.normal <- head((1:n.weeks)[temp2$clasequ])
    if (length(inicio.normal) > 0) {
      if (mixmdl.normal$parameters$mean[1] > inicio.normal) {
        temp2$classification <- 2
        temp2$clasequ <- FALSE
      }
      if (mixmdl.normal$parameters$mean[2] < inicio.normal) {
        temp2$classification <- 1
        temp2$clasequ <- FALSE
      }
    }
    n.changes <- sum(temp2$clasequ, na.rm = TRUE)
    if (n.changes == 0) {
      # One single wave or transitions from 2 to 1, counting as only one wave
      # Option: fit new model with one normal
      mixmdl.normal <- densityMclust(data.rep, G = 1, modelNames = "V", verbose = FALSE)
      temp1 <- as.data.frame(cdensV(x1, parameters = mixmdl.normal$parameters))
      inicio.normal <- NA
      temp3 <- data.frame(
        normal1 = temp1[, 1] * mixmdl.normal$parameters$pro[1] * total.rates,
        normal2 = NA,
        season.sub.normal = 1,
        part1 = resultados.i$rates,
        part2 = NA,
        stringsAsFactors = FALSE
      )
    } else if (n.changes > 0) {
      # Two waves, overlapping
      temp3 <- data.frame(
        normal1 = temp1[, 1] * mixmdl.normal$parameters$pro[1] * total.rates,
        normal2 = temp1[, 2] * mixmdl.normal$parameters$pro[2] * total.rates,
        season.sub.normal = c(rep(1, inicio.normal - 1), rep(2, n.weeks - inicio.normal + 1)),
        part1 = c(resultados.i$rates[1:(inicio.normal - 1)], rep(NA, n.weeks - inicio.normal + 1)),
        part2 = c(rep(NA, inicio.normal - 1), resultados.i$rates[inicio.normal:n.weeks]),
        stringsAsFactors = FALSE
      )
    }
    resultados.i <- cbind(resultados.i, temp3)
    rm("temp1", "temp2", "temp3")
    resultados.i$normal <- resultados.i$normal1 + resultados.i$normal2
    resultados.i$coeficiente <- resultados.i$rates.no.miss / resultados.i$normal
    resultados.i$week <- 1:n.weeks
    if (!is.na(i.output)) {
      outputdir <- file.path(i.output)
      if (!dir.exists(outputdir)) dir.create(outputdir)
      normal1 <- NULL
      normal2 <- NULL
      part1 <- NULL
      part2 <- NULL
      rates.no.miss <- NULL
      week <- NULL
      axis.x.range.original <- range(resultados.i$week, na.rm = TRUE)
      axis.x.otick <- optimal.tickmarks(axis.x.range.original[1], axis.x.range.original[2], 10, i.include.min = TRUE, i.include.max = TRUE)
      axis.x.range <- axis.x.otick$range
      axis.x.ticks <- axis.x.otick$tickmarks
      axis.x.labels <- rownames(resultados.i)[axis.x.otick$tickmarks]
      p1 <- ggplot(resultados.i) +
        geom_line(aes(x = week, y = rates.no.miss), color = "#FF0000", size = 1, alpha = 0.7) +
        labs(title = seasons[i], x = "Week", y = "Rates") +
        scale_x_continuous(breaks = axis.x.ticks, limits = axis.x.range, labels = axis.x.labels) +
        theme_light() +
        theme(plot.title = element_text(hjust = 0.5))
      if (any(!is.na(resultados.i$part1))) {
        p1 <- p1 +
          geom_area(aes(x = week, y = part1), fill = "#B8E2EF") +
          geom_line(aes(x = week, y = normal1), color = "#0066CC", size = 1, linetype = 4) +
          geom_vline(aes(xintercept = mixmdl.normal$parameters$mean[1]), linetype = 4, color = "#0066CC")
      }
      if (any(!is.na(resultados.i$part2))) {
        p1 <- p1 +
          geom_area(aes(x = week, y = part2), fill = "#ABFF73") +
          geom_line(aes(x = week, y = normal2), color = "#59955C", size = 1, linetype = 4) +
          geom_vline(aes(xintercept = mixmdl.normal$parameters$mean[2]), linetype = 4, color = "#59955C")
      }
      if (any(!is.na(resultados.i$part1)) && any(!is.na(resultados.i$part2))) {
        p1 <- p1 +
          geom_vline(aes(xintercept = inicio.normal - 0.5), size = 1, linetype = 2, color = "#BF00BF")
      }
      ggsave(paste0(i.prefix, " (Season ", i, ").png"), plot = p1, device = "png", scale = 1, width = 8, height = 6, units = "in", dpi = 150, path = outputdir)
    }
    detalles$nombre <- mixmdl.normal
    names(detalles)[names(detalles) == "nombre"] <- seasons[i]
    inicios.i <- data.frame(inicio = as.numeric(inicio.normal))
    names(inicios.i)[names(inicios.i) == "inicio"] <- seasons[i]
    resultados.i.1 <- resultados.i[names(resultados.i) %in% c("part1", "part2")]
    resultados.i.2 <- resultados.i[names(resultados.i) %in% c("normal1", "normal2")]
    names(resultados.i.1) <- c(paste(seasons[i], "(1)", sep = ""), paste(seasons[i], "(2)", sep = ""))
    names(resultados.i.2) <- c(paste(seasons[i], "(1)", sep = ""), paste(seasons[i], "(2)", sep = ""))
    resultados.1 <- cbind(resultados.1, resultados.i.1)
    resultados.2 <- cbind(resultados.2, resultados.i.2)
    inicios <- cbind(inicios, inicios.i)
    rm("resultados.i.1", "resultados.i.2", "inicios.i")
  }
  resultados.1 <- resultados.1[!(names(resultados.1) %in% seasons)]
  resultados.2 <- resultados.2[!(names(resultados.2) %in% seasons)]
  inicios <- inicios[!(names(inicios) %in% "dummy")]
  return(list(data.observed = resultados.1, data.expected = resultados.2, breaks = inicios, details = detalles))
}
