#!perl
#
# Craig Fitzgeraldd

use warnings;
use strict;
use JSON;
use Gnu::TinyDB;
use Gnu::CGIUtil qw(Route ReturnText ReturnJSON);

my @routes = (
#   {method => "GET", resource => "stops",     fn => \&GetStops    },
#   {method => "GET", resource => "positions", fn => \&GetPositions},
   {method => "GET", resource => "places",     fn => \&GetPlaces   },
   {method => "GET", resource => "paths",      fn => \&GetPaths    },
);

MAIN:
   Connection("geo");
   Route(@routes);
   exit(0);

#sub GetStops {
#   my ($id, $params, $resource) = @_;
#
#   my $sql = "select id,time,duration,lat,lon from craigpos where isstop=1";
#   $sql .= " and DATE(time) = '$params->{date}'" if $params->{date};
#   $sql .= " order by id";
#   ReturnJSON(FetchArray($sql));
#}
#
#sub GetPositions {
#   my ($id, $params, $resource) = @_;
#
#   my $sql = "select id,isstop,time,duration,lat,lon from craigpos";
#   $sql .= " where DATE(time) = '$params->{date}'" if $params->{date};
#   $sql .= " order by id";
#   ReturnJSON(FetchArray($sql));
#}

sub GetPlaces {
   my ($id, $params, $resource) = @_;

   my $sql = "select * from places";
   $sql .= " where DATE(time) = '$params->{date}'" if $params->{date};
   $sql .= " order by id";
   ReturnJSON(FetchArray($sql));
}

   

sub GetPaths {
   my ($id, $params, $resource) = @_;

   my $sql = "select * from paths";
   $sql .= " where DATE(time) = '$params->{date}'" if $params->{date};
   $sql .= " order by id";

   my $paths = FetchArray($sql);
   map{MapLocations($_)} @{$paths};

   my $pathMap = {map{$_->{id} => $_} @{$paths}};

   my $waypoints = FetchArray("select * from waypoints order by id");
   foreach my $point (@{$waypoints}) {
      my $path = $pathMap->{$point->{pathid}};
      next unless $path;
      push(@{$path->{waypoints}}, $point);
   }
   ReturnJSON($paths);
}


sub MapLocations {
   my ($path) = @_;

   $path->{startloc} = {lat => $path->{startlat}, lng => $path->{startlng}};
   $path->{endloc}   = {lat => $path->{endlat}, lng => $path->{endlng}};
   delete @{$path}{qw(startlat startlng endlat endlng)};
}
