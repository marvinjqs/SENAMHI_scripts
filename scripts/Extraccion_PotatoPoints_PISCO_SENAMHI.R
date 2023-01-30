#################################
# EXTRACCIÓN DE DATOS DE LOS PRODUCTOS PISCO - SENAMHI EN BASE A LAS GRILLAS DE PAPA EN PERÚ
# International Potato Center, Lima - Perú ; 2023
# Marvin J. Quispe Sedano
# Email: marvinjqs@gmail.com
#################################

#---------------------------------------------------------
# Para limpiar la consola:
# TeclaS :  Ctrl + L

# Para limpiar el workspace:
rm(list = ls())

###############
#  Paquetes   #
###############

library(terra)
library(sf)

# FIJAR EL DIRECTORIO DE TRABAJO

setwd("D:/")

# Aumentar el tamaño de memoria para terra

terraOptions()
terraOptions(memfrac = 0.8)
terraOptions()
gc()

# Leer los datos de PISCO SENAMHI TMAX, TMIN, TDEW Y PREC

lf_PISCO_TMAX <- list.files("D:/DATOS/PISCO_SENAMHI/TMAX/", pattern = "tmax_daily.*\\.nc", full.names = T)
lf_PISCO_TMIN <- list.files("D:/DATOS/PISCO_SENAMHI/TMIN/", pattern = "tmin_daily.*\\.nc", full.names = T)
lf_PISCO_TDEW <- list.files("D:/DATOS/PISCO_SENAMHI/TDEW/", pattern = "td_daily.*\\.nc", full.names = T)
lf_PISCO_PP <- list.files("D:/DATOS/PISCO_SENAMHI/PP/Resample/", pattern = "prec_daily.*\\.nc", full.names = T)

PISCO_TMAX <- lapply(lf_PISCO_TMAX, FUN = function(x) terra::rast(x))
PISCO_TMIN <- lapply(lf_PISCO_TMIN, FUN = function(x) terra::rast(x))
PISCO_TDEW <- lapply(lf_PISCO_TDEW, FUN = function(x) terra::rast(x))
PISCO_PP <- lapply(lf_PISCO_PP, FUN = function(x) terra::rast(x))

# Leer los puntos - centroides de grilla - de áreas donde se cultiva papa
potato_grid <- st_read("D:/CIP/LATEBLIGHT/SIMCAST_PISCO/Potato_grid/CenagroData/CENAGRO_OnlyPotatoes_Pisco_Altitude.shp")

# Extraer los datos DE PISCO SENAMHI usando las grillas de cultivo de papa y exportar a .rds (mejor eficiencia que .csv en R)

extract_PISCO_values <- function(PISCO_raster, name_var) {
  
  df_extract <- terra::extract(PISCO_raster, potato_grid)
  colnames(df_extract) <- c("ID", as.character(time(PISCO_raster)))
  
  df_extract_stack <- cbind(df_extract[1], stack(df_extract[2:ncol(df_extract)]))
  colnames(df_extract_stack) <- c("ID", name_var, "FECHA")
  
  raster_name <- gsub(".nc", "", basename(sources(PISCO_raster)))
  file_name <- paste(raster_name, "_potatogrid.rds", sep ="")
  #write.(df_extract_stack, file = file_name, row.names = F)
  saveRDS(df_extract_stack, file = file_name)
  print("Extracting the data ...")
  
}

time_init <- Sys.time()

setwd("D:/CIP/LATEBLIGHT/SIMCAST_PISCO/R_outputs/")

TMAX_sample <- PISCO_TMAX[1:60]
TMIN_sample <- PISCO_TMIN[1:60]
TDEW_sample <- PISCO_TDEW[1:60]
PP_sample <- PISCO_PP[1:60]

lapply(TMAX_sample, FUN = function(x) extract_PISCO_values(x, "TMAX"))
lapply(TMIN_sample, FUN = function(x) extract_PISCO_values(x, "TMIN"))
lapply(TDEW_sample, FUN = function(x) extract_PISCO_values(x, "TDEW"))
lapply(PP_sample, FUN = function(x) extract_PISCO_values(x, "PP"))


time_final <- Sys.time()








