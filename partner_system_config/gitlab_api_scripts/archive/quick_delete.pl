
use GitLab::API::v3;
use GitLab::API::v3::Constants;
use Data::Dumper;
use Getopt::Long;
use IPC::Run3;
use LWP::UserAgent ();
use JSON::Parse 'parse_json';

my %opts;

GetOptions(\%opts,"proj_ids:s");




my $url="http://gitlabee9/api/v3";
my $admin_user = "root";
my $admin_pass="Testing123";

my $token = get_token($url,$admin_user,$admin_pass);

my $curl = "curl -X GET   'http://gitlabee9/api/v3/projects?private_token=$token'   -H 'cache-control: no-cache'";

print "The curl is \n";
print $curl;
my ($stdin,$stderr,$stdout);
run3 $curl, undef, \$stdout,\$stderr;

my $json = parse_json($stdout);

#print Dumper($json);

my @proj_ids;
foreach my $item (@{$json}) {
  print $item->{"id"}, "\n";
  push @proj_ids, $item->{"id"};
}


my $api = GitLab::API::v3->new(
    url   => $url,
    token => $token,
);

foreach my $id (@proj_ids) {
print "deleteing $id";
    $project = $api->delete_project( $id);
    print Dumper($project);

}

sub get_token {
  my $url = shift;
  my $user = shift;
  my $pass = shift;

  $url .= "/session";
  
  my $token;

  my $ua = LWP::UserAgent->new;
  
  my $form = { "login" => $user,
	       "password" => $pass,
	     };
  
  my $response = $ua->post($url, $form);
  my $resp_obj;
  if ($response->is_success) {
    
    $resp_obj = parse_json ($response->decoded_content);

    $token =  $resp_obj->{"private_token"};
  }
  else {
    die $response->status_line;
  }

  return $token;
}



__END__
