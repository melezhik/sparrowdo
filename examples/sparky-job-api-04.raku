  if tags()<stage> eq "main" {

    # spawns a child job

    use Sparky::JobApi;

    my %r = job-queue %(
      project => "spawned_jobs",
      description => "my spawned job",
      tags => %(
        stage => "child",
        foo => 1,
        bar => 2,
      ),
    );

    my $job-id = %r<job-id>;

    say "queue spawned job, job id = {$job-id}";

    use HTTP::Tinyish;

    my $http = HTTP::Tinyish.new;

    my $supply = supply {

      my $i = 1;

      while True {
          my %r = $http.get("http://127.0.0.1:4000/status/spawned_jobs/{$job-id}");
          %r<status> == 200 or next;
          if %r<content>.Int == 1 {
            emit %( id => $job-id, status => "OK");
            done;
          } elsif %r<content>.Int == -1 {
            emit %( id => $job-id, status => "FAIL");
            done;
          } elsif %r<content>.Int == 0 {
            emit %( id => $job-id, status => "RUNNING");
          }
          $i++;
          if $i>=3000 { # timeout after 3000 requests
            emit %( id => $job-id, status => "TIMEOUT");
            done
          }
      }
    }

    $supply.tap( -> $v {
      if $v<status> eq "FAIL" or $v<status> eq "OK"  or $v<status> eq "TIMEOUT" {
        say $v;
      }
    });
  } elsif tags()<stage> eq "child" {

    # child job here

    say "config: ", config().perl;
    say "tags: ", tags().perl;

  }
