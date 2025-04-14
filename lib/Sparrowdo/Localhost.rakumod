use v6;

unit module Sparrowdo::Localhost;

use Sparrowdo::Utils;

sub run-tasks-localhost (%args?) is export {

  say "[localhost] run tasks" if %args<verbose>;

  my $cmd = "bash --login .sparrowdo/sparrowrun.sh";

  say "[localhost] effective cmd: $cmd" if %args<verbose>;

  shell $cmd;

}

sub bootstrap-localhost (%args?) is export {

  say "[localhost] bootstrap" if %args<verbose>;

  my @cmd = ( "sudo", "--login", "sh", "{$*CWD}/.sparrowdo/bootstrap.sh" {rakudo-linux-version()} {rakudo-linux-install-prefix()} );

  run @cmd;

}

