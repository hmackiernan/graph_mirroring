# add specified user to specified group

# Assumes that the ssh key of the user as-whom this script is run has been added to the gerrit instance's 'admin' user's
# keyring -- probably a pretty terrible assumption.


use strict;
use Net::OpenSSH;
use Data::Dumper;
use Getopt::Long;

my %opt = (
	   'debug' => 1,
	   'admin_user'=>"admin",
	  );

GetOptions(
	   \%opt,
	   'host|server:s',
	   'port:s',
	   'admin_user:s',
	   'users:s',
	   'groupname:s'
	  );

print Dumper(\%opt);

# Get an ssh connexion to the Gerrit sshd
my $login = $opt{'admin_user'}."\@".$opt{'host'}.":".$opt{'port'};
print "Connecting with $login\n";
my $gerrit_ssh = Net::OpenSSH->new($login);


my $ret = add_users_to_group($opt{'users'},$opt{'groupname'},$gerrit_ssh,\%opt);

print "Return was\n";
print $ret;



sub add_users_to_group {
  my $users = shift;
  my $groupname = shift;
  my $ssh = shift;
  my $conf_hr = shift;



  # compose some values together to be used in cmd string
  my @users = split /\,/, $users;

  my @user_args = map {" --add $_ "} @users;
  my $user_arg_string = join(" ", @user_args);

    
  my $cmd = " gerrit set-members $user_arg_string $groupname";
  print "would run:\n $cmd\n";

#  sshopen3 $login, *SEND, *RECV, *ERRORS, "mkdir -p $target_dir" or die "$0:ssh failure $1";

  my ($out, $err) = $ssh->capture2($cmd);
  $ssh->error and    die "remote command failed: " . $ssh->error;
  return $out;
  
  
}
