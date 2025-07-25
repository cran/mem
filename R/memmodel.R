#' @title Methods for influenza modelization
#'
#' @description
#' Function \code{memmodel} is used to calculate the threshold for influenza epidemic using historical
#' records (surveillance rates).
#'
#' The method to calculate the threshold is described in the Moving Epidemics Method (MEM) used to
#' monitor influenza activity in a weekly surveillance system.
#'
#' @name memmodel
#'
#' @aliases summary.flu,plot.flu,print.flu
#'
#' @param i.data Data frame of input data.
#' @param i.seasons Maximum number of seasons to use.
#' @param i.type.threshold Type of confidence interval to calculate the threshold.
#' @param i.level.threshold Level of confidence interval to calculate the threshold.
#' @param i.tails.threshold Tails for the confidence interval to calculate the threshold.
#' @param i.type.intensity Type of confidence interval to calculate the intensity thresholds.
#' @param i.level.intensity Levels of confidence interval to calculate the intensity thresholds.
#' @param i.tails.intensity Tails for the confidence interval to calculate the threshold.
#' @param i.type.curve Type of confidence interval to calculate the modelled curve.
#' @param i.level.curve Level of confidence interval to calculate the modelled curve.
#' @param i.type.other Type of confidence interval to calculate length, start and percentages.
#' @param i.level.other Level of confidence interval to calculate length, start and percentages.
#' @param i.method Method to calculate the optimal timing of the epidemic.
#' @param i.param Parameter to calculate the optimal timing of the epidemic.
#' @param i.centering Number of weeks to center the moving seasons.
#' @param i.n.max Number of pre-epidemic values used to calculate the threshold.
#' @param i.type.boot Type of bootstrap technique.
#' @param i.iter.boot Number of bootstrap iterations.
#' @param i.mem.info include information about the package in the graph.
#' @param i.use.t Whether to use t-values (t distribution) instead of z-values (normal distribution).
#'
#' @return
#' \code{memmodel} returns an object of class \code{mem}.
#' An object of class \code{mem} is a list containing at least the following components:
#' \describe{
#'   \item{i.data}{input data}
#'   \item{pre.post.intervals}{Pre/post confidence intervals (Threhold is the upper limit
#'   of the confidence interval).}
#'   \item{ci.length}{Mean epidemic length confidence interval.}
#'   \item{ci.percent}{Mean covered percentage confidence interval.}
#'   \item{mean.length}{Mean length.}
#'   \item{moving.epidemics}{Moving epidemic rates.}
#'   \item{mean.start}{Mean epidemic start.}
#'   \item{epi.intervals}{Epidemic levels of intensity.}
#'   \item{typ.curve}{Typical epidemic curve.}
#'   \item{n.max}{Effective number of pre epidemic values.}
#' }
#'
#' @details
#' Input data is a data frame containing rates that represent historical influenza surveillance
#' data. It can start and end at any given week (tipically at week 40th), and rates can be
#' expressed as per 100,000 inhabitants (or per consultations, if population is not
#' available) or any other scale.
#'
#' Parameters \code{i.type}, \code{i.type.threshold} and \code{i.type.curve} defines how to
#' calculate confidence intervals along the process.
#'
#' \code{i.type.curve} is used for calculating the typical influenza curve,
#' \code{i.type.threshold} is used to calculate the pre and post epidemic threshold and
#' \code{i.type} is used for any other confidende interval used in the method.
#'
#' All three parameters must be a number between \code{1} and \code{6}:
#'
#' \describe{
#' \item{1}{Arithmetic mean and mean confidence interval.}
#' \item{2}{Geometric mean and mean confidence interval.}
#' \item{3}{Median and the Nyblom/normal aproximation confidence interval.}
#' \item{4}{Median and bootstrap confidence interval.}
#' \item{5}{Arithmetic mean and point confidence interval (standard deviations).}
#' \item{6}{Geometric mean and point confidence interval (standard deviations).}
#' }
#'
#' Option \code{3} uses the Hettmansperger and Sheather (1986) and Nyblom (1992) method,
#' when there is enough sample size. If sample size is small, then the normal aproximation
#' will be used as described in Conover, 1980, p. 112. Refer to EnvStats package for
#' more information.
#'
#' Option \code{4} uses two more parameters: \code{i.type.boot} indicates which bootstrap
#' method to use. The values are the same of those of the \code{boot::boot.ci} function.
#' Parameter \code{i.iter.boot} indicates the number of bootstrap samples to use. See
#' \code{boot::boot} for more information about this topic.
#'
#' Parameters \code{i.level}, \code{i.level.threshold} and \code{i.level.curve} indicates,
#' respectively, the level of the confidence intervals described above.
#'
#' The \code{i.n.max} parameter indicates how many pre epidemic values to use to calculate
#' the threshold. A value of -1 indicates the program to use an appropiate number of points
#' depending on the number of seasons provided as input. \code{i.tails} tells the program
#' to use 1 or 2 tailed confidence intervals when calculating the threshold (1 is
#' recommended).
#'
#' Parameters \code{i.method} and \code{i.param} indicates how to find the optimal timing
#' of the epidemics. See \code{\link{memtiming}} for details on the values this parameters
#' can have.
#'
#' The \code{i.use.t} parameter allows to use the t-value (from a t distribution) instead
#' of the z-value (from a normal distribution) for confidence intervals that rely on z/t-values.
#' Useful when using less than 30 values to calculate confidence intervals.
#'
#' It is important to know how to arrange information in order to use with memapp. The key points are:
#'
#' \enumerate{
#' \item One single epidemic wave each season.
#' \item Never delete a rate inside an epidemic.
#' \item Accommodate week 53.
#' \item Do not inflate missing values with zeroes.
#' }
#'
#' Data must contain information from the historical series. Surveillance period can start and end at
#' any given week (typically start at week 40th and ends at week 20th), and data can have any units and
#' can be expressed in any scale (typically rates per 100,000 inhabitants or consultations).
#'
#' The table must have one row per epidemiological week and one column per surveillance season. A season
#' is a full surveillance period from the beginning to the end, where occurs at some point one single
#' epidemic wave on it. No epidemic wave can be spared in two consecutive seasons. If so, you have to
#' redefine the start and end of the season defined in your dataset. If a season have two waves, it must
#' be split in two periods and must be named accordingly with the seasons name conventions described
#' below. Each cell contains the value for a given week in a given season.
#'
#' The first column should contain the names of the weeks. When the season contains two different calendar
#' years, the week will go from 40th of the first year to 52nd, and then from 1st to 20th. When the season
#' contains one year, the weeks will go from 1st to 52nd.
#'
#' Note: If there is no column with week names, the application will name the weeks numbering from 1 to
#' the number of rows.
#'
#' \enumerate{
#' \item In the northern hemisphere countries, the surveillance period usually goes from
#' week 40 to 20 of the following year (notation: season 2016/2017).
#' \item In the southern hemisphere countries, the surveillance period usually goes from
#' week 18 to 39 same year (notation: season 2017).
#' }
#'
#' The first row must contain the names of the seasons. This application understand the naming of a
#' season when it contains one or two four digits year separated by / and one one-digit number
#' between parenthesis to identify the wave number. The wave number part in a name of a season is
#' used when a single surveillance period has two epidemic waves that have to be separated in order
#' to have reliable results. In this case, each wave is placed in different columns and named ending
#' with (1) for the first period, (2) for the second, and so on.
#'
#' @examples
#' # Castilla y Leon Influenza Rates data
#' data(flucyl)
#' # Finds the timing of the first season: 2001/2002
#' epi <- memmodel(flucyl)
#' print(epi)
#' summary(epi)
#' plot(epi)
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
#' Hettmansperger, T. P., and S. J Sheather. 1986. Confidence Intervals Based on Interpolated Order
#' Statistics. Statistics and Probability Letters 4: 75-79. doi:10.1016/0167-7152(86)90021-0.
#'
#' Nyblom, J. 1992. Note on Interpolated Order Statistics. Statistics and Probability Letters 14:
#' 129-31. doi:10.1016/0167-7152(92)90076-H.
#'
#' Conover, W.J. (1980). Practical Nonparametric Statistics. Second Edition. John Wiley and Sons, New York.
#'
#' @keywords influenza
#'
#' @export
#' @importFrom stats loess qt qnorm quantile runif var
#' @importFrom grDevices colorRampPalette colorRamp dev.off rgb tiff
#' @importFrom RColorBrewer brewer.pal
#' @importFrom graphics abline axis legend matplot mtext par points text lines
memmodel <- function(i.data,
                     i.seasons = 10,
                     i.type.threshold = 5,
                     i.level.threshold = 0.95,
                     i.tails.threshold = 1,
                     i.type.intensity = 6,
                     i.level.intensity = c(0.40, 0.90, 0.975),
                     i.tails.intensity = 1,
                     i.type.curve = 2,
                     i.level.curve = 0.95,
                     i.type.other = 3,
                     i.level.other = 0.95,
                     i.method = 2,
                     i.param = 2.8,
                     i.centering = -1,
                     i.n.max = -1,
                     i.type.boot = "norm",
                     i.iter.boot = 10000,
                     i.mem.info = TRUE,
                     i.use.t = FALSE) {
  if (is.null(dim(i.data))) {
    memmodel.output <- NULL
    cat("Incorrect number of dimensions, input must be a data.frame\n")
  } else {
    # Test if first column is week.name
    if (all(i.data[, 1] %in% 1:53)) {
      datos <- i.data[-1]
      rownames(datos) <- i.data[, 1]
    } else {
      datos <- i.data
      if (!all(rownames(i.data) %in% 1:53)) rownames(datos) <- seq_len(NROW(i.data))
    }
    datos <- datos[apply(datos, 2, function(x) sum(x, na.rm = TRUE) > 0)]
    if (!(ncol(datos) > 1)) {
      memmodel.output <- NULL
      cat("Incorrect number of dimensions, at least two seasons of valid data (non-zero values) required\n")
    } else {
      if (is.matrix(datos)) datos <- as.data.frame(datos)
      if (is.null(i.seasons)) i.seasons <- NA
      if (!is.na(i.seasons)) if (i.seasons > 0) datos <- datos[(max((dim(datos)[2]) - i.seasons + 1, 1)):(dim(datos)[2])]
      datos <- as.data.frame(apply(datos, 2, fill.missing))
      semanas <- dim(datos)[1]
      anios <- NCOL(datos)
      # Calcular el optimo
      if (is.na(i.n.max)) {
        n.max <- max(1, round(30 / anios, 0))
      } else {
        if (i.n.max == -1) {
          n.max <- max(1, round(30 / anios, 0))
        } else if (i.n.max == 0) {
          n.max <- semanas
        } else {
          n.max <- i.n.max
        }
      }
      if (is.null(i.method)) i.method <- 2
      if (is.na(i.method)) i.method <- 2
      if (is.null(i.param)) i.param <- 2.8
      if (is.na(i.param)) i.param <- 2.8
      optimo <- apply(datos, 2, memtiming, i.n.values = n.max, i.method = i.method, i.param = i.param)

      datos.duracion.real <- extraer.datos.optimo.map(optimo)

      # por defecto la aritmetica en ambos
      ic.duracion <- iconfianza(datos = as.numeric(datos.duracion.real[1, ]), nivel = i.level.other, tipo = i.type.other, ic = TRUE, tipo.boot = i.type.boot, iteraciones.boot = i.iter.boot, colas = 2, use.t = i.use.t)
      ic.duracion <- rbind(ic.duracion, c(floor(ic.duracion[1]), round(ic.duracion[2]), ceiling(ic.duracion[3])))
      ic.porcentaje <- iconfianza(datos = as.numeric(datos.duracion.real[2, ]), nivel = i.level.other, tipo = i.type.other, ic = TRUE, tipo.boot = i.type.boot, iteraciones.boot = i.iter.boot, colas = 2, use.t = i.use.t)
      duracion.media <- ic.duracion[2, 2]

      if (is.na(i.centering) || i.centering == -1) duracion.centrado <- duracion.media else duracion.centrado <- i.centering

      ########################################################################################
      # Calcula todos los parametros asociados a la temporada gripal en base a la estimacion #
      # del numero de semanas de duracion total.                                             #
      ########################################################################################

      # Datos de la gripe en la temporada REAL y en la temporada MEDIA, esta ultima sirve para unir las temporadas.

      semana.inicio <- as.integer(rownames(datos)[1])
      gripe <- array(dim = c(7, anios, 3), dimnames = list(
        "indicators" = c("epidemic start", "epidemic end", "sum of epidemic values", "sum of values", "covered percentage", "sum of pre-epidemic values", "sum of post-epidemic values"),
        "seasons" = names(datos),
        "type" = c("real epidemic", "mean length epidemic", "centered length epidemic")
      ))
      datos.duracion.media <- extraer.datos.curva.map(optimo, duracion.media)
      datos.duracion.centrado <- extraer.datos.curva.map(optimo, duracion.centrado)

      ## Estimacion del numero de semana en el  comienza la gripe

      ic.inicio <- iconfianza(datos = as.numeric(datos.duracion.real[4, ]), nivel = i.level.other, tipo = i.type.other, ic = TRUE, tipo.boot = i.type.boot, iteraciones.boot = i.iter.boot, colas = 2, use.t = i.use.t)
      ic.inicio <- rbind(ic.inicio, c(floor(ic.inicio[1]), round(ic.inicio[2]), ceiling(ic.inicio[3])))
      ic.inicio <- rbind(ic.inicio, c(semana.absoluta(ic.inicio[2, 1], semana.inicio), semana.absoluta(ic.inicio[2, 2], semana.inicio), semana.absoluta(ic.inicio[2, 3], semana.inicio)))
      ic.inicio <- ic.inicio[c(2, 3, 1), ]
      inicio.medio <- ic.inicio[1, 2]

      ic.inicio.centrado <- iconfianza(datos = as.numeric(datos.duracion.centrado[4, ]), nivel = i.level.other, tipo = i.type.other, ic = TRUE, tipo.boot = i.type.boot, iteraciones.boot = i.iter.boot, colas = 2, use.t = i.use.t)
      ic.inicio.centrado <- rbind(ic.inicio.centrado, c(floor(ic.inicio.centrado[1]), round(ic.inicio.centrado[2]), ceiling(ic.inicio.centrado[3])))
      ic.inicio.centrado <- rbind(ic.inicio.centrado, c(semana.absoluta(ic.inicio.centrado[2, 1], semana.inicio), semana.absoluta(ic.inicio.centrado[2, 2], semana.inicio), semana.absoluta(ic.inicio.centrado[2, 3], semana.inicio)))
      ic.inicio.centrado <- ic.inicio.centrado[c(2, 3, 1), ]
      inicio.centrado <- ic.inicio.centrado[1, 2]

      for (j in 1:anios) {
        ## Semana en la q comienza la temporada.real
        gripe[1, j, 1] <- datos.duracion.real[4, j]
        ## Semana en la q acaba
        gripe[2, j, 1] <- datos.duracion.real[5, j]
        ## numero de casos en la temporada.real de gripe
        gripe[3, j, 1] <- datos.duracion.real[3, j]
        ## Numero de casos totales de la temporada global
        gripe[4, j, 1] <- sum(datos[, j], na.rm = TRUE)
        ## Porcentaje cubierto de casos de la temporada gripal
        gripe[5, j, 1] <- datos.duracion.real[2, j]
        ## Casos Acumulados justo antes de comenzar la temporada gripal
        if (gripe[1, j, 1] > 1) gripe[6, j, 1] <- sum(datos[1:(gripe[1, j, 1] - 1), j], na.rm = TRUE) else gripe[6, j, 1] <- 0
        ## Casos Despues de la temporada gripal
        if (gripe[2, j, 1] < semanas) gripe[7, j, 1] <- sum(datos[(gripe[2, j, 1] + 1):semanas, j], na.rm = TRUE) else gripe[7, j, 1] <- 0

        gripe[1, j, 2] <- datos.duracion.media[4, j]
        gripe[2, j, 2] <- datos.duracion.media[5, j]
        gripe[3, j, 2] <- datos.duracion.media[3, j]
        gripe[4, j, 2] <- sum(datos[, j], na.rm = TRUE)
        gripe[5, j, 2] <- datos.duracion.media[2, j]
        if (gripe[1, j, 2] > 1) gripe[6, j, 2] <- sum(datos[1:(gripe[1, j, 2] - 1), j], na.rm = TRUE) else gripe[6, j, 2] <- 0
        if (gripe[2, j, 2] < semanas) gripe[7, j, 2] <- sum(datos[(gripe[2, j, 2] + 1):semanas, j], na.rm = TRUE) else gripe[7, j, 2] <- 0

        gripe[1, j, 3] <- datos.duracion.centrado[4, j]
        gripe[2, j, 3] <- datos.duracion.centrado[5, j]
        gripe[3, j, 3] <- datos.duracion.centrado[3, j]
        gripe[4, j, 3] <- sum(datos[, j], na.rm = TRUE)
        gripe[5, j, 3] <- datos.duracion.centrado[2, j]
        if (gripe[1, j, 3] > 1) gripe[6, j, 3] <- sum(datos[1:(gripe[1, j, 3] - 1), j], na.rm = TRUE) else gripe[6, j, 3] <- 0
        if (gripe[2, j, 3] < semanas) gripe[7, j, 3] <- sum(datos[(gripe[2, j, 3] + 1):semanas, j], na.rm = TRUE) else gripe[7, j, 3] <- 0
      }

      # Indice de estado temporal. Si es un 1 me dice que estamos en epoca pretemporada,
      # si pone un 2 indica que estamos en temporada gripal. Si pone un 3 indica que
      # estamos en posttemporada.

      indices.temporada <- array(dim = c(semanas, anios, 3), dimnames = list(
        "weeks" = rownames(datos),
        "seasons" = names(datos),
        "type" = c("real epidemic", "mean length epidemic", "centered length epidemic")
      ))
      for (j in 1:anios) {
        indices.temporada[-((datos.duracion.real[4, j]):semanas), j, 1] <- 1
        indices.temporada[(datos.duracion.real[4, j]):(datos.duracion.real[5, j]), j, 1] <- 2
        indices.temporada[-(1:(datos.duracion.real[5, j])), j, 1] <- 3

        indices.temporada[-((datos.duracion.media[4, j]):semanas), j, 2] <- 1
        indices.temporada[(datos.duracion.media[4, j]):(datos.duracion.media[5, j]), j, 2] <- 2
        indices.temporada[-(1:(datos.duracion.media[5, j])), j, 2] <- 3

        indices.temporada[-((datos.duracion.centrado[4, j]):semanas), j, 3] <- 1
        indices.temporada[(datos.duracion.centrado[4, j]):(datos.duracion.centrado[5, j]), j, 3] <- 2
        indices.temporada[-(1:(datos.duracion.centrado[5, j])), j, 3] <- 3
      }


      # Grafico del esquema de las temporadas gripales para su union

      longitud.esquema <- semanas + maxFixNA(datos.duracion.centrado[4, ]) - minFixNA(datos.duracion.centrado[4, ])
      inicio.epidemia.esquema <- maxFixNA(datos.duracion.centrado[4, ])

      esquema.temporadas <- array(dim = c(longitud.esquema, anios + 2, 3), dimnames = list(
        "dummy weeks" = as.character(1:longitud.esquema),
        "seasons" = c(names(datos), "mean season week", "mean season index"),
        "type" = c("absolute week", "relative week", "values")
      ))

      for (j in 1:anios) {
        diferencia.anual <- inicio.epidemia.esquema - datos.duracion.centrado[4, j]
        for (i in 1:semanas) {
          esquema.temporadas[i + diferencia.anual, j, 1] <- i
          esquema.temporadas[i + diferencia.anual, j, 2] <- semana.absoluta(i, semana.inicio)
          esquema.temporadas[i + diferencia.anual, j, 3] <- datos[i, j]
        }
      }

      diferencia.global <- inicio.epidemia.esquema - inicio.centrado
      for (i in 1:semanas) {
        if ((i + diferencia.global) >= 1 && (i + diferencia.global) <= longitud.esquema) {
          esquema.temporadas[i + diferencia.global, anios + 1, 1] <- i
          esquema.temporadas[i + diferencia.global, anios + 1, 2] <- semana.absoluta(i, semana.inicio)
          esquema.temporadas[i + diferencia.global, anios + 1, 3] <- i
        }
      }

      esquema.temporadas[, anios + 2, ] <- 3
      esquema.temporadas[1:(diferencia.global + inicio.medio - 1), anios + 2, ] <- 1
      esquema.temporadas[(diferencia.global + inicio.medio):(diferencia.global + inicio.medio + duracion.media - 1), anios + 2, ] <- 2

      ## Temporadas moviles

      temporadas.moviles <- esquema.temporadas[, c(1:anios), 3]

      ## Limites de la temporada

      # Limites relativos

      ## En ttotal reordenamos la gripe para q todas las temporadas comiencen la semana "estinicio" (es decir, quitamos informacion
      ## por delante y por detras de esquema.temporada[,,3] para que queden 35 semanas (las que hay).

      temporadas.moviles.recortada <- array(dim = c(semanas, anios), dimnames = list(
        "dummy weeks" = as.character(1:semanas),
        "seasons" = names(datos)
      ))

      ## Temporada gripal comienza "estinicio" y termina en "estinicio+temporada-1"

      for (j in 1:anios) {
        for (i in 1:semanas) {
          if ((i + diferencia.global) >= 1 && (i + diferencia.global) <= longitud.esquema) {
            temporadas.moviles.recortada[i, j] <- temporadas.moviles[i + diferencia.global, j]
          } else {
            temporadas.moviles.recortada[i, j] <- NA
          }
        }
      }

      ## Dibujamos la curva epidemica tipo

      # Importante: ?Quitamos los ceros?
      iy <- is.na(temporadas.moviles.recortada)
      tempmoviles.recortada.noceros <- temporadas.moviles.recortada
      tempmoviles.recortada.noceros[iy] <- NA
      curva.tipo <- t(apply(tempmoviles.recortada.noceros, 1, iconfianza, nivel = i.level.curve, tipo = i.type.curve, ic = TRUE, tipo.boot = i.type.boot, iteraciones.boot = i.iter.boot, colas = 2, use.t = i.use.t))

      ## Seleccionamos los periodos pre, epidemia, y post

      ## PRE y POST-TEMPORADA GRIPAL

      ## Como no se registra mas q de la semana 40 a la 20, tenemos q muchas de las semanas tienen tasa 0, eliminamos esas semanas,
      ## ya q podrian llevar a una infraestimacion de la tasa base fuera de temporada

      pre.datos <- as.vector(as.matrix(extraer.datos.pre.epi(optimo)))
      post.datos <- as.vector(as.matrix(extraer.datos.post.epi(optimo)))
      epi.datos <- as.vector(as.matrix(extraer.datos.epi(optimo)))
      epi.datos.2 <- as.vector(as.matrix(apply(datos, 2, maxnvalores, n.max = n.max)))

      pre.post.datos <- rbind(pre.datos, post.datos)

      # IC de la linea basica de pre y post temporada

      # por defecto estaba la geometrica
      pre.d <- pre.datos[!is.na(pre.datos)]
      post.d <- post.datos[!is.na(post.datos)]
      epi.d <- epi.datos[!is.na(epi.datos)]
      epi.d.2 <- epi.datos.2[!is.na(epi.datos.2)]

      pre.i <- iconfianza(datos = pre.d, nivel = i.level.threshold, tipo = i.type.threshold, ic = TRUE, tipo.boot = i.type.boot, iteraciones.boot = i.iter.boot, colas = i.tails.threshold, use.t = i.use.t)
      post.i <- iconfianza(datos = post.d, nivel = i.level.threshold, tipo = i.type.threshold, ic = TRUE, tipo.boot = i.type.boot, iteraciones.boot = i.iter.boot, colas = i.tails.threshold, use.t = i.use.t)
      epi.intervalos <- numeric()
      for (niv in i.level.intensity) {
        epi.intervalos <- rbind(epi.intervalos, c(niv, iconfianza(datos = epi.d, nivel = niv, tipo = i.type.intensity, ic = TRUE, tipo.boot = i.type.boot, iteraciones.boot = i.iter.boot, colas = i.tails.intensity, use.t = i.use.t)))
      }
      epi.intervalos.2 <- numeric()
      for (niv in i.level.intensity) {
        epi.intervalos.2 <- rbind(epi.intervalos.2, c(niv, iconfianza(datos = epi.d.2, nivel = niv, tipo = i.type.intensity, ic = TRUE, tipo.boot = i.type.boot, iteraciones.boot = i.iter.boot, colas = i.tails.intensity, use.t = i.use.t)))
      }

      pre.post.intervalos <- rbind(pre.i, post.i)

      memmodel.output <- list(
        pre.post.intervals = pre.post.intervalos,
        ci.length = ic.duracion,
        ci.percent = ic.porcentaje,
        ci.start = ic.inicio,
        mean.length = duracion.media,
        mean.start = inicio.medio,
        centered.length = duracion.centrado,
        centered.start = inicio.centrado,
        moving.epidemics = temporadas.moviles.recortada,
        epi.intervals = epi.intervalos,
        epi.intervals.full = epi.intervalos.2,
        typ.curve = curva.tipo,
        n.max = n.max,
        n.seasons = anios,
        n.weeks = semanas,
        data = datos,
        start.week = semana.inicio,
        epi.data = epi.datos,
        epi.data.nona = epi.d,
        epi.data.full = epi.datos.2,
        epi.data.nona.full = epi.d.2,
        optimum = optimo,
        real.length.data = datos.duracion.real,
        seasons.data = gripe,
        season.indexes = indices.temporada,
        season.scheme = esquema.temporadas,
        seasons.moving = temporadas.moviles,
        pre.post.data = pre.post.datos,
        pre.data.nona = pre.d,
        post.data.nona = post.d,
        epidemic.thresholds = as.numeric(pre.post.intervalos[, 3]),
        intensity.thresholds = as.numeric(epi.intervalos[, 4]),
        param.data = i.data,
        param.seasons = i.seasons,
        param.type.threshold = i.type.threshold,
        param.level.threshold = i.level.threshold,
        param.tails.threshold = i.tails.threshold,
        param.type.intensity = i.type.intensity,
        param.level.intensity = i.level.intensity,
        param.tails.intensity = i.tails.intensity,
        param.type.curve = i.type.curve,
        param.level.curve = i.level.curve,
        param.type.other = i.type.other,
        param.level.other = i.level.other,
        param.method = i.method,
        param.param = i.param,
        param.centering = i.centering,
        param.n.max = i.n.max,
        param.type.boot = i.type.boot,
        param.iter.boot = i.iter.boot,
        param.mem.info = i.mem.info
      )

      memmodel.output$call <- match.call()
      class(memmodel.output) <- "mem"
    }
  }
  return(memmodel.output)
}

