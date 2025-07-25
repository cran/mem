#' confidence interval por the median using KC Method
#'
#' @keywords internal
#' @importFrom EnvStats eqnpar
iconfianza.percentil.eqnpar <- function(datos, q = 0.50, nivel = 0.95, ic = TRUE, colas = 2) {
  x <- datos[!is.na(datos)]
  # eqnpar requires more than one unique values in x
  n <- length(unique(x))
  if (n == 0) {
    med <- NA
    l.i <- NA
    l.s <- NA
  } else if (n == 1) {
    med <- x[1]
    l.i <- x[1]
    l.s <- x[1]
  } else {
    if (colas != 2) {
      temp1 <- try(EnvStats::eqnpar(x = x, p = q, ci = TRUE, ci.method = "interpolate", approx.conf.level = nivel, ci.type = "lower"), silent = TRUE)
      temp2 <- try(EnvStats::eqnpar(x = x, p = q, ci = TRUE, ci.method = "interpolate", approx.conf.level = nivel, ci.type = "upper"), silent = TRUE)
      if ("try-error" %in% class(temp1) || "try-error" %in% class(temp2)) {
        temp1 <- try(EnvStats::eqnpar(x = x, p = q, ci = TRUE, ci.method = "normal.approx", approx.conf.level = nivel, ci.type = "lower"), silent = TRUE)
        temp2 <- try(EnvStats::eqnpar(x = x, p = q, ci = TRUE, ci.method = "normal.approx", approx.conf.level = nivel, ci.type = "upper"), silent = TRUE)
      }
      if ("try-error" %in% class(temp1) || "try-error" %in% class(temp2)) {
        med <- NA
        l.i <- NA
        l.s <- NA
      } else {
        med <- as.numeric(temp1$quantiles)
        l.i <- as.numeric(temp1$interval$limits[1])
        l.s <- as.numeric(temp2$interval$limits[2])
      }
    } else {
      temp1 <- try(EnvStats::eqnpar(x = x, p = q, ci = TRUE, ci.method = "interpolate", approx.conf.level = nivel, ci.type = "two-sided"), silent = TRUE)
      if ("try-error" %in% class(temp1)) temp1 <- try(EnvStats::eqnpar(x = x, p = q, ci = TRUE, ci.method = "normal.approx", approx.conf.level = nivel, ci.type = "two-sided"), silent = TRUE)
      if ("try-error" %in% class(temp1)) {
        med <- NA
        l.i <- NA
        l.s <- NA
      } else {
        med <- as.numeric(temp1$quantiles)
        l.i <- as.numeric(temp1$interval$limits[1])
        l.s <- as.numeric(temp1$interval$limits[2])
      }
    }
  }
  if (ic) iconfres <- c(l.i, med, l.s) else iconfres <- rep(med, 3)
  iconfres
}
