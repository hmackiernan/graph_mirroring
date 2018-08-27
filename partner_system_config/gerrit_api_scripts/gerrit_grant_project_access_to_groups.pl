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

my %opt = (
	   'debug' => 1,
	   'admin_user'=>"admin",
	   'admin_pass'=>"password",

	  );

GetOptions(
	   \%opt,
	   'host|server:s',
	   'port:s',
	   'admin_user:s',
	   'group_list:s',
	  );

print Dumper(\%opt);

my $gerrit_ua = LWP::UserAgent->new();

# A way to specify permissions to set for each ref; these
# are the typical defaults
my $perms_hr = { 'refs/heads/*' => [ 'label-Code-Review', 'createTag', 'submit', 'create', 'delete'],
		 'refs/tags/*' =>  ['createTag', 'create', 'delete'],
	       };

#my @groups = qw(460c1a8aba9a25cc074183bde6d926e335c784f5 f34776dc1498c05c97dfafe5cda238dd854ffda9);
# @groups=qw(f34776dc1498c05c97dfafe5cda238dd854ffda9);

my @groups=split/,/,$opt{'group_list'};

my @groups_guid;



foreach my $group (@groups) {
  print "Type of \$gerrit_ua is " . ref($gerrit_ua) . "\n";
  my $ret = lookup_group($group,$opt{'admin_user'},$opt{'admin_pass'},$gerrit_ua,\%opt);
  my $group_guid = $ret->{'id'};
  print "For group $opt{'groupname'} the guid is $group_guid \n";
  push @groups_guid, $group_guid;
}

my $json_txt = construct_json_grant_access($perms_hr,\@groups_guid,\%opt);

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



sub lookup_group {
  # Given a plain string name of the group, hit the REST endpoint and query that group
  # parse the HTTP::Message (after cleanup) to turn the JSON into a Perl object
  # returns the ref to that object to caller

  my $groupname = shift;
  my $user = shift;
  my $password = shift;
  my $ua = shift;
  my $conf_hr = shift;

  print "The type of ua: " . ref($ua),"\n";
  
  # get host, port from conf hash
  my $host = $conf_hr->{"host"};
  my $port = $conf_hr->{"port"};

  my $base_url = "http://" . $host . ":" . $port;

  # The credentials method demands a 'webloc' (the base url minus the http scheme)
  # and the realm  'Gerrit Code Review'
  $ua->credentials($host.":".$port,"Gerrit Code Review",$user, $password, );

  # particular query for this operation
  my $query = "a/groups";

  # assemble the query
  my @query_bits;
  push @query_bits, $base_url;
  push @query_bits, $query;
  push @query_bits, $groupname;
  my $query_url = join("/",@query_bits);

  print "Would hit $query_url\n";
  
  my $ret = $ua->get($query_url);

  # For some reason, the response HTTP message has extra cruft before the JSON payload, clean that up
  my $content = $ret->content;
  $content =~ s/\)\]\}\'//;
#  print $content,"\n";
  
  my $content_json = parse_json($content);

  return $content_json;
  
  
}
