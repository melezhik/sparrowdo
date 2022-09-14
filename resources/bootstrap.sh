export PATH=$PATH:$HOME/.raku/bin/:/opt/rakudo-pkg/bin # to support latest rakudo distributions that install zef separately to ~/.raku

set -e

echo "start bootstrap"

case "$OS" in
  alpine)
    apk update --wait 120
    apk add --no-cache --wait 120 curl perl bash git openssl-dev
    curl -1sLf 'https://dl.cloudsmith.io/public/nxadm-pkgs/rakudo-pkg/setup.alpine.sh' | bash
    apk add rakudo-pkg
    zef --version || install-zef
  ;;
  amazon|centos|red)
    yum -q -y install make curl perl bash redhat-lsb-core git perl-JSON-PP openssl-devel
    curl -1sLf \
    'https://dl.cloudsmith.io/public/nxadm-pkgs/rakudo-pkg/setup.rpm.sh' \
    | bash
    yum -q -y install rakudo-pkg
    zef --version || install-zef
  ;;
  arch|archlinux)
    pacman -Syy
    pacman -S --needed --noconfirm -q curl perl bash git openssl rakudo
  ;;
  debian|ubuntu)
    DEBIAN_FRONTEND=noninteractive
    apt-get update -q -o Dpkg::Use-Pty=0
    apt-get install -q -y -o Dpkg::Use-Pty=0 build-essential curl perl bash git lsb-release libssl-dev
    curl -1sLf 'https://dl.cloudsmith.io/public/nxadm-pkgs/rakudo-pkg/setup.deb.sh' | bash
    apt-get update -qq && apt-get install -q -y -o Dpkg::Use-Pty=0 rakudo-pkg
    zef --version || install-zef
  ;;
  fedora)
    dnf -yq install curl perl bash redhat-lsb-core git openssl-devel
    curl -1sLf \
    'https://dl.cloudsmith.io/public/nxadm-pkgs/rakudo-pkg/setup.rpm.sh' \
    | bash
    dnf -yq install rakudo-pkg
    zef --version || install-zef
  ;;
  opensuse)
    curl -1sLf \
    'https://dl.cloudsmith.io/public/nxadm-pkgs/rakudo-pkg/setup.rpm.sh' \
    | bash
    zypper install -y rakudo-pkg
    zypper install -y git curl tar gzip libopenssl-devel
    zef --version || install-zef
  ;;
  *)
    printf "Your OS (%s) is not supported\n" "$OS"
    exit 1
esac

if raku -MTomtit -e 1; then
  echo "Tomtit already installed"
else
  zef install --/test --force-install --install-to=home Tomtit
fi

if raku -MSparky::JobApi -e 1; then
  echo "Sparky::JobApi already installed"
else
  zef install --/test --force-install --install-to=home Sparky::JobApi
fi


