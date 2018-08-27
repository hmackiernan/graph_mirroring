# Given the name of a group, get the group's GUID
# Uses the REST API

use strict;
use Net::OpenSSH;
use Data::Dumper;
use Getopt::Long;
use LWP::UserAgent ();
use JSON::Parse 'parse_json';

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
	   'admin_pass:s',
	   'groupname:s',
	  );

print Dumper(\%opt);

my $gerrit_ua = LWP::UserAgent->new();


my $ret = lookup_group($opt{'groupname'},$opt{'admin_user'},$opt{'admin_pass'},$gerrit_ua,\%opt);

my $group_guid = $ret->{'id'};
print "For group $opt{'groupname'} the guid is $group_guid \n";



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
