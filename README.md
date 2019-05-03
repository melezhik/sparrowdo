# Sparrowdo

Run Sparrow6 tasks remotely.

# Build status

[![Build Status](https://travis-ci.org/melezhik/sparrowdo.svg)](https://travis-ci.org/melezhik/sparrowdo)

# Install

    zef install Sparrowdo

# Usage

    sparrowdo --host=remote-host [options]

For example:

    # ssh host, bootstrap first, use of local repository
    sparrowdo --host=13.84.166.232  --repo=file:///home/gimy/repo --verbose  --bootstrap

    # docker host, don't add sudo
    sparrowdo --docker=SparrowBird --no_sudo

    # localhost, with sudo
    sparrowdo --localhost


# DSL

Sparrow6 DSL is high level functions to manage configurations.

Just create a file named `sparrowdo` in current working directory and add few functions:

    $ cat sparrowfile

    user 'zookeeper';

    group 'birds';

    directory '/var/data/avifauna/greetings/', %( owner => 'zookeeper' );

    file-create '/var/data/avifauna/greetings/sparrow.txt', %( 
        owner => 'zookeeper',
        group => 'birds', 
        mode  => '0644', 
        content => 'I am little but I am smart'
    );

    service-start 'nginx';

    package-install ('nano', 'ncdu', 'mc' );


The full list of function is available at [Sparrow6 DSL](https://github.com/melezhik/Sparrow6/blob/master/documentation/dsl.md)
documentation.

If DSL is not enough you can call any Sparrow6 plugin using `task-run` function:


    task-run "show me your secrets", "azure-kv-show", %(
      kv      => "Stash" # key vault name
      secret  => ( "password", "login" ) # secret names
    )


## DSL vs `task-run` function

DSL is high level adapter with addition of some "syntax sugar" to make a code concise and readable. 

DSL functions are Perl6 functions, you take advantage of input parameters validation. 

However DSL is limited. Not every Sparrow6 plugin has related DSL function.

Once we've found some Sparrow6 plugin common enough we add a proper DSL wrapper for it.

In case you need more DSL wrappers let us know!

# Sparrowdo workflow

      ====================                                   ====================
      |                  |  --- [ Bootstrap ]                |                  | LocalHost
      |    MasterHost    |  --- [ Sparrowdo Scenario ] --->  |    TargetHost    | Docker 
      |                  |               *                   |                  | Ssh
      ====================               |                   ====================
       {Sparrow6 Module}                 |                    {Sparrow6 Module}
                                          \    parameters
                                           \-----------------> [ tasks ]
                                                                ^  ^  ^
                                                               /  /  /
                                 ------------                 /  /  /
                                { Repository } ---------------------
                                 ------------        [ plugins ]
                                 ------------
                                /      |     \
                               /       |      \
                              /        |       \
                             /         |        \
                          [CPAN]   [RubyGems] [PyPi]


## Master host

Master host is where Sparrow6 tasks "pushed" to target hosts.

Sparrowdo should be installed on master host:

    $ zef install Sparrowdo

## Sparrowdo scenario

Sparrowdo scenario is collection of Sparrow6 tasks executed on target host.

## Target hosts

Target hosts are configured by Sparrow6 which should be installed there as well:

    $ zef install Sparrow6

## Bootstrap

Bootstrap is process of automation of Sparrow6 installation on target host:

    $ sparrowdo --host=192.168.0.1 --bootstrap

Bootstrap runs under `sudo` and requires sudo privileges on target host.

## Sudo

Execution of Sparrow6 tasks on target host is made under `sudo` by default, to disable this use `no_sudo` flag:

    $ sparrowdo --docker=brave_cat --no_sudo # We don't need sudo on docker

## Varios types of target hosts

Once sparrowfile is created it could be run on target host.

Ssh host:

    $ sparrowdo --host=192.168.0.1

Docker container:

    $ sparrowdo --docker=old_dog

Localhost:

    $ sparrowdo --localhost

## Repositories

Sparrowdo repository is storage various Sparrow6 plugins that executed on target hosts.

During scenario execution Sparrowdo pulls  plugin from repository and runs it _with parameters_.

Parametrized with certian parameters Sparrow6 plugin is a Sparrow6 task.

* Detailed explanation of Sparrow6 tasks is available at [Sparrow6 development](https://github.com/melezhik/Sparrow6/blob/master/documentation/development.md) documentation.
* Detailed explanation of Sparrow6 plugins  [Sparrow6 plugins](https://github.com/melezhik/Sparrow6/blob/master/documentation/plugins.md) documentation
* Detailed explanation of Sparrow6 repositories is available at [Sparrow6 repositories](https://github.com/melezhik/Sparrow6/blob/master/documentation/repository.md) documentation.

By default [main Sparrow6](https://sparrowhub.org) repository is used to manage task dependencies:

    $ sparrowdo --host=192.168.0.1 # SparrowHub repository is used

Unless `--repo` flag is used, which comes in different flavors:

    $ sparrowdo --repo=file:///tmp/repo --localhost # use /tmp/repo repository for local mode

    $ docker run --name --name=fox -d sh -v /tmp/repo:/var/data
    $ sparrowdo --repo=/var/data --docker=fox --repo=file://var/data # mount /tmp/repo to /var/data within docker instance

    $ sparrowdo --repo=http://sparrow.repo # use http repository

Ssh mode supports synchronizing local file repositories with master and target host using rsync.
It extremely useful if for some reason you can't use http based repositories:

    $ sparrowdo --sync=/tmp/repo --host=192.168.0.1 # rsync local repository /tmp/repo to target host
    # and use it within there


Read [Sparrow6 documentation](https://github.com/melezhik/Sparrow6/blob/master/documentation/repository.md)
on task repositories.

# Sparrowdo files anatomy

When Sparrowdo scenario executed there are might be _related_ that get _copied_ to a target host,
for convenience, so that one can reliably refer to those files inside Sparrowdo scenario.

Thus Sparrowdo _project_ might consists of various files and folders:

    .
    ├── conf
    │   └── alternative.pl6
    ├── config.pl6
    ├── data
    │   └── list.dat
    ├── files
    │   └── baz.txt
    ├── sparrowfile
    └── templates
        └── animals.tmpl

* `sparrowfile`

The minimal setup is just `sparrowfile` placed in the current working directory.

That file contains Sparrowdo scenario to be executed.

One may optionally define other data that make up the whole set up:

* `conf`

Directory to hold configuration files

* `config.pl6` 

Default configuration file, if placed in current working directory will define Sparrowdo configuration, see
also [scenarios configuration](#scenario-configuration) section, alternatively one may place configuration file to `conf` directory and
choose to run with that file:


    $ sparrowdo --conf=conf/alternative.pl6


* `files`

Directory containing files, so one could write such a scenario:

    file "/foo/bar/baz.txt", %( source => "files/baz.txt" )

* `templates`

The same as `files` directory, but for templates, technically `templates` and `files` as equivalent, but
named separately for logical reasons. Obviously one can populate templates using that directory:


    template-create '/var/data/animals.txt', %(
      source => ( slurp 'templates/animals.tmpl' ),
      owner => 'zookeeper',
      group => 'animals' ,
      mode => '644',
      variables => %(
        name => 'red fox',
        language => 'English'
      ),
    );

* `data`

The same as `files` and `templates` folder but to keep "data" files, just another folder
 to separate logically different pieces of data:


    file "/data/list.txt", %( source => "data/list.dat" )

# Scenario configuration

If `config.pl6` file exists at the current working directory it _will be
loaded_ via Perl6 [EVALFILE](https://docs.perl6.org/routine/EVALFILE) at the _beginning_ of scenario. 

For example:

    $ cat config.pl6

    {
      user         => 'foo',
      install-base => '/opt/foo/bar'
    }

Later on in the scenario you may access config data via `config` function, that returns
configuration as Perl6 Hash object:

    $ cat sparrowfile

    my $user         = config<user>;
    my $install-base = config<install-base>;

To refer configuration files at arbitrary location use `--conf` parameter:

    $ sparrowdo --conf=conf/alternative.conf

See also [Sparrowdo files anatomy](#sparrowdo-files-anatomy) section.

# Including other Sparrowdo scenarios

Because Sparrowdo scenarios are Perl6 code files, you're free to include other scenarios into
"main" one using via Perl6 [EVALFILE](https://docs.perl6.org/routine/EVALFILE) mechanism:


    $ cat sparrowfile

    EVALFILE "another-sparrowfile";

Including another scenario does not include related files (`data`, `files`, `templates`) into main one,
so you can only reuse Sparrowdo scenario itself, but not it's _related_ files.

# Bootstrap and manual install

To ensure that target hosts has all required Sparrow6 dependencies one may choose bootstrap mechanism that
installs those dependencies on target host. This operation is carried out under `sudo`.

Bootstrap is disabled by default and should be enabled by `--bootstrap` option:

    $ sparrowdo --host=192.168.0.1 --bootstrap

Be aware that all dependencies will be installed _system wide_ rather then user account, because `sudo` is used.

if you don't want bootstrap target host, you can always choose to install Sparrow6 zef module 
on target host, which is enough to start using Sparrowdo to manage target host:

    $ zef install Sparrow6

# Run Sparrowdo on docker

Sparrowdo supports docker as target host, just refer to running docker container by name to
run Sparrowdo scenario on it:

    $ sparrowdo --docker=running-horse

# Run Sparrowdo on ssh hosts

This is probably one the most common use case for Sparrowdo - configuring servers by ssh:

    $ sparrowdo --host=192.168.0.1

# Run Sparrowdo in local mode

In case you need to run sparrowdo on localhost use `--localhost` flag:

    $ sparrowdo --localhost

# Sparrowdo cli 

`sparrowdo` is Sparrowdo cli to run Sparrowdo scenarios, it accepts following arguments:

* `--host`

Ssh host to run Sparrowdo scenario on. Default value is `127.0.0.1`, none required.

* `--docker`

Docker container name to run Sparrowdo scenario on, none required.

* `--localhost`

If set, runs Sparrowdo in localhost, in that case Sparrow6 tasks get run directly withouth launching ssh

* `--ssh_user`

If set defines ssh user when run Sparrowdo scenarion over ssh, none required.

* `--ssh_port`

If set defines ssh port to use  when run Sparrowdo scenarion over ssh. Default value is 22.



If set, run Sparrowdo scenario on localhost, don't consfuse with `--host=127.0.0.1` which
runs scenarion on the machine but using ssh.

* `--repo`

If set, define Sparrow6 repository `URL`, for example:

    --repo=https://192.168.0.1 # Http repository

    --repo=file:///var/data/repo # Local file system repository

If Sparrow6 repository not set by usign `--repo`, main Sparrow6 repository is used which http://sparrowhub.org

Sparrowdo uses repository to pull plugins from, see also [Sparrowdo workflow](#sparrowdo-workflow) section.

See also [Sparrow6 Repositories](https://github.com/melezhik/Sparrow6/blob/master/documentation/repository.md)
documentation.

* `--sync`

If set synchronize local file system repository with target hosts using `rsync`, it's useful if for some reasons
remote http repositories are not available or disable, so one can _automatically copy_ repository from master host
to target. `--sync` parameter value should file path pointing repository directory at master host:

    --sync=/var/data/repository

* `--no_index_update`

If set, don't request Sparrow6 repository update. Useful when in limited internet and using http based remote repositories.

* `--verbose`

If set print additional information during Sparrowdo scenario execution.

* `--debug`

If set, runs Sparrow6 tasks in `debug` mode, giving even more information, during scenario execution.

* `--prefix`

If set, define path to be appending to local cache directory on target host, used predominantly 
when running concurrent Sparrowdo scenario on one target host, for example in Sparky CI server.
None required, no default value.

# Author

Alexey Melezhik

# See also

* [Sparrow6](https://github.com/melezhik/Sparrow6)

# Thanks

To God as the One Who inspires me to do my job!

