use v6;

unit module Sparrowdo::Utils;

use Sparrowdo::Bootstrap;

sub rakudo-linux-version () is export {
  'rakudo-moar-2024.06-01-linux-x86_64-gcc'
}

sub rakudo-linux-install-prefix () is export {
  '/opt/sparrowdo/rakudo'
}

sub generate-sparrowdo-harness (%args) is export {

  my $prefix = %args<prefix> || "default";

  say "[utils] generate-sparrowdo-harness" if %args<verbose>;
  say "[utils] clean up .sparrowdo directory" if %args<verbose>;

  if %args<verbose> {
    shell "if test -d .sparrowdo; then rm -rfv .sparrowdo; else echo '.sparrowdo dir does not exist'; fi";
  } else {
    shell "if test -d .sparrowdo; then rm -rf .sparrowdo; else : ; fi";
  }

  say "[utils] create .sparrowdo directory" if %args<verbose>;

  mkdir ".sparrowdo";

  if "{%args<sparrowfile>}".IO ~~ :f {

    say "copy {%args<sparrowfile>} to .sparrowdo/sparrowfile" if %args<verbose>;

    copy(%args<sparrowfile>, ".sparrowdo/sparrowfile");
  }

  say "[utils] generate bootstrap script: .sparrowdo/bootstrap.sh" if %args<verbose>;

  my $fh = open ".sparrowdo/bootstrap.sh", :w;
  $fh.say(bootstrap-script());
  $fh.close;

  say "[utils] generate sparrowrun.sh script: .sparrowdo/sparrowrun.sh" if %args<verbose>;

  $fh = open ".sparrowdo/sparrowrun.sh", :w;

  $fh.say("set -e");

  $fh.say("# deployment type: {%args<type>}");

  $fh.say("# activate sparrowdo shipped rakudo");

  $fh.say("eval \$({rakudo-linux-install-prefix()}/{rakudo-linux-version()}/scripts/set-env.sh --quiet 2>/dev/null)");

  $fh.say("# add binaries installed via zef install --to=home");
  
  $fh.say("export PATH=~/.raku/bin/:\$PATH");

  if %args<type> eq 'docker' {

    $fh.say("cd /var/.sparrowdo/env/$prefix/.sparrowdo");

  } elsif %args<localhost> {

    $fh.say("cd .sparrowdo/");

  } else {

    $fh.say("cd .sparrowdo/env/$prefix/.sparrowdo");

  }


  $fh.say("export SP6_CONFIG={%args<config>}") if %args<config> and %args<config>.IO ~~ :e ; 

  if %args<sync> {
    $fh.say("export SP6_REPO=file://\$PWD/{%args<sync>.IO.basename}")
  } else {
    $fh.say("export SP6_REPO={%args<repo>}") if %args<repo>;
  }

  $fh.say("export SP6_PREFIX=.sparrowdo/$prefix");
  $fh.say("export SP6_DEBUG=1") if %args<debug>;
  $fh.say("export SP6_CARTON_OFF={%*ENV<SP6_CARTON_OFF>}") if %*ENV<SP6_CARTON_OFF>;
  $fh.say("export SP6_TAGS='{%args<tags>}'") if %args<tags>;
  $fh.say("export SP6_FORMAT_COLOR=1") if %args<color>;

  if %args<sudo> && %args<type> eq 'default' {
    if $%args<index-update> {
      $fh.say("sudo env PATH=\$PATH SP6_FORMAT_COLOR=\$SP6_FORMAT_COLOR SP6_PREFIX=\$SP6_PREFIX SP6_DEBUG=\$SP6_DEBUG SP6_REPO=\$SP6_REPO SP6_TAGS=\$SP6_TAGS raku -MSparrow6::Task::Repository -e Sparrow6::Task::Repository::Api.new.index-update;");
    }
    $fh.say("sudo env PATH=\$PATH d=\$dir SP6_FORMAT_COLOR=\$SP6_FORMAT_COLOR  SP6_CONFIG=\$SP6_CONFIG SP6_CARTON_OFF=\$SP6_CARTON_OFF SP6_PREFIX=\$SP6_PREFIX SP6_DEBUG=\$SP6_DEBUG SP6_REPO=\$SP6_REPO SP6_TAGS=\$SP6_TAGS raku -MSparrow6::DSL sparrowfile");
  } else {
    if $%args<index-update> {
      $fh.say("raku -MSparrow6::Task::Repository -e Sparrow6::Task::Repository::Api.new.index-update");
    }
    $fh.say("raku -MSparrow6::DSL sparrowfile");
  }

  $fh.close;

  if %args<verbose> {
    say ".sparrowdo/sparrowrun.sh content";
    say slurp(".sparrowdo/sparrowrun.sh");
  }

  prepare-sparrowdo-files %( verbose => %args<verbose> );

}

sub prepare-sparrowdo-files (%args?)  is export {

  say "[utils] prepare sparrowdo files" if %args<verbose>;
  say "[utils] cwd: {$*CWD}" if %args<verbose>;

  shell "touch .sparrowdo/sparrowdo.dummy";

  my @cmd = (
    'cp',
    '-r',
  );

  #push @cmd, "-v" if %args<verbose>;

  push @cmd, "2>&1";

  my @files;

  push @files, "config.pl6" if "config.pl6".IO ~~ :f;
  push @files, "templates" if "templates".IO ~~ :d;
  push @files, "files" if "files".IO ~~ :d;
  push @files, "conf" if "conf".IO ~~ :d;
  push @files, "data" if "data".IO ~~ :d;


  if @files.elems > 0 {

    say "copy additional sparrowdo files: {@files.perl}" if %args<verbose>;

    push @cmd, @files, ".sparrowdo/";

    my $cmd = join " ", @cmd;

    say "[utils] effective cmd: $cmd" if %args<verbose>;

    shell @cmd;


  }

}

