#!/usr/bin/perl -w

use strict;
use warnings;

# ls -format="single-column"

my $old;
my %files;
my @notmv;

my $rep_path = shift;
my $F;

open $F, "ls --format='single-column' $rep_path |" or die "Cannot use ls!\n";

while (<$F>) {
	if (/^([0-9]+.*\.flac)$/) {
		$old = $1;
		$_ = $1;
		s/\!//g;
		s/ - /_/g;
		s/ +/-/g;
		s/'/-/g;
		s/, /-/g;
		s/,//g;
		s/(.)/\L$1/g;
		s/-\./\./g;
		s/\.-/_/g;
		s/([0-9]+)-/$1_/g;
		#$_ = "$1_$2";
		#$files{$old} = "$1_$2";
		$files{$old} = $_;
		#print "Want to rewrite: '$old' to '$_' ?\n";
	}
	else {
		/^(.*)$/;
		print "File does not match pattern: '$1'\n";
		push @notmv , $1;
	}
}

print "The following rewriting will be done:\n";
for my $key (keys %files) {
	print "'$key' to '$files{$key}'\n"
}

print "The following files won't be moved:\n";
for my $el (@notmv) {
	print "'$el'\n";
}

print "Do you agree? [y/n]\n";
$_ = <>;
#print "$_\n";
if ($_ eq "y\n") {
	print "Start moves...\n";
	for my $key (keys %files) {
		print "$rep_path/$key ---> $rep_path/$files{$key}";
		system ("mv","$rep_path/$key","$rep_path/$files{$key}");
		print " [ok]\n";
	}
}
else {
	print "[WARNING] No change done!\n";
}



