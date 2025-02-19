# Codi GEE per calcular la velocitat mitjana diària del vent a Andorra (1981-2024)

## Introducció
Aquest codi calcula la velocitat mitjana diària del vent a la regió d'Andorra utilitzant dades de reanàlisi **ERA5** del ECMWF. El resultat final s'exporta com un fitxer CSV amb la velocitat del vent expressada en m/s.

> **Nota**: Aquest codi utilitza un fitxer *shapefile* d’Andorra que has d’haver pujat al teu espai d’*assets* a Google Earth Engine.

## Característiques del codi:
- Utilitza dades d'ERA5-HOURLY amb una resolució espacial de ~9 km.
- Selecciona els components del vent en les direccions u (est-oest) i v (nord-sud).
- La velocitat del vent s'obté aplicant la fórmula següent:$$ V = \sqrt{u^2 + v^2} $$
- El resultat final és una taula CSV amb la data i la velocitat del vent mitjana diària (m/s).

## Passos del codi:
1. Definició de la regió d'interès (ROI).
2. Filtrar les dades d'ERA5 pel període desitjat.
3. Calcular la velocitat mitjana diària del vent en m/s
4. Exportació dels resultats a CSV.

## Codi complet (Google Earth Engine)
```js
// DEFINICIÓ DE LA REGION OF INTEREST (ROI)
var table = ee.FeatureCollection("projects/ee-my-aquintanac01/assets/Andorra");
var roi = table.geometry(); // Converteix el shapefile a geometria

// 2024 //
/***** 
 * Calculem la velociitat mitjana diària del vent a Andorra
 * del 1 de gener de x any fins a l’1 de gener de x+1 en un sol CSV.
 *****/

/***** 1️⃣ FUNCIÓ PER OBTENIR LA VELOCITAT DEL VENT ******/
function obtenirVelocitatVentERA5(startDate, endDate) {
  
  // 🔹 Carreguem la col·lecció ERA5 i filtrem per dates i ROI
  var coleccioERA5 = ee.ImageCollection('ECMWF/ERA5/HOURLY')
    .filterDate(startDate, endDate)
    .filterBounds(roi)
    .select(['u_component_of_wind_10m', 'v_component_of_wind_10m']);

  // 🔹 Generem una llista de dates úniques dins del període
  var datesUniques = ee.List(coleccioERA5.aggregate_array('system:time_start'))
    .map(function(t) { return ee.Date(t).format('YYYY-MM-dd'); })
    .distinct();

  // 🔹 Funció per calcular la velocitat mitjana diària del vent
  function mitjanaDiariaVent(dateStr) {
    var date = ee.Date(dateStr);
    var imatgesDelDia = coleccioERA5.filterDate(date, date.advance(1, 'day'));

    // ✅ Càlcul de la velocitat del vent: sqrt(u² + v²)
    var imatgeVelocitat = imatgesDelDia.map(function(img) {
      var u = img.select('u_component_of_wind_10m');
      var v = img.select('v_component_of_wind_10m');
      var velocitatVent = u.pow(2).add(v.pow(2)).sqrt();  
      return velocitatVent.rename('wind_speed_m_s');
    }).mean();  // Mitjana diària

    // ✅ Convertim cada imatge en un Feature amb data i velocitat
    return ee.Feature(null, {  
      'date': dateStr,
      'wind_speed_m_s': ee.Number(imatgeVelocitat.reduceRegion({
        reducer: ee.Reducer.mean(),
        geometry: roi,
        scale: 9000,  
        maxPixels: 1e13
      }).get('wind_speed_m_s')).format('%.3f')  // 💾 Format correcte per Excel
    });
  }

  // 🔹 Aplicar la funció a totes les dates
  return ee.FeatureCollection(datesUniques.map(mitjanaDiariaVent));
}

/***** 2️⃣ DEFINIM L'INTERVAL DE DATES ******/
var startDate = ee.Date.fromYMD(2024, 1, 1);
var endDate   = ee.Date.fromYMD(2025, 1, 1);

/***** 3️⃣ CREEM LA COL·LECCIÓ AMB LA VELOCITAT DEL VENT ******/
var taula = obtenirVelocitatVentERA5(startDate, endDate);

/***** ️4️⃣ EXPORTACIÓ DE RESULTATS EN FORMAT CSV ******/
Export.table.toDrive({
  collection: taula,
  description: 'Taula_velocitat_vent_2024_Andorra',
  folder: 'ARI',  // 📂 Canvia-ho segons el teu Drive
  fileFormat: 'CSV',
  selectors: ['date', 'wind_speed_m_s'] // 📌 Només aquestes columnes (sense JSON)
});

/***** 5️⃣ IMPRIMIM ELS RESULTATS PER COMPROVAR ******/
print('📊 Col·lecció de velocitat del vent ERA5 per a Andorra (2024):', taula);
```

### Columnes de la taula exportada:

| Columna              | Descripció                              |
|----------------------|------------------------------------------|
| `date`               | Data en format YYYY-MM-DD               |
| `wind_speed_m_s`     | Velocitat mitjana del vent (m/s) |

### Recursos addicionals:
- [Documentació oficial de Google Earth Engine](https://developers.google.com/earth-engine).
- Si necessitem modificar el codi per calcular la velocitat en km/h, només caldria afegir:
```js
   - var velocitat_kmh = velocitatVent.multiply(3.6).rename('wind_speed_kmh');
```




