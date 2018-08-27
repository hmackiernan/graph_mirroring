use Getopt::Long;
use GitLab::API::v3;
use GitLab::API::v3::Constants qw(:all);
use Data::Dumper;

sub create_users() {
  my $api = shift;
  my $desired_users_hr = shift;
  my $opts = shift;

  my $ret; # return of search
 DESIRED: foreach my $desired_user (sort(keys(%{$desired_users_hr}))) {
    print "working on $desired_user\n";
    $ret = $api->users({"search" => $desired_user});
    
    # if(exists($existing_users_hr->{$desired_user})) {
    if (scalar(@{$ret}) == 1) {
      #    print "$desired_user exists with id $existing_users_hr->{$desired_user}{'id'}\n";
    print "$desired_user exists with id $ret->[0]{'id'}\n";
    #    existing_users_hr->{$desired_user}{'id'};
    $desired_users_hr->{$desired_user}{'id'} = $ret->[0]{'id'};
    next DESIRED;
  } else {
    print "$desired_user does not exist (or possiblymultiples returned)...creating...\n";
    my $params = {
		  "email" => "$desired_user\@" . $opts{'server_name'} . "fake.com",
		  "username" => $desired_user,
		  "name" => $desired_user,
		  "password" => "password",
		 };
    $api->create_user( $params);

    $ret = $api->users({"search" => $desired_user});
    print "user $desired_user created with id " . $ret->[0]{'id'};
    $desired_users_hr->{$desired_user}{'id'} = $ret->[0]{'id'};
  }
    
  }
  
  # return the updated desired user list
  return $desired_users_hr;
}


1;
__END__
