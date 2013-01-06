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
File::Path::mkpath( [$exedir, $datadir, "$datadir/style", $htmldir] ) unless $noop;
File::Path::mkpath($mandir, {}) if $mandir && !$noop;

print "Installing executables to $exedir...\n";
install("vhdocl", "$exedir/vhdocl", 0755) unless $noop;
install("vdocupdate", "$exedir/vdocupdate", 0755) unless $noop;
if( $^O eq "MSWin32" ) {
    # Windoze associates interpreters with script file extensions, so
    # installing as .pl allows running without typing "perl" explicitly.  But
    # also update the straight installs (above) for backward compatibility.
    install("vhdocl", "$exedir/vhdocl.pl", 0755) unless $noop;
    install("vdocupdate", "$exedir/vdocupdate.pl", 0755) unless $noop;
}

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

if( $^O eq "MSWin32" && (!defined($ENV{"VHDOCL_DATADIR"}) || lc($ENV{"VHDOCL_DATADIR"}) ne lc($datadir)) ) {
    print <<EOF;
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
To complete the install, define the environment variable VHDOCL_DATADIR as
\`$datadir'.
On Windows XP, right click on the "My Computer" icon -> select "Properties"
from the context menu -> click on the "Advanced" tab -> click the button
"Environment variables" at the bottom -> click on the "New" button in the lower
part ("System variables") and add the new variable to allow all users to run
VHDocL; or use the "New" button in the upper part ("User variables") if you do
not have administrator privileges or want to install it only for yourself.
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
EOF
}
elsif( $datadir ne "/usr/local/share/vhdocl" && $datadir ne "/usr/share/vhdocl"
       && (!defined($ENV{"VHDOCL_DATADIR"}) || $ENV{"VHDOCL_DATADIR"} ne $datadir) ) {
    print <<EOF;
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
To complete the install, define the environment variable VHDOCL_DATADIR as
\`$datadir'.
In most Linux distributions, and for global installs, this is done by adding a
pair of scripts to the directory /etc/profile.d which contain:
export VHDOCL_DATADIR="$datadir"
for the sh shell; and for csh:
setenv VHDOCL_DATADIR "$datadir"
If you install vhdocl in your own home directory, add an appropriate line to
~/.profile or your personal shell rc file.  For other shells or operating
systems, please refer to your system documentation.
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
EOF
}

my @reqmods= qw(Cwd File::Spec File::Path File::Glob File::Copy Digest::MD5);
my @needmods;

for my $mod (@reqmods) {
    eval "require $mod;";
    if( $@ ) { push @needmods, $mod; }
}
if( @needmods ) {
    print "+" x 79, "\nBefore vhdocl can be run, you have to install the ",
          "following Perl module", (@needmods > 1? "s":""), ":\n",
          join(", ", @needmods), ",\nwhich can be downloaded from ",
          "http://cpan.org .\n", "+" x 79, "\n";
}

eval { require Time::HiRes; };
if( $@ ) {
    print( @needmods?
    "If you want to benchmark vhdocl, you also need the module Time::HiRes.\n":
    "If you want to benchmark vhdocl, you have to install the Perl module\n".
    "Time::HiRes, which can be downloaded from http://cpan.org .\n" );
}

