#!/usr/bin/perl -w
use strict;
use Time::Local;

my ($rday,$rmonth,$ryear);
my $day = 60*60*24;
my ($unter,$ober);
my $easter;
my @alles;

###########
sub options
###########
{
	my ($day,$month,$year);
	if (@ARGV>=2) {
		print "\nUsage: $0 [[[dd.]mm.]yyyy]\n\n";
		exit 1;
	} 
	if (@ARGV==1) {
		($day,$month,$year) = split(/\./,$ARGV[0]);
		if (! defined $year) {
			$year = $month;
			$month = $day;
			undef $day;
		}
		if (! defined $year) {
			$year = $month;
			undef $month;
		}
	} else {
		($day,$month,$year) = (localtime)[3,4,5];
		$month++;
		$year += 1900;
	}
	return ($day,$month,$year);
}
##############
sub calceaster # Ostern berechnen
##############
{
	my $j = $ryear;
	my $a = $j % 19;
	my $b = int($j / 100);
	my $c = $j % 100;
	my $d = int($b / 4);
	my $e = $b % 4;
	my $f = int(( $b + 8 ) / 25);
	my $g = int(( $b - $f + 1 ) / 3);
	my $h = ( 19 * $a + $b - $d - $g + 15 ) % 30;
	my $i = int($c / 4);
	my $k = $c % 4;
	my $l = ( 32 + 2 * $e + 2 * $i - $h - $k ) % 7;
	my $m = int(( $a + 11 * $h + 22 * $l ) / 451);
	my $n = int(( $h + $l - 7 * $m + 114 ) / 31);
	my $o = ( $h + $l - 7 * $m + 114 ) % 31;

	return timelocal(0,0,12,$o+1,$n-1,$j-1900);
}
#############
sub vergleich # Vergleichsfunktion um zwei Datumszeilen zu vergleichen
#############
{
	my (@ha,@hb);
	@ha = split(/ /,$a);
	@ha = split(/\./,$ha[0]);
	@hb = split(/ /,$b);
	@hb = split(/\./,$hb[0]);
	return timelocal(0,0,12,$ha[0],$ha[1]-1,$ha[2]-1900) 
               <=>
	       timelocal(0,0,12,$hb[0],$hb[1]-1,$hb[2]-1900);
}
###############
sub zeitstempel
###############
{
	my $zeile = $_[0];
	$zeile =~ s/([0-9.]+)\s.*/$1/;
	my ($day,$month,$year) = split(/\./,$zeile);
	return timelocal(0,0,12,$day,$month-1,$year-1900);
}
#############
sub wochentag
#############
{
	my @wochentag = qw(So Mo Di Mi Do Fr Sa);
	return $wochentag[
		(localtime(
			zeitstempel($_[0])
		))[6]
	];
}
############
sub add2list
############
{
	my ($dd,$mm,$yyyy,$remark) = @_;
	$dd = "0" . $dd if (($dd < 10) && (length($dd)<2));
	$mm = "0" . $mm if (($mm < 10) && (length($mm)<2));
	push @alles,"$dd.$mm.$yyyy $remark";
}
###########
sub readdat
###########
{
	my $zeit;
	my $beschreibung;
	my $dat1;
	my $dat2;
	my ($dat1_day,$dat1_month,$dat1_year);
	my ($dat2_day,$dat2_month,$dat2_year);
	if (-r 'daterem.dat') {
		open(DATA,"< daterem.dat") 
			or die "\nIrgendetwas stimmt hier nicht!\n\n";
		while (<DATA>) {
			chomp;
			s/^#.*//g; # entfernt Kommentarzeilen
			s/\s{2,}/ /g; # ersetzt mehrere WS durch ein Leerzeichen
			s/^\s+//g; # entfernt Whitespace(s) am Zeilenanfang
			s/\s+$//g; # entfernt Whitespace(s) am Zeilenende
			if (m/^.+$/) {
				($zeit,$beschreibung) = split(/ /, $_, 2);
				if ($zeit =~ m/^[-0-9]+$/) { # Osterdaten
					$zeit = $zeit * $day + $easter;
					($dat1_day,$dat1_month,$dat1_year) = (localtime($zeit))[3,4,5];
					$dat1_month++;
					$dat1_year += 1900;
					add2list($dat1_day,$dat1_month,$dat1_year,$beschreibung);
				} elsif ($zeit =~ m/.+-.+/) { # Ein Zeitraum
					($dat1,$dat2) = split(/-/ , $zeit);
					($dat1_day,$dat1_month,$dat1_year) = split(/\./,$dat1);
					($dat2_day,$dat2_month,$dat2_year) = split(/\./,$dat2);
					$dat2_year ||= $ryear;
					$dat1_month ||= $dat2_month;
					$dat1_year ||= $dat2_year;
					
					$dat1 = timelocal(0,0,12,$dat1_day,$dat1_month-1,$dat1_year-1900);
					$dat2 = timelocal(0,0,12,$dat2_day,$dat2_month-1,$dat2_year-1900);
					while ($dat1 <= $dat2) {
						($dat1_day,$dat1_month,$dat1_year) = (localtime($dat1))[3,4,5];
						$dat1_month++;
						$dat1_year += 1900;
						add2list($dat1_day,$dat1_month,$dat1_year,$beschreibung);
						$dat1 += $day;
					}
					
				} else { # Ein einzelnes Datum
					($dat1_day,$dat1_month,$dat1_year) = split(/\./,$zeit);
					$dat1_year ||= $ryear;
					add2list($dat1_day,$dat1_month,$dat1_year,$beschreibung);
				}
			}
		}
		close DATA;
	} else {
		print "\nNo datafile!\n\n";
	}
}

($rday,$rmonth,$ryear) = options;
$easter = calceaster;
readdat;
@alles = sort vergleich @alles;

if (! defined $rmonth) {
	foreach (grep(/\.$ryear /,@alles)) {
		print wochentag($_),", $_\n";
	}
} elsif (! defined $rday) {
	foreach (grep(/\.$rmonth\.$ryear /,@alles)) {
		print wochentag($_),", $_\n";
	}
} else {
	$unter = timelocal(0,0,0,$rday,$rmonth-1,$ryear-1900);
	$ober  = timelocal(59,59,23,$rday,$rmonth-1,$ryear-1900);
	foreach (@alles) {
		if ((zeitstempel($_)>=$unter) && (zeitstempel($_)<=$ober)) {
			print wochentag($_),", $_\n";
		}
	}
}
