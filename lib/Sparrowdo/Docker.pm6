use v6;

unit module Sparrowdo::Docker;

use Sparrowdo::Utils;

sub prepare-docker-host ($host,%args?) is export {

  say "[docker] prepare instance: $host" if %args<verbose>;

  say "[docker] copy harness files" if %args<verbose>;

  my @cp-cmd = (
    "docker",
    "cp",
    ".sparrowdo/",
    "$host:/root/",
  );

  run @cp-cmd;

}


sub run-tasks-docker-host ($host,%args?) is export {

  say "[docker] run tasks on instance $host" if %args<verbose>;

  my $cmd = "docker exec -i $host sh /root/.sparrowdo/sparrowrun.sh";

  say "[docker] effective cmd: $cmd" if %args<verbose>;

  shell $cmd;

}

sub bootstrap-docker-host ($host, %args?) is export {

  say "[docker] bootstrap" if %args<verbose>;

  my @cmd = (
    "docker",
    "exec",
    "-i",
    "$host",
    "sh", 
    "/root/.sparrowdo/bootstrap.sh"
  );

  run @cmd;

}
