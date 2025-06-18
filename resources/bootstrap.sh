set -e

echo "start bootstrap"

rakudo_linux_version=$1
rakudo_linux_tarball=https://rakudo.org/dl/rakudo/$rakudo_linux_version.tar.gz
rakudo_linux_install_prefix=$2

install_rakudo_linux()
{

   # try to use already installed rakudo
   eval $($rakudo_linux_install_prefix/$rakudo_linux_version/scripts/set-env.sh --quiet)

   if raku --version 2>/dev/null; then
      echo "rakudo already installed"
   else
      mkdir -p $rakudo_linux_install_prefix
      chmod a+r -R $rakudo_linux_install_prefix
      rm -rf $rakudo_linux_install_prefix/$rakudo_linux_version.tar.gz
      wget $rakudo_linux_tarball -P $rakudo_linux_install_prefix
      cd $rakudo_linux_install_prefix
      tar -xzf $rakudo_linux_version.tar.gz
      eval $($rakudo_linux_install_prefix/$rakudo_linux_version/scripts/set-env.sh --quiet)
      raku --version
      zef --version
   fi
}

install_sparrow()
{

  if raku -MSparrow6 -e 1 2>/dev/null; then
    echo "Sparrow6 already installed"
  else
    zef install --/test OpenSSL
    zef install --/test JSON::Tiny
    zef install --/test IO::Socket::SSL
    zef install --/test HTTP::Tiny
    zef install --/test MIME::Base64
    zef install --/test File::Directory::Tree
    zef install --/test Data::Dump
    zef install --/test JSON::Fast
    zef install --/test Terminal::ANSIColor
    zef install --/test YAMLish
    zef install --/test Sparrow6
  fi

  zef upgrade --/test Sparrow6

  if raku -MSparky::JobApi -e 1 2>/dev/null; then
    echo "Sparky::JobApi already installed"
  else
    zef install --/test  Sparky::JobApi
  fi

}

# =============================================================================

case "$OS" in
  alpine)
    repo=http://dl-cdn.alpinelinux.org/alpine/edge/testing/
    apk update --wait 120
    apk add --no-cache --wait 120 curl bash zef
    apk add --no-cache --wait 120 -u --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community/  rakudo
    echo "install Sparrow6, Sparky-Job-Api ..."
    apk add --no-cache --wait 120 -u --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing/ raku-sparrow6 raku-sparky-job-api
  ;;
  rocky|rhel|red)
    yum -q -y install curl-minimal || yum -q -y install curl
    yum -q -y install bash wget openssl-devel perl-JSON-PP
    install_rakudo_linux
    install_sparrow
  ;;
  amazon|centos|fedora)
    yum -q -y install curl bash wget openssl-devel perl-JSON-PP
    install_rakudo_linux
    install_sparrow
  ;;
  arch|archlinux)
    pacman -Sy --noconfirm archlinux-keyring
    pacman -Suyy --noconfirm
    pacman -S --needed --noconfirm -q curl bash openssl openssl-1.1
    install_rakudo_linux
    install_sparrow
  ;;
  debian|ubuntu)
    DEBIAN_FRONTEND=noninteractive
    apt-get update -q -o Dpkg::Use-Pty=0
    apt-get install -q -y -o Dpkg::Use-Pty=0 curl bash libssl-dev
    install_rakudo_linux
    install_sparrow
  ;;
  fedora)
    dnf -yq install curl bash openssl-devel
    install_rakudo_linux
    install_sparrow
  ;;
  opensuse)
    zypper install -y curl tar gzip libopenssl-devel
    install_rakudo_linux
    install_sparrow
  ;;
  *)
    printf "Your OS (%s) is not supported\n" "$OS"
    exit 1
esac
