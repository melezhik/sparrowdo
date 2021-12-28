
use Sparky::JobApi;

if tags()<stage> eq "main" {

    my $rand = ('a' .. 'z').pick(20).join('');

    job-queue %(
      project => "worker_1",
      job-id => "{$rand}_1",
      description => "spawned job",
      tags => %(
        seed => $rand,
        stage => "child",
        i => 1,
      ),
     );

    use HTTP::Tinyish;

    my $http = HTTP::Tinyish.new;

    my @jobs;

    # wait all 10 recursively launched jobs
    # that are not yet launched by that point
    # but will be launched recursively
    # in "child" jobs 


    for 1 .. 10 -> $i {

      my $supply = supply {

        #my $j = 1;

        while True {
          my %r = $http.get("http://127.0.0.1:4000/status/worker_{$i}/{$rand}_{$i}");
          %r<status> == 200 or next;
          if %r<content>.Int == 1 {
            emit %( id => "worker_{$i}/{$rand}_{$i}", status => "OK");
            done;
          } elsif %r<content>.Int == -1 {
            emit %( id => "worker_{$i}/{$rand}_{$i}", status => "FAIL");
            done;
          } elsif %r<content>.Int == 0 {
            emit %( id => "worker_{$i}/{$rand}_{$i}", status => "RUNNING");
          }
          #$j++;
          #if $j>=300 { # timeout after 300 requests
          #  emit %( id => "worker_{$i}/{$rand}_{$i}", status => "TIMEOUT");
          #  done
          #}
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

  } elsif tags()<stage> eq "child" {

    say "I am a child job!";

    say tags().perl;

    if tags()<i> < 10 {

      my $i = tags()<i>.Int + 1;

      # do some useful stuff here
      # and launch another recursive job
      # with predefined project and job ID
      # i tagged variable gets incremented
      # recursively launched jobs
      # get waited in a "main" scenario 

      job-queue %(
        project => "worker_{$i}",
        job-id => "{tags()<seed>}_{$i}",
        description => "spawned job",
        tags => %(
          seed => tags()<seed>,
          stage => "child",
          i => $i,
        ),
     );
   }
}

