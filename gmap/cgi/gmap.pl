#!perl
#
# Craig Fitzgeraldd

use warnings;
use strict;
use JSON;
use Gnu::TinyDB;
use Gnu::CGIUtil qw(Route ReturnText ReturnJSON);

my @routes = (
   {method => "GET", resource => "stops",     fn => \&GetStops    },
   {method => "GET", resource => "positions", fn => \&GetPositions},
);

MAIN:
   Connection("geo");
   Route(@routes);
   exit(0);

sub GetStops {
   my ($id, $params, $resource) = @_;

   my $sql = "select id,time,duration,lat,lon from craigpos where isstop=1";
   $sql .= " and DATE(time) = '$params->{date}'" if $params->{date};
   $sql .= " order by id";
   ReturnJSON(FetchArray($sql));
}

sub GetPositions {
   my ($id, $params, $resource) = @_;

   my $sql = "select id,isstop,time,duration,lat,lon from craigpos";
   $sql .= " where DATE(time) = '$params->{date}'" if $params->{date};
   $sql .= " order by id";
   ReturnJSON(FetchArray($sql));
}

