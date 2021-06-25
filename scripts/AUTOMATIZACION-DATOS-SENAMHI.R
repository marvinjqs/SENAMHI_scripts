#################################
# AUTOMATIZACION DE LA DESCARGA DE DATOS HIDROMETEOROLOGICOS DE SENAMHI
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

# FIJAR EL DIRECTORIO DE TRABAJO

setwd("C:/Users/Asus/Desktop/R/INTERMEDIO/CLASE3") 


# DEFINIR UNA FUNCION PARA LA DESCARGA DE DATOS

library(RSelenium)

download_senamhi_data <- function(url_list) {
  
  # NUMERO ALEATORIO DE PUERTO 
  port <- as.integer(runif(1, min = 5000, max = 6000))
  
  # EJECUTAMOS EL DRIVER DE GOOGLE CHROME 
  rD <- rsDriver(port = port, browser = "chrome", 
                 chromever = "91.0.4472.19")
  
  remDrv <- rD$client
  
  for (url in url_list){
  
  # INGRESAR AL URL
  remDrv$navigate(url)
  
  # ENCONTRAR EL BOTON DE DESCARGA 
  down_button <- remDrv$findElement(using = "id", "export2")
  down_button$clickElement()
  
  }
  
  # CERRAR LA SESION ACTUAL
  remDrv$close()
  rD$server$stop()
  rm(rD, remDrv)
  gc()

}

# EJECUTAR LA FUNCION PARA DESCARGAR TODOS LOS MESES DE UN AÑO

list_url <- list()

for (i in 1:9) {
  
  list_url[i] = paste("https://www.senamhi.gob.pe//mapas/mapa-estaciones-2/_dato_esta_tipo02.php?estaciones=472AC278&CBOFiltro=20200",
               i, "&t_e=M&estado=AUTOMATICA&cod_old=&cate_esta=EMA&alt=247", sep = "")
  
 }

for (i in 10:12) {
  
  list_url[i] = paste("https://www.senamhi.gob.pe//mapas/mapa-estaciones-2/_dato_esta_tipo02.php?estaciones=472AC278&CBOFiltro=2020",
               i, "&t_e=M&estado=AUTOMATICA&cod_old=&cate_esta=EMA&alt=180", sep = "")
  
}

download_senamhi_data(list_url)


# IMPORTAR LOS ARCHIVOS CSV DE UNA CARPETA 

wd_path <- "C:/Users/Asus/Desktop/R/INTERMEDIO/CLASE3"
myfiles <- list.files(path=wd_path, pattern="*.csv", full.names=TRUE)

df_list <- list()

for (i in 1:length(myfiles)){
  
  df_list[[i]] <- read.table(myfiles[i], sep = ",", header = T ,
                             skip = 10 , stringsAsFactors = F, 
                             na.strings = "S/D")
}

# CONCATENAR LOS DATAFRAMES DE LA LISTA

df <- Reduce(function(...) merge(... , all=TRUE), df_list)








