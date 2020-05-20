use v6;

unit module Sparrowdo::Ssh;

use Sparrowdo::Utils;

sub prepare-ssh-host ($host,%args?) is export {

  say "[ssh] prepare host: $host" if %args<verbose>;

  say "[ssh] copy harness files" if %args<verbose>;

  my @cmd = (
    "scp",
    "-r",
    "-q",
    "-o",
    "ConnectionAttempts=1",
    "-o",
    "ConnectTimeout=5",
    "-o",
    "UserKnownHostsFile=/dev/null",
    "-o",
    "StrictHostKeyChecking=no",
    (  %args<ssh-port> ?? "-P {%args<ssh-port>}" !! "-P 22" ),
    ( %args<ssh-private-key> ?? "-i {%args<ssh-private-key>}" !! "" ),
    ".sparrowdo/",
    (  %args<ssh-user> ?? "{%args<ssh-user>}\@$host:" !! "$host:" ),
  );

  my $cmd =  @cmd.join(" ");

  say "[ssh] effective cmd: $cmd" if %args<verbose>;

  shell $cmd;

  if %args<sync> {

    say "[scp] sync local repo from {%args<sync>}" if %args<verbose>;

    @cmd = (
      "scp",
      "-r",
      "-q",
      "-o",
      "ConnectionAttempts=1",
      "-o",
      "ConnectTimeout=5",
      "-o",
      "UserKnownHostsFile=/dev/null",
      "-o",
      "StrictHostKeyChecking=no",
      (  %args<ssh-port> ?? "-P {%args<ssh-port>}" !! "-P 22" ),
      (  %args<ssh-private-key> ?? "-i {%args<ssh-private-key>}" !! "" ),
      %args<sync>,
      (  %args<ssh-user> ?? "{%args<ssh-user>}\@$host:.sparrowdo/" !! "$host:.sparrowdo/" ),
    );
  
    $cmd =  @cmd.join(" ");
  
    say "[ssh] effective cmd: $cmd" if %args<verbose>;

    shell $cmd;
    
  }

}


sub run-tasks-ssh-host ($host,$sparrowfile,%args?) is export {

  say "[ssh] run tasks from $sparrowfile on host $host" if %args<verbose>;

  my @cmd = ("ssh");

  push @cmd,  ("-l", %args<ssh-user> ) if   %args<ssh-user>;

  push @cmd, (
    "-q",
    "-o",
    "ConnectionAttempts=1",
    "-o",
    "ConnectTimeout=5",
    "-o",
    "UserKnownHostsFile=/dev/null",
    "-o",
    "StrictHostKeyChecking=no",
    "-tt",
    ( %args<ssh-port> ?? "-p {%args<ssh-port>}" !! "-p 22" ),
    ( %args<ssh-private-key> ?? "-i {%args<ssh-private-key>}" !! "" ),
    (  %args<ssh-user> ?? "{%args<ssh-user>}\@$host" !! "$host" ),
    "bash --login .sparrowdo/sparrowrun.sh"
  );


  my $cmd =  @cmd.join(" ");

  say "[scp] effective cmd: $cmd" if %args<verbose>;

  shell $cmd;


}

sub bootstrap-ssh-host ($host, %args?) is export {

  say "[ssh] bootstrap" if %args<verbose>;

  my @cmd = (
    "ssh",
    "-q",
    "-o",
    "ConnectionAttempts=1",
    "-o",
    "ConnectTimeout=5",
    "-o",
    "UserKnownHostsFile=/dev/null",
    "-o",
    "StrictHostKeyChecking=no",
    "-o",
    "ServerAliveInterval=300",
    "-o",
    "ServerAliveCountMax=2",
    "-tt",
    ( %args<ssh-port> ?? "-p {%args<ssh-port>}" !! "-p 22" ),
    ( %args<ssh-private-key> ?? "-i {%args<ssh-private-key>}" !! "" ),
  );

  push @cmd, ("-l", %args<ssh-user> ) if   %args<ssh-user>;

  push @cmd, (
    "$host",
    "sudo --login sh \\\$PWD/.sparrowdo/bootstrap.sh"
  );

  my $cmd =  @cmd.join(" ");

  say "[ssh] effective cmd: $cmd" if %args<verbose>;

  shell $cmd;


}

