# Create a project with the given name and description
# Also explicitly sets the Change-Id to false for the newly created project

use strict;
use Net::OpenSSH;
use Data::Dumper;
use Getopt::Long;

my %opt = (
	   'debug' => 1,
	   'admin_user'=>'admin',
	  );

GetOptions(
	   \%opt,
	   'host|server:s',
	   'port:s',
	   'admin_user:s',
	   'project_name:s',
	   'project_desc|project_description:s'
	  );

print Dumper(\%opt);


# Get an ssh connexion to the Gerrit sshd
my $login = $opt{'admin_user'}."\@".$opt{'host'}.":".$opt{'port'};
print "Connecting with $login\n";
my $gerrit_ssh = Net::OpenSSH->new($login);

create_project($opt{'project_name'},$opt{'project_desc'},$gerrit_ssh,\%opt);

sub create_project {
  my $proj = shift;
  my $desc = shift;
  my $ssh = shift;
  my $conf_hr = shift;

  # pull out a few values from conf_hr


  # compose some values together to be used in cmd string

  
  my $create_cmd = " gerrit create-project --description \'$desc\'  $proj";
  print "would run:\n $create_cmd\n";
  my ($create_out, $create_err) = $ssh->capture2($create_cmd);
  $ssh->error and    die "remote command failed: " . $ssh->error;

  my $set_cmd = " gerrit set-project --change-id false  $proj";
  print "would run:\n $set_cmd\n";
  my ($set_out, $set_err) = $ssh->capture2($set_cmd);
  $ssh->error and    die "remote command failed: " . $ssh->error;

  
}
