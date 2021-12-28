if tags()<stage> eq "main" {

    use Sparky::JobApi;

    my $project = "spawned_01";

    my $r = job-queue %(
      project => $project,
      description => "spawned job", 
      tags => %(
        stage => "child",
        foo => 1,
        bar => 2,
      ),
    );

    say $r.perl;

    say "queue spawned job, job id = {$r<job-id>}";

} elsif tags()<stage> eq "child" {

  say "I am a child scenario";
  say "config: ", config().perl;
  say "tags: ", tags().perl;

}
