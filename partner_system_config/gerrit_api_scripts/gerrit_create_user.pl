# Create users in a gerrit instance using the ssh method against the gerrit server's ssh port

# Assumes that the ssh key of the user as-whom this script is run has been added to the gerrit instance's 'admin' user's
# keyring -- probably a pretty terrible assumption.

use strict;
use Net::OpenSSH;
use Data::Dumper;
use Getopt::Long;

my %opt = (
	   'debug' => 1,
	   'admin_user'=>'admin',
	   'admin_pass'=>'password',
	  );

GetOptions(
	   \%opt,
	   'host|server:s',
	   'port:s',
	   'admin_user:s',
	   'admin_pass:s',
	   'username:s',
	   'password:s',
	  );

print Dumper(\%opt);

# TODO - add ssh key(s) to user
# TODO - add additional email addresses to users (could derive from SSH key if we are careful about how we generate them)
#        Gerrit will reject a commit if the users email address doesn't match one of the 'contacts' defined in the Gerrit user record

# admin_pass is not used since this connexion is via SSH; assumes the keys are in place

# Get an ssh connexion to the Gerrit sshd
my $login = $opt{'admin_user'}."\@".$opt{'host'}.":".$opt{'port'};
print "Connecting with $login\n";
my $gerrit_ssh = Net::OpenSSH->new($login);


create_user($opt{'username'},$opt{'password'},$gerrit_ssh,\%opt);

sub create_user {
  my $user = shift;
  my $password = shift;
  my $ssh = shift;
  my $conf_hr = shift;

  # pull out a few values from conf_hr
  my $port = $conf_hr->{'port'};
  my $host = $conf_hr->{'host'};

  # compose some values together to be used in cmd string
  my $email = $user . "\@" . $host;
  my $full_name = $user;
  $full_name =~ s/\b(\w)/\U$1/g;
  
  my $cmd = "gerrit create-account --full-name " . $full_name . " --email " . $email . " --http-password " . $password. " " . $user;
  print "would run:\n $cmd\n";

    my ($out, $err) = $ssh->capture2($cmd);
  $ssh->error and    die "remote command failed: " . $ssh->error;
  return $out;
  
}
