#!/usr/bin/perl

use strict;
#use warnings;

use Cwd;
use Audio::FLAC::Header;
use DBI;

my $path = Cwd::realpath(shift);
print "path: $path\n";

my $dbpath = shift;
print "path to database: $dbpath\n";

my $datasource = "dbi:SQLite:dbname=$dbpath";
my $user = '';
my $passwd = '';
my $db = DBI->connect($datasource,$user,$passwd,{}) or die "Cannot connect to dabase: $dbpath\n";


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
		warn "Neither file nor directory ??? $p\n";
	}
}

sub get_tag {
	my $tags = shift;
	my $label = shift;
	$_ = $label;
	s/(.)/\L$1/g;
	my $label_lower = $_;
	$_ = $label;
	s/(.)(.*)/$1\L$2/;
	my $label_mix = $_;

	if ($tags->{$label}) { return $tags->{$label}; }
	elsif ($tags->{$label_lower}) { return $tags->{$label_lower}; }
	elsif ($tags->{$label_mix}) { return $tags->{$label_mix}; }
	else { return ''; }
}

sub handle_file {
	my $file = shift;
	if ($file =~ /.*\.flac$/) {
		my $flac = Audio::FLAC::Header->new($file);
		my $info = $flac->info();
		my $tags = $flac->tags();

		my $select;
		my $sth;
		my $rv;
		my $insert;
		my @row;

		# DBI access
		# does artist already in database?
		my $artistname = get_tag($tags,'ARTIST');

		$select = "SELECT id FROM Artist WHERE name='$artistname';";
		$sth = $db->prepare($select);
		$rv = $sth->execute() or die "Error while querying database artist!\n";
		@row = $sth->fetchrow_array();
		if (@row == 0) { # this artist does not belong to database
			$insert = "INSERT INTO Artist VALUES (null,\"$artistname\",0);";
			$db->do($insert) or print "[Error] $insert\n";
			$sth = $db->prepare($select);
			$rv = $sth->execute() or die "Error while querying database artist!\n";
			@row = $sth->fetchrow_array();
		}
		my $artistid = $row[0];

		
		my $albumartistid = $artistid;
		my $albumartist = get_tag($tags,'ALBUMARTIST');
		if ($albumartist eq '') { $albumartist = $artistname; }

		if ($albumartist ne $artistname) {
			$select = "SELECT id FROM Artist WHERE name='$albumartist';";
			$sth = $db->prepare($select);
			$rv = $sth->execute() or die "Error while querying database artist!\n";
			@row = $sth->fetchrow_array();
			if (@row == 0) { # this artist does not belong to database
				$insert = "INSERT INTO Artist VALUES (null,\"$albumartist\",0);";
				$db->do($insert) or print "[Error] $insert\n";
				$sth = $db->prepare($select);
				$rv = $sth->execute() or die "Error while querying database artist!\n";
				@row = $sth->fetchrow_array();
			}
			$albumartistid = $row[0];
		}

		# does album already exists?
		my $albumname = get_tag($tags,'ALBUM');
		my $discnumber = get_tag($tags,'DISCNUMBER');
		if ($discnumber eq '') { $discnumber = 1; }
		my $date = get_tag($tags,'DATE');
		if ($date eq '') { $date = 0; }

		$_ = $date;
		s/[^0-9]*([0-9]+).*/$1/g;
		$date = $_;

		$select = "SELECT id FROM Album WHERE title='$albumname' AND disc_number=$discnumber;";

		$sth = $db->prepare($select);
		$rv = $sth->execute();
		@row = $sth->fetchrow_array();
		if (@row == 0) { # this album does not belong to database
			$insert = "INSERT INTO Album VALUES (null,\"$albumname\",$discnumber,$albumartistid,$date);";
			$db->do($insert) or print "[Error] $insert\n";
			$sth = $db->prepare($select);
			$rv = $sth->execute() or die "Error while querying database artist!\n";
			@row = $sth->fetchrow_array();
		}

		my $albumid = $row[0];

		my $tracktitle = get_tag($tags,'TITLE');
		my $tracknumber = get_tag($tags,'TRACKNUMBER');
		if ($tracknumber eq '') { $tracknumber=0; }

		$insert = "INSERT INTO Track VALUES (\"$file\",\"$tracktitle\",$albumid,$tracknumber,$artistid,'');";
		$db->do($insert) or print "[Error] $insert\n";
	
	}
	else {
		#warn "Not a flac file: $file";
	}
}

$db->do("BEGIN TRANSACTION;");

explore $path;

$db->do("COMMIT;");

$db->disconnect();

