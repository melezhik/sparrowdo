say "config: ", config().perl;
say "tags: ", tags().perl;

use Sparky::JobApi;

my @jobs;

for config()<jobs><> -> $i {

  my $supply = supply {

    my $project = $i<project>;
    my $job-id = $i<job-id>;

    my $j = Sparky::JobApi.new(:$project,:$job-id);

      while True {

        my $status = $j.status;

        emit %( id => "{$project}/{$job-id}", status => $status );

        done if $status eq "FAIL" or $status eq "OK";

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

