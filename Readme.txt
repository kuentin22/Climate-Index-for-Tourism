############
#
# Calcul % de núvols a Andorra 1981-Actualitat
#
############

ESTAT: Analitzar la presència de núvols a Andorra des de l’any 1981 fins a l’actualitat, utilitzant dades de tres fonts diferents: ERA5, MODIS i Sentinel-2. L’objectiu és calcular el percentatge de núvols per dia i exportar els resultats en format CSV per al seu anàlisi posterior.

FONTS: 
      - ERA5 (1981-1999): Dades de la col·lecció ECMWF/ERA5/HOURLY amb una resolució aproximada de 28 km. Es treballa amb la variable 	total_cloud_cover.
      - MODIS (2000-2022): Dades del satèl·lit MODIS de la col·lecció MODIS/006/MOD09GA amb una resolució espacial de 1 km. S’utilitza la 	banda state_1km per detectar núvols.
      - Sentinel-2 (2019-Actualitat): Dades del satèl·lit Sentinel-2 de la col·lecció COPERNICUS/S2_SR amb una resolució de 10 m. Es fa 	servir la banda SCL per la classificació d’escena.
      - Tots els càlculs es realitzen sobre la regió d’Andorra, definida mitjançant un shapefile pujat com a asset a Google Earth Engine.

CODI: el codi s'ha dut a terme en el marc de l'informe d'indicadors de Turisme (Alex Quintana, Ian Serra, Oriol Travesset i Laura Trapero).  

OBJECTIU:       
      - Calcular el % de núvols per a cada dia des de 1981 fins a l'actualitat sobre Andorra.
      - Integrar diferents fonts de dades per cobrir tot el rang temporal.
      - Exportar els resultats en un CSV, on cada fila representa un dia i conté la data (date) i el percentatge de núvols 	(percent_nuvolositat).

OBSERVACIONS:
    ERA5:
      - Dades disponibles des de 1981.
      - La variable total_cloud_cover es multiplica per 100 per obtenir el percentatge.
      - Resolució espacial més baixa, adequada per anàlisi climàtic a llarg termini.

    MODIS:
      - Disponible des de l’any 2000.
      - Es treballa amb la banda state_1km per identificar núvols mitjançant operacions bitwise (0-1).

    Sentinel-2:
      - Disponible des de 2017.
      - Resolució espacial de 10 m, ideal per anàlisi de detalls més fins.
      - Es fa servir la banda SCL per identificar núvols amb codis específics (8, 9, 10).
      - Els píxels de neu/gel (SCL=11) no s’han inclòs en aquest càlcul.
      - Els resultats es poden processar posteriorment amb R per a una anàlisi més detallada.
	*** Qualsevol ombra de núvol (SCL=3) no es considera núvol directe, però pot afectar la interpretació en algun cas. (si es considera necessari ho podem tenir en compte i afegir). ***


EL CODI COMPLET de GEE ES TROBA ALS FITXERS:

codi_GEE_ERA5 (per al període 1981-1999)

codi_GEE_MODIS (per al període 2000-2022)

codi_GEE_Sentinel2 (per al període 2019-Actualitat)

Tots els arxius es troben a la carpeta RMarkdown de cada carpeta


