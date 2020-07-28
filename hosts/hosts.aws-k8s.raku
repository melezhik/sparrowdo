use JSON::Tiny;
use Data::Dump;

my $data = from-json("/home/melezhik/projects/terraform/examples/aws-k8s/terraform.tfstate".IO.slurp);

my $master-ip;

my @aws-instances = $data<resources><>.grep({ 
  .<type> eq "aws_instance" 
}).map({

  if .<instances>[0]<attributes><tags><Name> eq "master" {
    $master-ip = .<instances>[0]<attributes><public_ip>
  }

  %( 
    host => .<instances>[0]<attributes><public_dns>,
    tags => "{.<instances>[0]<attributes><tags><Name>},name={.<instances>[0]<attributes><tags><Name>},aws,ip={.<instances>[0]<attributes><public_ip>}"
  )
});

for @aws-instances -> $i {
  $i<tags> ~= ",master_ip={$master-ip}";
}

say Dump(@aws-instances);

@aws-instances;
