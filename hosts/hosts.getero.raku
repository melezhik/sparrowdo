use JSON::Tiny;

my $data = from-json("/home/melezhik/projects/terraform/examples/aws/terraform.tfstate".IO.slurp);

my @aws-instances = $data<resources><>.grep({ .<type> eq "aws_instance" }).map({.<instances>.flat}).flat;

my @list;

push @list, %(
  host => "docker:alpine",
  tags => "docker"
);

for @aws-instances -> $i {
  push @list, %(
    host => $i<attributes><public_dns>, 
    tags => 'aws' 
  );
} 

@list;
