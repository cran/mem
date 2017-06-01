% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/transformdata.R
\name{transformdata}
\alias{transformdata}
\title{Data transformation}
\usage{
transformdata(i.data, i.range.x = NA, i.name = "rates",
  i.max.na.per = 100)
}
\arguments{
\item{i.data}{Data frame of input data.}

\item{i.range.x}{First and last surveillance week.}

\item{i.name}{Name of the column to transform.}

\item{i.max.na.per}{maximum percentage of na's in a season allowable, otherwise, the season is removed}
}
\value{
\code{transformdata} returns a data.frame where each column has a different season and
rownames are the name of the epidemiological week.
}
\description{
Function \code{transformdata} transforms data from year,week,rate to week,rate1,...,rateN
suitable to use with mem.
}
\details{
Yet to be written
}
\examples{
# Castilla y Leon Influenza Rates data
data(flucylraw)
# Transform data
newdata<-transformdata(flucylraw, i.range.x=c(40,20))$data
epi<-memmodel(newdata)
print(epi)
summary(epi)
plot(epi)

}
\references{
Vega Alonso, Tomas, Jose E Lozano Alonso, Raul Ortiz de Lejarazu, and Marisol Gutierrez Perez. 2004.
Modelling Influenza Epidemic: Can We Detect the Beginning and Predict the Intensity and Duration?
International Congress Series, Options for the Control of Influenza V. Proceedings of the International
Conference on Options for the Control of Influenza V, 1263 (June): 281-83. doi:10.1016/j.ics.2004.02.121.\cr
Vega, Tomas, Jose Eugenio Lozano, Tamara Meerhoff, Rene Snacken, Joshua Mott, Raul Ortiz de Lejarazu, and
Baltazar Nunes. 2013. Influenza Surveillance in Europe: Establishing Epidemic Thresholds by the Moving
Epidemic Method. Influenza and Other Respiratory Viruses 7 (4): 546-58. doi:10.1111/j.1750-2659.2012.00422.x.\cr
Vega, Tomas, Jose E. Lozano, Tamara Meerhoff, Rene Snacken, Julien Beaute, Pernille Jorgensen, Raul Ortiz
de Lejarazu, et al. 2015. Influenza Surveillance in Europe: Comparing Intensity Levels Calculated Using
the Moving Epidemic Method. Influenza and Other Respiratory Viruses 9 (5): 234-46. doi:10.1111/irv.12330.
}
\author{
Jose E. Lozano \email{lozalojo@gmail.com}
}
\keyword{influenza}