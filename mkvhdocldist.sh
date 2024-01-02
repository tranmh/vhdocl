#!/bin/bash

if [ -n "$1" ]; then
    commit=$1
    echo "Packaging current version as $commit"
else
    commit=`git describe --tags`
    echo "Packaging version $commit"
fi

sed -e 's/^my \$version\>.*$/my $version= "'"$commit"'";/' vhdocl > vhdocl-dist/vhdocl

cp pod/vhdocl.pod vhdocl-dist/

rm -f vhdocl-dist/pod2htm?.tmp

ln -sf vhdocl-dist vhdocl-"$commit"

tar czhf vhdocl-"$commit".tgz vhdocl-"$commit"

rm -f vhdocl-"$commit"

