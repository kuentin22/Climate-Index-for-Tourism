# Codi GEE per calcular el % de núvols amb MODIS a Andorra (2000-2022)

## Introducció
Aquest codi calcula el percentatge de coberta nuvosa a la regió d'Andorra utilitzant dades del satèl·lit **MODIS**. Aquest satèl·lit proporciona dades globals diàries amb resolució d'1 km des de l'any 2000, cosa que permet fer un seguiment detallat de la coberta nuvosa.

> **Nota**: Aquest codi utilitza un fitxer *shapefile* d’Andorra que has d’haver pujat al teu espai d’*assets* a Google Earth Engine.

## Característiques del codi:
- Satèl·lit: MODIS
- Resolució espacial: 1 km
- Període: 2000-2022
- Cobertura: Andorra
- Banda utilitzada: state_1km per a la detecció de núvols
- No cal fer un mosaic per Andorra, ja que cada imatge de MODIS cobreix un àrea d'aprox. 2330 km x 2000 km.

## Passos del codi:
1. Definició de la regió d'interès (ROI).
2. Filtratge d’imatges per dates i regió.
3. Càlcul del % de núvols per a cada dia. S'utilitza la banda state_1km per identificar els píxels amb núvols.
4. Exportació dels resultats a CSV.

## Codi complet (Google Earth Engine)
```js
// DEFINICIÓ DE LA REGION OF INTEREST (ROI)
var table = ee.FeatureCollection("projects/ee-my-aquintanac01/assets/Andorra");
var roi = table.geometry(); // Converteix el shapefile a geometria

// 2010 //
/***** 
 * Calculem el % de núvols 
 * de l’1 de gener de 2010 fins a l’1 de gener de 2011 en un sol CSV.
 *****/
 
// 1) Funció principal 
function creaColleccioAmbNuvols_MODIS(startDate, endDate) {

  // a) CARREGUEM I FILTREM IMATGES DE LA COL·LECCIÓ MODIS
  var coleccioMODIS = ee.ImageCollection('MODIS/006/MOD09GA')
    .filterDate(startDate, endDate)
    .filterBounds(roi);

  // b) Afegim un atribut "date" (String) a cada imatge (format YYYY-MM-dd)
  var coleccioAmbData = coleccioMODIS.map(function(img) {
    var dataStr = ee.Date(img.get('system:time_start')).format('YYYY-MM-dd');
    return img.set('date', dataStr);
  });

  // c) Extraiem dates úniques
  var distintesDates = coleccioAmbData.distinct('date');

  // d) Funció per agrupar imatges per data
  function grupPerData(feature) {
    var dataStr = ee.String(feature.get('date'));
    var imatgesMismaData = coleccioAmbData.filter(ee.Filter.eq('date', dataStr));
    return imatgesMismaData.mosaic()
      .set('date', dataStr)
      .set('system:time_start', ee.Date(dataStr).millis());
  }

  // e) Creem la col·lecció diària (una imatge per data)
  var coleccioDiaria = ee.ImageCollection.fromImages(
    distintesDates.aggregate_array('date').map(function(d) {
      return grupPerData(ee.Feature(null, {date: ee.String(d)}));
    })
  );

  /***** FUNCIÓ PER CALCULAR EL % DE NÚVOLS UTILITZANT MODIS ******/
  /**
   * La banda "state_1km" de MODIS codifica informació sobre núvols
   * Especificació: https://lpdaac.usgs.gov/products/mod09ga_v006/
   * Núvols: bits 0-1 (00 = cel clar, 01/10/11 = núvols)
   */
  function calculaPercentNubositat(imatge) {
    var state1km = imatge.select('state_1km');
    // Extraiem els bits 0-1 de la banda `state_1km`
    var cloudMask = state1km.bitwiseAnd(3).neq(0); // Detecta píxels amb núvols

    // Comptem el nombre total de píxels dins del ROI
    var pixelsTotals = state1km.reduceRegion({
      reducer: ee.Reducer.count(),
      geometry: roi,
      scale: 1000,       // Resolució de MODIS (1000m), banda 'stake_1km'
      maxPixels: 1e13
    }).get('state_1km');

    // Comptem el nombre de píxels nublats dins del ROI
    var pixelsNuvols = cloudMask.reduceRegion({
      reducer: ee.Reducer.sum(),
      geometry: roi,
      scale: 1000,
      maxPixels: 1e13
    }).get('state_1km');

    // Calculem el % de núvols
    var percentNuvols = ee.Number(pixelsNuvols)
                          .divide(ee.Number(pixelsTotals))
                          .multiply(100);

    return imatge.set('PERCENT_NUVOLOSITAT', percentNuvols);
  }

  // f) Calculem % núvols a totes les imatges
  var coleccioAmbNuvols = coleccioDiaria.map(calculaPercentNubositat);

  return coleccioAmbNuvols;
}

// 3) Definim l’interval de dates (1 de gener 2000 a 1 de gener 2001)
var startDate = ee.Date.fromYMD(2010, 1, 1);
var endDate   = ee.Date.fromYMD(2011, 1, 1);

// 4) Creem la col·lecció amb % núvols per tot l'any
var coleccioMODIS = creaColleccioAmbNuvols_MODIS(startDate, endDate);

// 5) Convertim cada imatge en un Feature (filera) amb data i % núvols
var taulaMODIS = coleccioMODIS.map(function(img) {
  return ee.Feature(null, {
    'date': img.get('date'),
    'percent_nuvolositat': img.get('PERCENT_NUVOLOSITAT')
  });
});

// 6) Definim la tasca d’export a CSV
Export.table.toDrive({
  collection: taulaMODIS,
  description: 'Taula_nuvolositat_2010_Andorra',
  folder: 'ARI',  // Canvia pel nom de la carpeta del teu Drive, si escau
  fileFormat: 'CSV'
});

// 7) Imprimim a la consola per comprovar la col·lecció
print('Col·lecció de l’any 2010 (1 de gen fins 1 de gen 2011):', coleccioMODIS);
```

### Columnes de la taula exportada:

| Columna              | Descripció                              |
|-----------------------|------------------------------------------|
| `date`               | Data en format YYYY-MM-DD               |
| `percent_nuvolositat`| Percentatge de píxels classificats com núvols |

### Recursos addicionals:
- [Documentació oficial de Google Earth Engine](https://developers.google.com/earth-engine).


