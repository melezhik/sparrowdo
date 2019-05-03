Revision history for Sparrowdo

{{$NEXT}}

    - Dump tasks data in verbose mode

0.0.45  2019-01-07T13:19:02-06:00

    - sparrowdo cli - `--conf` option to pass a path to Sparrowdo configuration file
    - fix for `--color` in term-out sub

0.0.44  2018-12-30T22:01:39-06:00

    - Introducing `-q` option for `sparrowdo` cli
    - Refactoring - replace `say` by dedicated `term-out` function

0.0.43  2018-12-04T21:56:24Z

    - Fix: `no index update` handling subtle bugs
    - Fix: resolve path to sparrowdo.ini configuration file for root user

0.0.42  2018-10-19T15:48:12Z

    - Windows support

    - Add cwd to `bash` command

    - Workaround for weird bug when `shell` does not raise exeption in case of unsuccessful exit code from run command - https://github.com/rakudo/rakudo/issues/2292#issuecomment-422848157

    - Fixing bugs in integration tests

0.0.41  2018-10-18T20:55:45Z

    - Windows support

0.0.40  2018-08-14T16:52:16-05:00

    - Feature - Sparrowdo variables - https://github.com/melezhik/sparrowdo/pull/31/ , thanks to @spigel

    - Bug fix - handle sparrowdo.ini file

    - Bug fix - travis tests are fixed ( used ubuntu as api box intead of centos )

    - Minimal support for Darwin OS ( make sparrowdo runnable on OSx )

0.0.39  2018-05-30T20:52:47Z

    - Fixed sparrowdo travis tests
    - Hot fix for cwd parameter default value

# 0.0.38 2018-05-30

* `--cwd parameter` default value is current working directory ( which is good choice for `--local_mode` run )
* README.md refactored and improved, added "Getting started with Sparrowdo" section, thanks to @Tyil - #24
* git-scm may accept ssh key, thanks to @spigell
* copy-local-file now may copy directories, thanks to @spigell
* running sparrowdo on none bootstrapped system now emerges more friendly/understandable message #26
* don't raise errors when `--boostrap` and sparrowfile does not exist

# 0.0.37 2018-01-20

- Git Scm now is able to checkout branch 
- Vagrant support

# 0.0.36 2017-12-04

- docker exec do not allocate pseudo tty

# 0.0.35 2017-10-16

- Git scm - add user and debug parameters
- Use mi6 CPAN uploader to upload distro to CPAN

# 0.0.34 2017-10-16

- Sparrowdo bootstrap is compelte rewitten, huge thanks to @Tyil
- Parallel tests for varios OS, huge thanks for @Tyil

# 0.0.33 2017-10-11

- Funtoo Linux  Bootstrap
- Minor bug fixes (#13)
- Minor fixes in bootstrap function

# 0.0.32 2017-10-09

Core-dsl doc: `on_change` parameter for `template` function

# 0.0.31 2017-09-21

- Ssh passwords support, acknowledges to @Spigell - https://github.com/melezhik/sparrowdo/pull/12
- Minor fixes at sparrowdo cache method
- Improvment of tests
- bin/sparrowdo small refactoring

# 0.0.30 2017-09-21

- Minoca OS bootstrap support 

# 0.0.29 2017-09-13

- Archlinux bootstrap impoved, thanks to @Spigell (https://github.com/melezhik/sparrowdo/pull/10 , https://github.com/melezhik/sparrowdo/pull/11 )


# 0.0.28 2017-09-01

- Sets format for reports by using `--format`, `OUTTENTIC_FORMAT`, or sparrowdo.ini file

# 0.0.26 2017-08-03

- Core dsl - minor fixes for subroutines signatures to make it sure it works on recent Rakudo

# 0.0.26 2017-08-03

- Core dsl - make hash parameters optional ( the bug appears on the recent Rakudo )
- `sparrowhub_api` - `~/sparrowdo.ini` parameter to set SparrowHub API Url 

# 0.0.25 2017-07-25

- Git SCM support 

# 0.0.24 2017-07-20

- Minor correction to alpine bootstrap
- Documenting zef DSL

# 0.0.23 2017-07-07

- Universal bootstrap: ubuntu / alpine bugfix

# 0.0.22 2017-07-06

- Universal bootstrap

# 0.0.21 2017-06-29

- Support for --cwd option
- Sparrow/Sparrowdo cache files refactoring to allow run multiple sparrowdo scenarios on the same host safely
- Now respect no_color completely
- Varios zef dsl fixes

# 0.0.20 2017-06-22

- Experimental zef support ( not even documented )

# 0.0.19 2017-06-15

- Http-ok function now is able to check web page content

# 0.0.18 2017-05-05

- Improve http-ok asserts ( support many signatures )

# 0.0.17

- Asserts
- Added license to META6 file

# 0.0.16 

copy-local-file - experimental feature

# 0.0.15 2017-04-12

Figure out my tests. Fix for #3

# 0.0.14 2017-04-12

* Pass module parameters by command line
* Change colors in reports ( to be more readable at travis and asciinema )

# 0.0.12 2017-04-11

A minor fixes for Travis and bootstrap

# 0.0.11 2017-04-11

Final version for: running multiple tasks (plugins) with multiples parameters via command line

# 0.0.10 2017-04-10

Running multiple tasks from command line

# 0.0.9 2017-04-04

Changing reports layout

# 0.0.8 2017-03-17

* Add SparrowRoot input parameter

# 0.0.7 2017-02-01

* a lot of improvements for bash/ssh/scp core dsl functions

# 0.0.6

* core-dsl/ssh - refactoring

# 0.0.5

* core-dsl/ssh - fix documentation issues / add `create` parameter

# 0.0.4

* core-dsl/ssh - explicit exit at the end of ssh command

# 0.0.3

* core-dsl/bash - generated a proper description for command ( if not set ) instead of dummy "execute bash command"
* core-dsl/ssh function added

# 0.0.2

* File core-dsl : Add support for `source` parameter
* Add alias for task_run - task-run 
* Prettified the docs ( minor changes ) 

# 0.0.1

* First version
