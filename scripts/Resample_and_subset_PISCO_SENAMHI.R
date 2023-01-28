#################################
# RESAMPLEO Y SUBSETING DE DATOS GRILLADOS DE PRECIPITACION PISCO v2.1 - SENAMHI
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

# FIJAR EL DIRECTORIO DE TRABAJO

setwd("D:/DATOS/PISCO_SENAMHI/")

# Aumentar el tamaño de memoria para terra

terraOptions()
terraOptions(memfrac = 0.8)
terraOptions()
gc()

# Importar los datos

rpisco_pp <- rast("D:/DATOS/PISCO_SENAMHI/PP/PISCO_prec_h.nc")
grid_resample <- rast("D:/DATOS/PISCO_SENAMHI/TDEW/td_daily_1981_01.nc")


# Añadir las fechas al dataset de Pisco pp

seq_dates <- seq.Date(from = as.Date("1981-01-01"), 
                by = "1 day",
                length.out = nlyr(rpisco_pp))

terra::time(rpisco_pp) <- seq_dates

# Crear un bucle para resamplear y exportar los datos

setwd("D:/DATOS/PISCO_SENAMHI/PP/Resample/")

seq_months <- unique(format(seq_dates, "%Y-%m"))
seq_months_idx <- unique(format(seq_dates, "%Y_%m"))

time_initial <- Sys.time()

for (i in 1:length(seq_months)) {
  
  date1 <- paste(seq_months[i],"-01",sep = "")
  date2 <- seq.Date(from = as.Date(paste(seq_months[i],"-01",sep = "")), by = "1 month", length.out = 2)[2]
  raster_pp <- rpisco_pp[[time(rpisco_pp) >= date1 & time(rpisco_pp) < date2]]
  
  raster_pp_resample <- resample(raster_pp, grid_resample, method="bilinear")
  writeCDF(raster_pp_resample, paste("prec_daily_", seq_months_idx[i], ".nc", sep = ""), 
           overwrite = TRUE, varname = "prec", unit = "mm/day")
}

time_final <- Sys.time()


