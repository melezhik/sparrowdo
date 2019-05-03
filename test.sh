#!/bin/bash

st=0

for i in $(ls examples/active/*/sparrowfile); do 

  echo run $i;
    sparrowdo  --host=$1  --repo=file:///home/$USER/repo --verbose   --sparrowfile=$i  || st=1;
  echo

done

if test $st -eq 0; then
  echo all tests passed
else
  echo some tests failed
fi

exit $st

