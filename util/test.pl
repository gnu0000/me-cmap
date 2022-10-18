#!perl

use warnings;
use strict;
use JSON;
use Time::Piece;
use POSIX qw(strftime);
use Time::Piece;
use Gnu::TinyDB;
use Gnu::StringUtil  qw(Chip Trim TrimList _CSVParts LineString CleanInputLine);
use Gnu::FileUtil    qw(SlurpFile);
use Gnu::Template    qw(Template Usage);
use Gnu::ArgParse;

MAIN:
   ArgBuild("*^debug *^help");
   ArgParse(@ARGV) or die ArgGetError();
   Usage() if ArgIs("help") || !ArgIs();
   Test(ArgGet());
   exit(0);


sub Test {
   my ($filespec) = @_;

   my $data = decode_json (SlurpFile($filespec));

   my $to = $data->{timelineObjects};

   foreach my $o (@{$to}) {
      foreach my $key (sort keys %{$o}) {
         PrintPlaceVisit     ($o->{$key}) if $key =~ /placeVisit/;
         PrintActivitySegment($o->{$key}) if $key =~ /activitySegment/;
         PrintWhatsThis      ($o->{$key}) if !$key =~ /placeVisit|activitySegment/;
      }
   }
}


sub PrintPlaceVisit {
   my ($o) = @_;

   my $lat   = $o->{location   }->{latitudeE7    } / 10000000;
   my $lon   = $o->{location   }->{longitudeE7   } / 10000000;
   my $addr  = $o->{location   }->{address       };
   my $tag   = $o->{location   }->{sourceInfo    }->{deviceTag};
   my $start = $o->{duration   }->{startTimestamp};
   my $end   = $o->{duration   }->{endTimestamp  };
   my $clat  = $o->{centerLatE7} / 10000000;
   my $clon  = $o->{centerLngE7} / 10000000;

   my $dt = TimeDelta($start,$end);

   print "PlaceVisit:\n";
   print "   loc: $lat, $lon\n";
   print "  cloc: $clat, $clon\n";
   print "  time: $start -> $end [$dt]\n";
   print "  addr: $addr\n";
   print "   tag: $tag\n";
}

sub PrintActivitySegment {
   my ($o) = @_;

   my $slat  = $o->{startLocation}->{latitudeE7    } / 10000000;
   my $slon  = $o->{startLocation}->{longitudeE7   } / 10000000;
   my $elat  = $o->{endLocation  }->{latitudeE7    } / 10000000;
   my $elon  = $o->{endLocation  }->{longitudeE7   } / 10000000;
   my $tag   = $o->{startLocation}->{sourceInfo    }->{deviceTag};
   my $start = $o->{duration     }->{startTimestamp};
   my $end   = $o->{duration     }->{endTimestamp  };

   my $dt = TimeDelta($start,$end);

   print "ActivitySegment:\n";
   print "   startloc: $slat, $slon\n";
   print "     endloc: $elat, $elon\n";
   print "       time: $start -> $end  [$dt]\n";
   print "   waypoints:\n";

   my $pts = $o->{waypointPath}->{waypoints};
   foreach my $pt (@{$pts}) {
      my $lat = $pt->{latE7} / 10000000;
      my $lon = $pt->{lngE7} / 10000000;
      print "      loc: $lat, $lon\n";
   }
}

sub PrintWhatsThis {
   my ($o) = @_;

   print "Unknown:\n";
}


sub TimeDelta {
   my ($begin, $end) = @_;

   my ($b, $e) = map Time::Piece->strptime(s/\.\d*Z?\z//r, '%Y-%m-%dT%H:%M:%SZ'), ($begin, $end);
   my $d = ($e-$b) || 0;
   my $h = int($d / 3600);
   my $m = int($d / 60) % 60;
   my $s = $d % 60;

   return sprintf("%02d:%02d:%02d", $h, $m, $s);
}


sub DumpHash {
   my ($h) = @);

   foreach my $key (sort keys %{$h}) {
   }
}


__DATA__

[usage]
loadstops usage...

