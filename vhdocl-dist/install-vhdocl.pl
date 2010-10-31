#!/usr/bin/perl -w

use strict;
use File::Path;
use File::Copy;
use Pod::Html;

my $usage= <<EOF;
usage: install-vhdocl.pl [ -n ] [ DATADIR=<directory> ] [ <installation dir> ]
EOF

sub install
{
    my ($src, $dest, $mode)= @_;

    copy($src, $dest) and chmod($mode, $dest);
}

my $destdir;
my $datadir;
my $noop;

for (@ARGV) {
    if( /^DATADIR=(.*)$/ ) {
        $datadir= $1;
    }
    elsif( /^-h$/i || /^--?help$/i ) {
        print $usage;
        exit;
    }
    elsif( /^-n$/i ) {
        $noop= 1;
    }
    else {
        $destdir= $_;
    }
}

my ($exedir, $mandir, $htmldir);

if( $^O eq "MSWin32" || $^O eq "MacOS" ) {
    if( !$destdir ) {
        print "No default installation directory on this platform.  Please give it on the command line.\n";
        print $usage;
        exit;
    }
    $datadir ||= "$destdir/data";
    $exedir= $destdir;
    $htmldir= "$destdir/doc";
}
else {
    $destdir ||= "/usr/local";
    $datadir ||= "$destdir/share/vhdocl";
    $exedir= "$destdir/bin";
    $mandir= "$destdir/man/man1";
    $htmldir= "$destdir/share/doc/vhdocl";
}

print "Installing to $destdir, data directory $datadir...\n";

print "Crating install directories...\n";
File::Path::make_path($exedir, $datadir, "$datadir/style", $htmldir) unless $noop;
File::Path::make_path($mandir) if $mandir && !$noop;

print "Installing executables to $exedir...\n";
install("vhdocl", "$exedir/vhdocl", 0755) unless $noop;
install("vdocupdate", "$exedir/vdocupdate", 0755) unless $noop;

if( $mandir ) {
    require Pod::Man;

    my $parser= Pod::Man->new( "stderr" => 1 );
    print "Installing manual page to $mandir...\n";
    $parser->parse_from_file("vhdocl", "$mandir/vhdocl.1") unless $noop;
}

print "Installing HTML manual to $htmldir...\n";
pod2html("--infile=vhdocl", "--outfile=$htmldir/vhdocl.html") unless $noop;

print "Installing style files to $datadir...\n";
if( !$noop ) {
    my @stylefiles= glob("style/*");
    for (@stylefiles) {
        install($_, "$datadir/$_", 0644);
    }
}

print "Done.\n";

if( $datadir ne "/usr/local/share/vhdocl" && $datadir ne "/usr/share/vhdocl" ) {
    print "Remember to define the environment variable VHDOCL_DATADIR as `$datadir'.\n";
}

