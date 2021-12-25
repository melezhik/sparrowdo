if tags()<stage> eq "main" {

    use Sparky::JobApi;

    my $job-id = job-queue %(
      description => "spawned job", 
      #workers => 90,
      tags => %(
        stage => "child",
        foo => 1,
        bar => 2,
      ),
    );

    say "queue spawned job, job id = {$job-id}";

} elsif tags()<stage> eq "child" {

  say "I am a child scenario";
  say "config: ", config().perl;
  say "tags: ", tags().perl;

}
