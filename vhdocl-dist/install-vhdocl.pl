#!/usr/bin/perl -w

use strict;
use File::Path;
use File::Copy;
use Pod::Html;

my $usage= <<EOF;
usage: install-vhdocl.pl [ -n ] [ DATADIR=<directory> ] [ <installation dir> ]
-n      No operation - output what would be done, but do nothing
DATADIR Target directory for style files
The installation directory is the base directory for the executable and most
other files.  Use -n to view the individual install paths.
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

print $noop? "Pretending to install" : "Installing", " to $destdir, data directory $datadir...\n";

print "Creating install directories...\n";
File::Path::make_path($exedir, $datadir, "$datadir/style", $htmldir) unless $noop;
File::Path::make_path($mandir) if $mandir && !$noop;

print "Installing executables to $exedir...\n";
install("vhdocl", "$exedir/vhdocl", 0755) unless $noop;
install("vdocupdate", "$exedir/vdocupdate", 0755) unless $noop;

if( $mandir ) {
    require Pod::Man;

    my $parser= Pod::Man->new( "stderr" => 1 );
    print "Installing manual page to $mandir...\n";
    $parser->parse_from_file("vhdocl.pod", "$mandir/vhdocl.1") unless $noop;
}

print "Installing HTML manual to $htmldir...\n";
pod2html("--infile=vhdocl.pod", "--outfile=$htmldir/vhdocl.html") unless $noop;
unlink "pod2htmd.tmp", "pod2htmi.tmp" unless $noop;

print "Installing style files to $datadir...\n";
if( !$noop ) {
    my @stylefiles= glob("style/*");
    for (@stylefiles) {
        install($_, "$datadir/$_", 0644);
    }
}

print $noop? "Rerun without -n to install to these directories.\n" : "Done.\n";

if( $datadir ne "/usr/local/share/vhdocl" && $datadir ne "/usr/share/vhdocl" ) {
    print "Remember to define the environment variable VHDOCL_DATADIR as `$datadir'.\n";
}

