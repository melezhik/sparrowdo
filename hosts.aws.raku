use JSON::Tiny;
use Data::Dump;
use Sparrow6::DSL;

my $data = from-json("/home/melezhik/projects/terraform/examples/aws/terraform.tfstate".IO.slurp);
my $backend-ip;
my $database-ip;

my @aws-instances = $data<resources><>.grep({ 
  .<type> eq "aws_instance" 
}).map({

  if .<instances>[0]<attributes><tags><Name> eq "backend" {
    $backend-ip = .<instances>[0]<attributes><public_ip>
  }
  if .<instances>[0]<attributes><tags><Name> eq "database" {
    $database-ip = .<instances>[0]<attributes><public_ip>
  }


  %( 
    host => .<instances>[0]<attributes><public_dns>,
    tags => "{.<instances>[0]<attributes><tags><Name>},aws,ip={.<instances>[0]<attributes><public_ip>}"
  )
});

for @aws-instances -> $i {
  $i<tags> ~= ",backend_ip={$backend-ip}";
  $i<tags> ~= ",database_ip={$database-ip}"
}

say Dump(@aws-instances);

#exit(0);

@aws-instances;
