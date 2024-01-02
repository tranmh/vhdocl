#!/usr/bin/env perl

use strict;
use warnings;
use File::Copy;

my $usage= <<EOF;
usage: install-from-git.pl [ -n ] [ DATADIR=<directory> ] [ <installation dir> ]
-n      Update package directory, but only pretend to install
DATADIR Target directory for style files
The installation directory is the base directory for the executable and most
other files.  Use -n to view the individual install paths.
EOF

if( grep /^(?:-h|--?help)$/i, @ARGV ) {
    print $usage;
    exit;
}

print "Copying current version to package directory...\n";

# Rename dummy files to copy destinations to prevent creation of root-owned
# files:
move("./vhdocl-dist/vhdocl-empty", "./vhdocl-dist/vhdocl")
    if ! -e "./vhdocl-dist/vhdocl" && -f "./vhdocl-dist/vhdocl-empty";
move("./vhdocl-dist/vhdocl.pod-empty", "./vhdocl-dist/vhdocl.pod")
    if ! -e "./vhdocl-dist/vhdocl.pod" && -f "./vhdocl-dist/vhdocl.pod-empty";

copy("./pod/vhdocl.pod", "./vhdocl-dist") or die
   "Could not copy .pod documentation - are you in the repository directory?";

my $commit= `git describe --tags`;
if( $? ) {
    print STDERR "Warning: Could not determine git revision\n";
    $commit= undef;
}
else {
    chomp $commit;
}

my $script;
{
    local $/;
    open SCR, "<vhdocl" or die "Could not read current vhdocl version";
    $script= <SCR>;
    close SCR;
}

$script =~ s/^my \$version\b.*$/my \$version= "$commit";/m if $commit;

open SCR, ">./vhdocl-dist/vhdocl" or die "Could not write vhdocl to package directory";
print SCR $script;
close SCR;

chdir "./vhdocl-dist";

exec "./install-vhdocl.pl", @ARGV;

