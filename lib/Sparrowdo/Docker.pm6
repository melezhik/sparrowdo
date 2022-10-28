use v6;

unit module Sparrowdo::Docker;

use Sparrowdo::Utils;

sub docker-cmd () {

  return %*ENV<SPARROWDO_DOCKER_BIN> || "docker";

}

sub prepare-docker-host ($host,%args?) is export {

  say "[docker] prepare instance: $host" if %args<verbose>;

  say "[docker] copy harness files" if %args<verbose>;

  my $prefix = %args<prefix> || "default";

  my @rmdir-cmd = (
    docker-cmd(),
    "exec",
    "-i",
    $host,
    "rm",
    "-rf",
    "/var/.sparrowdo/env/$prefix",
  );

  run @rmdir-cmd;

  my @cp-cmd = (
    docker-cmd(),
    "exec",
    "-i",
    $host,
    "mkdir",
    "-p",
    "/var/.sparrowdo/env/$prefix",
  );

  run @cp-cmd;

  @cp-cmd = (
    docker-cmd(),
    "cp",
    ".sparrowdo/",
    "$host:/var/.sparrowdo/env/$prefix/",
  );

  run @cp-cmd;

  my @chmod-cmd = (
    docker-cmd(),
    "exec",
    "-i",
    $host,
    "chmod",
    "-R",
    "a+rwx",
    "/var/.sparrowdo/env/$prefix",
  );

  run @chmod-cmd;
}


sub bootstrap-docker-host ($host, %args?) is export {

  say "[docker] bootstrap" if %args<verbose>;

  my $prefix = %args<prefix> || "default";

  my @cmd = (
    docker-cmd(),
    "exec",
    "--user",
    "root",
    "-i",
    "$host",
    "sh", 
    "/var/.sparrowdo/env/$prefix/.sparrowdo/bootstrap.sh"
  );

  run @cmd;

}

sub run-tasks-docker-host ($host,%args?) is export {

  say "[docker] run tasks on instance $host" if %args<verbose>;

  my $prefix = %args<prefix> || "default";

  my $cmd = "{docker-cmd()} exec -i $host sh -l /var/.sparrowdo/env/$prefix/.sparrowdo/sparrowrun.sh";

  say "[docker] effective cmd: $cmd" if %args<verbose>;

  shell $cmd;

}

