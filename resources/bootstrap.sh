export PATH=/opt/rakudo-pkg/bin:$PATH
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
    rm -rf /etc/yum.repos.d/rakudo-pkg.repo
    echo -e "[rakudo-pkg]\nname=rakudo-pkg\nbaseurl=https://dl.bintray.com/nxadm/rakudo-pkg-rpms/`lsb_release -is`/`lsb_release -rs| cut -d. -f1`/x86_64\ngpgcheck=0\nenabled=1" | tee -a /etc/yum.repos.d/rakudo-pkg.repo
    yum -q -y install rakudo-pkg
  ;;
  arch|archlinux)
    pacman -Syy
    pacman -S --needed --noconfirm -q curl perl bash git
    pacman -S --needed --noconfirm -q rakudo
  ;;
  debian|ubuntu)
    DEBIAN_FRONTEND=noninteractive
    apt-get update -q -o Dpkg::Use-Pty=0
    apt-get install -q -y -o Dpkg::Use-Pty=0 build-essential curl perl bash git lsb-release apt-transport-https ca-certificates 
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 379CE192D401AB61
    rm -rf /etc/apt/sources.list.d/rakudo-pkg.list
    echo "deb https://dl.bintray.com/nxadm/rakudo-pkg-debs `lsb_release -cs` main" | tee -a /etc/apt/sources.list.d/rakudo-pkg.list
    apt-get update -qq && apt-get install -q -y -o Dpkg::Use-Pty=0 rakudo-pkg
  ;;
  fedora)
    dnf -yq install curl perl bash redhat-lsb-core git
    rm -rf /etc/yum.repos.d/rakudo-pkg.repo
    echo -e "[rakudo-pkg]\nname=rakudo-pkg\nbaseurl=https://dl.bintray.com/nxadm/rakudo-pkg-rpms/`lsb_release -is`/`lsb_release -rs| cut -d. -f1`/x86_64\ngpgcheck=0\nenabled=1" | tee -a /etc/yum.repos.d/rakudo-pkg.repo
    dnf -yq install rakudo-pkg
  ;;
  opensuse)
    zypper install -y lsb-release
    #zypper ar -f https://dl.bintray.com/nxadm/rakudo-pkg-rpms/openSUSE/`lsb-release -rs`/x86_64 rakudo-pkg
    zypper install -y rakudo-pkg
    zypper install -y git curl tar gzip
  ;;
  *)
    printf "Your OS (%s) is not supported\n" "$OS"
    exit 1
esac

zef install --/test --force-install https://github.com/melezhik/Sparrow6.git


