#!perl
#
# select min(lat), max(lat), min(lon), max(lon),  max(lat)-min(lat) as dlat, max(lon)-min(lon) as dlon from stops where location like "%2nd Avenue%";
#
# eval (29.651701143613035 - 29.650280057552443)/2
# 0.000710543
# 
# eval 29.650280057552443 + (29.651701143613035 - 29.650280057552443)/2
# 29.6509906006
# 
# eval (-82.3194931476251 - -82.31814889346224)/2
# -0.0006721271
# 
# eval -82.3194931476251 - (-82.3194931476251 - -82.31814889346224)/2
# -82.3188210205

use warnings;
use strict;
use JSON;
use Gnu::TinyDB;
use Gnu::StringUtil  qw(Chip Trim TrimList _CSVParts LineString CleanInputLine);
use Gnu::Template qw(Template Usage);
use Gnu::ArgParse;

my $LOCS = {
   craig  => {lat=>29.6178683333099  , lon=>-82.3517873495817 , leeway=>0.0005 },
   corny  => {lat=>29.649860303369643, lon=>-82.31680335259082, leeway=>0.0005 },
   white  => {lat=>29.64991934064076 , lon=>-82.31922652992795, leeway=>0.0005 },
   gary   => {lat=>29.66046172186144 , lon=>-82.18477626581182, leeway=>0.0005 },
   inn    => {lat=>29.6509906006     , lon=>-82.3188210205    , leeway=>0.00075},
   chalet => {lat=>29.664012016217878, lon=>-82.34611535720249, leeway=>0.0005 },
   newguy => {lat=>29.696877710236716, lon=>-82.35741783286224, leeway=>0.0005 },
   matt   => {lat=>29.83244221104071 , lon=>-82.60120848674829, leeway=>0.0005 },
   monique=> {lat=>29.664112030777734, lon=>-82.34515105262169, leeway=>0.0005 },
   rocco  => {lat=>29.650778913772328, lon=>-82.31419038238347, leeway=>0.0005 },
};

MAIN:
   Connection("geo");

   ArgBuild("*^leeway= *^debug *^positions *^help");
   ArgParse(@ARGV) or die ArgGetError();
   Usage() if ArgIs("help") || !ArgIs();

   QueryPositions() if ArgIs("positions");
   QueryStops()     if !ArgIs("positions");
   exit(0);


sub QueryPositions {
   my $what = ArgGet();

   my $loc    = $LOCS->{$what} or die "what is $what?";
   my $leeway = ArgIs("leeway") ? ArgGet("leeway") : $ loc->{leeway};
   my $fence  = GeoFence($loc, $leeway);

   my $sql =
      "SELECT * FROM positions WHERE " .
      "isstop = 1 AND " .
      "lat > $fence->{it} AND lat < $fence->{xt} AND " .
      "lon > $fence->{in} AND lon < $fence->{xn}";

   my $rows = FetchArray($sql);
   map {print "$_->{time} $_->{duration} $_->{location} $_->{lat} $_->{lon}\n"} @{$rows};
}



sub QueryStops {
   my $what = ArgGet();

   my $loc    = $LOCS->{$what} or die "what is $what?";
   my $leeway = ArgIs("leeway") ? ArgGet("leeway") : $ loc->{leeway};
   my $fence  = GeoFence($loc, $leeway);

   my $sql =
      "SELECT * FROM stops WHERE " .
      "lat > $fence->{it} AND lat < $fence->{xt} AND " .
      "lon > $fence->{in} AND lon < $fence->{xn}";

   my $rows = FetchArray($sql);
   map {print "$_->{Begin} $_->{End} $_->{Description}      ($_->{Location})\n"} @{$rows};
}

sub GeoFence {
   my ($loc, $leeway) = @_;

   return {
      it => $loc->{lat} - $leeway, 
      xt => $loc->{lat} + $leeway,
      in => $loc->{lon} - $leeway, 
      xn => $loc->{lon} + $leeway,
   }
}

__DATA__

[usage]
loadstops usage...   

