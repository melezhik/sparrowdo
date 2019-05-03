set -e

export SP6_REPO=http://sparrow6.southcentralus.cloudapp.azure.com

distro=$1

sparrowfile=$2

machine_type=$3

PATH=/usr/local/bin:/opt/rakudo-pkg/bin/:~/.perl6/bin:$PATH


if test "$distro" = "localhost"; then

  sparrowdo --host=127.0.0.1 --verbose --sparrowfile=$sparrowfile --repo=file:///tmp/repo

elif test "$machine_type" = "any" && test ! "$distro" = "localhost"; then

  sparrowdo --docker=$distro --verbose --sparrowfile=$sparrowfile --repo=file:///tmp/repo

fi

