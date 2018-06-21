#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 14;


my $result;

###

print "# Call with help parameter\n";

$result = `python3 ./daterem.py --help`;

cmp_ok( $?, '==', 0, "Exit code should be zero" );
like( $result, '/^usage: daterem\.py /m', "Show usage" );
like( $result, '/^positional arguments:/m', "Show positional arguments" );
like( $result, '/^optional arguments:/m', "Show optional arguments" );


###

print "# Call with non-existent file\n";

$result = `python3 ./daterem.py --file /dev/null/non-existent/file`;

cmp_ok( $?, '==', 256, "Exit code should be 256" );
like( $result, '/^Error: cannot open file /m', "Show error message" );


###

print "# Call with specific date and a test file\n";

$result = `python3 ./daterem.py --file t/testfile-1.dat 20.06.2018`;

cmp_ok( $?, '==', 0, "Exit code should be zero" );
like( $result, '/^Wed, /m', "It was a Wednesday" );
like( $result, '/Person 1/', "Show person 1" );
unlike( $result, '/age:/', "Don't recognize the german word geboren (born) in the default" );


###

print "# Call with specific date and a test file and the born parameter\n";

$result = `python3 ./daterem.py --file t/testfile-1.dat --born geboren 20.06.2018`;

cmp_ok( $?, '==', 0, "Exit code should be zero" );
like( $result, '/^Wed, /m', "It was a Wednesday" );
like( $result, '/Person 1/', "Show person 1" );
like( $result, '/age 68 years/', "Recognize the german word geboren (born) now" );


