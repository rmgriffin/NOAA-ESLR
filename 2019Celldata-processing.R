# Setup -------------------------------------------------------------------
rm(list=ls()) # Clears workspace

#system("sudo apt install libgeos-dev libproj-dev libgdal-dev libudunits2-dev -y") # Install linux geospatial dependencies 

# Install/call libraries
#install.packages("renv")
#renv::init()

PKG <- c("googledrive","tidyverse", "rgdal","raster","sf","furrr","data.table","filesstrings","rnaturalearth")

for (p in PKG) {
  if(!require(p,character.only = TRUE)) {  
    install.packages(p)
    require(p,character.only = TRUE)}
}

renv::snapshot()
rm(p,PKG)

## Cell data
# Mass shapefiles https://docs.digital.mass.gov/dataset/massgis-data-state-outlines
# Cell data is from AirSage
dir.create(file.path('Data'), recursive = TRUE)
folder_url<-"https://drive.google.com/open?id=1egzpicB1TTFB7ZNLd22GZHgratbZPFcm"
folder<-drive_get(as_id(folder_url))
files<-drive_ls(folder)
dl<-function(files){
  walk(files, ~ drive_download(as_id(.x), overwrite = TRUE))
}
setwd("./Data")
system.time(map(files$id,dl))
system.time(unzip("2019Celldata.zip", exdir = "."))
file.remove("2019Celldata.zip")
setwd("..")
rm(files, folder, folder_url, dl)

## Processing
Cvg<-st_read("./Data/Coverage.gpkg")
Cvg<-st_transform(Cvg,crs = 32619)
MA<-st_read("./Data/MA_poly.gpkg")
MA<-st_transform(MA,crs = 32619)
C01<-read_csv("./Data/nation-wide-shorelines-201901.csv",col_names = TRUE)
D01<-st_as_sf(C01, coords = c("lon_bin", "lat_bin"),crs = 4326, agr = "constant")
D01<-st_transform(D01,crs = 32619)

DJ01<-st_join(D01,MA, left=FALSE)
DJ01<-DJ01 %>% dplyr::select(c(device_count,geometry))
st_write(DJ01,"DJ01.gpkg")

## Quick plot
a<-ggplot() +
  geom_sf(data = DJ01, aes(fill=device_count))

# Seems to be missing a chunk of data on Cape Cod - perhaps this is the area Nate already has?
# Point sampling seems to be roughly every 100m

# Template
a<-ggplot() +
  geom_sf(data=sm, color = "tan") +
  geom_sf(data=rd.sc, color = "grey") +
  geom_sf(data = PUD500m, aes(fill=PUD_b)) +
  scale_fill_brewer(palette = "Oranges", na.translate = FALSE, guide = guide_legend(override.aes = list(linetype = "blank"), title = "Flickr User Days")) + # https://github.com/tidyverse/ggplot2/issues/2763
  geom_sf(data=ESI, aes(color="ESI Line"), show.legend = TRUE) +
  scale_color_manual(values = c("ESI Line" = "black"), name = "") +
  geom_label_repel(data = cdp, aes(label=NAME, geometry = geometry), stat = "sf_coordinates", min.segment.length = 0, size=2.5, point.padding = NA) +
  coord_sf(xlim=c(-122.5402,-122.3882),ylim=c(37.38338,37.5586), datum = NA) +
  theme_void() +
  theme(legend.position = c(0.25, 0.32), legend.margin = margin(-0.25,0,0,0, unit="cm"), panel.background = element_rect(fill = "aliceblue", color = NA), axis.title.x=element_blank(), axis.title.y=element_blank(), legend.text=element_text(size=7), legend.title=element_text(size=8), plot.margin=unit(c(0.1,0.1,0.1,0.1),"cm")) +
  xlab(NULL) + 
  ylab(NULL)