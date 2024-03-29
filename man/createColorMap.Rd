% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/createColorMap.R
\name{createColorMap}
\alias{createColorMap}
\title{Creates a color scheme based on a named vector}
\usage{
createColorMap(namedList, ...)
}
\arguments{
\item{namedList}{A vector containing named strings of format: c("Taxa" = "Group", ...)}

\item{...}{Optional arguments to be passed that specify what color scheme to be used.}

\item{colorScheme}{name for any color scheme available in the RColorBrewer package. Any of the following:}

\item{colors}{a vector containing named strings matching each group to a color of format: c("Trees" = "green", "Shrubs" = "#000000", "Grasses" = "#000", ...)}

\item{greyscale}{a boolean value that sets all colors for all groups to black. This is recommended if it is not desired to subdivide pollen into specific groups and when more than 10 pollen taxa are used.}

\item{colorblind}{a boolean value that determines whether the color map that maps each taxa to a color should be colorblind friendly.}
}
\value{
A named vector matching each taxa to a color based on it's group affiliation.
}
\description{
This function takes a named vector such as created by assignGroupToTaxa and will choose an appropriate color scheme from the RColorBrewer package. Optionally, a specific colour for each group variable can be defined or a specific ColorScheme will be chosen. Remind that the maximum amount of supported colours of a color palette in RColorBrewer is 12. A higher number of group variables will result in a greyscale plot which is also recommended for readability.
}
\examples{
namedList <- c("Pinus" = "Trees", "Betula" = "Shrubs", "Poaceae" = "Grasses", "Picea" = "Trees")
createColorMap(namedList)

#>     Pinus    Betula   Poaceae     Picea      Artemisia
#>    "#7FC97F" "#BEAED4" "#FDC086" "#7FC97F"   "#FFFF99"

createColorMap(namedList, colorScheme = "Accent")

#>     Pinus    Betula   Poaceae     Picea      Artemisia
#>  "#7FC97F" "#BEAED4" "#FDC086"   "#7FC97F"   "#FFFF99"

createColorMap(namedList, colors = c("Trees" = "green", "Shrubs" = "#000000", "Grasses" = "#000"))

#>    Pinus    Betula     Poaceae     Picea     Artemisia
#>    "green" "#000000"    "#000"   "green"     "red"

createColorMap(namedList, greyscale = TRUE)

#>    Pinus    Betula     Poaceae     Picea     Artemisia
#>  "#0d0d0d" "#0d0d0d"   "#0d0d0d"   "#0d0d0d" "#0d0d0d"

createColorMap(namedList, colorblind = TRUE)

#>  Pinus    Betula       Poaceae     Picea     Artemisia
#> "#A6611A" "#DFC27D"     "#80CDC1"   "#A6611A"  "#018571"

}
