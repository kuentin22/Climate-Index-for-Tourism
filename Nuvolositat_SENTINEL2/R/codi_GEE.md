# Codi GEE per calcular el % de núvols a Andorra (2019-Actualitat)

## Introducció
Aquest codi calcula el percentatge de núvols diaris a la regió d'Andorra utilitzant les imatges del satèl·lit **Sentinel-2** (L2A i L2B). El resultat final s'exporta com un fitxer CSV amb el % de núvolositat per cada dia.

> **Nota**: Aquest codi utilitza un fitxer *shapefile* d’Andorra que has d’haver pujat al teu espai d’*assets* a Google Earth Engine.

## Característiques del codi:
- Utilitza el satèl·lit Sentinel-2 amb resolució 10x10m.
- Genera mosaics diaris combinant diferents "tiles".
- Càlcul del percentatge de núvols basat en la banda *SCL*.

## Passos del codi:
1. Definició de la regió d'interès (ROI).
2. Filtratge d’imatges per dates i regió.
3. Creació de mosaics diaris per cada data.
4. Càlcul del % de núvols.
5. Exportació dels resultats a CSV.

## Codi complet (Google Earth Engine)
```js
// DEFINICIÓ DE LA REGION OF INTEREST (ROI)
var table = ee.FeatureCollection("projects/ee-my-aquintanac01/assets/Andorra");
var roi = table.geometry(); // Converteix el shapefile a geometria

// 2024 //
/***** 
 * Calculem el % de núvols (mosaic diari Sentinel-2)
 * del 1 de gener de x any fins a l’1 de gener de x+1 en un sol CSV.
 *****/

// 1) Funció principal que, donades data inicial i final, crea una col·lecció
//    on cada dia té un mosaic diari i una propietat amb el % de núvols.
function creaColleccioMosaicAmbNuvols(startDate, endDate) {
  
  // a) CARREGUEM I FILTREM IMATGES DE LA COL·LECCIÓ SENTINEL-2
  var coleccioS2 = ee.ImageCollection('COPERNICUS/S2_SR')
    .filterDate(startDate, endDate)
    .filterBounds(roi);
  
  // b) Afegim un atribut "date" (String) a cada imatge (format YYYY-MM-dd)
  var coleccioS2AmbData = coleccioS2.map(function(img) {
    var dataStr = ee.Date(img.get('system:time_start')).format('YYYY-MM-dd');
    return img.set('date', dataStr);
  });
  
  // c) Extreiem dates únique
  var distintesDates = coleccioS2AmbData.distinct('date');
  
  // d) Funcio per crear un mosaic per cada dia
  function mosaicPerData(feature) {
    var dataStr = ee.String(feature.get('date'));
    var imatgesMismaData = coleccioS2AmbData.filter(ee.Filter.eq('date', dataStr));
    var mosaic = imatgesMismaData.mosaic(); // combina "tiles" del mateix dia
    return mosaic
      .set('date', dataStr)
      .set('system:time_start', ee.Date(dataStr).millis());
  }
  
  // e) Creem la col·lecció mosaicada (una imatge per data)
  var coleccioMosaics = ee.ImageCollection.fromImages(
    distintesDates.aggregate_array('date').map(function(d) {
      return mosaicPerData(ee.Feature(null, {date: ee.String(d)}));
    })
  );
  
/***** 2) FUNCIÓ PER CALCULAR EL % DE NÚVOLS DINS LA ROI ******/
/** 
 * Sentinel-2 conté la banda "SCL" (Scene Classification Layer),
 * on cada píxel té un codi segons el tipus de superfície/condició:
 *   0 => No data
 *   1 => Saturat o defectuós
 *   2 => Àrees fosques
 *   3 => Cloud shadow (ombra de núvol)
 *   4 => Vegetació
 *   5 => No vegetat?
 *   6 => Aigua
 *   7 => No classificat
 *   8 => Cloud medium probability (núvol amb probabilitat mitjana)
 *   9 => Cloud high probability (núvol amb alta probabilitat)
 *   10 => Cirrus fins
 *   11 => neu o gel
 * 
 *   Els valors d'interès per a núvols solen ser 8 (Cloud medium prob),
 *   9 (Cloud high prob) i 10 (Cirrus fins)
 */
 
  function calculaPercentNubositat(imatge) {
    // Seleccionem la banda SCL
    var scl = imatge.select('SCL');
    // Màscara per detectar núvols (SCL = 8, 9 o 10)
    var mascaraNuvols = scl.eq(8).or(scl.eq(9)).or(scl.eq(10));
    
    // Comptem el nombre total de píxels dins del ROI
    var pixelsTotals = scl.reduceRegion({
      reducer: ee.Reducer.count(),
      geometry: roi,
      scale: 10,        // resolució de Sentinel-2
      maxPixels: 1e13   // per evitar errors en regions grans
  }).get('SCL');      // ens diu quants píxels hi ha
    
  // (f) Comptem el nombre de píxels "nublats" dins del ROI
    //    Amb la màscara 0/1, 'sum()' calcula directament els píxels "true"
    var pixelsNuvols = mascaraNuvols.reduceRegion({
      reducer: ee.Reducer.sum(),
      geometry: roi,
      scale: 10,
      maxPixels: 1e13
    }).get('SCL');
    
    // Calculem el % de núvols (núvols / total) * 100
    var percentNuvols = ee.Number(pixelsNuvols)
                          .divide(ee.Number(pixelsTotals))
                          .multiply(100);
    
    // Retornem la imatge amb una nova propietat que indica el % de núvols
    return imatge.set('PERCENT_NUVOLOSITAT', percentNuvols);
  }
  
  // g) Calculem % núvols a totes les imatges mosaicades
  var coleccioMosaicsAmbNuvols = coleccioMosaics.map(calculaPercentNubositat);
  
  return coleccioMosaicsAmbNuvols;
}

// 3) Definim l’interval de dates (p.ex.: 1 de gener 2024 a 1 de gener 2025)
var startDate = ee.Date.fromYMD(2024, 1, 1);
var endDate   = ee.Date.fromYMD(2025, 1, 1);

// 4) Creem la col·lecció mosaicada amb % núvols per tot l'any
var coleccio = creaColleccioMosaicAmbNuvols(startDate, endDate);

// 5) Convertim cada imatge en un Feature (filera) amb data i % núvols
var taula = coleccio.map(function(img) {
  return ee.Feature(null, {
    'date': img.get('date'),
    'percent_nuvolositat': img.get('PERCENT_NUVOLOSITAT')
  });
});

// 6) Exportem la taula generada a CSV 
Export.table.toDrive({
  collection: taula,
  description: 'Taula_nuvolositat_2024_Andorra_original',
  folder: 'ARI',  // Canvia pel nom de la carpeta del teu Drive, si escau
  fileFormat: 'CSV'
});

// 7) Imprimim a la consola per comprovar la col·lecció
print('Col·lecció de l’any 2024 (1 de gen fins 1 de gen 2025):', coleccio);
```

### Columnes de la taula exportada:

| Columna              | Descripció                              |
|-----------------------|------------------------------------------|
| `date`               | Data en format YYYY-MM-DD               |
| `percent_nuvolositat`| Percentatge de píxels classificats com núvols |

### Recursos addicionals:
- [Documentació oficial de Google Earth Engine](https://developers.google.com/earth-engine).
- [Tutorials de Sentinel-2](https://sentinel.esa.int/web/sentinel/user-guides/sentinel-2-msi).




