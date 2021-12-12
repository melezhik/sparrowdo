# Sparky Integration

This section describes how to run Sparrowdo scenarios in asynchronous mode, using [Sparky](https://github.com/melezhik/sparky) backend. 

## Install Sparky

```
git clone https://github.com/melezhik/sparky.git
cd sparky
zef install . --/test

# Initialize Sparky DB
raku db-init.raku

# Run Sparky daemon
nohup sparkyd &

# Run Sparky Web UI
nohup raku bin/sparky-web.raku &
```

## Create sparrowdo scenario

`$ nano sparrowfile`

```raku
package-install "nano";
```

## Setup hosts

`$ nano hosts.raku`

```raku
[
  "localhost", # run on localhost
  "192.168.0.1", # run on remote host using ssh
  "docker:webapp", # run on docker container, named `webapp`
]
```

Hosts specification. Hosts file should be a Raku code returning an Array of hosts, where host is a one of the following:

* `localhost` - localhost, run Sparrowdo on localhost, no remote execution
* `hostname` - remotehost, run Sparrowdo on remote host `hostname` using ssh protocol
* `docker:name` - docker, run Sparrowdo on docker container, named `name` using `docker exec`

## Run Sparrowdo

`sparrowdo --host=hosts.raku --bootstrap`

This command run sparrowdo scenario asynchronously for all hosts defined in host file.

## Check builds in Sparky UI

To track build execution, use Sparky web interface.

* Go to http://127.0.0.1:3000

* Check queue and recent builds tabs

Queue tab contains a list of builds to be executed.

Recent build tab contains a list of currently executed builds.

# Advanced topics

## Tags

Tags are symbolic labels attached to hosts, tags allow to: 

* separate one hosts from another.
* pass key/value pairs to hosts configurations

To assign tag one need to declare hosts in `host` file using Raku Hash notation:

```raku
[
   %( host => "192.168.0.1", tags => "loadbalancer" ),
   %( host => "192.168.0.2", tags => "frontend" ),
   %( host => "192.168.0.3", tags => "database" ),
]
```

To handle tag, use `tags()` function within sparrowdo scenario:

```raku
if tags()<loadbalancer> or tags()<frontend> {
  package-install "nginx";
} elsif tags()<database> {
  package-install "mysql";
}
```

One can attach more then one tag using `,` separator:

```raku
%(
  host => "192.168.0.1", 
  tags => "database,dev" 
);
```

Or using Raku List syntax:


```raku
%(
  host => "192.168.0.1", 
  tags => [ "database", "dev" ]
);
```

One can filter out certain hosts by providing `--tags` cli option:

```raku
sparrowdo --sparrowfile=database.raku --tags=database,prod --host=hosts.raku
```

This command will queues builds only for hosts having `database` and `prod` tags.

## key/value pairs

To assign key/value parameters to hosts use `tags` with `key=value` syntax:

```raku
%(
    host => "192.168.0.1",
    tags => "server=nginx,port=443"
)
```

Alternatively one can use Raku hashes for tags:

```raku
%( 
   host => "localhost",
   tags => %(
     server => "nginx",
     port => "443" 
   ) 
);
```

Or as Raku Arrays:

```raku
%( 
   host => "localhost",
   tags => [ "frontend", "dev" ]
);
```


To handle `key/value` pairs use standard Raku Hash mechanism:

```raku

my $port = tags()<nginx-port>
```

You can pass `key/value` tags as cli parameters as well:

```
sparrowdo --sparrowfile=database.raku --tags=nginx_port=443,mode=production --host=hosts.raku
```

## names

To give builds descriptive names use `name` key, it should not contain spaces.

A build name will appear in Sparky reports list:


```raku
%( 
   host => "localhost",
   tags => %(
     server => "nginx",
     port => "443",
     name => "web-server"
   ),
);
```

## Bind build to project

To run a build on a certain Sparky project use `project` key:

```raku
%(
   host => "localhost",
   project => "web-app-build" 
);
```

## Watcher jobs

Watcher jobs mechanism allows one to wait until all asynchronous job finishes
and does some action upon this even. This is very powerful and flexible feature
enabling really complex scenarios:

To active watcher mode one needs to do 2 steps:

1. Use `--watch` parameter when run `sparrowdo`:

```bash
sparrowdo --hosts=hosts.raku --watch=watch.raku
```

Watch parameter should point to a file with Raku
scenario implementing watcher logic, see next.


2. Watch scenario

`watch.raku` file might contain the following
code:

```raku
use Curlie;

my \c = Curlie.new;
my @jobs;

for config()<jobs><> -> $j {
  my $supply = supply {
      my $i = 1;
      while True {
          c.get: "http://127.0.0.1:3000/status/{$j<project>}/{$j<job-id>}" or next;
          if c.res.content.Int == 1 {
            emit %( id => $j<job-id>, status => "OK");
            done;
          } elsif c.res.content.Int == -1 {
            emit %( id => $j<job-id>, status => "FAIL");
            done;
          } elsif c.res.content.Int == 0 {
            emit %( id => $j<job-id>, status => "RUNNING");
          }
          $i++;
          if $i>=300 { # timeout after 300 requests
            emit %( id => $j<job-id>, status => "TIMEOUT");
            done
          }
      }
  }

  $supply.tap( -> $v {
      if $v<status> eq "FAIL" or $v<status> eq "OK"  or $v<status> eq "TIMEOUT" {
        push @jobs, $v;
      }
      say $v;
  });

}

say @jobs.grep({$_<status> eq "OK"}).elems, " jobs finished successfully";
say @jobs.grep({$_<status> eq "FAIL"}).elems, " jobs failed";
say @jobs.grep({$_<status> eq "TIMEOUT"}).elems, " jobs timeouted";
```

This simple scenario illustrates how one can iterate though jobs (`config()<jobs>`)
and get their statuses when they are finished using [Sparky HTTP API](https://github.com/melezhik/sparky#build-status-1).

To get job details use `%job` hash keys:

```raku
  say "job name: ", $j<name>;
  say "project: ", $j<project>;
  say "job host: ", $j<host>;
  say "job tags: ", $j<tags>;
```


## Existing IAAS tools integration

Sparrowdo integrates well with some well known infrastructure provision tools, for example with Terraform. Main workflow is one
first deploy cloud infrastructure using a dedicated tool, and then provision hosts using Sparrowdo.

### Terraform integration

As Terraform keeps hosts configuration in `state` JSON file, it's very easy to parse it and feed hosts into sparrowdo:

`hosts.raku:`

```raku
use JSON::Tiny;

my $data = from-json("/home/melezhik/projects/terraform/examples/aws/terraform.tfstate".IO.slurp);

my @aws-instances = $data<resources><>.grep({ .<type> eq "aws_instance" }).map({.<instances>.flat}).flat;

my @list;

for @aws-instances -> $i {
  push @list, %( 
    host => $i<attributes><public_dns>, 
    tags => 'aws' 
  );
} 

@list
```  
