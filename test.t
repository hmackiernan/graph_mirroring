# delete a repo from p4d, then try to clone it through gconn
use strict;
use P4::test;
use lib "$script_home_abspath";
use GCONN;
my @users = qw(alice bob);

note "$script_home_abspath is the script_home_abspath";


my $base_parnter_url = "http://gitlabee9";

my  $testRoot = P4::test::getTestingDir;
cd $testRoot;

