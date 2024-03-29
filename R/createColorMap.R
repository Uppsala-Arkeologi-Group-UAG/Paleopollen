#' @title Creates a color scheme based on a named vector
#' @description This function takes a named vector such as created by assignGroupToTaxa and will choose an appropriate color scheme from the RColorBrewer package. Optionally, a specific colour for each group variable can be defined or a specific ColorScheme will be chosen. Remind that the maximum amount of supported colours of a color palette in RColorBrewer is 12. A higher number of group variables will result in a greyscale plot which is also recommended for readability.
#'
#'
#' @param namedList A vector containing named strings of format: c("Taxa" = "Group", ...)
#' @param ... Optional arguments to be passed that specify what color scheme to be used.
#'
#' @param colorScheme name for any color scheme available in the RColorBrewer package. Any of the following:
#' @param colors a vector containing named strings matching each group to a color of format: c("Trees" = "green", "Shrubs" = "#000000", "Grasses" = "#000", ...)
#' @param greyscale a boolean value that sets all colors for all groups to black. This is recommended if it is not desired to subdivide pollen into specific groups and when more than 10 pollen taxa are used.
#' @param colorblind a boolean value that determines whether the color map that maps each taxa to a color should be colorblind friendly.
#'
#' @import RColorBrewer
#' @importFrom methods hasArg
#' @importFrom stats setNames
#' @return A named vector matching each taxa to a color based on it's group affiliation.
#' @export
#'
#' @examples
#' namedList <- c("Pinus" = "Trees", "Betula" = "Shrubs", "Poaceae" = "Grasses", "Picea" = "Trees")
#' createColorMap(namedList)
#'
#' #>     Pinus    Betula   Poaceae     Picea      Artemisia
#' #>    "#7FC97F" "#BEAED4" "#FDC086" "#7FC97F"   "#FFFF99"
#'
#' createColorMap(namedList, colorScheme = "Accent")
#'
#' #>     Pinus    Betula   Poaceae     Picea      Artemisia
#' #>  "#7FC97F" "#BEAED4" "#FDC086"   "#7FC97F"   "#FFFF99"
#'
#' createColorMap(namedList, colors = c("Trees" = "green", "Shrubs" = "#000000", "Grasses" = "#000"))
#'
#' #>    Pinus    Betula     Poaceae     Picea     Artemisia
#' #>    "green" "#000000"    "#000"   "green"     "red"
#'
#' createColorMap(namedList, greyscale = TRUE)
#'
#' #>    Pinus    Betula     Poaceae     Picea     Artemisia
#' #>  "#0d0d0d" "#0d0d0d"   "#0d0d0d"   "#0d0d0d" "#0d0d0d"
#'
#' createColorMap(namedList, colorblind = TRUE)
#'
#' #>  Pinus    Betula       Poaceae     Picea     Artemisia
#' #> "#A6611A" "#DFC27D"     "#80CDC1"   "#A6611A"  "#018571"
#'

