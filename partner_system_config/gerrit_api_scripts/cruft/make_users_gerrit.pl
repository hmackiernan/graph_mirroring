use Getopt::Long;
use Data::Dumper;
use LWP::UserAgent ();
use JSON::Parse 'parse_json';

my %opt = ("server_name" => "gitlabce",
	  );

GetOptions(\%opt,"server_name:s");

print Dumper(\%opt);


# temporary hack until I get config file processing sorted
my $servers_hr = {
		  'hsm-gitlabee'=> {'url'=> undef,
					  'token'=> undef,
				   },

		  'gitlabee9'=> {'url'=> "http://gitlabee9/api/v3",
				 'token'=> "cWFjr-wm2N93--YX6VSo",

					 },
		   'hsm-gitlabee-geo3' =>{'url'=> 'http://hsm-gitlabee-geo3.das.perforce.com/api/v3',
					  'token'=> '_Ma98cFLE5stiWGKJvke'
					 },

		  'gitlabce' =>{'url'=> 'http://gitlabce/api/v3',
				'admin_user' => 'root',
				'admin_pass' => 'password',
				'token' => "uWjyanFsJsAKsKR1PSC7",
				    },
		   };


my $server_name=$opt{'server_name'};

my $url = $servers_hr->{$server_name}{"url"};
my $user = $servers_hr->{$server_name}{"admin_user"};
my $pass = $servers_hr->{$server_name}{"admin_pass"};
print "url is $url user is $user and pass is $pass\n";

print "Getting token. . .\n";
my $token = &get_token($url,$user,$pass);
print "Got token $token for server $opt{'server_name'}", "\n";
$servers_hr->{$server_name}{"token"} = $token;


# get the API connection (use the values looked up from the provided server name)

 my $api = GitLab::API::v3->new(
				url   => $servers_hr->{$opt{'server_name'}}{"url"},
				token => $servers_hr->{$opt{'server_name'}}{"token"},
			       );


# users and their default access levels; assumed to exist 
# TODO: write code to check, and create them in gitlab if they do not
# and add keys etc.
my $desired_users_hr = { "alice" => {"level" => $GITLAB_ACCESS_LEVEL_MASTER,
				     "password" =>"password",
				     "id"=> undef},
			 
			 "bob"=>  => {"level" => $GITLAB_ACCESS_LEVEL_MASTER,
				      "password" =>"password",
				      "id" => undef},

			 "carol"=>  => {"level" => $GITLAB_ACCESS_LEVEL_MASTER,
				      "password" =>"password",
				      "id" => undef},
			 
			 "service_user" => {"level" => $GITLAB_ACCESS_LEVEL_DEVELOPER,
					    "password" =>"password",
					    "id" => undef},
			 
};
		 

#$desired_users_hr= &create_users($api,$desired_users_hr,$opts);
#print Dumper($desired_users_hr);
my $email;
foreach my $user (sort(keys(%{$desired_users_hr}))) {
  print "Creating $user...\n";
  $email = $user . "\@" . $server_name;
  my $ret = create_user($api,$user,$desired_users_hr->{$user}{"password"},$email);
  print Dumper($ret);
}



print "end.\n";
sub create_user() {
  my $api = shift;
  my $user = shift;
  my $password = shift;
  my $email = shift;
  my $msg = undef;
  my $id = undef;

  if ($debug) {
    print " Check arguments";
    print "user is $user\n";
    print "password is $password\n";
    print "email is $email\n";
  }
  
  # check existence
  print "working on $user\n";
  $ret = $api->users({"search" => $user});
  if (scalar(@{$ret}) == 1) {
    # if exists, return with ID of already existing user
    $id = $ret->[0]{'id'};
    $msg =  "$user exists with id $id";
    print $msg if ($debug);
  } else {
    $msg = "$user does not exist, creating";
    print $msg if ($debug);
    my $params = {
		  "email" =>  $email,
		  "username" => $user,
		  "name" => $user,
		  "password" => $password,
		 };
    $api->create_user( $params);
    $ret = $api->users({"search" => $user});
    $id = $ret->[0]{'id'};
    $msg .= "user $user created with id $id";
  }

  return {"id" => $id,"msg"=>$msg};


  # if not exist, create user and return with ID of newly created user

  
}




sub create_users() {
  my $api = shift;
  my $desired_users_hr = shift;

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





# NS prefix for projects to avoid having to lookup and use the ID
my $ns = "root/";

my $projects_hr = {
    "pub-http-geo3" => {"visibility" => $GITLAB_VISIBILITY_LEVEL_PUBLIC,
		   },

    "priv-http-geo3" => {"visibility" => $GITLAB_VISIBILITY_LEVEL_PRIVATE,
		   },

    "pub-ssh-geo3" => {"visibility" => $GITLAB_VISIBILITY_LEVEL_PUBLIC,
		   },

    "priv-ssh-geo3" => {"visibility" => $GITLAB_VISIBILITY_LEVEL_PRIVATE,
		   },
    
};

# my $api = GitLab::API::v3->new(
#     url   => $v3_api_url,
#     token => $token,
# );


# use the values looked up from the provided server name

 my $api = GitLab::API::v3->new(
				url   => $servers_hr->{"gitlab"}{"url"},
				token => $servers_hr->{"gitlab"}{"token"},
			       );


# Stupid bookkeeping. . .
# get all the users
my @users = $api->users();

# compare to the hash of users we care about, if found in that hash, backfill
# the userid for later use where (unfathomably) the username cannot be used.
foreach my $u (@{$users[0]}) {

    my $name = $u->{"name"},"\n";
    my $username = $u->{"username"},"\n";
    my $id = $u->{"id"},"\n";
    print $name,"\t",$id,"\t";
    print $username,"\n";
    if ( exists ($users_hr->{$username})) {
	print "$username is a known user\n";
	$users_hr->{$username}{"id"} = $id;
    } else {
	print "$username is not a known user\n";
    }
}

# debug
print Dumper($users_hr);

# convenience variable
my $project;

foreach my $proj (sort(keys(%{$projects_hr}))) {
    print $proj,"\n";
    my $params = 	{"name" => $proj,
			 "visibility_level" => $projects_hr->{$proj}{"visibility"},
    };
    print Dumper($params);
    $project = $api->create_project(
	$params,
	);
    print $project->{"id"};
    print $project->{"visibility"};
#    print Dumper($project);

	
	
}

# check what projects were created
my $projects = $api->projects();
foreach my $thing (@{$projects}) {
    print $thing->{"id"}, "\t", $thing->{"name"}, "\t", $thing->{"visibility_level"}, "\n";
}

# Add users to projects
# for each project in The List Of Projects We Care About, add each user in The List Of Users We Care About
#  at the specified access level from the hash.

foreach my $proj (@{$projects}) {
    foreach my $u (sort(keys(%{$users_hr}))) {
# Debug
#	print "would add to project " . $proj->{"id"} . "user " .$u .  "at access level " . $users_hr->{$u}{"level"} . " under id " . $users_hr->{$u}{"id"} . "\n";
	$api->add_project_member(
	    $proj->{"id"},
	    {"user_id" => $users_hr->{$u}{"id"},
	     "access_level" => $users_hr->{$u}{"level"},
	    }
	    );
    }
}

## methods

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



__END__


curl -X POST   http://gitlabce/api/v3/session/   -H 'cache-control: no-cache'   -H 'content-type: application/x-www-form-urlencoded'   -H 'postman-token: f702296d-6e45-fed8-3424-ecfb06fadc80'   -d 'login=root&password=password'



1;
__END__
