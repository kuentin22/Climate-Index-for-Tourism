############
#
# Càlcul % de núvols a Andorra (1981-Actualitat)
#
############

ESTAT: Analitzar la presència de núvols a Andorra des de l’any 1981 fins a l’actualitat, utilitzant dades d'ERA5 (ECMWF). L’objectiu és calcular el percentatge de núvols per dia i exportar els resultats en format CSV pel seu anàlisi posterior.

FONT: 
      - ERA5 (1981-2024): Dades de la col·lecció ECMWF/ERA5/HOURLY amb una resolució aproximada de 28 km. Es treballa amb la variable total_cloud_cover.
      - Tots els càlculs es realitzen sobre la regió d’Andorra, definida mitjançant un shapefile pujat com a asset a Google Earth Engine.

CODI: el codi s'ha dut a terme en el marc de l'informe d'indicadors de Turisme (Alex Quintana, Ian Serra, Oriol Travesset i Laura Trapero).  

OBJECTIU:       
      - Calcular el % de núvols per a cada dia des de 1981 fins a l'actualitat sobre Andorra.
      - Exportar els resultats en un CSV, on cada fila representa un dia i conté la data (date) i el percentatge de núvols 	(percent_nuvolositat).

OBSERVACIONS:
    ERA5:
      - Dades diàries disponibles des de 1981.
      - La variable total_cloud_cover es multiplica per 100 per obtenir el percentatge.
      - Resolució espacial més baixa, però que ens permet realizar un anàlisi climàtic a llarg termini.

EL CODI COMPLET de GEE ES TROBA ALS FITXERS:

codi_GEE (pel període 1981-2024)

El procediment i codi es troba a la carpeta RMarkdown



############
#
# Càlcul de la velocitat del vent mitjana diària a Andorra (1981-Actualitat)
#
############

OBJECTIU:
      - Analitzar l'evolució de la velocitat del vent a Andorra des de l’any 1981 fins a l’actualitat, utilitzant dades de la reanàlisi ERA5. 
      - L’objectiu és calcular la velocitat mitjana diària del vent a 10 metres sobre el nivell del terra i exportar els resultats en format **CSV** per al seu posterior anàlisi.

FONTS DE DADES:
      - ERA5 (1981-Actualitat)  
      - Col·lecció de reanàlisi **ECMWF/ERA5/HOURLY** amb resolució espacial de **9 km** (ERA5-Land).
      - Es treballa amb les següents variables:
         - `u_component_of_wind_10m`: Component del vent en direcció est-oest.
         - `v_component_of_wind_10m`: Component del vent en direcció nord-sud.
      - La velocitat del vent es calcula utilitzant la fórmula: **Vvent (m/s) = √(u² + v²)**
      - L’anàlisi es realitza sobre la regió d’Andorra, definida mitjançant un *shapefile* pujat com a *asset* a Google Earth Engine.

MÈTODE DE CÀLCUL:
      1. Filtratge de dades: Es seleccionen les imatges d’ERA5 dins de l’interval de dates definit.
      2. Càlcul de la velocitat del vent: Es calcula la mitjana diària de la velocitat del vent combinant les components `u` i `v` amb la fórmula de velocitat.
      3. Exportació dels resultats: Es crea un fitxer **CSV**, on cada fila representa un dia i conté:
         - `date`: Data en format YYYY-MM-DD.
         - `wind_speed_m_s`: Velocitat mitjana del vent en **m/s**.
      4. Postprocessat: Els resultats es poden analitzar posteriorment amb **R o Python**, i es poden convertir a **km/h** si és necessari.

OBSERVACIONS:
     - La resolució d’ERA5 és de **9 km**, adequada per estudis de tendències climàtiques.
     - La velocitat del vent es calcula a 10 metres sobre el terra.
     - Per convertir els valors a km/h, es pot aplicar la conversió:  
     - **1 m/s = 3.6 km/h**
     - L’exportació a CSV està optimitzada per evitar errors en la lectura a Excel.

EL CODI COMPLET de GEE ES TROBA AL FITXER codi_GEE (per al període 1981-Actualitat) a la carpeta RMarkdown

