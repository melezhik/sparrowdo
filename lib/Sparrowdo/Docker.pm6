use v6;

unit module Sparrowdo::Docker;

use Sparrowdo::Utils;

sub prepare-docker-host ($host,%args?) is export {

  say "[docker] prepare instance: $host" if %args<verbose>;

  say "[docker] copy harness files" if %args<verbose>;

  my $prefix = %args<prefix> || "default";

  my @cp-cmd = (
    "podman",
    "exec",
    "-i",
    $host,
    "mkdir",
    "-p",
    "/root/.sparrowdo/env/$prefix",
  );

  run @cp-cmd;


  @cp-cmd = (
    "podman",
    "cp",
    ".sparrowdo/",
    "$host:/root/.sparrowdo/env/$prefix/",
  );

  run @cp-cmd;

}


sub bootstrap-docker-host ($host, %args?) is export {

  say "[docker] bootstrap" if %args<verbose>;

  my $prefix = %args<prefix> || "default";

  my @cmd = (
    "podman",
    "exec",
    "-i",
    "$host",
    "sh", 
    "/root/.sparrowdo/env/$prefix/.sparrowdo/bootstrap.sh"
  );

  run @cmd;

}

sub run-tasks-docker-host ($host,%args?) is export {

  say "[docker] run tasks on instance $host" if %args<verbose>;

  my $prefix = %args<prefix> || "default";

  my $cmd = "podman exec -t $host sh /root/.sparrowdo/env/$prefix/.sparrowdo/sparrowrun.sh";

  say "[docker] effective cmd: $cmd" if %args<verbose>;

  shell $cmd;

}

