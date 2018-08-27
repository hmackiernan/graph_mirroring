use Getopt::Long;
use GitLab::API::v3;
use GitLab::API::v3::Constants qw(:all);
use Data::Dumper;
use LWP::UserAgent ();
use JSON::Parse 'parse_json';

my %opt = ("server_name" => "gitlabce",
	  );

GetOptions(\%opt,
	   "server_name:s",
	   "project_suffix:s",
	  );

print Dumper(\%opt);


# temporary hack until I get config file processing sorted
my $servers_hr = {
		  'hsm-gitlabee'=> {'url'=> undef,
					  'token'=> undef,
				   },

		  'gitlabee9'=> {'url'=> "http://gitlabee9/api/v3",

				 'token' => "X5uL9exdFWD5oGSU6USR",
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



print "Getting token. . .\n";
my $server_name=$opt{'server_name'};
my $url = $servers_hr->{ $server_name }{"url"};
my $user = $servers_hr->{$server_name}{"admin_user"};
my $pass = $servers_hr->{$server_name}{"admin_pass"};
print "url is $url user is $user and pass is $pass\n";
print "The URL is $url\n";
my $token = &get_token($url,$user,$pass);
print "Got token $token for server $opt{'server_name'}", "\n";
$servers_hr->{$server_name}{"token"} = $token;



# users and their default access levels; assumed to exist 

my $desired_users_hr = { "alice" => {"level" => $GITLAB_ACCESS_LEVEL_MASTER,
			     "id"=> undef},

	      "bob"=>  => {"level" => $GITLAB_ACCESS_LEVEL_MASTER,
			   "id" => undef},
		 
	      "service_user" => {"level" => $GITLAB_ACCESS_LEVEL_DEVELOPER,
				 "id" => undef},
};
		 



# NS prefix for projects to avoid having to lookup and use the ID
my $ns = "root/";

my $projects_hr = {
    "pub-http" => {"visibility" => $GITLAB_VISIBILITY_LEVEL_PUBLIC,
		   },

    "priv-http" => {"visibility" => $GITLAB_VISIBILITY_LEVEL_PRIVATE,
		   },

    "pub-ssh" => {"visibility" => $GITLAB_VISIBILITY_LEVEL_PUBLIC,
		   },

    "priv-ssh" => {"visibility" => $GITLAB_VISIBILITY_LEVEL_PRIVATE,
		   },
    
};



# use the values looked up from the provided server name

 my $api = GitLab::API::v3->new(
				url   => $servers_hr->{$opt{'server_name'}}{"url"},
				token => $servers_hr->{$opt{'server_name'}}{"token"},
			       );


print "===\n";
print "Creating users";
print "===\n";
$desired_users_hr= &create_users($api,$desired_users_hr,$opts);
print Dumper($desired_users_hr);


print "===\n";
print "Creating projects";
print "===\n";

# convenience variable
my $project;

foreach my $proj (sort(keys(%{$projects_hr}))) {
    print $proj,"\n";
    my $params = 	{"name" => $proj . $opt{"project_suffix"},
			 "visibility_level" => $projects_hr->{$proj}{"visibility"},
    };
    print Dumper($params);
    print "Creating_project...\n";
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
    foreach my $u (sort(keys(%{$desired_users_hr}))) {
# Debug
#	print "would add to project " . $proj->{"id"} . "user " .$u .  "at access level " . $users_hr->{$u}{"level"} . " under id " . $users_hr->{$u}{"id"} . "\n";
	$api->add_project_member(
	    $proj->{"id"},
	    {"user_id" => $desired_users_hr->{$u}{"id"},
	     "access_level" => $desired_users_hr->{$u}{"level"},
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
    print Dumper($ret);
    if (scalar(@{$ret}) == 1) {
      print "$desired_user exists with id $ret->[0]{'id'}\n";

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
    print "Creating...\n";
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



1;
__END__
