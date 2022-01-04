export PATH=$PATH:$HOME/.raku/bin/:/opt/rakudo-pkg/bin # to support latest rakudo distributions that install zef separately to ~/.raku

set -e

case "$OS" in
  alpine)
    apk update --wait 120
    apk add --wait 120 curl perl bash git
    curl -s -L -k -o /tmp/rakudo-pkg-Alpine3.10_2020.02.1-04_x86_64.apk https://github.com/nxadm/rakudo-pkg/releases/download/v2020.02.1-04/rakudo-pkg-Alpine3.10_2020.02.1-04_x86_64.apk
    apk add --allow-untrusted /tmp/rakudo-pkg-Alpine3.10_2020.02.1-04_x86_64.apk

  ;;
  amazon|centos|red)
    yum -q -y install make curl perl bash redhat-lsb-core git perl-JSON-PP
    curl -1sLf \
    'https://dl.cloudsmith.io/public/nxadm-pkgs/rakudo-pkg/setup.rpm.sh' \
    | bash
    yum -q -y install rakudo-pkg
    install-zef
  ;;
  arch|archlinux)
    pacman -Syy
    pacman -S --needed --noconfirm -q curl perl bash git
    pacman -S --needed --noconfirm -q rakudo
  ;;
  debian|ubuntu)
    DEBIAN_FRONTEND=noninteractive
    apt-get update -q -o Dpkg::Use-Pty=0
    apt-get install -q -y -o Dpkg::Use-Pty=0 build-essential curl perl bash git lsb-release
    curl -1sLf 'https://dl.cloudsmith.io/public/nxadm-pkgs/rakudo-pkg/setup.deb.sh' | bash
    apt-get update -qq && apt-get install -q -y -o Dpkg::Use-Pty=0 rakudo-pkg
    zef --version || install-zef
  ;;
  fedora)
    dnf -yq install curl perl bash redhat-lsb-core git
    curl -1sLf \
    'https://dl.cloudsmith.io/public/nxadm-pkgs/rakudo-pkg/setup.rpm.sh' \
    | bash
    dnf -yq install rakudo-pkg
    install-zef
  ;;
  opensuse)
    curl -1sLf \
    'https://dl.cloudsmith.io/public/nxadm-pkgs/rakudo-pkg/setup.rpm.sh' \
    | bash
    zypper install -y rakudo-pkg
    zypper install -y git curl tar gzip
  ;;
  *)
    printf "Your OS (%s) is not supported\n" "$OS"
    exit 1
esac

zef install --/test --force-install https://github.com/melezhik/Sparrow6.git https://github.com/melezhik/sparky-job-api.git


