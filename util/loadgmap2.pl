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
   my $lng   = $o->{location   }->{longitudeE7   } / 10000000;
   my $addr  = $o->{location   }->{address       };
   my $tag   = $o->{location   }->{sourceInfo    }->{deviceTag};
   my $start = $o->{duration   }->{startTimestamp};
   my $end   = $o->{duration   }->{endTimestamp  };
   my $clat  = $o->{centerLatE7} / 10000000;
   my $clng  = $o->{centerLngE7} / 10000000;
   my $dt    = TimeDelta($start,$end);

#  print "\nUnknown/Unused device tag: $tag\n" unless $DEVICES->{$tag};
#  return unless $DEVICES->{$tag};

   my $sql = "INSERT INTO places (time, duration, lat, lng, address) VALUES (?,?,?,?,?)";
   ExecSQL($sql, df($start), $dt, $lat, $lng, $addr);
   
   print ("*");
}

sub LoadActivitySegment {
   my ($o) = @_;

   my $tag   = $o->{startLocation}->{sourceInfo    }->{deviceTag};
   my $slat  = $o->{startLocation}->{latitudeE7    } / 10000000;
   my $slng  = $o->{startLocation}->{longitudeE7   } / 10000000;
   my $elat  = $o->{endLocation  }->{latitudeE7    } / 10000000;
   my $elng  = $o->{endLocation  }->{longitudeE7   } / 10000000;
   my $start = $o->{duration     }->{startTimestamp};
   my $end   = $o->{duration     }->{endTimestamp  };
   my $mode  = $o->{waypointPath }->{travelMode    };
   my $ways  = $o->{waypointPath }->{waypoints     };

#   print "\nUnknown/Unused device tag: $tag\n" unless $DEVICES->{$tag};
#   return unless $DEVICES->{$tag};

   my $sql = "INSERT INTO paths (starttime, endtime, startlat, startlng, endlat, endlng, mode) VALUES (?,?,?,?,?,?,?)";
   ExecSQL($sql, df($start), df($end), $slat, $slng, $elat, $elng, $mode);
   
   my $pathId =  GetInsertId();

   foreach my $pt (@{$ways}) {
      my $lat = $pt->{latE7} / 10000000;
      my $lng = $pt->{lngE7} / 10000000;

      my $sql = "INSERT INTO waypoints (pathid, lat, lng) VALUES (?,?,?)";
      ExecSQL($sql, $pathId, $lat, $lng);
   }
   print (".");
}

sub LoadWhatsThis {
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

# deconstruct GMT timestring, construct local timestring
#
sub df {
   my ($in) = @_;

   my $epoch = str2time($in);
   my ($sec,$min,$hour,$mday,$mon,$year) = localtime($epoch); 
   my $out = sprintf('%04d-%02d-%02d %02d:%02d:%02d', $year+1900,$mon+1,$mday,$hour,$min,$sec);
   return $out;
}


__DATA__

[usage]
loadgoogle usage...



