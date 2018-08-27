use GitLab::API::v3;
use Data::Dumper;

my $v3_api_url = "http://gitlabeegeo1/api/v3";
my $token = "xxQiwvse45NRJvcgfWmx";
my $api = GitLab::API::v3->new(
    url   => $v3_api_url,
    token => $token,
    );

my %users = {"alice" => ["Alice","alice@gitlabeegeo1"],
	     "bob" => ["Bob","bob@gitlabeegeo1"],
};

my $u;
foreach $u (keys(%{$users})) {
  my $ret =  $api->create_user(
      {
	  "name" => $users->{$u}[0],
	  "username" => $u,
	  "email" => $users->{$u}[1],
      }
	);
  print Dumper($ret);
}
