#!raku 

use Sparky::JobApi;

class Pipeline {

  has Str $.url = tags()<url> || "https://dev.azure.com/assmt2022";
  has Str $.token = tags()<token>;
  has Str $.agent = tags()<agent> || "";

  method !wait-jobs(@q){

    my @jobs;

    for @q -> $j {
      my $s = supply { 
        while True {
          my %out = $j.info; %out<status> = $j.status;  
          emit %out; 
          done if $j.status eq "FAIL" or $j.status eq "OK"; 
          sleep(5) 
        } 
      }
     $s.tap( -> $v { say $v; push @jobs, $v if $v<status> eq "FAIL" or $v<status> eq "OK" } );
   }

    say @jobs.grep({$_<status> eq "OK"}).elems, " jobs finished successfully";

    say @jobs.grep({$_<status> eq "FAIL"}).elems, " jobs failed";

    die if @jobs.grep({$_<status> eq "FAIL"}).elems;

  }

  method !queue($api,$agent) {

    my $q = Sparky::JobApi.new(:$api);

    $q.queue({
      description => "install ado agent, {$agent}",
      tags => %(
        stage => "install",
        token => $.token,
        url => $.url,
        agent => $agent,
      ),
      sparrowdo => %(
        sudo => True,
      );
    });

    say "queue spawned job, ",$q.info.perl;

    return $q;


  }

  method stage-main() {
  
    my @q;

    @q.push: self!queue("http://sparky01.centralus.cloudapp.azure.com:4000","agent01_01");

    @q.push: self!queue("http://sparky02.centralus.cloudapp.azure.com:4000","agent02_01");

    self!wait-jobs(@q);

  } 

  method stage-install() {

    say "url: ", $.url;

    say "agent: ", $.agent;

    #say "token: ", $.token;

    task-run "install", "ado-install-agent", %(
      distro => "https://vstsagentpackage.azureedge.net/agent/2.195.2/vsts-agent-linux-x64-2.195.2.tar.gz",
      url => "https://dev.azure.com/assmt2022",
      agent => $.agent,
      token => $.token,
    );

  }

}


Pipeline.new."stage-{tags()<stage>||'main'}"();

