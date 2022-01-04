use Sparky::JobApi;

my @workers = 'http://sparrowhub.io:4000', 'http://40.122.145.44:4000', 'http://40.83.40.131:4000';

  if tags()<stage> eq "main" {

    my @q;

    for @workers -> $w {

      my $j = Sparky::JobApi.new(api => $w, workers => 80);

      $j.queue({
        description => "test job",
        tags => %(
          stage => "child",
        ),
      });

      push @q, $j;

    }

    my @jobs;

    for @q -> $q {

      my $supply = supply {

        while True {

          my $status = $q.status;

          emit %( id => $q.info()<job-id>, status => $status );

          done if $status eq "FAIL" or $status eq "OK";

          sleep(1);

        }

      }

      $supply.tap( -> $v {
        push @jobs, $v if $v<status> eq "FAIL" or $v<status> eq "OK";
        say $v;
      });

    }

    say @jobs.grep({$_<status> eq "OK"}).elems, " jobs finished successfully";
    say @jobs.grep({$_<status> eq "FAIL"}).elems, " jobs failed";
    say @jobs.grep({$_<status> eq "TIMEOUT"}).elems, " jobs timeouted";

  } elsif tags()<stage> eq "child" {

    say "I am a child job!";

    say tags().perl;

  }


