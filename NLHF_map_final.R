library(dplyr)
library(leaflet)
library(rgdal)
library(spdplyr)

shape_file <- readOGR(dsn = "Local_Authority_Districts__December_2019__Boundaries_UK_BUC.shp")

wgs84 = '+proj=longlat +datum=WGS84'
shape_file_trans <- spTransform(shape_file, CRS(wgs84))

shape_file_trans %>% 
  leaflet() %>% 
  addTiles() %>% 
  addPolygons(popup=~lad19nm)

funding <- read.csv("funding_data_final.csv", stringsAsFactors=F)

shapes_funding_merge <- left_join(shape_file_trans, funding, by=c("lad19cd"="ons_code"))

pal <- colorNumeric("Greens", domain=shapes_funding_merge$PerPerson)

popup2 <- paste0("<strong>", shapes_funding_merge$lad19nm, 
                 "</strong><br />Per-head funding: £", as.character(shapes_funding_merge$PerPerson))

leaflet() %>%
  addProviderTiles("CartoDB.Positron") %>%
  setView(-2, 55, zoom = 5) %>% 
  addPolygons(data = shapes_funding_merge , 
              fillColor = ~pal(shapes_funding_merge$PerPerson), 
              fillOpacity = 0.7, 
              weight = 0.2, 
              smoothFactor = 0.2, 
              popup = ~popup2) %>%
  addLegend(pal = pal, 
            values = shapes_funding_merge$PerPerson, 
            position = "bottomright", 
            title = "Per-person funding (£)")