createColorMap <- function(namedList, ...){

  colorSchemes <- RColorBrewer::brewer.pal.info
  if(is.numeric(namedList)) namedList <- paste(namedList)
  if(is.null(names(namedList))) namedList <- setNames(namedList, namedList)
  assignedColors <- namedList
  groups <- unique(namedList)
  translation_key <- setNames(rep("#0d0d0d",length(groups)), groups)


# Handles optional parameters not required by the function.
#----------------------------------------------------------------
  params <- list(...)
  optionalParamNames <- c("colorScheme", "colors", "greyscale", "colorblind")
  unusedParams <- setdiff(names(params),optionalParamNames)
  if(length(unusedParams))
    stop('unused parameters: ',paste(unusedParams,collapse = ', '))
#----------------------------------------------------------------


# Handles the optional argument 'colorScheme'
#----------------------------------------------------------------
  if(hasArg("colorScheme")){

    if(hasArg("colorblind")){
      if(colorSchemes[params$colorScheme,]$colorblind != params$colorblind){
        warning(call. = FALSE, immediate. = TRUE, sprintf("You set 'colorblind' to %i, but the colorScheme you chose is%s for colorblind
                selecting another colorScheme that fullfills 'colorblind'", params$colorblind, c("", " not")[as.integer(colorSchemes[params$colorScheme,]$colorblind)+1]))

        color_prop <- colorSchemes[params$colorScheme,]
        params$colorScheme <- row.names(colorSchemes)[colorSchemes$maxcolors >= color_prop$maxcolors & colorSchemes$category == color_prop$category & colorSchemes$colorblind == params$colorblind][1]

        print(sprintf("Selected %s instead!", params$colorScheme))
      }
    }

    # Checks if the argument "colors" is initialized together with colorScheme.
    if(hasArg("colors")){
      warning(call. = FALSE, immediate. = TRUE, "You should not use the argument 'colorScheme' and provide your own color list at the same time!
              Ignoring the 'colorScheme' argument!")

    # Checks if the supplied colorScheme name is valid.


    }else if(!params$colorScheme %in% row.names(colorSchemes)){
      stop('unknown color scheme: ', params$colorScheme, ".", "\n",
           "Use any of these instead: ", paste(row.names(colorSchemes), collapse = ", "),
           ".\n", "or create your own colorScheme, by using the argument 'colors'." )


    # Checks whether the supplied colorScheme has not enough colours to combine with the supplied list of taxa.
    }else if(length(groups) > colorSchemes[params$colorScheme,]$maxcolors){
      warning(call. = FALSE, immediate. = TRUE,
      sprintf("The chosen colorScheme has only %d colours, but you have &d groups/taxa. Changing to Set3.", colorSchemes[params$colorScheme,]$maxcolors ,length(groups)))

      translation_key <- setNames(RColorBrewer::brewer.pal(length(groups), "Set3"),groups)

    # Checks whether the supplied number of taxa is higher than the maximum amount of colours supplied by any colorBrewer
    }else if(length(groups) > 12) {

        warning(call. = F, immediate. = T, "To many taxa, changing to greyscale. Provide your own set of colours via 'colors'.")
        translation_key <- setNames(rep("#0d0d0d", length(groups)), groups)


    }else{

      # If none of the above are true, the colorScheme will be assigned to the respective group as intended.
      translation_key <- setNames(RColorBrewer::brewer.pal(length(groups), params$colorScheme) ,groups)
    }
  }
#----------------------------------------------------------------

# Handles the optional argument 'colors'
#----------------------------------------------------------------
  if(hasArg("colors")){

    check_colors <- params$colors %in% grDevices::colors() | sapply(params$colors, checkHexColor)
    if(!all(check_colors)){stop("Unknown color: ", params$colors[!check_colors])}

    # Checks whether the supplied vector has the same amount of groups.
    if(length(groups) != length(params$colors)){
      stop('Length of color values (%d) is not the same as the amount of groups (%d) or taxa(%d)', length(params$colors), length(groups), length(namedList))

    }else if(length(groups) == length(params$colors)){

      #Checks whether the user supplied a named vector.
      if(is.null(names(params$colors))){
        warning(call. = FALSE, immediate. = TRUE, "Color vector is not named, colors will be assigned in order")

        translation_key <- setNames(params$colors, groups)


      }else if(!all(names(params$colors) %in% groups)){

        stop(paste(names(params$colors)[!(names(params$colors) %in% groups)], collapse = ", "),
          " are not in any assigned group (", paste(groups, collapse = ", "), ")")

      }else{

        for(name in names(params$colors)){
          translation_key[name] <- params$colors[name]
        }
      }
    }
  }
#----------------------------------------------------------------

# Handels the optional argument 'greyscale'
#----------------------------------------------------------------
  if(hasArg("greyscale")){

    if(params$greyscale == T & (hasArg("colors") || hasArg("colorScheme") || hasArg("colorblind"))){
      warning(call. = F, immediate. = T, " if greyscale is set to true all other optional arguments are ignored.")

    }

    if(params$greyscale == T){
      # Same as initialized, but in case any other argument was true.
      translation_key <- setNames(rep("#0d0d0d",length(groups)), groups)
    }
  }
#----------------------------------------------------------------

# Handels the optional argument 'colorblind' when 'colorScheme' is not provided
#----------------------------------------------------------------
  if(hasArg("colorblind") & !hasArg("colorScheme")){
    if(hasArg("colors")){stop("This function cannot check whether your manually supplied colorpalette is colorblind friendly!")}
    if(hasArg("greyscale")){stop("Cannot create a colorblind friendly colorpalette based on greyscale.")}
    if(params$colorblind){
      colorScheme <- row.names(colorSchemes)[colorSchemes$maxcolors >= length(groups) & colorSchemes$colorblind == T][1]
      if(is.na(colorScheme)){
        warning(call. = F, immediate = T, "There are too many taxa, cannot find an appropriate colorscheme in 'RColorBrewer' that supports colorblindness.
                Changing to greyscale mode instead!")
        translation_key <- setNames(rep("#0d0d0d",length(groups)), groups)
        }else{
        translation_key <- setNames(RColorBrewer::brewer.pal(name = colorScheme, n = length(groups)), groups)
      }
    }
  }
#----------------------------------------------------------------

# Handels the case where no optional parameters are provided.
#----------------------------------------------------------------
  if(length(params) == 0){
    colorScheme <- row.names(colorSchemes)[colorSchemes$maxcolors >= length(groups) & colorSchemes$category == "qual"][1]
    if(is.na(colorScheme)){
      warning(call. = F, immediate = T, "There are too many taxa, cannot find an appropriate colorscheme in 'RColorBrewer' that supports this many taxa.
                Changing to greyscale mode instead!")
      translation_key <- setNames(rep("#0d0d0d",length(groups)), groups)
    }else{
      translation_key <- setNames(RColorBrewer::brewer.pal(name = colorScheme, n = length(groups)), groups)
    }
  }
#----------------------------------------------------------------

  assignedColors <- setNames(translation_key[assignedColors], names(assignedColors))

  return(assignedColors)
}

#---------------------------------------------------------------------------------------------------------
# This function checks whether the strings provided are a hex representation of colors.
#---------------------------------------------------------------------------------------------------------
#' @keywords internal
checkHexColor <- function(a){
  if(!is.character(a)){ return(F)}
  if(is.null(a)){return(F)}
  if(!(nchar(a) == 4 || nchar(a) == 7)){ return(F)}
  if(substr(a,1,1) !="#"){return(F)}
  if(!grepl("^#[0-9a-fA-F]+$",a)){print("no")
    return(F)}else{return(T)}
}
