#!/bin/sh

commit=`git log --decorate=short | head -n 1`

if echo $commit | grep -q '\<tag: ' ; then
    commit=`echo $commit | sed -e 's/^.*\<tag: \([^,]\+\).*$/\1/'`
    echo "Packaging version $commit"
else
    commit="${commit##commit }"
    commit=${commit:0:8}
    echo "Packaging commit $commit"
fi

sed -e 's/^my \$version\>.*$/my $version= "'"$commit"'";/' vhdocl > vhdocl-dist/vhdocl

cp pod/vhdocl.pod vhdocl-dist/

rm -f vhdocl-dist/pod2htm?.tmp

ln -sf vhdocl-dist vhdocl-"$commit"

tar czhf vhdocl-"$commit".tgz vhdocl-"$commit"

rm -f vhdocl-"$commit"

