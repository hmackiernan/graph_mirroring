# Given the name of a group
# and the name of a project
# Uses the REST API
# to look up that group's GUID
# and apply the listed permissions to that group on that project

use strict;
use Net::OpenSSH;
use Data::Dumper;
use Getopt::Long;
use LWP::UserAgent ();
use JSON::Parse 'parse_json';
use JSON;

my %opt = ();

#TODO
# Since it's possible to specify adds and removes in one JSON payload, it would be nice if we could
# specify in the permissions input data "add these perms to this ref for this group, and delete these perms
# for this ref for this group.  This would mean rotating the data before using it since the order of the keys
# as given is different to the order needed by the HTTP endpoint

my $perms_hr = { 'refs/heads/*' => [ 'label-Code-Review', 'createTag', 'submit', 'create', 'delete'],
		 'refs/tags/*' =>  ['createTag', 'create', 'delete'],
	       };

# get the guid from the txt name
my @groups = qw(460c1a8aba9a25cc074183bde6d926e335c784f5 f34776dc1498c05c97dfafe5cda238dd854ffda9);
 @groups=qw(f34776dc1498c05c97dfafe5cda238dd854ffda9);

#my $to_json_hr = {'add' =>  {'refs/heads/*' => {'permissions' => {'submit'=>   {'rules' => {         '460c1a8aba9a25cc074183bde6d926e335c784f5' => {'action' => 'ALLOW','force' => ''}}}}}},		 };

my $json_txt = construct_json_grant_access($perms_hr,\@groups,\%opt);


print $json_txt;

sub construct_json_grant_access {
  my $perms_hr = shift;
  my $groups = shift;
  my $conf_hr = shift;

  my $to_json_hr;
  foreach my $ref (sort(keys(%{$perms_hr}))) {
    foreach my $permission (sort(@{$perms_hr->{$ref}})) {
      foreach my $group (@{$groups}) {
	$to_json_hr->{"add"}{$ref}{"permissions"}{$permission}{"rules"}{$group} = {"action" => "ALLOW", "force"=>"false"};
      }
    }
  }

  my $json_txt = to_json($to_json_hr);

  return $json_txt;
}


__END__
my $json_txt = <<JSON;
{
 "add": {
 		"refs/heads/*": {
 				"permissions": {
 						"submit": {
 							"rules": {
 								"460c1a8aba9a25cc074183bde6d926e335c784f5": {
 								           "action": "ALLOW",
                                                                           "force": false
 								}
 							}
 						}
 				}
 		}
 }
}

JSON

my $parsed = parse_json($json_txt);
print Dumper($parsed);

## add multiples
{
 "add": 
 	      {"refs/heads/*": {
 				"permissions": {
 						"submit": {
 							"rules": {"460c1a8aba9a25cc074183bde6d926e335c784f5": {"action": "ALLOW",
                            				"force": false
 								}
 							}
 						},
 					   "push": {
 					   	 	"rules": {"460c1a8aba9a25cc074183bde6d926e335c784f5": {"action": "ALLOW",
                            				"force": false
 								}
 							}
 					   }
 					   }
 				}
 	      }
 	      }
 
}
 									
 							
