#' @title Influenza Epidemic Timing
#'
#' @description
#' Function \code{memtiming} is used to find the optimal timing of an influenza epidemic
#' in a set of weekly influenza surveillance rates. It provides the start and the end of
#' the epidemic, also it returns a list of pre-epidemic and post-epidemic rates that can
#' be used to calculate influenza baselines and thresholds.
#'
#' @name memtiming
#'
#' @aliases summary.epidemic,plot.epidemic,print.epidemic
#'
#' @param i.data a numeric object  (or one that can be coerced to that class).
#' @param i.n.values a number, which indicates how many pre-epidemic values are taken from the pre-epidemic period.
#' @param i.method a number from 1 to 4, to select which optimization method to use.
#' @param i.param an optional parameter used by the method.
#' @param i.mem.info include information about the package in the graph.
#'
#' @return
#' \code{memtiming} returns an object of class \code{epidemic}.
#' An object of class \code{epidemic} is a list containing at least the following components:
#' \describe{
#'   \item{i.data}{input data}
#'   \item{data}{data with missing rates filled with data from smothing regression}
#'   \item{map.curve}{MAP curve}
#'   \item{slope.curve}{slope of the MAP curve}
#'   \item{optimum.map}{optimum}
#'   \item{pre.epi}{pre-epidemic highest rates}
#'   \item{epi}{epidemic highest rates}
#'   \item{post.epi}{post-epidemic highest rates}
#'   \item{pre.epi.data}{pre-epidemic rates}
#'   \item{epi.data}{epidemic rates}
#'   \item{post.epi.data}{post-epidemic rates}
#' }
#'
#' @details
#' The method to calculate the optimal timing of an epidemic is described as part of the
#' \emph{Moving Epidemics Method} (MEM), used to monitor influenza activity in a weekly
#' surveillance system.
#'
#' Input data is a vector of rates that represent a full influenza surveillance season.
#' It can start and end at any week (tipically at week 40th), and rates can be expressed
#' as per 100,000 inhabitants (or per consultations, if population is not available) or
#' any other scale.
#'
#' The \code{i.n.values} parameter is used to get information from the pre-epidemic and
#' post-epidemic period. The function will extract the highest pre/post values in order
#' to use it later to calculate other influenza indicators, such as baseline activity or
#' threshold for influenza epidemic.
#'
#' Depending of the value \code{i.method}, the function will use a different method to
#' calculate the optimum epidemic timing.
#'
#' \describe{
#' \item{1}{original method}
#' \item{2}{fixed criterium method}
#' \item{3}{slope method}
#' \item{4}{second derivative method}
#' }
#'
#' All methods are based upon the MAP curve, as described in the MEM Method.
#'
#' The \emph{original method} uses the process shown in the original paper, which describes
#' the MEM as it was created. The \emph{fixed criterium method} is an update of the MEM
#' that uses the slope of the MAP curve fo find the optimum, which is the point where the
#' slope is lower than a predefined value. The \emph{slope method} also calculates the
#' slope of the MAP curve, but the optimum is the one that matches the global/mean slope.
#' The \emph{second derivative method} calculates the second derivative and equals to zero
#' to search an inflexion point in the original curve.
#'
#' Two of the four methods require an additional parameter \code{i.param}: for the
#' \emph{fixed criterium method} is the predefined value to find the optimum, which
#' typically is 2.5-3.0\%, and for the \emph{original method} it is needed the window
#' parameter to smooth the map curve. A value of \code{-1} indicates it should use
#' \code{\link[sm]{h.select}} to select the window parameter. See \code{\link[sm]{sm}} for more
#' information about this topic.
#'
#' @examples
#' # Castilla y Leon Influenza Rates data
#' data(flucyl)
#' # Finds the timing of the first season: 2001/2002
#' tim <- memtiming(flucyl[1])
#' print(tim)
#' summary(tim)
#' plot(tim)
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
#' @importFrom methods is
memtiming <- function(i.data,
                      i.n.values = 5,
                      i.method = 2,
                      i.param = 2.8,
                      i.mem.info = TRUE) {
  if (!is.null(dim(i.data))) if (ncol(i.data) != 1) stop("Incorrect use of this function. Use memtiming() with a single season.")
  if (is.null(i.method)) i.method <- 2
  if (is.na(i.method)) i.method <- 2
  if (is.null(i.param)) i.param <- 2.8
  if (is.na(i.param)) i.param <- 2.8

  datos <- fill.missing(as.vector(as.matrix(i.data)))

  curva.map <- calcular.map(datos)
  temp1 <- calcular.optimo(curva.map, i.method, i.param)
  optimo.map <- temp1$resultados
  curva.slope <- temp1$datos
  umbral.slope <- temp1$umbral
  epi.ini <- optimo.map[4]
  epi.fin <- optimo.map[5]
  n.datos <- length(datos)
  if (is.na(epi.ini) && !is.na(epi.fin)) epi.ini <- 1
  if (!is.na(epi.ini) && is.na(epi.fin)) epi.fin <- n.datos
  if (is.na(epi.ini) && is.na(epi.fin)) {
    pre.epi.datos <- datos
    epi.datos <- NA
    post.epi.datos <- NA
  } else {
    pre.epi.datos <- datos[-(epi.ini:n.datos)]
    epi.datos <- datos[epi.ini:epi.fin]
    post.epi.datos <- datos[-(1:epi.fin)]
  }
  pre.epi <- maxnvalores(pre.epi.datos, i.n.values)
  epi <- maxnvalores(epi.datos, i.n.values)
  post.epi <- maxnvalores(post.epi.datos, i.n.values)
  memtiming.output <- list(
    map.curve = curva.map,
    slope.curve = curva.slope,
    slope.threshold = umbral.slope,
    optimum.map = optimo.map,
    pre.epi = pre.epi,
    post.epi = post.epi,
    epi = epi,
    pre.epi.data = pre.epi.datos,
    post.epi.data = post.epi.datos,
    epi.data = epi.datos,
    data = datos,
    param.data = i.data,
    param.n.values = i.n.values,
    param.method = i.method,
    param.param = i.param,
    param.mem.info = i.mem.info
  )
  memtiming.output$call <- match.call()
  class(memtiming.output) <- "epidemic"
  return(memtiming.output)
}

