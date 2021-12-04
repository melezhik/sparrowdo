# Sparky Integration

This section describes how to run Sparrowdo scenarios in asynchronous mode, using [Sparky](https://github.com/melezhik/sparky) backend. 

## Install Sparky

```
git clone https://github.com/melezhik/sparky.git
cd sparky
zef install .

# Initialize Sparky DB
raku db-init.raku

# Run Sparky daemon
nohup sparkyd &

# Run Sparky Web UI
nohup raku bin/sparky-web.raku &
```

## Install Sparrowdo

```bash
# # we will need Bleeding edge versions of Sparrow6 and Sparrowdo
zef install https://github.com/melezhik/sparrow6.git 
zef install https://github.com/melezhik/sparrowdo.git
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

Names.

To give hosts descriptive names, that will be visible in Sparky reports one can use `name` key:

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

## Watcher jobs

Watcher jobs mechanism allows one to wait until all asynchronous job finishes
and does some action upon this even. This is very powerful and flexible feature
enabling really complex scenarios:

To active watcher mode one needs to do 2 steps:


1. Use `--watch` flag when run `sparrowdo`:

```bash
sparrowdo --hosts=hosts.raku --watch
```

2. create `watch.raku` file:

```raku

use Curlie;
my \c = Curlie.new;

my @jobs;

# iterate through jobs
# and get their statuses
# till all jobs are finished

while @jobs.elems < config()<jobs>.elems {

  for config()<jobs><> -> $j {
    c.get: "http://127.0.0.1/status/$project/{$j<job_id>}";
    if c.res.content == 1 {
      push @jobs, %( id => $j<job_id>, status => "OK")        
    }  elsif c.res.content == -1 {
      push @jobs, %( id => $j<job_id>, status => "FAIL")        
    }
  }
}

  say @jobs.grep({$_<status> eq "OK"}).elems, " jobs finished successfully";
  say @jobs.grep({$_<status> eq "FAIL"}).elems, " jobs failed";

```

This simple scenario ilustrates how one can iterate though jobs (`config()<jobs>`)
and get their statuses when they are finishedusing Sparky [HTTP API](https://github.com/melezhik/sparky#build-status-1).

To get job details use `%job` hash keys:

```raku
  say "job name: ", $j<name>;
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
