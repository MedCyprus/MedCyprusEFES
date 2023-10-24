<script type="text/javascript">
/* For polygons coordinates */
    function chunkArray(myArray, chunk_size){
    var index = 0;
    var arrayLength = myArray.length;
    var tempArray = [];
    for (index = 0; index &lt; arrayLength; index += chunk_size) {
    myChunk = myArray.slice(index, index+chunk_size);
    tempArray.push(myChunk);
    }
    return tempArray;
    }
    
    /*Maps layers*/
    var osm = L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: 'Map data: &lt;a href="https://www.openstreetmap.org/copyright"&gt;OpenStreetMap&lt;/a&gt;'
    }); 
    var terrain = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Shaded_Relief/MapServer/tile/{z}/{y}/{x}', {
    attribution: 'Tiles and source: Esri',
    maxZoom: 13
    });
    var dare = L.tileLayer('https://dh.gu.se/tiles/imperium/{z}/{x}/{y}.png', {
    minZoom: 4,
    maxZoom: 11,
    attribution: 'Data: &lt;a href="https://imperium.ahlfeldt.se/"&gt;DARE&lt;/a&gt; CC BY 4.0'
    }); 
    var Stamen_Terrain = L.tileLayer('https://stamen-tiles-{s}.a.ssl.fastly.net/terrain/{z}/{x}/{y}{r}.{ext}', {
    attribution: 'Tiles: &lt;a href="http://stamen.com"&gt;Stamen&lt;/a&gt;, Data: &lt;a href="https://www.openstreetmap.org/copyright"&gt;OSM&lt;/a&gt;', 
    subdomains: 'abcd', minZoom: 0, maxZoom: 18, ext: 'png'
});
    var Esri_WorldStreetMap = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}', {
    attribution: 'Tiles and source: Esri'
});
    var Esri_WorldTopoMap = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}', {
    attribution: 'Tiles: Esri'
});

// satellite
var Esri_WorldImagery = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
    attribution: 'Tiles and source: Esri'
});

var CartoDB_Positron = L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
    attribution: '&lt;a href="https://www.openstreetmap.org/copyright"&gt;OSM&lt;/a&gt;, &lt;a href="https://carto.com/attributions"&gt;CARTO&lt;/a&gt;', 
    subdomains: 'abcd', maxZoom: 20
});

var CartoDB_Voyager = L.tileLayer('https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png', {
    attribution: '&lt;a href="https://www.openstreetmap.org/copyright"&gt;OSM&lt;/a&gt;, &lt;a href="https://carto.com/attributions">CARTO&lt;/a&gt;', 
    subdomains: 'abcd', maxZoom: 20
});

        
    var all_places = [];
    var select_linked_places = [];
    var LeafIcon = L.Icon.extend({ options: {iconSize: [30, 30]} });
    var markerIcon = new LeafIcon({iconUrl: '../../../assets/images/marker-icon.png'});
    
    for (var [key, value] of Object.entries(points)) {
    all_places.push(L.marker([value.substring(0, value.lastIndexOf(",")), value.substring(value.lastIndexOf(",") +1)], {icon: markerIcon, id:key.substring(key.lastIndexOf("@") +1)}).bindPopup('&lt;a href="#0"&gt;'.replace("0", key.substring(key.lastIndexOf("@") +1)) + key.substring(0, key.indexOf("#")) + '&lt;/a&gt; &lt;span class="block"&gt;Inscriptions: ' + key.substring(key.indexOf("#") +1, key.lastIndexOf("@")) + '&lt;/span&gt; &lt;span class="block"&gt;Coordinates: ' + value + '&lt;/span&gt;'));
    };
     
    var toggle_places = L.layerGroup(all_places);
    var toggle_select_linked_places = L.layerGroup(select_linked_places);
    var baseMaps = {"Carto Voyager": CartoDB_Voyager, "OSM": osm, "Terrain": terrain, "Esri Satellite": Esri_WorldImagery};
    var overlayMaps = { };
    var layers = [CartoDB_Voyager, osm, terrain, Esri_WorldImagery];
    var markers = all_places;
    
    function openPopupById(id){ for(var i = 0; i &lt; markers.length; ++i) { if (markers[i].options.id == id){ markers[i].openPopup(); }; }}
    
    function displayById(id){ for(var i = 0; i &lt; markers.length; ++i) { if (markers[i].options.id == id){
    toggle_select_linked_places.addLayer(markers[i]); 
    }; }}
</script>