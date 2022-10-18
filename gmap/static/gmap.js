"use strict";

class MapRunner {
   constructor(options) {
      self.url      = "/cgi-bin/gmap.pl";
      this.markers  = [];
      this.line     = 0;
      this.stopMap  = {};
      this.lineMap  = {};
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

   async GetData() {
      let response = await fetch(`${self.url}/positions`);
      let positions = await response.json();
      this.stopMap = {};

      for (let position of positions) {
         let date = this.DateFromTime(position.time);
         if (!this.lineMap.hasOwnProperty(date))
            this.lineMap[date] = [];
         this.lineMap[date].push({lat:position.lat - 0, lng:position.lon - 0});

         if (!position.isstop) continue;
         if (!this.stopMap.hasOwnProperty(date))
            this.stopMap[date] = [];
         this.stopMap[date].push(position);
      }
   }

   CreateMap(options) {
      this.o = Object.assign(this.defaultPos, options);
      this.map = new google.maps.Map(document.getElementById('map'), this.o);
   }

   CreatePopup() {
      this.popup = new google.maps.InfoWindow({
         content: "<div>This is a test</div>",
      });
   }

   PlotStops(date) {
      this.ClearLinesAndStops();

      let bounds = new google.maps.LatLngBounds();
      let lineData = this.lineMap[date];
      if (lineData) {
         let opt = {
            path: lineData,
            geodesic: true,
            strokeColor: "#9900FF",
            strokeOpacity: 0.5,
            strokeWeight: 3,
         };
         this.line = new google.maps.Polyline(opt);
         this.line.setMap(this.map);
         lineData.map((pt) => bounds.extend(new google.maps.LatLng(pt.lat, pt.lng)));
      }
      let stops = this.stopMap[date];
      if (!stops) return;

      for (let stop of stops) {
         let marker = new google.maps.Marker({
             position: {lat:stop.lat - 0,lng:stop.lon - 0},
             map: this.map,
         });
         marker.stop = stop;
         marker.addListener("click", (e) => this.ShowPopup(e, marker));
         this.markers.push(marker);
         bounds.extend(new google.maps.LatLng(stop.lat, stop.lon));
      }

      if ($("#reposition").prop("checked")) this.map.fitBounds(bounds);
   }

   ClearLinesAndStops() {
      if (this.line)
         this.line.setMap(null);

      for (let marker of this.markers) {
         marker.setMap(null);
      }
      this.markers = [];
   }

   ShowPopup(e, marker) {
      this.popup.setContent(this.GetTitle(marker.stop));
      this.popup.open({
         anchor: marker,
         map: this.map,
         shouldFocus: false,
      });
   }

   GetTitle(stop) {
      let gtime = stop.time.split(" ")[1];
      let parts = gtime.split(":");
      let pday = parts[0] - 0  > 11 ? "pm" : "am";
      if (parts[0] > 12) parts[0] -= 12;
      return `${parts[0]}:${parts[1]}:${parts[2]}${pday} for ${stop.duration}`;
   }

   DateChange() {
      let date = $("#date").val();
      this.PlotStops(date);
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


