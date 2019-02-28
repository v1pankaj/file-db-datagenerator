#!/usr/bin/perl -w

use strict;
my $increment = $ARGV[0];
#print $increment."++";
my $epoch = time;
#print $epoch."==";
$epoch = (time+$increment);
#print $epoch."^^";
print $epoch;
