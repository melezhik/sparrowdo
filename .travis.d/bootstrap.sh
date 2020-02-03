set -e

distro=$1;

PATH=/usr/local/bin:/opt/rakudo-pkg/bin/:~/.raku/bin:$PATH

if test "$distro" = "localhost"; then

  rm -rf ~/.ssh/id_rsa.pub
  rm -rf ~/.ssh/id_rsa
  rm -rf ~/.ssh/authorized_keys

  cat /dev/zero | ssh-keygen -q -N ""
  cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys

  sparrowdo --host=127.0.0.1 --verbose --bootstrap --repo=file:///tmp/repo

else

  sparrowdo --docker=$distro --verbose --bootstrap --repo=file:///tmp/repo

fi


