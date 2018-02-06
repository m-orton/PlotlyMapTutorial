# Plotly Map tutorial in R with BOLD data 
# Matt Orton
# ***Make sure to use RStudio with this script***

# Packages you need
install.packages("plotly")
library(plotly)
install.packages("readr")
library(readr)

# As an easy way to pick a file
parseDoc <- file.choose()

# Private datasets from BOLD 

# Reading a private dataset (csv or tsv)
dfTestPrivate <- read_csv(parseDoc)

# Or can do tsv with read_tsv command

# Downloading directly from BOLD API

# The URL below is what is modified by the user and will determine the taxon, geographic region, 
# etc. Example: taxon=Aves$geo=all, see above in Guidelines and Tips for more
# information on how to use the BOLD API.

# The read_tsv function has been modified to select only certain columns to save
# on downloading time (just using a small example dataset):

# Here I'm using cats cause I like cats
dfTestPublic <- read_tsv("http://www.boldsystems.org/index.php/API_Public/combined?taxon=Felidae&geo=all&format=tsv")

# Some basic filtering of data

# Can use grep commonds to filter according to data columns you want
containCOI <- grep( "COI-5P", dfTestPublic$markercode)
dfTestPublic <-dfTestPublic[containCOI,]

# Removing sequences with no coordinate data since we are mapping 
containLat <- grep( "[0-9]", dfTestPublic$lat)
dfTestPublic <-dfTestPublic[containLat,]

# Get rid of records without BIN since for mapping purposes, Im going to color code 
# according to BIN
noBIN <- which(is.na(dfTestPublic$bin_uri == TRUE))
dfTestPublic <- dfTestPublic[-noBIN,]

# Mapping with Plotly - can go here for more details on scattergeo maps:
# https://plot.ly/r/scatter-plots-on-maps/

# Can modify some of these map elements to customize the map
mapLayout <- list(
  resolution = 50, # Two choices either 100 (low resolution) or 50 (higher resolution)
  showland = TRUE,
  showlakes = TRUE,
  showcountries = TRUE,
  showocean = TRUE,
  countrywidth = 0.5,
  landcolor = toRGB("light grey"),
  lakecolor = toRGB("white"),
  oceancolor = toRGB("white"),
  projection = list(type = 'equirectangular'), # Check the plotly website for the various map options
  lonaxis = list(
    showgrid = TRUE,
    gridcolor = toRGB("gray40"),
    gridwidth = 0.5
  ),
  lataxis = list(
    showgrid = TRUE,
    gridcolor = toRGB("gray40"),
    gridwidth = 0.5
  )
)

# New dataframe column with data for hovering over points on the map.
# Can add more columns to hover if you want more detail on the map for each
# point on the map. 
# For instance here I have it so that when you hover over a point you can see the BIN but can specify other
# columns from the dataframe
dfTestPublic$hover <- 
  paste("BIN",dfTestPublic$bin_uri,
        sep = "<br>")


# This command will ensure the pairing results dataframe can be read by plotly.
attach(dfTestPublic)

# This command will show a scatterplot map organized by coordinate data and color coded by BIN
# Note the map wont show in RStudio, you have to click on the icon in the viewer called
# "show in new window" -> little box with with arrow

# Map with just points and Set1 qualitative color palette
# Note: for private datasets its Lat and Lon not lat and lon
p1 <- plot_ly(dfTestPublic, lat = lat, lon = lon, 
        # Here I chose to use a preset color palette for my colors
        # There are many that can be found on the plotly website: Set1,Set2 for qualitative colors
        # Can also do spectral for 
        text = hover, color = bin_uri, mode = "markers", colors = "Set1", 
        type = 'scattergeo') %>%
  layout(geo = mapLayout, legend = list(orientation = 'h')) 


# Map with points and gradient color palette
p2 <- plot_ly(dfTestPublic, lat = lat, lon = lon, 
        # Here I chose to use a preset color palette for my colors
        # There are many that can be found on the plotly website: Set1,Set2 for qualitative colors
        # Can also do spectral for 
        text = hover, color = bin_uri, mode = "markers", colors = "Spectral", 
        type = 'scattergeo') %>%
  layout(geo = mapLayout, legend = list(orientation = 'h')) 

# Map with points and lines and custom colors (hex codes)

# If using custom colors and plotting according to BIN - first determine how many colors you need
numColors = length(unique(dfTestPublic$bin_uri))

# For cats there are 8 BINs

p3 <- plot_ly(dfTestPublic, lat = lat, lon = lon, 
        # Note there are different color sets: Set1, Set2, Set3 etc. for qualitative colors
        # Here I used custom hex color codes so each BIN is a distinct color
        # you can go here for hex codes: https://www.colorcombos.com
        # choose the colors you like and then copy over the hex codes
        text = hover, color = bin_uri, mode = "markers+lines", colors = c("#005B9A","#F964FF","#74C2E1","#FFBD50","#C43939","#30CF40","#F1CF00","#00EAFF"), 
        type = 'scattergeo') %>%
  layout(geo = mapLayout, legend = list(orientation = 'h')) # can do legend  either horizontal or vertical 'v'

# plot the maps
# ***You will need to click on the icon in the viewer (bottom right corner) that
# says "show in new window" (little box with arrow beside the refresh icon). 
# Unfortunately, this does not show the actual map directly in Rstudio.
# The map will appear in a web browser window, though you don't have to be 
# online to do this.***

p1

p2

p3

# For more customization - can create a plotly account and upload your map data there
# You can customize it more on the plotly website

# For uploading to plotly server for online viewing of map.

# You will first have to create a plotly account to do this:
# https://plot.ly/

# Note there is a limit of one plot for the free version of the Plotly account,
# and the plot is public, meaning other people on plotly can view the plot, 
# though it is not easily found on the website without the direct link.

# To obtain additional plots on the server, you have to pay for a package.

# Run these commands for uploading user details, enter username and API key in 
# the empty quotations to run commands:
# (obtained from making an account and in settings of account details) 

# Sys.setenv("plotly_username"="") 
# Sys.setenv("plotly_api_key"="")

# Run this command for posting of map to plotly server 
# must specify your map variable name and filename (what you want the map to be called)

# plotly_POST(p, filename = "")
