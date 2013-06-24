\name{mem-package}
\alias{mem-package}
\alias{mem}
\docType{package}
\title{
Moving Epidemics Method R Package
}
\description{
This package creates the model described in the \emph{Moving Epidemics Method} (MEM), 
used to monitor influenza activity during the seasonal surveillance.
}
\details{
\tabular{ll}{
Package: \tab mem\cr
Type: \tab Package\cr
Title: \tab Moving Epidemics Method R Package.\cr
Version: \tab 1.3\cr
Date: \tab 2013-06-24\cr
Author: \tab Jose E. Lozano Alonso <lozalojo@jcyl.es>\cr
Maintainer: \tab Jose E. Lozano Alonso <lozalojo@jcyl.es>\cr
Depends: \tab R (>= 3.00.1)\cr
Description: \tab Modelization of influenza epidemics in order to monitor future 
activity.\cr
License: \tab GPL (>= 2)\cr
}
Functions to calculate the optimal timing of the epidemic and a threshold to give an 
early alert of the upcoming epidemic.
}
\author{
Jose E. Lozano Alonso <lozalojo@jcyl.es>.
}
\references{
Vega T., Lozano J.E. (2004) Modelling influenza epidemic - can we detect the beginning 
and predict the intensity and duration? International Congress Series 1263 (2004) 
281-283.\cr
Vega T., Lozano J.E. (2012) Influenza surveillance in Europe: establishing epidemic 
thresholds by the Moving Epidemic Method. Influenza and Other Respiratory Viruses, 
DOI:10.1111/j.1750-2659.2012.00422.x.
}
\keyword{ package }
\examples{
require(mem)
## Castilla y Leon Influenza Rates data 
data(flucyl)
## Optimal timing of an epidemic
tim<-epitiming(flucyl[1])
print(tim)
summary(tim)
plot(tim)
## Threshold calculation
epi<-epimem(flucyl)
print(epi)
summary(epi)
plot(epi)
## Intensity thresholds
intensity<-memintensity(flucyl)
intensity
## Trend parameters
trend<-memtrend(flucyl)
trend
}
