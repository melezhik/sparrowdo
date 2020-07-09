use JSON::Tiny;
use Data::Dump;

my $data = from-json("/home/melezhik/projects/terraform/examples/aws/terraform.tfstate".IO.slurp);

my @aws-instances = $data<resources><>.grep({ .<type> eq "aws_instance" }).map({.<instances>.flat}).flat;

#say Dump(@aws-instances);
#exit(0);

my @list;

for @aws-instances -> $i {
  push @list, %( host => $i<attributes><public_dns>, tags => 'aws' );
  #say Dump($i);
} 


say @list.perl;

@list;
