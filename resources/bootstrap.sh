export PATH=$PATH:$HOME/.raku/bin/:/opt/rakudo-pkg/bin # to support latest rakudo distributions that install zef separately to ~/.raku

set -e

echo "start bootstrap"

install_zef()
{
  if zef -v 2>/dev/null; then
    echo "zef already installed"
  else
    rm -rf /tmp/zef
    git clone https://github.com/ugexe/zef.git /tmp/zef
    cd /tmp/zef
    raku -I. bin/zef install . --/test --install-to=home --force-install
  fi
}
case "$OS" in
  alpine)
    apk update --wait 120
    apk add --no-cache --wait 120 curl perl bash git openssl-dev
    curl -1sLf 'https://dl.cloudsmith.io/public/nxadm-pkgs/rakudo-pkg/setup.alpine.sh' | bash
    apk add rakudo-pkg
    install_zef
  ;;
  amazon|centos|red)
    yum -q -y install make curl perl bash redhat-lsb-core git perl-JSON-PP openssl-devel
    curl -1sLf \
    'https://dl.cloudsmith.io/public/nxadm-pkgs/rakudo-pkg/setup.rpm.sh' \
    | bash
    yum -q -y install rakudo-pkg
    install_zef
  ;;
  arch|archlinux)
    pacman -Syy
    pacman -S --needed --noconfirm -q curl perl bash git openssl base-devel openssl-1.1
    if raku -v 2>/dev/null; then
      echo "rakudo already installed"
    else
      id -u aur &>/dev/null || useradd -m aur
      su - aur -c "rm -rf /tmp/rakudo && git clone https://aur.archlinux.org/rakudo-bin.git /tmp/rakudo && cd /tmp/rakudo && makepkg --skippgpcheck"
      pacman --noconfirm -U /tmp/rakudo/*.tar.zst
    fi
    install_zef
  ;;
  debian|ubuntu)
    DEBIAN_FRONTEND=noninteractive
    apt-get update -q -o Dpkg::Use-Pty=0
    apt-get install -q -y -o Dpkg::Use-Pty=0 build-essential curl perl bash git lsb-release libssl-dev
    curl -1sLf 'https://dl.cloudsmith.io/public/nxadm-pkgs/rakudo-pkg/setup.deb.sh' | bash
    apt-get update -qq && apt-get install -q -y -o Dpkg::Use-Pty=0 rakudo-pkg
    install_zef
  ;;
  fedora)
    dnf -yq install curl perl bash redhat-lsb-core git openssl-devel
    curl -1sLf \
    'https://dl.cloudsmith.io/public/nxadm-pkgs/rakudo-pkg/setup.rpm.sh' \
    | bash
    dnf -yq install rakudo-pkg
    install_zef
  ;;
  opensuse)
    curl -1sLf \
    'https://dl.cloudsmith.io/public/nxadm-pkgs/rakudo-pkg/setup.rpm.sh' \
    | bash
    zypper install -y rakudo-pkg
    zypper install -y git curl tar gzip libopenssl-devel
    install_zef
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


