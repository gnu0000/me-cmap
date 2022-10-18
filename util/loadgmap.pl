#!perl
# This loads location data from a google location data export
# Specifically: it loads the files in the zip file in location:
#     Takeout\Location History\Semantic Location History
#

use warnings;
use strict;
use JSON;
use Time::Piece;
use POSIX qw(strftime);
use DateTime;
use Date::Parse;
use Time::Local qw( timelocal_posix timegm_posix );
use Gnu::TinyDB;
use Gnu::StringUtil  qw(Chip Trim TrimList _CSVParts LineString CleanInputLine);
use Gnu::FileUtil    qw(SlurpFile);
use Gnu::Template    qw(Template Usage);
use Gnu::ArgParse;

#my $DEVICES = {
#   "-1971026223" => 0, # ONEPLUS A5000
#   "-70899665"   => 0, # SM-T590
#   "-1996565516" => 1, # Pixel 5a
#   "-86491829"   => 1, # Pixel 3a
#};
#
#my $IGNORE_DEVICES = {
#   "-70899665"   => 0, # SM-T590
#};


MAIN:
   Connection("geo");

   ArgBuild("*^debug *^help");
   ArgParse(@ARGV) or die ArgGetError();
   Usage() if ArgIs("help") || !ArgIs();
   Load(ArgGet());
   exit(0);


sub Load {
   my ($filespec) = @_;

   my $srcdata = SlurpFile($filespec);
   die "can't find or open $filespec\n" unless $srcdata;

   my $data = decode_json ($srcdata);
   my $to = $data->{timelineObjects};

   foreach my $o (@{$to}) {
      foreach my $key (sort keys %{$o}) {
         LoadPlaceVisit     ($o->{$key}) if $key =~ /placeVisit/;
         LoadActivitySegment($o->{$key}) if $key =~ /activitySegment/;
         LoadWhatsThis      ($o->{$key}) if !$key =~ /placeVisit|activitySegment/;
      }
   }
   print ("\n");
}

sub LoadPlaceVisit {
   my ($o) = @_;

   my $lat   = $o->{location   }->{latitudeE7    } / 10000000;
   my $lon   = $o->{location   }->{longitudeE7   } / 10000000;
   my $addr  = $o->{location   }->{address       };
   my $tag   = $o->{location   }->{sourceInfo    }->{deviceTag};
   my $start = $o->{duration   }->{startTimestamp};
   my $end   = $o->{duration   }->{endTimestamp  };
   my $clat  = $o->{centerLatE7} / 10000000;
   my $clon  = $o->{centerLngE7} / 10000000;
   my $dt    = TimeDelta($start,$end);

#   print "\nUnknown/Unused device tag: $tag\n" unless $DEVICES->{$tag};
#   return unless $DEVICES->{$tag};

   LoadRec(1, $start, $dt, $clat, $clon, $addr, "visit");
   print ("*");
}

sub LoadActivitySegment {
   my ($o) = @_;

   my $tag   = $o->{startLocation}->{sourceInfo    }->{deviceTag};
   my $slat  = $o->{startLocation}->{latitudeE7    } / 10000000;
   my $slon  = $o->{startLocation}->{longitudeE7   } / 10000000;
   my $elat  = $o->{endLocation  }->{latitudeE7    } / 10000000;
   my $elon  = $o->{endLocation  }->{longitudeE7   } / 10000000;
   my $start = $o->{duration     }->{startTimestamp};
   my $end   = $o->{duration     }->{endTimestamp  };
   my $dt = TimeDelta($start,$end);

#   print "\nUnknown/Unused device tag: $tag\n" unless $DEVICES->{$tag};
#   return unless $DEVICES->{$tag};

   LoadRec(0, $start, "00:00:00", $slat, $slon, "", "start");
   print (".");

   my $pts = $o->{waypointPath}->{waypoints};
   foreach my $pt (@{$pts}) {
      my $lat = $pt->{latE7} / 10000000;
      my $lon = $pt->{lngE7} / 10000000;

      LoadRec(0, $start, "00:00:00", $lat, $lon, "", "waypoint");
      print (".");
   }
   LoadRec(0, $end, "00:00:00", $elat, $elon, "", "end");
   print (".");
}

sub LoadWhatsThis {
   my ($o) = @_;

   print "Unknown:\n";
}

sub LoadRec
   {
   my ($isstop, $start, $dt, $lat, $lon, $addr, $descr) = @_;

   my $sql = "INSERT INTO craigpos (isstop, time, duration, lat, lon, location, description) VALUES (?,?,?,?,?,?,?)";
   ExecSQL($sql, $isstop, df($start), $dt, $lat, $lon, $addr, $descr);
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

# deconstruct GMT timestring, construct local timestring
#
sub df {
   my ($in) = @_;

#   #my ($year,$mon,$day,$hour,$min,$sec) = $in =~ m[(\d+)-(\d+)-(\d+)T(\d+):(\d+):(\d+)\.?\d*Z];
#   #return sprintf('%04d-%02d-%02d %02d:%02d:%02d', $year,$mon,$day,$hour,$min,$sec);
#   my ($year,$mon,$mday,$hour,$min,$sec) = $in =~ m[(\d+)-(\d+)-(\d+)T(\d+):(\d+):(\d+)\.?\d*Z];
#   my $timem = timegm_posix( $sec, $min, $hour, $mday, $mon, $year );
#   ($sec,$min,$hour,$mday,$mon,$year) = localtime($timem); 
#
#   #return sprintf('%04d-%02d-%02d %02d:%02d:%02d', $year,$mon,$mday,$hour,$min,$sec);
#   my $out = sprintf('%04d-%02d-%02d %02d:%02d:%02d', $year,$mon,$mday,$hour,$min,$sec);
#print "\n [$in] -> [$out]";
#   return $out;
#}
#
#sub DumpHash {
#   my ($h) = @);
#
#   foreach my $key (sort keys %{$h}) {
#   }

   my $epoch = str2time($in);
   my ($sec,$min,$hour,$mday,$mon,$year) = localtime($epoch); 
   my $out = sprintf('%04d-%02d-%02d %02d:%02d:%02d', $year+1900,$mon+1,$mday,$hour,$min,$sec);
   return $out;
}


__DATA__

[usage]
loadstops usage...

