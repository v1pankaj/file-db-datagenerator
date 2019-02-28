#!/usr/bin/perl -w

my $addition = $ARGV[0];
my $epoch = time;

#print $epoch."\n";

$epoch = (time+$addition); 

#print $epoch."\n";
#print $addition;

my @months = ("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
my ($sec, $min, $hour, $day,$month,$year) = (localtime($epoch))[0,1,2,3,4,5,6];
my $AMPM = "AM";


if ($hour > 12) {
	$hour = ($hour-12);
#	print "Hour is".$hour."\n";
	$AMPM = "PM";
	if ($hour == "00") {
		$hour = "12";
		$AMPM = "AM";
	}
}
else {
	$AMPM = "AM";
	if ($hour == "12"){
#	if ($hour == "00") {
		$hour = "12";
		$AMPM = "PM";
	}
	if ($hour == "00") {
		$hour = "12";
		$AMPM = "AM";
	}
#	print "Second Hour is".$hour."\n";
}


if (length($day) == 1) {
	$day = "0".$day;
}
if (length($hour) == 1) {
	$hour = "0".$hour;
}
if (length($min) == 1) {
	$min = "0".$min;
}
if (length($sec) == 1) {
	$sec = "0".$sec;
}
$year = $year+1900;
$year = substr $year, 2;

my $dateis = $day."-".$months[$month]."-".$year." ".$hour.".".$min.".".$sec.".000000000 ".$AMPM;
print $dateis;
#print $dateis."#".$epoch;
