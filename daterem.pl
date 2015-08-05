#!/usr/bin/perl -w
use strict;
use Time::Local;

my ($rday,$rmonth,$ryear);
my $day = 60*60*24;
my $easter;
my @all;


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
	$month = "0" . $month if (defined $month) and (length($month) == 1);
	$day = "0" . $day if (defined $day) and (length($day) == 1);
	return ($day,$month,$year);
}


##############
sub calceaster # Calculate easter date
               # https://en.wikipedia.org/wiki/Computus#Anonymous_Gregorian_algorithm
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


###########
sub compare # Function to compare two date lines
###########
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


#############
sub timestamp
#############
{
	my $line = $_[0];
	$line =~ s/([0-9.]+)\s.*/$1/;
	my ($day,$month,$year) = split(/\./,$line);
	return timelocal(0,0,12,$day,$month-1,$year-1900);
}


#############
sub weekday
#############
{
	my @weekday = qw(Su Mo Tu We Th Fr Sa);
	return $weekday[
		(localtime(
			timestamp($_[0])
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
	push @all,"$dd.$mm.$yyyy $remark";
}


###########
sub readdat
###########
{
	my $time;
	my $description;
	my $dat1;
	my $dat2;
	my ($dat1_day,$dat1_month,$dat1_year);
	my ($dat2_day,$dat2_month,$dat2_year);
	if (-r 'daterem.dat') {
		open(DATA,"< daterem.dat") 
			or die "\ndaterem.dat not found in current directory!\n\n";
		while (<DATA>) {
			chomp;
			s/^#.*//g; # removes commented lines
			s/\s{2,}/ /g; # replaces multiple white spaces with only one
			s/^\s+//g; # removes whitespace(s) from beginning of lines
			s/\s+$//g; # removes whitespace(s) from line ends
			if (m/^.+$/) {
				($time,$description) = split(/ /, $_, 2);
				if ($time =~ m/^[-0-9]+$/) { # depending on easter
					$time = $time * $day + $easter;
					($dat1_day,$dat1_month,$dat1_year) = (localtime($time))[3,4,5];
					$dat1_month++;
					$dat1_year += 1900;
					add2list($dat1_day,$dat1_month,$dat1_year,$description);
				} elsif ($time =~ m/.+-.+/) { # periods
					($dat1,$dat2) = split(/-/ , $time);
					($dat1_day,$dat1_month,$dat1_year) = split(/\./,$dat1);
					($dat2_day,$dat2_month,$dat2_year) = split(/\./,$dat2);
					$dat2_year ||= $ryear;
					$dat1_month ||= $dat2_month;
					$dat1_year ||= $dat2_year;
					
                                        # Add begin-end date to description
                                        $description .= " [$time]";

					$dat1 = timelocal(0,0,12,$dat1_day,$dat1_month-1,$dat1_year-1900);
					$dat2 = timelocal(0,0,12,$dat2_day,$dat2_month-1,$dat2_year-1900);
					while ($dat1 <= $dat2) {
						($dat1_day,$dat1_month,$dat1_year) = (localtime($dat1))[3,4,5];
						$dat1_month++;
						$dat1_year += 1900;
						add2list($dat1_day,$dat1_month,$dat1_year,$description);
						$dat1 += $day;
					}
					
				} else { # a single date
					($dat1_day,$dat1_month,$dat1_year) = split(/\./,$time);
					$dat1_year ||= $ryear;
					add2list($dat1_day,$dat1_month,$dat1_year,$description);
				}
			}
		}
		close DATA;
	} else {
		print "\nNo datafile!\n\n";
	}
}


#############
sub printline
#############
{
	my ($output) = @_;
	print weekday($_),", $_";
	if ( ( my $year_of_birth ) = $_ =~ /\W(?:born|dead|started|year) (\d{4})/ ) {
		my $age = $ryear - $year_of_birth;
		print ", age $age year";
		print "s" if ($age > 1);
	}
	print "\n";
}


($rday,$rmonth,$ryear) = options;
$easter = calceaster;
readdat;
@all = sort compare @all;


if (! defined $rmonth) {
	foreach (grep(/\.$ryear /,@all)) {
		printline($_);
	}
} elsif (! defined $rday) {
	foreach (grep(/\.$rmonth\.$ryear /,@all)) {
		printline($_);
	}
} else {
	foreach (grep(/$rday\.$rmonth\.$ryear /,@all)) {
		printline($_);
	}
}
