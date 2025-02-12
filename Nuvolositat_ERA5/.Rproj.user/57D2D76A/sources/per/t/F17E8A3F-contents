###########################################################################
# Títol: Taula valors finals nuvolositat. Post-GEE (Automatitzat)
# Autor: Alexandre Quintana Clarà
# Data: 06/02/2025
###########################################################################

# Carreguem llibreries necessàries
library(tidyverse)
library(readxl)
library(writexl)

# Primer hem de tenir en un xlsx (DRIVE) amb el llistat del % de nuvolositat de cada any 

# Definim les rutes base
ruta_input <- "C:/Users/aquintana/Desktop/ARI/CIT/Nuvolositat_ERA5/Originals/"
ruta_output <- "C:/Users/aquintana/Desktop/ARI/CIT/Nuvolositat_ERA5/Corregits/"

# Funció per "netejar" la columna 'date' (eliminar la part de l'hora)
neteja_data <- function(data) {
  return(sub(" .*", "", data))  # Elimina tot després de l'espai
}

# Funció per formatar 'percent_nuvolositat'
formata_nuvolositat <- function(x) {
  x_sense_punts <- gsub("[.,]", "", x)  # Eliminar punts i comes
  
  # Si té més de 10 dígits, convertir-lo a milers amb 3 decimals
  if (nchar(x_sense_punts) > 10) {
    num <- as.numeric(x_sense_punts)
    return(formatC(num / 1e18, digits = 3, format = "f", decimal.mark = ","))
  }
  
  return(x)  # Retornar el valor original si no cal formatar
}

# Bucle per processar els fitxers des de 1981 fins a 1999
for (any in 1981:1999) {
  # Noms dels fitxers d'entrada i sortida
  fitxer_input <- paste0(ruta_input, "Taula_nuvolositat_", any, "_Andorra.xlsx")
  fitxer_output <- paste0(ruta_output, "Taula_nuvolositat_", any, "_Andorra_CORREGIT.xlsx")
  
  # Verifiquem si el fitxer existeix
  if (file.exists(fitxer_input)) {
    # Llegim el fitxer Excel de la fulla 'Sheet1'
    dades <- read_excel(path = fitxer_input, sheet = "Sheet1")
    
    # 1️⃣ Netejm la columna 'date'
    dades$date <- sapply(dades$date, neteja_data)
    
    # 2️⃣ Formaemr la columna 'percent_nuvolositat'
    dades$percent_nuvolositat <- sapply(dades$percent_nuvolositat, formata_nuvolositat)
    
    # 3️⃣ Elimiemr la columna '.geo' si existeix
    if (".geo" %in% colnames(dades)) {
      dades <- dades %>% select(-.geo)
    }
    
    # Guardem el fitxer corregit a la carpeta "Corregits"
    write_xlsx(dades, path = fitxer_output)
    
    # Missatge per indicar el progrés
    cat("✅ Fitxer de l'any", any, "processat i guardat com:", fitxer_output, "\n")
  } else {
    cat("⚠️ Fitxer no trobat per l'any:", any, "\n")
  }
}

print("🚀 Processament finalitzat per a tots els fitxers.")

