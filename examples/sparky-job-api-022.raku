  if tags()<stage> eq "main" {

    use Sparky::JobApi;

    my $project = "spawned_01";

    my %r = job-queue %(
      project => $project,
      description => "spawned job", 
      tags => %(
        stage => "child",
        foo => 1,
        bar => 2,
      ),
      sparrowdo => %(
        no_index_update => True
      )
    );

    say "queue spawned job, job id = {%r<job-id>}";

  } elsif tags()<stage> eq "child" {

    use Sparky::JobApi;

    say "I am a child scenario";

    my $project = "spawned_02";

    my %r = job-queue %(
      project => $project,
      description => "spawned job2",
      tags => %(
        stage => "off",
        foo => 1,
        bar => 2,
      ),
      sparrowdo => %(
        host => "sparrowhub.io",
        ssh_user => "root",
      )
    );

    say "queue spawned job, job id = {%r<job-id>}";

  } elsif tags()<stage> eq "off" {

    say "I am off now, good buy!";
    say "config: ", config().perl;
    say "tags: ", tags().perl;

  }

