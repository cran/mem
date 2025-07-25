% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/memgoodness.R
\name{memgoodness}
\alias{memgoodness}
\title{Goodness of fit of the mem}
\usage{
memgoodness(
  i.data,
  i.seasons = 10,
  i.type.threshold = 5,
  i.level.threshold = 0.95,
  i.tails.threshold = 1,
  i.type.intensity = 6,
  i.level.intensity = c(0.4, 0.9, 0.975),
  i.tails.intensity = 1,
  i.type.curve = 2,
  i.level.curve = 0.95,
  i.type.other = 2,
  i.level.other = 0.95,
  i.method = 2,
  i.param = 2.8,
  i.n.max = -1,
  i.type.boot = "norm",
  i.iter.boot = 10000,
  i.calculation.method = "default",
  i.goodness.method = "cross",
  i.goodness.threshold = NA,
  i.goodness.intensity = NA,
  i.detection.values = seq(1, 5, 0.1),
  i.weeks.above = 1,
  i.output = ".",
  i.graph = FALSE,
  i.prefix = "",
  i.min.seasons = 6,
  i.labels.axis = c("Week", "Weekly rate"),
  i.labels.periods = c("Pre", "Epidemic", "Post"),
  i.labels.intensities = c("Epidemic thr", "Medium thr", "High thr", "Very high thr"),
  i.labels.details = c("algorithm", "threshold", "Method used",
    "weeks above/below the threshold", "week(s) above the threshold", "Sensitivity",
    "Specificity")
)
}
\arguments{
\item{i.data}{Data frame of input data.}

\item{i.seasons}{Maximum number of seasons to use.}

\item{i.type.threshold}{Type of confidence interval to calculate the threshold.}

\item{i.level.threshold}{Level of confidence interval to calculate the threshold.}

\item{i.tails.threshold}{Tails for the confidence interval to calculate the threshold.}

\item{i.type.intensity}{Type of confidence interval to calculate the intensity thresholds.}

\item{i.level.intensity}{Levels of confidence interval to calculate the intensity thresholds.}

\item{i.tails.intensity}{Tails for the confidence interval to calculate the threshold.}

\item{i.type.curve}{Type of confidence interval to calculate the modelled curve.}

\item{i.level.curve}{Level of confidence interval to calculate the modelled curve.}

\item{i.type.other}{Type of confidence interval to calculate length, start and percentages.}

\item{i.level.other}{Level of confidence interval to calculate length, start and percentages.}

\item{i.method}{Method to calculate the optimal timing of the epidemic.}

\item{i.param}{Parameter to calculate the optimal timing of the epidemic.}

\item{i.n.max}{Number of pre-epidemic values used to calculate the threshold.}

\item{i.type.boot}{Type of bootstrap technique.}

\item{i.iter.boot}{Number of bootstrap iterations.}

\item{i.calculation.method}{method of determining true/false positives and true/false negatives.}

\item{i.goodness.method}{method to calculate goodness.}

\item{i.goodness.threshold}{pre/post epidemic thresholds for threshold goodness method.}

\item{i.goodness.intensity}{intensitie thresholds (medium, high, very high) for threshold goodness method.}

\item{i.detection.values}{values to use in the i.param value of \code{memtiming}.}

\item{i.weeks.above}{number of weeks over the threshold to give the alert.}

\item{i.output}{output directory for graphs.}

\item{i.graph}{whether the graphs must be written or not.}

\item{i.prefix}{prefix used for naming graphs.}

\item{i.min.seasons}{minimum number of seasons to perform goodness, default=6.}

\item{i.labels.axis}{different labels used by output graphs}

\item{i.labels.periods}{different labels used by output graphs}

\item{i.labels.intensities}{different labels used by output graphs}

\item{i.labels.details}{different labels used by output graphs}
}
\value{
\code{memgoodness} returns a list.
A list containing at least the following components:
\describe{
  \item{validity.data}{data for each value analysed.}
  \item{results}{Total weeks, non-missing weeks, true positives, false positives
true negatives, false negatives, sensitivity, specificity .}
  \item{peaks}{distribution of the levels of intensity of the peaks.}
  \item{peaks.data}{Peak value, week of the peak value, epidemic and intensity thresholds and intensity level of each season analysed.}
}
}
\description{
Function \code{memgoodness} calculates different indicators related to the goodness of the MEM
for detecting the epidemics, using data from the model and using all data in the original dataset.
}
\details{
The indicators calculated are sensitivity, specificity, positive predictive value, negative
predictive value, percent agreement and the Matthews correlation coefficient.

How goodness is calculated:

MEM calculates goodness indicators in an iterative process. In each iteration:

\enumerate{
\item For one particular season the timing is calculated to determine which weeks are inside
the pre, post and epidemic periods. This is used as the real data: a real positive outcome
(epidemic weeks) and a real negative outcome (pre and post-epidemic weeks).
\item With a set of seasons, pre-epidemic threshold is calculated. This threshold is compared
with values from the season selected in the first step and see if values are above or below the
threshold. This is used as the observed data: an observed positive outcome (week value above
the threshold), and observed negative outcome (week value below the threshold).
\item Each week has a real and an observed outcome, so it can be classified in:
\describe{
  \item{True positives (TP)}{real positive, observed positive: values of the epidemic period above the threshold.}
  \item{True negatives (TN)}{real negative, observed negative: values of the non-epidemic period below the threshold.}
  \item{False positives (FP)}{real negative, observed positive: values of the non-epidemic period above the threshold.}
  \item{False negatives (FN)}{real positive, observed negative: values of the epidemic period below the threshold.}
}
\item The process is repeated for each season in the dataset (each iteration a different value
until all seasons have been processed).
\item All TP, TN, FP and FN are pooled together and sensitivity, specificity, positive predictive value,
negative predictive value, percent agreement and the Matthews correlation coefficient are calculated.
}

There are two ways of deciding the set of seasons used to calculate the pre-epidemic threshold in each
iteration and it is determined by the \code{i.goodness.method}.

\describe{
  \item{cross}{For each value, the surrounding seasons (after or before the current value) are selected up
to the number of Max. seasons (parameter of the Model box). To calculate the thresholds for season 2010/2011,
data from 2005/2006 to 2009/2010 and from 2011/20012 to 2015/2016 will be taken.}
  \item{sequential}{Only preceding seasons are used (before the current value) up to the number of Max. seasons.
To calculate the thresholds for season 2010/2011, data from 2000/2001 to 2009/2010 are taken.}
  \item{threshold}{The pre/post epidemic and intensity thresholds are fixed values for all the seasons and
are compared with the epidemic as determined by MEM algorithm.}
}

The \code{i.calculation.method} is used to determine when the alert based on the epidemic threshold.
The "default" method sets all values above the threshold as epidemic, and all the values below as non-epidemic.
Pre-epidemic threshold is used for values before the peak, and post-epidemic threshold for values after
the peak.
The "alternative" method sets an epidemic start and epidemic end, all the values in between are epidemic values.
The epidemic start is when \code{i.weeks.above} (default=1) consecutive weeks are above the pre-epidemic threshold.
The epidemic end is the first week below the post-epidemic threshold after the epidemic start.
Note that if no post-epidemic threshold is provided, the pre-epidemic value is used instead.
}
\examples{
# Castilla y Leon Influenza Rates data
data(flucyl)
# Goodness of fit
epi.good <- memgoodness(flucyl, i.detection.values = seq(2.6, 2.8, 0.1))
epi.good$results
epi.good$peaks
}
\references{
Vega T, Lozano JE, Ortiz de Lejarazu R, Gutierrez Perez M. Modelling influenza epidemic - can we
detect the beginning and predict the intensity and duration? Int Congr Ser. 2004 Jun;1263:281-3.

Vega T, Lozano JE, Meerhoff T, Snacken R, Mott J, Ortiz de Lejarazu R, et al. Influenza surveillance
in Europe: establishing epidemic thresholds by the moving epidemic method. Influenza Other Respir
Viruses. 2013 Jul;7(4):546-58. DOI:10.1111/j.1750-2659.2012.00422.x.

Vega T, Lozano JE, Meerhoff T, Snacken R, Beaute J, Jorgensen P, et al. Influenza surveillance in
Europe: comparing intensity levels calculated using the moving epidemic method. Influenza Other
Respir Viruses. 2015 Sep;9(5):234-46. DOI:10.1111/irv.12330.

Lozano JE. lozalojo/mem: Second release of the MEM R library. Zenodo [Internet]. [cited 2017 Feb 1];
Available from: \url{https://zenodo.org/record/165983}. DOI:10.5281/zenodo.165983
}
\author{
Jose E. Lozano \email{lozalojo@gmail.com}
}
\keyword{influenza}
