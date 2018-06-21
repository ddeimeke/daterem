#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 12;


my $result;

###

print "# Call without parameters\n";

$result = `python3 ./daterem.py`;

cmp_ok( $?, '==', 0, "Exit code should be zero" );


###

print "# Call with specific date\n";

$result = `python3 ./daterem.py 25.05.2010`;

cmp_ok( $?, '==', 0, "Exit code should be zero" );
like( $result, '/^Tue, /m', "It was a Tuesday" );
like( $result, '/Dirks Logbuch/', "This entry should be found" );
like( $result, '/Dirks Logbuch, started 2005,/', "The 'started' should be shown" );
like( $result, '/Dirks Logbuch.*, ago: 5 years$/', "The 'ago' should be detected" );
like( $result, '/Nerd Pride Day/', "This entry should be found" );
like( $result, '/Nerd Pride Day, year 2006,/', "The 'year' should be shown" );
like( $result, '/Nerd Pride Day.*, age 4 years$/m', "The 'age' should be detected" );


###

print "# Call with specific month\n";

$result = `python3 ./daterem.py 04.2018`;

cmp_ok( $?, '==', 0, "Exit code should be zero" );
like( $result, '/^Sun, 01\.04\.2018, Easter Sunday/m', "Detect easter sunday" );
like( $result, '/^Mon, 02\.04\.2018, Easter Monday/m', "Detect easter monday" );


