#!/usr/bin/perl -w

use strict;
use warnings;

use Cwd;
use Audio::FLAC::Header;

sub explore {
	my $p = shift;
	next if ($p =~ /.*\/\.[^\/]*$/);
	$p = Cwd::realpath $p;
	if ( -d $p) {
		my $dir;
		opendir $dir,$p or die "Cannot open directory: $p";
		while (my $file = readdir($dir)) {
			explore("$p/$file");
		}
	}
	elsif (-f $p) {
		handle_file($p);
	}
	else {
		print "Neither file nor directory ??? $p\n";
	}
}

sub handle_file {
	my $file = shift;
	if ($file =~ /.*\.flac$/) {
		print "---[FILE PATH:$file]---\n";

		my $flac = Audio::FLAC::Header->new($file);
		
		my $info = $flac->info();
		print "Infos:\n";
		for (keys %$info) {
			print "$_: $info->{$_}\n";
		}
		
		my $tags = $flac->tags();
		print "Tags:\n";
		for (keys %$tags) {
			print "$_: $tags->{$_}\n";
		}

		print "\n";
	}
}

my $path = Cwd::realpath(shift);
print "path: $path\n";

explore $path;

