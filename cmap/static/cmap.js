"use strict";

class MapRunner {
   constructor(options) {
      self.url      = "/cgi-bin/cmap.pl";
      this.markers  = [];
      this.line     = 0;
      this.stopMap  = {};
      this.lineMap  = {};
      this.defaultPos = {zoom:13, center:{lat:29.649813,lng:-82.316970}}

      this.GetData();
      this.CreateMap();
      this.CreatePopup();

      $(" #date").get(0).valueAsDate = new Date();
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
         position.isstop -= 0;
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

   async CreateMap(options) {
      this.o = Object.assign(this.defaultPos, options);
      this.map = new google.maps.Map(document.getElementById('map'), this.o);

      //const { Map } = await google.maps.importLibrary("maps");
      //this.map = new Map(document.getElementById("map"), {
      //   center:{lat:29.649813,lng:-82.316970},
      //   zoom:13 
      //});
   }

   CreatePopup() {
      this.popup = new google.maps.InfoWindow({
         content: "<div>This is a test</div>",
      });
   }

   MarkerIcon(time) {
      let hour  = time.substr(11,2) - 0;
      let zhour = (hour + 19) % 24;
      let label = (hour - 1) % 12 + 1;
      let fs    = label < 10 ? 10   : 7.5;
      let fx    = label < 10 ? 3.75 : 2;
      let fy    = label < 10 ? 10   : 9;
      let color = zhour < 7  ? "hsla(144, 100%, 18%, 0.7)" :
                  zhour < 15 ? "hsla(233, 100%, 40%, 0.7)" :
                               "hsla(0  , 100%, 38%, 0.7)" ;
      let template = 
         "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 14 20' height='200' width='140'>" +
            "<path d='M7 0 L14 3 7 20 0 3 Z' fill='{color}' />" +
            "<text fill='white' font-size='{fs}' font-family='Verdana' x='{fx}' y='{fy}'>{label}</text>" +
         "</svg>";
      let svg = template.replace(/{color}/, color).replace(/{fs}/,fs).replace(/{fx}/,fx).replace(/{fy}/,fy).replace(/{label}/,label);
      return "data:image/svg+xml," + svg;
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
      if (!stops) 
         return;
      for (let stop of stops) {
         let marker = new google.maps.Marker({
             position: {lat:stop.lat - 0,lng:stop.lon - 0},
             map: this.map,
             icon: {url: this.MarkerIcon(stop.time), scaledSize: new google.maps.Size(35, 35)},
             optimized: false
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
      this.popup.setContent(this.GetInfo(marker.stop));
      this.popup.open({
         anchor: marker,
         map: this.map,
         shouldFocus: false,
      });
   }

   GetInfo(stop) {
      let gtime = stop.time.split(" ")[1];
      let parts = gtime.split(":");
      let pday = parts[0] - 0  > 11 ? "pm" : "am";
      if (parts[0] > 12) parts[0] -= 12;
      let txt = `<div>${parts[0]}:${parts[1]}:${parts[2]}${pday} for ${stop.duration} <a href="http://maps.google.com/maps?q=${stop.lat},${stop.lon}&z=15" target="_blank">map</a></div>`;
      return txt;
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

  //(g=>{var h,a,k,p="The Google Maps JavaScript API",c="google",l="importLibrary",q="__ib__",m=document,b=window;b=b[c]||(b[c]={});var d=b.maps||(b.maps={}),r=new Set,e=new URLSearchParams,u=()=>h||(h=new Promise(async(f,n)=>{await (a=m.createElement("script"));e.set("libraries",[...r]+"");for(k in g)e.set(k.replace(/[A-Z]/g,t=>"_"+t[0].toLowerCase()),g[k]);e.set("callback",c+".maps."+q);a.src=`https://maps.${c}apis.com/maps/api/js?`+e;d[q]=f;a.onerror=()=>h=n(Error(p+" could not load."));a.nonce=m.querySelector("script[nonce]")?.nonce||"";m.head.append(a)}));d[l]?console.warn(p+" only loads once. Ignoring:",g):d[l]=(f,...n)=>r.add(f)&&u().then(()=>d[l](f,...n))})({
  //  key: "AIzaSyBVLyUcEXJgaDleyYLIkqX6D9sA_CSHH78",
  //  v: "weekly",
  //});

   var mr = new MapRunner(options);
});


