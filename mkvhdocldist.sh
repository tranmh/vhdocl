#!/bin/sh

ver=`grep '^my $version' vhdocl | sed 's/.*"\(.*\)".*/\1/'`

cp vhdocl vhdocl-dist/

mv vhdocl-dist vhdocl-"$ver"

tar czf vhdocl-"$ver".tgz vhdocl-"$ver"

mv vhdocl-"$ver" vhdocl-dist

