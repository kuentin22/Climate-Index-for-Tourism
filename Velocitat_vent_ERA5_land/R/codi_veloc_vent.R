###########################################################################
# Títol: Taula valors finals velocitat vent (m/s)
# Autor: Alexandre Quintana Clarà
# Data: 14/01/2025
###########################################################################

# 📚 Carreguem llibreries necessàries
library(tidyverse)
library(readxl)
library(writexl)

# 📂 Definim les rutes base
ruta_input <- "C:/Users/aquintana/Desktop/ARI/CIT/Velocitat_vent_ERA5_land/Originals/"
ruta_output <- "C:/Users/aquintana/Desktop/ARI/CIT/Velocitat_vent_ERA5_land/Corregits/"

# ✅ Funció actualitzada per formatar 'velocitat_vent'
formata_nuvolositat <- function(x) {
  x_sense_punts <- gsub("[.,]", "", x)  # Eliminar punts i comes
  
  # Si té exactament 17 dígits, eliminem el primer dígit
  if (nchar(x_sense_punts) == 17) {
    x_sense_punts <- substr(x_sense_punts, 2, nchar(x_sense_punts))
  }
  
  # Si té més de 10 dígits, dividir per 1e12 per ajustar el format
  if (nchar(x_sense_punts) > 10) {
    num <- as.numeric(x_sense_punts)
    return(formatC(num / 1e18, digits = 3, format = "f", decimal.mark = ","))
  }
  
  return(x)  # Retornar el valor original si no cal formatar
}

# Bucle per processar els fitxers des de 2000 fins a 2022
for (any in 1981:2024) {
  # Noms dels fitxers d'entrada i sortida
  fitxer_input <- paste0(ruta_input, "Taula_Velocitat_vent_", any, "_Andorra.xlsx")
  fitxer_output <- paste0(ruta_output, "Taula_Velocitat_vent_", any, "_Andorra_CORREGIT.xlsx")
  
  # Verifiquem si el fitxer existeix
  if (file.exists(fitxer_input)) {
    # Llegim el fitxer Excel de la fulla 'Sheet1'
    dades <- read_excel(path = fitxer_input, sheet = "Sheet1")
    
    # 1️⃣ Formatar la columna 'percent_nuvolositat'
    dades$wind_speed_m_s <- sapply(dades$wind_speed_m_s, formata_velocitat)
    
    # 2️⃣ Eliminar la columna '.geo' si existeix
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

