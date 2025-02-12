# Codi GEE per calcular el % de núvols amb ERA5 a Andorra (1981-1999)

## Introducció
Aquest codi calcula el percentatge de cobertura de núvols diari per a la regió d'Andorra utilitzant les dades de reanàlisi del model **ERA5** (ECMWF). El resultat final s'exporta com un fitxer CSV amb el % de núvolositat per cada dia.

> **Nota**: Aquest codi utilitza un fitxer *shapefile* d’Andorra que has d’haver pujat al teu espai d’*assets* a Google Earth Engine. A part, ERA5 proporciona dades a resolució horària i amb una resolució espacial d'aproximadament 28 km.

## Característiques del codi:
- Font de dades: ERA5 (Hourly Data).
- Resolució espacial: ~28 km.
- Resolució temporal: Diària 
- Variable analitzada: total_cloud_cover (cobertura total de núvols en fracció 0-1).
- Resultat: Percentatge de cobertura de núvols per dia en format CSV.

## Passos del codi:
1. Definició de la Regió d'Interès (ROI): Importació del shapefile d'Andorra.
2. Filtrat de dades: Selecció de la col·lecció ERA5 per a les dates i ROI especificats.
3. Càlcul de la mitjana diària: Es fa la mitjana de la cobertura de núvols per cada dia.
4. Conversió a percentatge: Multiplicació per 100 per obtenir el percentatge.
5. Exportació dels resultats: En format CSV.

## Codi complet (Google Earth Engine)
```js
// DEFINICIÓ DE LA REGION OF INTEREST (ROI)
var table = ee.FeatureCollection("projects/ee-my-aquintanac01/assets/Andorra");
var roi = table.geometry(); // Converteix el shapefile a geometria

// 1981 //
/***** 
 * Calculem el % de núvols amb ERA-5
 * del 1 de gener de x any fins a l’1 de gener de x+1 en un sol CSV.
 *****/

// Carreguem la col·lecció ERA5 i filtrem per dates i ROI
function obtenirCoberturaNuvolsERA5(startDate, endDate) {
  var coleccioERA5 = ee.ImageCollection('ECMWF/ERA5/HOURLY')
    .filterDate(startDate, endDate)
    .filterBounds(roi)
    .select('total_cloud_cover'); // Seleccionem la variable de cobertura de núvols

// Generem una llista de dates úniques dins del període
  var datesUniques = ee.List(coleccioERA5.aggregate_array('system:time_start'))
    .map(function(t) { return ee.Date(t).format('YYYY-MM-dd'); })
    .distinct();

// Funció per calcular la mitjana diària de núvols
  function mitjanaDiaria(dateStr) {
    var date = ee.Date(dateStr);
    var imatgesDelDia = coleccioERA5.filterDate(date, date.advance(1, 'day'));
    var imatgeMitjana = imatgesDelDia.mean().multiply(100); // Convertim fracció (0-1) a %

    return imatgeMitjana.set({
      'date': dateStr,
      'system:time_start': date.millis()
    });
  }

// Apliquem la funció a totes les dates
  var coleccioDiaria = ee.ImageCollection(datesUnicas.map(mitjanaDiaria));

  return coleccioDiaria;
}

// Definim l'interval de dates
var startDate = ee.Date.fromYMD(1981, 1, 1);
var endDate   = ee.Date.fromYMD(1982, 1, 1);

// Creem la col·lecció de núvols per tot el període
var coleccio = obtenirCoberturaNuvolsERA5(startDate, endDate);

// Convertim cada imatge en un Feature (filera) amb data i % de núvols
var taula = coleccio.map(function(img) {
  return ee.Feature(null, {
    'date': img.get('date'),
    'percent_nuvolositat': img.reduceRegion({
      reducer: ee.Reducer.mean(),
      geometry: roi,
      scale: 28000,  // Resolució d’ERA5 (~28km)
      maxPixels: 1e13
    }).get('total_cloud_cover')
  });
});

// Exportem la taula a CSV
Export.table.toDrive({
  collection: taula,,
  description: 'Taula_nuvolositat_1981_Andorra_ERA5',
  folder: 'ARI',
  fileFormat: 'CSV' // Després ho passem a xlsx
});

// Imprimim la col·lecció per a la comprovació
print('Cobertura de núvols ERA5 (1981-1982):', coleccio);
```

### Columnes de la taula exportada:

| Columna              | Descripció                              |
|-----------------------|------------------------------------------|
| `date`               | Data en format YYYY-MM-DD               |
| `percent_nuvolositat`| Percentatge mitjà de núvols sobre Andorra |

### Recursos addicionals:
- [Documentació oficial de Google Earth Engine](https://developers.google.com/earth-engine).



