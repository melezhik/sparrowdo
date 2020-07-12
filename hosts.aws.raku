use JSON::Tiny;
use Data::Dump;

my $data = from-json("/home/melezhik/projects/terraform/examples/aws/terraform.tfstate".IO.slurp);

my @aws-instances = $data<resources><>.grep({ 
  .<type> eq "aws_instance" 
}).map({
  %( 
    host => .<instances>[0]<attributes><public_dns>,
    tags => "{.<instances>[0]<attributes><tags><Name>},aws"
  )
});

say Dump(@aws-instances);

#exit(0);

@aws-instances;