#' @export
print.mem <- function(x, ...) {
  threshold <- as.data.frame(round(t(x$pre.post.intervals[1:2, 3]), 2))
  colnames(threshold) <- c("Pre", "Post")
  rownames(threshold) <- "Threshold"
  values <- as.data.frame(round(x$epi.intervals[, 4], 2))
  colnames(values) <- "Threshold"
  rownames(values) <- paste(c("Medium", "High", "Very high"), " (", round(x$epi.intervals[, 1] * 100, 1), "%)", sep = "")
  cat("Call:\n")
  print(x$call)
  cat("\nEpidemic threshold:\n")
  print(threshold)
  cat("\nIntensity thresholds:\n")
  print(values)
}

#' @export
summary.mem <- function(object, ...) {
  threshold <- as.data.frame(round(t(object$pre.post.intervals[1:2, 3]), 2))
  colnames(threshold) <- c("Pre", "Post")
  rownames(threshold) <- "Threshold"
  values <- as.data.frame(round(object$epi.intervals[, 4], 2))
  colnames(values) <- "Threshold"
  rownames(values) <- paste(c("Medium", "High", "Very high"), " (", round(object$epi.intervals[, 1] * 100, 1), "%)", sep = "")
  cat("Call:\n", sep = "")
  print(object$call)
  cat("\nParameters:\n", sep = "")
  cat("\t- General:\n", sep = "")
  cat("\t\t+ Number of seasons restriction: ", if (object$param.seasons == -1 | is.na(object$param.seasons)) "Unrestricted (maximum)" else paste("Restricted to ", object$param.seasons, sep = ""), "\n", sep = "")
  cat("\t\t+ Number of seasons used: ", object$n.seasons, "\n", sep = "")
  cat("\t\t+ Seasons used: ", paste(names(object$data), collapse = ", "), "\n", sep = "")
  cat("\t\t+ Number of weeks: ", object$n.weeks, "\n", sep = "")
  cat("\t- Confidence intervals:\n", sep = "")
  cat("\t\t+ Epidemic threshold: ", output.ci(object$param.type.threshold, object$param.level.threshold, object$param.tails.threshold), "\n", sep = "")
  cat("\t\t+ Intensity: ", output.ci(object$param.type.intensity, object$param.level.intensity, object$param.tails.intensity), "\n", sep = "")
  cat("\t\t+ Curve: ", output.ci(object$param.type.curve, object$param.level.curve, 2), "\n", sep = "")
  cat("\t\t+ Others: ", output.ci(object$param.type.other, object$param.level.other, 2), "\n", sep = "")
  cat("\t- Epidemic timing calculation:\n", sep = "")
  cat("\t\t+ Method: ", object$param.method, "\n", sep = "")
  cat("\t\t+ Parameter: ", object$param.param, "\n", sep = "")
  cat("\t- Epidemic threshold calculation:\n", sep = "")
  cat("\t\t+ Pre-epidemic values: ", if (is.na(object$param.n.max)) {
    paste("Optimized: ", object$n.max, sep = "")
  } else {
    if (object$param.n.max == -1) paste("Optimized: ", object$n.max, sep = "") else object$n.max
  }, "\n", sep = "")
  cat("\t\t+ Tails of CI: ", object$param.tails.threshold, "\n", sep = "")
  cat("\t- Intensity thresholds calculation:\n", sep = "")
  cat("\t\t+ Number of values: ", if (is.na(object$param.n.max)) {
    paste("Optimized: ", object$n.max, sep = "")
  } else {
    if (object$param.n.max == -1) paste("Optimized: ", object$n.max, sep = "") else object$n.max
  }, "\n", sep = "")
  cat("\t\t+ Tails of CI: ", object$param.tails.intensity, "\n", sep = "")
  cat("\t\t+ Levels of CI: ", paste0(paste0(c("Medium", "High", "Very high"), ": ", round(object$epi.intervals[, 1] * 100, 1), "%"), collapse = ", "), "\n")
  cat("\t- Bootstrap (if used):\n", sep = "")
  cat("\t\t+ Technique: ", if (is.na(object$param.type.boot)) "-" else object$param.type.boot, "\n", sep = "")
  cat("\t\t+ Bootstrap samples: ", if (is.na(object$param.iter.boot)) "-" else object$param.iter.boot, "\n", sep = "")
  cat("\nEpidemic description:\n", sep = "")
  cat("\t- Typical influenza epidemics starts at week ", round(object$ci.start[2, 2], 2), ". ", 100 * object$param.level.other, "% CI: [", round(object$ci.start[2, 1], 2), ",", round(object$ci.start[2, 3], 2), "]\n", sep = "")
  cat("\t- Typical influenza season lasts ", round(object$ci.length[1, 2], 2), " weeks. ", 100 * object$param.level.other, "% CI: [", round(object$ci.length[1, 1], 2), ",", round(object$ci.length[1, 3], 2), "]\n", sep = "")
  cat("\t- This optimal ", object$mean.length, " weeks influenza season includes the ", round(object$ci.percent[2], 2), "% of the total sum of rates\n\n", sep = "")
  cat("\nEpidemic threshold:\n", sep = "")
  print(threshold)
  cat("\n\nIntensity thresholds:\n", sep = "")
  print(values)
}

