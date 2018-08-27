
use GitLab::API::v3;
use GitLab::API::v3::Constants;
use Data::Dumper;
use Data::Dumper;

my %opt = ("server_name" => "gitlab",
	  );
print Dumper(\%opt);

# temporary hack until I get config file processing sorted
my $servers_hr = { 'hsm-gitlabee'=> {'url'=> undef,
					  'token'=> undef,
					 },
		   'hsm-gitlabee-geo3' =>{'url'=> 'http://hsm-gitlabee-geo3.das.perforce.com/api/v3',
					  'token'=> '_Ma98cFLE5stiWGKJvke'
					 },

		   'gitlab' =>{'url'=> 'http://gitlab/api/v3',
			       'token' => "hqoxTXkAKXsxtNy88mBs",
				    },
		   };


# cleans up projects in the specified list; housekeeping

#my $token = "-q82HwS34xDzRydu2XAu";
my $token = "hqoxTXkAKXsxtNy88mBs";
#my $v3_api_url = "http://hsm-gitlabee.das.perforce.com/api/v3";
my $v3_api_url = "http://gitlab/api/v3";

#my $api = GitLab::API::v3->new(
#    url   => $v3_api_url,
#    token => $token,
#);


# use the values looked up from the provided server name

 my $api = GitLab::API::v3->new(
				url   => $servers_hr->{"gitlab"}{"url"},
				token => $servers_hr->{"gitlab"}{"token"},
			       );


my @users = qw(alice bob service_user);

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


# todo: clean this up; project? project_return? pick one.
my $project;
my $project_return;
foreach my $proj (sort(keys(%{$projects_hr}))) {
    print $proj,"\n";

    my $encoded_id =  "root/".$proj;

    $project = $api->delete_project($encoded_id	);
	
}


my $projects = $api->projects();
foreach my $thing (@{$projects}) {
    print $thing->{"id"}, "\t", $thing->{"name"}, "\n";
}

