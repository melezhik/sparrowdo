use JSON::Tiny;
use Data::Dump;

my $data = from-json("/home/melezhik/projects/terraform/examples/aws/terraform.tfstate".IO.slurp);

my @aws-instances = $data<resources>.grep({ .<type> eq "aws_instance" }).pick<instances><>;

my @list;

for @aws-instances -> $i {
  push @list, $i<attributes><public_dns>;
} 

@list;