#' @export
plot.mem <- function(x, ...) {
  opar <- par(mfrow = c(1, 2), mar = c(4, 3, 1, 2) + 0.1, mgp = c(3, 0.5, 0), xpd = TRUE)

  # Graph 1
  semanas <- dim(x$data)[1]
  anios <- dim(x$data)[2]
  names.seasons <- sub("^.*\\(([^\\)]*)\\)$", "\\1", names(x$data), perl = TRUE)
  datos.graf <- x$moving.epidemics
  colnames(datos.graf) <- names(x$data)
  lab.graf <- (1:semanas) + x$ci.start[2, 2] - x$ci.start[1, 2]
  lab.graf[lab.graf > 52] <- (lab.graf - 52)[lab.graf > 52]
  lab.graf[lab.graf < 1] <- (lab.graf + 52)[lab.graf < 1]
  tipos <- rep(1, anios)
  anchos <- rep(2, anios)
  pal <- colorRampPalette(brewer.pal(4, "Spectral"))
  colores <- pal(anios)
  otick <- optimal.tickmarks(0, maxFixNA(datos.graf), 10)
  range.y <- c(otick$range[1], otick$range[2] + otick$by / 2)
  matplot(1:semanas,
    datos.graf,
    type = "l",
    sub = paste("Weekly incidence rates of the seasons matching their relative position in the model."),
    lty = tipos,
    lwd = anchos,
    col = colores,
    xlim = c(1, semanas),
    xlab = "",
    ylab = "",
    axes = FALSE,
    font.main = 2,
    font.sub = 1,
    ylim = range.y
  )
  # Ejes
  axis(1, at = seq(1, semanas, 1), labels = FALSE, cex.axis = 0.7, col.axis = "#404040", col = "#C0C0C0")
  axis(1,
    at = seq(1, semanas, 2), tick = FALSE,
    labels = as.character(lab.graf)[seq(1, semanas, 2)], cex.axis = 0.7, col.axis = "#404040", col = "#C0C0C0"
  )
  axis(1,
    at = seq(2, semanas, 2), tick = FALSE,
    labels = as.character(lab.graf)[seq(2, semanas, 2)], cex.axis = 0.7, line = 0.60, col.axis = "#404040", col = "#C0C0C0"
  )
  mtext(1, text = "Week", line = 2, cex = 0.8, col = "#000040")
  axis(2, at = otick$tickmarks, lwd = 1, cex.axis = 0.6, col.axis = "#404040", col = "#C0C0C0")
  mtext(2, text = "Weekly rate", line = 1.3, cex = 0.8, col = "#000040")
  if (x$param.mem.info) mtext(4, text = paste("mem R library - Jose E. Lozano - https://github.com/lozalojo/mem", sep = ""), line = 0.75, cex = 0.6, col = "#404040")
  i.temporada <- x$ci.start[1, 2]
  f.temporada <- x$ci.start[1, 2] + x$mean.length - 1
  lines(x = rep(i.temporada - 0.5, 2), y = range.y, col = "#FF0000", lty = 2, lwd = 2)
  lines(x = rep(f.temporada + 0.5, 2), y = range.y, col = "#40FF40", lty = 2, lwd = 2)
  lines(x = c(1, semanas), y = rep(x$epidemic.thresholds[1], 2), col = "#8c6bb1", lty = 2, lwd = 2)
  ya <- otick$range[2]
  if ((i.temporada - 1) <= (semanas - f.temporada)) xa <- f.temporada + 1 else xa <- 1
  legend(
    x = xa, y = ya, inset = c(0, 0), xjust = 0, seg.len = 1,
    legend = names.seasons,
    bty = "n",
    lty = tipos,
    lwd = anchos,
    col = colores,
    cex = 0.75,
    x.intersp = 0.5,
    y.intersp = 0.6,
    text.col = "#000000",
    ncol = 1
  )

  # Graph 2
  memsurveillance(
    i.current = data.frame(rates = x$typ.curve[, 2], row.names = rownames(x$data)),
    i.epidemic.thresholds = x$epidemic.thresholds,
    i.intensity.thresholds = x$intensity.thresholds,
    i.mean.length = x$mean.length,
    i.force.length = TRUE,
    i.graph.file = FALSE,
    i.week.report = NA,
    i.equal = FALSE,
    i.pos.epidemic = TRUE,
    i.no.epidemic = FALSE,
    i.no.intensity = FALSE,
    i.epidemic.start = x$ci.start[2, 2],
    i.range.x = as.numeric(c(rownames(x$data)[1], rownames(x$data)[semanas])),
    i.range.x.53 = FALSE,
    i.range.y = NA,
    i.no.labels = FALSE,
    i.start.end.marks = TRUE
  )

  par(opar)
}
