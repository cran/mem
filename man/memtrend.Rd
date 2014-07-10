\name{memtrend}
\alias{memtrend}
\title{
Methods for influenza trend calculation
}
\description{
Function \code{memtrend} is used to calculate the two parameters for defining the 
current influenza trend.\cr 
This method is based on the Moving Epidemics Method (MEM) used to monitor influenza 
activity in a weekly surveillance system.
}
\usage{
memtrend(i.data, i.seasons = 10)
}
\arguments{
  \item{i.data}{
Data frame of input data.
}
  \item{i.seasons}{
Maximum number of seasons to use.
}
}
\details{
Input data is a data frame containing rates that represent historical influenza surveillance 
data. It can start and end at any given week (tipically at week 40th), and rates can be 
expressed as per 100,000 inhabitants (or per consultations, if population is not 
available) or any other scale.\cr
The \code{i.seasons} parameter indicates how many seasons are used for calculating 
thresholds. A value of -1 indicates the program to use as many as possible. If there 
are less than this parameter, the program used all seasons avalaible.\cr
There are three different states for trend, to determine the state, the current rate 
and the difference of the current and last weekly rate are needed:\cr
\tabular{rlll}{
\tab \code{2} \tab Ascending - When the weekly rate is above the epidemic threshold and 
the difference of the current and last weekly rate is higher than Delta OR this is the 
first time the rate is above the epidemic threshold.\cr
\tab \code{3} \tab Descending - When the weekly rate is above the epidemic threshold 
and the difference of the current and last weekly rate is lower than Eta OR this is the 
first time the rate is below the epidemic threshold after having been above it.\cr
\tab \code{1} \tab Stable - Otherwise.\cr
}
}
\value{
\code{memtrend} returns a list with two objects, the first one is the parameter used in 
the calculations (\code{param.seasons}) and the second one (\code{trend.thresholds}) is 
a matrix 1x2 with the Ascending (Delta) and Descending parameters (Eta).
\tabular{rlll}{
\tab \code{1} \tab Delta - Ascending parameter.\cr
\tab \code{2} \tab Eta - Descending parameter.\cr
}
}
\references{
Vega T., Lozano J.E. (2004) Modelling influenza epidemic - can we detect the beginning 
and predict the intensity and duration? International Congress Series 1263 (2004) 
281-283.\cr
Vega T., Lozano J.E. (2012) Influenza surveillance in Europe: establishing epidemic 
thresholds by the Moving Epidemic Method. Influenza and Other Respiratory Viruses, 
DOI:10.1111/j.1750-2659.2012.00422.x.
}
\author{
Jose E. Lozano Alonso <lozalojo@jcyl.es>. 
}
\examples{
## Castilla y Leon Influenza Rates data 
data(flucyl)
## Finds the timing of the first season: 2001/2002
trend<-memtrend(flucyl)
trend
}
\keyword{ influenza }
