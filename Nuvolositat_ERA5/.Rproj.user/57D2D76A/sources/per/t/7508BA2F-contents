###########################################################################
# Títol: Taula valors finals nuvolositat. Post-GEE (Automatitzat)
# Autor: Alexandre Quintana Clarà
# Data: 06/02/2025
###########################################################################

# Carreguem llibreries necessàries
library(tidyverse)
library(fs)
library(ggthemes)
library(zoo)
library(tictoc)
library(readxl)
library(writexl)
library(lubridate)

# Primer hem de tenir en un xlsx (DRIVE) amb el llistat del % de nuvolositat de cada any 

# Definim la ruta del fitxer Excel que conté la taula
fitxer_input <- "C:/Users/aquintana/Desktop/ARI/CIT/Nuvolositat_ERA5/Originals/Taula_nuvolositat_1981_Andorra.xlsx"

fitxer_input <- "C:/Users/aquintana/Desktop/ARI/CIT/Nuvolositat_ERA5/Originals/Taula_nuvolositat_1982_Andorra.xlsx"

fitxer_input <- "C:/Users/aquintana/Desktop/ARI/CIT/Nuvolositat_ERA5/Originals/Taula_nuvolositat_1983_Andorra.xlsx"

fitxer_input <- "C:/Users/aquintana/Desktop/ARI/CIT/Nuvolositat_ERA5/Originals/Taula_nuvolositat_1984_Andorra.xlsx"

fitxer_input <- "C:/Users/aquintana/Desktop/ARI/CIT/Nuvolositat_ERA5/Originals/Taula_nuvolositat_1985_Andorra.xlsx"

fitxer_input <- "C:/Users/aquintana/Desktop/ARI/CIT/Nuvolositat_ERA5/Originals/Taula_nuvolositat_1986_Andorra.xlsx"

# Llegim el full 1 
valors_bons <- read_excel(path = fitxer_input, sheet = "Taula_nuvolositat_1981_Andorra")

valors_bons <- read_excel(path = fitxer_input, sheet = "Taula_nuvolositat_1982_Andorra")

valors_bons <- read_excel(path = fitxer_input, sheet = "Taula_nuvolositat_1983_Andorra")

valors_bons <- read_excel(path = fitxer_input, sheet = "Taula_nuvolositat_1984_Andorra")

valors_bons <- read_excel(path = fitxer_input, sheet = "Taula_nuvolositat_2023_Andorra")

valors_bons <- read_excel(path = fitxer_input, sheet = "Taula_nuvolositat_2024_Andorra")
valors_ori <- valors_bons[["percent_nuvolositat"]]

# Definim la funció de conversió 
conv_valor <- function(x) {
  # 1) Si conté 'E+' (notació científica: ex. "3,63E+12" o "5,42E+10")
  if (grepl("E/+", x)) {
    s <- gsub(",", ".", x)  # ex: "5,42E+10" -> "5.42E+10"
    num <- as.numeric(s)
    return(sub("/.", ",", formatC(num, digits=3, format="f")))
  }
  
  # 2) Si comença per "0."
  if (grepl("^0/.", x)) {
    num <- as.numeric(x)
    s <- formatC(num, digits=3, format="f")
    return(gsub("/.", ",", s))
  }
  
  # 3) Si és exactament "0.0"
  if (x == "0.0") {
    return("0")
  }
  
  # 4) Si té forma "X.Y" sense 'E+'
  if (grepl("^/d+\\./d+$", x)) {
    num <- as.numeric(x)
    s <- formatC(num, digits=3, format="f")
    return(gsub("/.", ",", s))
  }
  
  # 5) Cas general: molts punts
  no_dots <- gsub("/.", "", x)
  if (no_dots == "0") return("0")
  if (nchar(no_dots) < 5) {
    # p.e. "930.944" -> potser no hi ha prou dígits
    # Farem un parse a numeric a veure
    num <- as.numeric(x)
    return(as.character(num))
  }
  enters <- substr(no_dots, 1, 2)
  decimals <- substr(no_dots, 3, 5)
  return(paste0(enters, ",", decimals))
}

# Apliquem la conversió a tot el vector de la columna
# Però abans assegurem-nos que "valors_ori" és un "character", no "numeric"
valors_character <- as.character(valors_ori)

valors_formatats <- sapply(valors_character, conv_valor)

# Substituïm la columna original per la columna nova "formatada"
valors_bons[["percent_nuvolositat"]] <- valors_formatats

# Guardem el Data Frame corregit a un altre Excel
fitxer_output <- "C:/Users/aquintana/Desktop/ARI/CIT/Nuvolositat_ERA5/Originals/Taula_nuvolositat_1981_Andorra_CORREGIT.xlsx"
write_xlsx(valors_bons, path = fitxer_output)

fitxer_output <- "C:/Users/aquintana/Desktop/ARI/CIT/Nuvolositat_ERA5/Originals/Taula_nuvolositat_1982_Andorra_CORREGIT.xlsx"
write_xlsx(valors_bons, path = fitxer_output)

fitxer_output <- "C:/Users/aquintana/Desktop/ARI/CIT/Nuvolositat_ERA5/Originals/Taula_nuvolositat_1983_Andorra_CORREGIT.xlsx"
write_xlsx(valors_bons, path = fitxer_output)

fitxer_output <- "C:/Users/aquintana/Desktop/ARI/CIT/Nuvolositat_ERA5/Originals/Taula_nuvolositat_1984_Andorra_CORREGIT.xlsx"
write_xlsx(valors_bons, path = fitxer_output)

fitxer_output <- "C:/Users/aquintana/Desktop/ARI/CIT/Nuvolositat_ERA5/Originals/Taula_nuvolositat_1985_Andorra_CORREGIT.xlsx"
write_xlsx(valors_bons, path = fitxer_output)

fitxer_output <- "C:/Users/aquintana/Desktop/ARI/CIT/Nuvolositat_ERA5/Originals/Taula_nuvolositat_1986_Andorra_CORREGIT.xlsx"
write_xlsx(valors_bons, path = fitxer_output)

