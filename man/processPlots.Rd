% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/processPlots.R
\name{processPlots}
\alias{processPlots}
\title{Full process plots for mem}
\usage{
processPlots(i.flu, i.output = ".", i.prefix = "")
}
\arguments{
\item{i.flu}{Object of class flu.}

\item{i.output}{Output directory.}

\item{i.prefix}{Prefix for all files to be output.}
}
\value{
\code{processPlots} prints a set of graphs.
}
\description{
Function \code{processPlots} creates graphs of all mem process
}
\details{
Create plots related to the process of calculating MEM indicators to an
output directory, showing the MAP curves and the slope of the MAP curve
and how the timing is calculated.
}
\examples{
\donttest{
# Castilla y Leon Influenza Rates data
data(flucyl)
# Graphs
epi <- memmodel(flucyl)
# uncomment to execute
# processPlots(epi)
}

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
