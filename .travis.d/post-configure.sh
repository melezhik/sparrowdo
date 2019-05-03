set -e

distro=$1;

if test "$distro" = "localhost"; then
  echo "docker run is skipped for localhost";
  exit
fi

case "$distro" in
  centos) docker exec -i $distro  yum -q -y install perl-JSON-PP ;;
esac

