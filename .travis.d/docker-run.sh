set -e

distro=$1;

if test "$distro" = "localhost"; then
  echo "docker run is skipped for localhost";
  exit
fi

case "$distro" in
  archlinux) image=base/archlinux         ;;
  alpine)    image=jjmerelo/alpine-perl6  ;;
  *)         image=$distro
esac

docker run --name $distro -v /tmp/repo:/tmp/repo -td --entrypoint sh $image
