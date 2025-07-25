#' @title Creates the historical series graph of the datasets
#'
#' @description
#' Function \code{full.series.graph} creates a graph with the whole dataset.
#'
#' @name full.series.graph
#'
#' @param i.data Historical data series.
#' @param i.range.x Range x (surveillance weeks) of graph.
#' @param i.range.y Range y of graph.
#' @param i.output Directory where graph is saved.
#' @param i.graph.title Title of the graph.
#' @param i.graph.subtitle Subtitle of the graph.
#' @param i.graph.file Graph to a file.
#' @param i.graph.file.name Name of the graph.
#' @param i.plot.timing Plot the timing of epidemics.
#' @param i.plot.intensity Plot the intensity levels.
#' @param i.alternative.thresholds Use alternative thresholds, instead of the ones modelled by the input data (epidemic + 3 intensity thresholds)
#' @param i.color.pattern colors to use in the graph.
#' @param i.mem.info include information about the package in the graph.
#' @param ... other parameters passed to memmodel.
#'
#' @return
#' \code{full.series.graph} writes a tiff graph of the full series of the dataset.
#'
#' @details
#' Input data must be a data.frame with each column a surveillance season and each
#' row a week.
#'
#' The resulting graph is a time series-like plot showing all the columns in the
#' original dataset one after another.
#'
#' Color codes:
#' \enumerate{
#' \item Axis.
#' \item Tickmarks.
#' \item Axis labels.
#' \item Series line.
#' \item Series dots (default).
#' \item Title and subtitle.
#' \item Series dots (pre-epidemic).
#' \item Series dots (epidemic).
#' \item Series dots (post-epidemic).
#' \item Epidemic threshold.
#' \item Medium threshold.
#' \item High threshold.
#' \item Very high threshold.
#' }
#'
#' @examples
#' \donttest{
#' # Castilla y Leon Influenza Rates data
#' data(flucyl)
#' # Data of the last season
#' # uncomment to execute
#' # full.series.graph(flucyl)
#' }
#'
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
#' @importFrom grDevices dev.off rgb tiff
#' @importFrom graphics abline axis legend matplot mtext par points text lines plot
full.series.graph <- function(i.data,
                              i.range.x = NA,
                              i.range.y = NA,
                              i.output = ".",
                              i.graph.title = "",
                              i.graph.subtitle = "",
                              i.graph.file = TRUE,
                              i.graph.file.name = "",
                              i.plot.timing = FALSE,
                              i.plot.intensity = FALSE,
                              i.alternative.thresholds = NA,
                              i.color.pattern = c(
                                "#C0C0C0", "#606060", "#000000", "#808080", "#000000", "#001933",
                                "#00C000", "#800080", "#FFB401",
                                "#8c6bb1", "#88419d", "#810f7c", "#4d004b"
                              ),
                              i.mem.info = TRUE,
                              ...) {
  i.cutoff.original <- min(as.numeric(rownames(i.data)[1:3]))
  if (i.cutoff.original < 1) i.cutoff.original <- 1
  if (i.cutoff.original > 53) i.cutoff.original <- 53
  if (any(is.na(i.range.x)) || !is.numeric(i.range.x) || length(i.range.x) != 2) i.range.x <- c(min(as.numeric(rownames(i.data)[1:(min(3, NROW(i.data)))])), max(as.numeric(rownames(i.data)[(max(1, NROW(i.data) - 2)):NROW(i.data)])))
  if (i.range.x[1] < 1) i.range.x[1] <- 1
  if (i.range.x[1] > 53) i.range.x[1] <- 53
  if (i.range.x[2] < 1) i.range.x[2] <- 1
  if (i.range.x[2] > 53) i.range.x[2] <- 53
  if (i.range.x[1] == i.range.x[2]) i.range.x[2] <- i.range.x[2] - 1
  if (i.range.x[2] == 0) i.range.x[2] <- 53

  if (NCOL(i.data) > 1) {
    epi <- memmodel(i.data, ...)
    epidata <- epi$data
    epiindex <- epi$season.indexes[, , 1]
    epithresholds <- memintensity(epi)$intensity.thresholds
    i.data <- i.data[names(i.data) %in% names(epi$data)]
  } else {
    # I need the epi object to extract the data dataframe, which includes the original data + filled missing data and
    # the timing (which would be extracted with memtiming also)
    epi <- memmodel(cbind(i.data, i.data), ...)
    epidata <- epi$data[1]
    epiindex <- epi$season.indexes[, 1, 1]
    epithresholds <- NA
    i.data <- i.data[names(i.data) %in% names(epi$data)]
  }
  rm("epi")

  datos <- transformdata.back(i.data, i.name = "rates", i.range.x.final = i.range.x, i.cutoff.original = i.cutoff.original, i.fun = sum)$data
  datos.x <- seq_len(dim(datos)[1])
  semanas <- length(datos.x)
  datos.semanas <- as.numeric(datos$week)
  datos.temporadas <- datos$season
  datos.y <- as.numeric(datos[, names(datos) == "rates"])
  range.x <- range(datos.x, na.rm = TRUE)

  datos.fixed <- transformdata.back(epidata, i.name = "rates", i.range.x.final = i.range.x, i.cutoff.original = i.cutoff.original, i.fun = sum)$data
  datos.y.fixed <- as.numeric(datos.fixed[, names(datos.fixed) == "rates"])

  datos.missing <- datos.fixed
  datos.missing[!(is.na(datos) & !is.na(datos.fixed))] <- NA
  datos.y.missing <- as.numeric(datos.missing[, names(datos.missing) == "rates"])

  indices <- as.data.frame(epiindex)
  indices[is.na(epidata)] <- NA

  rownames(indices) <- rownames(i.data)
  names(indices) <- names(i.data)
  datos.indexes <- transformdata.back(indices, i.name = "rates", i.range.x.final = i.range.x, i.cutoff.original = i.cutoff.original, i.fun = function(x, ...) {
    if (all(is.na(x))) {
      return(NA)
    } else if (any(x == 2, ...)) {
      return(2)
    } else if (any(x == 1, ...)) {
      return(1)
    } else {
      return(3)
    }
  })$data
  datos.y.indexes <- as.numeric(datos.indexes[, names(datos.indexes) == "rates"])

  if (length(i.alternative.thresholds) == 4) {
    intensity <- i.alternative.thresholds
  } else {
    if (NCOL(i.data) > 1) {
      intensity <- as.numeric(epithresholds)
    } else {
      i.plot.intensity <- FALSE
      intensity <- NA
    }
  }

  if (i.graph.file.name == "") graph.name <- "series graph" else graph.name <- i.graph.file.name

  if (is.numeric(i.range.y)) {
    range.y.bus <- i.range.y
  } else if (i.plot.intensity) {
    range.y.bus <- c(0, maxFixNA(c(datos.y, intensity)))
  } else {
    range.y.bus <- c(0, maxFixNA(datos.y))
  }
  otick <- optimal.tickmarks(range.y.bus[1], range.y.bus[2], 10)
  range.y <- c(otick$range[1], otick$range[2] + otick$by / 2)

  # if (i.graph.file) tiff(filename=paste(i.output,"/",graph.name,".tiff",sep=""),width=8,height=6,units="in",pointsize="12",
  #                        compression="lzw",bg="white",res=300,antialias="none")
  if (i.graph.file) {
    png(
      filename = paste(i.output, "/", graph.name, ".png", sep = ""), width = 8, height = 6, units = "in", pointsize = "12",
      bg = "white", res = 300, antialias = "none"
    )
  }

  opar <- par(mar = c(5, 3, 3, 3) + 0.1, mgp = c(3, 0.5, 0), xpd = TRUE)

  # Plot the first time series. Notice that you don't have to draw the axis nor the labels
  matplot(datos.x, datos.y.fixed,
    axes = FALSE, xlab = "", ylab = "",
    type = "l",
    col = i.color.pattern[4],
    main = i.graph.title,
    xlim = range.x,
    ylim = range.y,
    lty = 1,
    col.main = i.color.pattern[6]
  )
  # Puntos de la serie de tasas
  if (i.plot.timing) {
    if (i.color.pattern[7] == i.color.pattern[9]) {
      etiquetas <- c("Non-epidemic", "Epidemic")
      tipos <- c(NA, NA)
      anchos <- c(NA, NA)
      colores <- c(i.color.pattern[7:8])
      puntos <- c(19, 19)
      colores.pt <- c(NA, NA)
    } else {
      etiquetas <- c("Pre-epidemic", "Epidemic", "Post-epidemic")
      tipos <- c(NA, NA, NA)
      anchos <- c(NA, NA, NA)
      colores <- c(i.color.pattern[7:9])
      puntos <- c(19, 19, 19)
      colores.pt <- c(NA, NA, NA)
    }
    # pre
    points(datos.x[datos.y.indexes == 1], datos.y[datos.y.indexes == 1], pch = 19, type = "p", col = i.color.pattern[7], cex = 0.75)
    points(datos.x[datos.y.indexes == 1], datos.y.missing[datos.y.indexes == 1], pch = 13, type = "p", col = i.color.pattern[7], cex = 0.75)
    # epi
    points(datos.x[datos.y.indexes == 2], datos.y[datos.y.indexes == 2], pch = 19, type = "p", col = i.color.pattern[8], cex = 0.75)
    points(datos.x[datos.y.indexes == 2], datos.y.missing[datos.y.indexes == 2], pch = 13, type = "p", col = i.color.pattern[8], cex = 0.75)
    # post
    points(datos.x[datos.y.indexes == 3], datos.y[datos.y.indexes == 3], pch = 19, type = "p", col = i.color.pattern[9], cex = 0.75)
    points(datos.x[datos.y.indexes == 3], datos.y.missing[datos.y.indexes == 3], pch = 13, type = "p", col = i.color.pattern[9], cex = 0.75)
  } else {
    etiquetas <- "Series"
    tipos <- 1
    anchos <- 1
    colores <- i.color.pattern[4]
    puntos <- 21
    colores.pt <- i.color.pattern[5]
    points(datos.x, datos.y, pch = 19, type = "p", col = i.color.pattern[5], cex = 0.75)
    points(datos.x, datos.y.missing, pch = 13, type = "p", col = i.color.pattern[5], cex = 0.75)
  }
  if (i.plot.intensity) {
    etiquetas <- c(etiquetas, "Epidemic thr", "Medium thr", "High thr", "Very high thr")
    tipos <- c(tipos, 2, 2, 2, 2)
    anchos <- c(anchos, 2, 2, 2, 2)
    colores <- c(colores, i.color.pattern[10:13])
    puntos <- c(puntos, NA, NA, NA, NA)
    colores.pt <- c(colores.pt, NA, NA, NA, NA)
    lines(x = datos.x[c(1, semanas)], y = rep(intensity[1], 2), lty = 2, , lwd = 2, col = i.color.pattern[10])
    lines(x = datos.x[c(1, semanas)], y = rep(intensity[2], 2), lty = 2, , lwd = 2, col = i.color.pattern[11])
    lines(x = datos.x[c(1, semanas)], y = rep(intensity[3], 2), lty = 2, , lwd = 2, col = i.color.pattern[12])
    lines(x = datos.x[c(1, semanas)], y = rep(intensity[4], 2), lty = 2, , lwd = 2, col = i.color.pattern[13])
  }
  # Ejes
  posicion.temporadas.m <- aggregate(datos.x, by = list(datos.temporadas), FUN = function(x) x[floor(length(x) / 2)])$x
  posicion.temporadas.f <- aggregate(datos.x, by = list(datos.temporadas), FUN = function(x) x[1])$x
  posicion.temporadas.l <- aggregate(datos.x, by = list(datos.temporadas), FUN = function(x) x[length(x)])$x
  axis(1,
    at = datos.x[datos.semanas %in% c(40, 50, 10, 20, 30)], tcl = -0.3,
    tick = TRUE,
    labels = FALSE,
    cex.axis = 0.7,
    col.axis = i.color.pattern[2], col = i.color.pattern[1]
  )
  axis(1,
    at = datos.x[datos.semanas %in% c(10, 30, 50)], las = 3,
    tick = FALSE,
    labels = datos.semanas[datos.semanas %in% c(10, 30, 50)],
    cex.axis = 0.5,
    line = 0.2,
    col.axis = i.color.pattern[2], col = i.color.pattern[1]
  )
  axis(1,
    at = datos.x[datos.semanas %in% c(20, 40)], las = 3,
    tick = FALSE,
    labels = datos.semanas[datos.semanas %in% c(20, 40)],
    cex.axis = 0.5,
    line = 0.2,
    col.axis = i.color.pattern[2], col = i.color.pattern[1]
  )
  axis(1,
    at = datos.x[c(posicion.temporadas.f, posicion.temporadas.l)], tcl = -0.3,
    tick = TRUE,
    labels = FALSE,
    cex.axis = 0.7,
    line = 1.7,
    col.axis = i.color.pattern[2], col = i.color.pattern[1]
  )
  axis(1,
    at = datos.x[posicion.temporadas.m],
    tick = FALSE,
    labels = datos.temporadas[posicion.temporadas.m],
    cex.axis = 0.5,
    line = 1,
    col.axis = i.color.pattern[2], col = i.color.pattern[1]
  )
  axis(2,
    at = otick$tickmarks,
    lwd = 1,
    cex.axis = 0.6,
    col.axis = i.color.pattern[2],
    col = i.color.pattern[1]
  )
  mtext(1, text = "Week", line = 2.5, cex = 0.8, col = i.color.pattern[3])
  mtext(2, text = "Weekly value", line = 1.3, cex = 0.8, col = i.color.pattern[3])
  mtext(3, text = i.graph.subtitle, cex = 0.8, col = i.color.pattern[6])
  if (i.mem.info) mtext(4, text = paste("mem R library - Jose E. Lozano - https://github.com/lozalojo/mem", sep = ""), line = 0.75, cex = 0.6, col = "#404040")

  xa <- "topright"
  ya <- NULL
  legend(
    x = xa, y = ya, inset = c(0, -0.05), xjust = 0,
    legend = rev(etiquetas),
    bty = "n",
    lty = rev(tipos),
    lwd = rev(anchos),
    col = rev(colores),
    pch = rev(puntos),
    pt.bg = rev(colores.pt),
    cex = 0.75,
    x.intersp = 0.5,
    y.intersp = 0.7,
    text.col = "#000000",
    ncol = 1
  )

  par(opar)
  if (i.graph.file) dev.off()
}
