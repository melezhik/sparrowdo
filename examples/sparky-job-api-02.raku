  if tags()<stage> eq "main" {

    use Sparky::JobApi;

    my $project = "spawned_01";

    my $job-id = job-queue %(
      project => $project,
      description => "spawned job", 
      tags => %(
        stage => "child",
        foo => 1,
        bar => 2,
      ),
    );

    say "queue spawned job, job id = {$job-id}";

  } elsif tags()<stage> eq "child" {

    use Sparky::JobApi;

    say "I am a child scenario";

    my $project = "spawned_02";

    my $job-id = job-queue %(
      project => $project,
      description => "spawned job2",
      tags => %(
        stage => "off",
        foo => 1,
        bar => 2,
      ),
    );

    say "queue spawned job, job id = {$job-id}";

  } elsif tags()<stage> eq "off" {

    say "I am off now, good buy!";
    say "config: ", config().perl;
    say "tags: ", tags().perl;

  }

