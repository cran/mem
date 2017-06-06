# The Moving Epidemics Method R Package

## Overview

This is the R package of the Moving Epidemics Method

## Installation

The package can be installed from the official R repositories (*CRAN*) using the built-in install function:

```
# install the mem CRAN version
install.packages("mem")
```

To install the lastest development version of *mem*, it is recommended to install it from the sources at github.


```
# in case you dont have devtools installed, install it
install.packages(devtools)

# install the new package from github
devtools::install_github("lozalojo/mem")
```

## Usage

```
# load the library
library("mem")

# run the help
help("mem")
```

## References

Vega T., Lozano J.E. (2004) Modelling influenza epidemic - can we detect the beginning 
and predict the intensity and duration? International Congress Series 1263 (2004) 
281-283.

Vega T., Lozano J.E. (2012) Influenza surveillance in Europe: establishing epidemic 
thresholds by the Moving Epidemic Method. Influenza and Other Respiratory Viruses, 
DOI:10.1111/j.1750-2659.2012.00422.x.