#' @export
print.epidemic <- function(x, ...) {
  cat("Call:\n")
  print(x$call)
  cat("\nOptimum:\n")
  print(x$optimum.map[1])
  cat("\nTiming:\n")
  print(x$optimum.map[4:5])
}

#' @export
summary.epidemic <- function(object, ...) {
  cat("Call:\n")
  print(object$call)
  cat("\nOptimum:\n")
  print(object$optimum.map[1:3])
  cat("\nTiming:\n")
  print(object$optimum.map[4:5])
  cat("\nPre-epidemic values:\n")
  print(object$pre.epi)
  cat("\nPost-epidemic values:\n")
  print(object$post.epi)
}

#' @export
plot.epidemic <- function(x, ...) {
  if (!is(x, "epidemic")) stop("input must be an object of class epidemic")
  title.graph <- names(x$param.data)
  if (is.null(title.graph)) title.graph <- ""
  x.data <- as.vector(as.matrix(x$param.data))
  x.data.fixed <- as.vector(as.matrix(x$data))
  x.data.missing <- x.data.fixed
  x.data.missing[!(is.na(x.data) & !is.na(x.data.fixed))] <- NA
  semanas <- length(x.data)
  i.epi <- x$optimum.map[4]
  f.epi <- x$optimum.map[5]
  otick <- optimal.tickmarks(0, maxnvalores(x.data.fixed), 10)
  range.y <- c(otick$range[1], otick$range[2] + otick$by / 2)
  opar <- par(mar = c(4, 3, 1, 2) + 0.1, mgp = c(3, 0.5, 0), xpd = TRUE)
  matplot(1:semanas, x.data.fixed,
    type = "l", col = "#808080",
    lty = c(1, 1), xaxt = "n", main = title.graph, ylim = range.y, axes = FALSE, xlab = "", ylab = ""
  )
  # Axis
  if (!is.null(rownames(x$param.data))) {
    week.labels <- rownames(x$param.data)
  } else {
    week.labels <- as.character(1:semanas)
  }
  axis(1,
    at = seq(1, semanas, 2), tick = FALSE,
    labels = week.labels[seq(1, semanas, 2)], cex.axis = 0.7, col.axis = "#404040", col = "#C0C0C0"
  )
  axis(1,
    at = seq(2, semanas, 2), tick = FALSE,
    labels = week.labels[seq(2, semanas, 2)], cex.axis = 0.7, line = 0.60, col.axis = "#404040", col = "#C0C0C0"
  )
  axis(1, at = seq(1, semanas, 1), labels = FALSE, cex.axis = 0.7, col.axis = "#404040", col = "#C0C0C0")
  mtext(1, text = "Week", line = 2, cex = 0.8, col = "#000040")
  axis(2, at = otick$tickmarks, lwd = 1, cex.axis = 0.6, col.axis = "#404040", col = "#C0C0C0")
  mtext(2, text = "Weekly rate", line = 1.3, cex = 0.8, col = "#000040")
  if (x$param.mem.info) mtext(4, text = paste("mem R library - Jose E. Lozano - https://github.com/lozalojo/mem", sep = ""), line = 0.75, cex = 0.6, col = "#404040")
  if (is.na(i.epi)) {
    puntos <- x.data
    points(1:semanas, puntos, pch = 19, type = "p", col = "#00C000", cex = 1.5)
    puntos <- x.data.missing
    points(1:semanas, puntos, pch = 13, type = "p", col = "#00C000", cex = 1.5)
  } else {
    # pre
    puntos <- x.data
    puntos[i.epi:semanas] <- NA
    points(1:semanas, puntos, pch = 19, type = "p", col = "#00C000", cex = 1.5)
    puntos <- x.data.missing
    puntos[i.epi:semanas] <- NA
    points(1:semanas, puntos, pch = 13, type = "p", col = "#00C000", cex = 1.5)
    # epi
    puntos <- x.data
    if (i.epi > 1) puntos[1:(i.epi - 1)] <- NA
    if (f.epi < semanas) puntos[(f.epi + 1):semanas] <- NA
    points(1:semanas, puntos, pch = 19, type = "p", col = "#800080", cex = 1.5)
    puntos <- x.data.missing
    if (i.epi > 1) puntos[1:(i.epi - 1)] <- NA
    if (f.epi < semanas) puntos[(f.epi + 1):semanas] <- NA
    points(1:semanas, puntos, pch = 13, type = "p", col = "#800080", cex = 1.5)
    # post
    puntos <- x.data
    puntos[1:f.epi] <- NA
    points(1:semanas, puntos, pch = 19, type = "p", col = "#FFB401", cex = 1.5)
    puntos <- x.data.missing
    puntos[1:f.epi] <- NA
    points(1:semanas, puntos, pch = 13, type = "p", col = "#FFB401", cex = 1.5)
  }

  # legend(semanas*0.70,otick$range[2]*0.99,
  legend("topright",
    inset = c(0, 0),
    legend = c("Crude rate", "Pre-epi period", "Epidemic", "Post-epi period"),
    bty = "n",
    lty = c(1, 1, 1, 1),
    lwd = c(1, 1, 1, 1),
    col = c("#808080", "#C0C0C0", "#C0C0C0", "#C0C0C0"),
    pch = c(NA, 21, 21, 21),
    pt.bg = c(NA, "#00C000", "#800080", "#FFB401"),
    cex = 1
  )
  par(opar)
}
