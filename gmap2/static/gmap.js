"use strict";

class MapRunner {
   constructor(options) {
      self.url      = "/cgi-bin/gmap-new.pl";
//      this.line     = 0;
//      this.stopMap  = {};
//      this.lineMap  = {};
//      this.placeMap =  {};
//      this.pathMap  =  {};

      this.dataMap    = {};  
      this.paths      = [];
      this.markers    = [];

      this.bounds     = {};
      this.defaultPos = {zoom:13, center:{lat:29.649813,lng:-82.316970}}

      this.GetData();
      this.CreateMap();
      this.CreatePopup();

      $("#date").get(0).valueAsDate = new Date();
      $("#date").on("change", (e) => this.DateChange(e));
      $("#prev").on("click" , (e) => this.NextDate(-1));
      $("#next").on("click" , (e) => this.NextDate(1));
      $(window ).on("keydown",(e) => this.KeyDown(e));
   }

   GetData() {
      this.dataMap =  {};

      this.GetPlaces();
      this.GetPaths();
   }

   // place:
   //    id
   //    time
   //    duration
   //    address
   //    loc
   //       lat
   //       lng
   //
   async GetPlaces() {
      let response = await fetch(`${self.url}/places`);
      let places = await response.json();

      for (let place of places) {
         let date = this.DateFromTime(place.time);
         if (!this.dataMap.hasOwnProperty(date))
            this.dataMap[date] = {places: [], paths: []};
         this.dataMap[date].places.push(place);
      }
   }


   // path:
   //    id
   //    startTime
   //    endTime
   //    startLoc
   //       lat
   //       lng
   //    endLoc
   //       lat
   //       lng
   //    waypoints []
   //    mode
   //
   //
   async GetPaths() {
      let response = await fetch(`${self.url}/paths`);
      let paths = await response.json();

      for (let path of paths) {
         this.VivifyPath(path)
         let date = this.DateFromTime(path.starttime);
         if (!this.dataMap.hasOwnProperty(date))
            this.dataMap[date] = {paths: [], paths: []};
         this.dataMap[date].paths.push(path);
      }
   }

   VivifyPath(path) {
      path.startloc.lat -= 0;
      path.startloc.lng -= 0;
      path.endloc.lat   -= 0;
      path.endloc.lng   -= 0;
      if (path.waypoints)
         path.waypoints.map((p) => {p.lat -= 0; p.lng -= 0});
   }

   CreateMap(options) {
      this.o = Object.assign(this.defaultPos, options);
      this.map = new google.maps.Map(document.getElementById('map'), this.o);

      // todo: move this stuff
      //this.dirSvc    = new google.maps.DirectionsService
      //this.renderSvc = new google.maps.DirectionsRenderer

   }

   CreatePopup() {
      this.popup = new google.maps.InfoWindow({
         content: "<div>This is a test</div>",
      });
   }

   PlotData(date) {
      this.ClearMap();

      this.bounds = new google.maps.LatLngBounds();
      let data = this.dataMap[date];
      if (!data) return;

      if (data.paths)  data.paths.map((path)  => this.PlotPath(path));
      if (data.places) data.places.map((place) => this.PlotPlace(place));

      if ($("#reposition").prop("checked")) this.map.fitBounds(this.bounds);
   }

   async PlotPath(path) {
      //this.line = new google.maps.Polyline(opt);
      //this.line.setMap(this.map);
      let dirService = new google.maps.DirectionsService;
      let waypts     = [];   // google.maps.DirectionsWaypoint

      if (path.waypoints) {
         waypts = path.waypoints.map ((pt) => {
            return {location: this.MakeLatLng(pt), stopover: false}
         });
      }

      await dirService
         .route({
            optimizeWaypoints: true,
            origin:            path.startloc,
            destination:       path.endloc,
            waypoints:         waypts,
            travelMode:        this.GetTravelMode(path.mode)
//            travelMode:        google.maps.TravelMode.DRIVING
         })
         .then((response) => {
            let renderer = new google.maps.DirectionsRenderer;
            renderer.setMap(this.map);
            renderer.setDirections(response);
            this.paths.push(renderer);
         })
         .catch((e) => 
            window.alert("Directions request failed due to " + e.message)
         );
   }

   MakeLatLng(o) {
      return new google.maps.LatLng(o.lat-0, o.lng-0);
      
   }

   GetTravelMode(mode) {
      switch(mode) {
         case "DRIVE"  : return google.maps.TravelMode.DRIVING;
         case "BICYCLE": return google.maps.TravelMode.BICYCLING;
         case "WALK"   : return google.maps.TravelMode.WALKING;
      }
      return google.maps.TravelMode.DRIVING;
   }

   PlotPlace(place) {
      let marker = new google.maps.Marker({
          position: {lat:place.lat - 0, lng:place.lng - 0},
          map: this.map,
      });
      marker.place = place;
      marker.addListener("click", (e) => this.ShowPopup(e, marker));
      this.markers.push(marker);
      this.bounds.extend(new google.maps.LatLng(place.lat, place.lng));
   }

   ClearMap() {
      this.markers.map(m => m.setMap(null));
      this.markers = [];

      this.paths.map(p => p.setMap(null));
      this.paths   = [];
   }

   ShowPopup(e, marker) {
      this.popup.setContent(this.GetInfo(marker.stop));
      this.popup.open({
         anchor: marker,
         map: this.map,
         shouldFocus: false,
      });
   }

   GetInfo(place) {
      let gtime = place.time.split(" ")[1];
      let parts = gtime.split(":");
      let pday = parts[0] - 0  > 11 ? "pm" : "am";
      if (parts[0] > 12) parts[0] -= 12;
      let txt = `<div>${parts[0]}:${parts[1]}:${parts[2]}${pday} for ${place.duration} <a href="http://maps.google.com/maps?q=${place.lat},${place.lng}&z=15" target="_blank">map</a></div>`;
      return txt;
   }

   DateChange() {
      let date = $("#date").val();
      this.PlotData(date);
   }

   NextDate(delta) {
      let date = new Date($("#date").val());
      let ms = date.getTime() + delta * 1000 * 60 * 60 * 24;
      let d1 = new Date(ms);
      let v1 = d1.toISOString().split('T')[0];
      $("#date").val(v1);
      this.DateChange();
   }

   KeyDown(e) {
      switch(e.originalEvent.which){
         case 37: return this.NextDate(-1); // left 
         case 38: return this.NextDate(1 ); // up   
         case 39: return this.NextDate(1 ); // right
         case 40: return this.NextDate(-1); // down 
      }
   }

   DateFromTime(time) {
      return time.split(" ")[0];
   }
}

$(function() {
   let options = {zoom:13, center:{lat:29.649813,lng:-82.316970}};
   var mr = new MapRunner(options);
});


