#!perl

use warnings;
use strict;
use Time::Piece;
use POSIX qw(strftime);
use Gnu::TinyDB;
use Gnu::StringUtil  qw(Chip Trim TrimList _CSVParts LineString CleanInputLine);
use Gnu::Template qw(Template Usage);
use Gnu::ArgParse;

MAIN:
   Connection("geo");

   ArgBuild("*^debug *^help");
   ArgParse(@ARGV) or die ArgGetError();
   Usage() if ArgIs("help") || !ArgIs();
   Load(ArgGet());
   exit(0);


sub Load {
   my ($spec) = @_;

   open (my $fh, "<", $spec) or die "Can't open $spec";
   my $line = <$fh>;
   return LoadStops($fh)     if $line =~ /AccSeconds/;
   return LoadPositions($fh) if $line =~ /Position_Date/;
   die "I don't understand $spec";
}

sub LoadPositions {
   my ($fh) = @_;

   my $prevrec;
   while (my $line = <$fh>) {
      next unless $line =~ /True|False/i;

      my $rec = PositionRecord($line);
      if ($prevrec) {
         next if ($prevrec->{isstop} && $rec->{isstop} && IsClose($prevrec, $rec));
         $prevrec->{duration} = TimeDelta($prevrec->{time}, $rec->{time});
         AddPositionRecord($prevrec);
      }
      $prevrec = $rec;
   }
}

sub AddPositionRecord {
   my ($rec) = @_;

   my $sql = "INSERT INTO positions (isstop, time, duration, lat, lon, heading, speed, elevation, location, description) VALUES (?,?,?,?,?,?,?,?,?,?)";
   ExecSQL($sql,
      $rec->{isstop}, 
      $rec->{time}, 
      $rec->{duration}, 
      $rec->{lat}, 
      $rec->{lon}, 
      $rec->{heading}, 
      $rec->{speed}, 
      $rec->{elevation}, 
      $rec->{location}, 
      $rec->{description}
   );
}

sub PositionRecord {
   my ($line) = @_;
   my $rec = {};

   my ($isstop, $time,$lat,$lon,$heading,$speed,$location,$description,$elevation) = (_CSVParts($line))[2..11];
   $rec->{isstop     } = $isstop =~ /true/i ? 1 : 0;
   $rec->{time       } = dt($time);
   $rec->{lat        } = nq($lat);
   $rec->{lon        } = nq($lon);
   $rec->{heading    } = $heading;
   $rec->{speed      } = nq($speed);
   $rec->{location   } = $location;
   $rec->{description} = $description;
   $rec->{elevation  } = nq($elevation);
   return $rec;
}

sub IsClose {
   my ($prevrec, $rec) = @_;

   my $delta = 0.0005;
   return 0 if abs($rec->{lat} - $prevrec->{lat}) > $delta;
   return 0 if abs($rec->{lon} - $prevrec->{lon}) > $delta;
   return 1;
}

sub TimeDelta {
   my ($begin, $end) = @_;

   my ($b, $e) = map Time::Piece->strptime(s/\.\d*Z?\z//r, '%Y-%m-%d %H:%M:%S'), ($begin, $end);
   my $d = ($e-$b) || 0;
   my $h = int($d / 3600);
   my $m = int($d / 60) % 60;
   my $s = $d % 60;

   return sprintf("%02d:%02d:%02d", $h, $m, $s);
}

sub LoadStops {
   my ($fh) = @_;

   my $sql = "INSERT INTO stops (Begin, End, Lat, Lon, Location, Description) VALUES (?,?,?,?,?,?)";

   while (my $line = <$fh>) {
      my ($description,$begin,$end,$lat,$lon,$location) = (_CSVParts($line))[5..11];
      ExecSQL($sql, dt($begin),dt($end),nq($lat),nq($lon),$location,$description);
      print (".");
   }
   print ("\n");
}

sub dt {
   my ($in) = @_;

   my ($mon,$day,$year,$hour,$min,$sec,$m) = $in =~ m[(\d+)/(\d+)/(\d+) (\d+):(\d+):(\d+) (\wM)];
   $hour += 12 if $m =~ /P/i && $hour != 12;
   return sprintf('%04d-%02d-%02d %02d:%02d:%02d', $year,$mon,$day,$hour,$min,$sec);
}

sub nq {
   my ($in) = @_;

   $in =~ s/"//g; #"
   return $in;
}

      
__DATA__

[usage]
loadstops usage...   

