# add one or more ssh keys to a specified user
# assumes user exists created by gerrit_create_user.pl
# takes an absolute path to a file containing the ssh key for the user


use strict;
use Net::OpenSSH;
use Data::Dumper;
use Getopt::Long;
use File::Slurp;

my %opt = (
	   'debug' => 1,
	   'admin_user'=>"admin",
	  );

GetOptions(
	   \%opt,
	   'host|server:s',
	   'port:s',
	   'admin_user:s',
	   'user:s',
	   'key_file:s',
	  );

print Dumper(\%opt);

# Get an ssh connexion to the Gerrit sshd
my $login = $opt{'admin_user'}."\@".$opt{'host'}.":".$opt{'port'};
print "Connecting with $login\n";
my $gerrit_ssh = Net::OpenSSH->new($login);

my $key = read_key_from_file($opt{'key_file'});

die "Failed to read key from $opt{'key_file'}" if (!defined($key));

my $ret = add_key_to_user($opt{'user'},$key,$gerrit_ssh,\%opt);

print "Return was\n";
print $ret;

sub read_key_from_file {
  my $path = shift;
  my $key = read_file($path);
  
  # $key will be undef in the case of an error; let caller check
  return $key;
}


sub add_key_to_user {
  my $user = shift;
  my $key = shift;
  my $ssh = shift;
  my $conf_hr = shift;

  chomp($key);

#  $key =~ s/\s/\\ /g;

  # compose some values together to be used in cmd string
    
  my $cmd = " gerrit set-account --add-ssh-key \"$key\" $user";
  print "would run:\n $cmd\n";

#  sshopen3 $login, *SEND, *RECV, *ERRORS, "mkdir -p $target_dir" or die "$0:ssh failure $1";

  my ($out, $err) = $ssh->capture2($cmd);
  $ssh->error and    die "remote command failed: " . $ssh->error;
  return $out;
  
  
}
