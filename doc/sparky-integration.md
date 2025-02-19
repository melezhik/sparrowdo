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

* Go to http://127.0.0.1:4000

* Check queue and recent builds tabs

Queue tab contains a list of builds to be executed.

Recent build tab contains a list of currently executed builds.

## With_sparky parameter

It's handy to use `--with_sparky` parameter instead of providing `host` file, if one
only wants to run for a single host. 

Examples.

Runs on localhost under Sparky server:

```bash
sparrowdo --with_sparky --localhost
```

Runs on remote host under Sparky server:

```bash
sparrowdo --host=192.168.0.1 --with_sparky 
```

# Advanced topics

## Tags

Tags are symbolic labels attached to hosts, tags allow to: 

* group hosts or separate them from earch other (ala ansible groups)

* pass key/value pairs to hosts configurations

To assign tag one need to declare hosts in `host` file using Raku Hash notation:

```raku
[
   %( host => "192.168.0.1", tags => "frontend" ),
   %( host => "192.168.0.2", tags => "loadbalancer" ),
   %( host => "192.168.0.3", tags => "backend" ),
   %( host => "192.168.0.4", tags => "backend" ),
   %( host => "192.168.0.5", tags => "database" ),
   %( host => "192.168.0.6", tags => "database" ),
   %( host => "192.168.0.7", tags => "database" ),
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

To run Sparrowdo deployment on all database hosts, use `--tags` cli parameter:

```bash
sparrowdo --sparrowfile=database.raku --tags=database --host=hosts.raku
```

One can attach more then one tag using `,` separator:

```raku
[
  %(
    host => "192.168.0.1", 
    tags => "database,master", 
  ),
  %(
    host => "192.168.0.2", 
    tags => "database,replica", 
  ),
  %(
    host => "192.168.0.3", 
    tags => "database,replica", 
  ),
];
```

Or using Raku List syntax:

```raku
[
  %(
    host => "192.168.0.1", 
    tags => [ "database", "master" ],
  ),
  %(
    host => "192.168.0.2", 
    tags =>[ "database", "replica" ],
  ),
  %(
    host => "192.168.0.3", 
    tags =>[ "database", "replica" ],
  ),
];
```

To filter out specific hosts for deployment provide `--tags` cli option:

```bash
sparrowdo --sparrowfile=database.raku --tags=database,replica --host=hosts.raku
```

This command will queues builds only for hosts having  both `database` and `replica` tags set.

## key/value pairs

To assign key/value parameters to hosts use `tags` with `key=value` syntax:

```raku
[
  %(
      host => "192.168.0.1",
      tags => "server=nginx,port=443",
  ),
];
```

Alternatively one can use Raku hashes to assign values to tags:

```raku
[
  %( 
    host => "192.168.0.1",
    tags => %(
      server => "nginx",
      port => "443", 
    ), 
  ),
  %( 
    :host<192.168.0.2>,
    tags => %(
      :server<nginx>,
      :443port, 
    ), 
  ),
];
```

Or as Raku Arrays:

```raku
[
  %( 
    host => "localhost",
    tags => [ "frontend", "dev" ],
  ),
];
```

Bool values for tags allow one easily implement hosts grouing in Ansible inventory style:

```raku
[
  %( 
    :host<db.host1.co>,
    tags => %(
      :5432port,
      :db_user<admin>,
      :database,
      :master,
    ), 
  ),
  %( 
    :host<db.host2.co>,
    tags => %(
      :5432port,
      :db_user<admin>,
      :database,
      :replica,
    ), 
  ),
  %( 
    :host<db.host3.co>,
    tags => %(
      :5432port,
      :db_user<admin>,
      :database,
      :replica,
    ), 
  ),
];

```

To select only database nodes with replica use following form:

```bash
--tags=database,replica
```

To handle `key/value` pairs inside Sparrowdo scenarios use standard Raku Hash mechanism:

```raku
my $port = tags()<port>; # 5432
my $db_user = tags()<db_user>; # admin
```

You can pass `key/value` tags as cli parameters as well, effectively overriding tags
if exist or setting new ones:

```
# override port and db_user for database replicas:
sparrowdo --sparrowfile=database.raku --tags=port=5400,db_user=operator,database,replica --host=hosts.raku
```

Spaces are valid in tags values:

```bash
--tags="author=funky coder,message=hello world,version=0.0.1"
```

```raku
  tags => %(
    band => "Perl Jam",
    singer => "Eddie Vedder",
    album => "Ten"
  )
```

## Special tags

## names

To give builds descriptive names use `name` key.

A build name will appear in Sparky reports list:

```raku
[
  %( 
    host => "localhost",
    tags => %(
      server => "nginx",
      port => "443",
      name => "deploy web server",
    ),
  ),
];
```

## Bind build to project

To run a build for specific Sparky project use `project` key:

```raku
[
  %(
    host => "localhost",
    project => "web-app-build", 
  ),
];
```

## Reserved tags

When sparrowdo scenarios using Sparky, there are some reserved tags:

* `SPARKY_JOB_ID`

Sparky Job ID

* `SPARKY_PROJECT`

Sparky project name


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
use Sparky::JobApi;

class Pipeline
  does Sparky::JobApi::Role
  {
    method stage-main { 
      my @jobs;
      for config()<jobs><> -> $i {
          my $project = $i<project>;
          my $job-id = $i<job-id>;
          push @jobs, Sparky::JobApi.new: :$project,:$job-id;
      }
    }
    my $st = self.wait-jobs: @jobs;
    if $st<OK> == @jobs.elems {
      say "all jobs succeeded";
    } else {
      die "some jobs failed or timeouted: {$st.perl}";
    }
  }
Pipeline.new.run;
```

This simple scenario illustrates how one can iterate though jobs (`config()<jobs>`)
and get their statuses when they are finished using [Sparky HTTP API](https://github.com/melezhik/sparky#build-status-1).

To get job details use `status()` and `info()` methods:

```raku
  for @jobs -> $j {
    say "job id: ", $j.job-id;
    say "project: ", $j.project;
    say "job status: ", $j.status();  
    say "status-url: ", $j.info()<status-url>;
  }
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
