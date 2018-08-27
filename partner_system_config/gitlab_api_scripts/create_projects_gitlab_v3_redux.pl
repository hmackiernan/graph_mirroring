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
	   "project_suffix:s");

print Dumper(\%opt);


# temporary hack until I get config file processing sorted
my $servers_hr = {
		  'hsm-gitlabee'=> {'url'=> undef,
					  'token'=> undef,
				   },

		  'gitlabee9'=> {'url'=> "http://gitlabee9/api/v3",
				 'token'=> "cWFjr-wm2N93--YX6VSo",
				 'admin_user' => 'root',
				 'admin_pass' => 'Testing123',

					 },


		  'gitlabee'=> {'url'=> "http://gitlabee/api/v3",
				 'token'=> "cWFjr-wm2N93--YX6VSo",
				 'admin_user' => 'root',
				 'admin_pass' => 'password',

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
    print "Created project: " . $project->{"path_with_namespace"};
    $projects_hr->{$proj}{"path_with_namespace"} = $project->{"path_with_namespace"};

	
	
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
