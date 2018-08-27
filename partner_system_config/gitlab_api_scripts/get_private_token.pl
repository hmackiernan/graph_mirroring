use strict;
use strict;
use warnings;
use LWP::UserAgent ();
use JSON::Parse 'parse_json';
use Data::Dumper;

# Given the Username and Password of a (presuambly)
# Administrator user, return the private access token for later API calls

my $url = "http://gitlabce/api/v3/session/";
my $user = "root";
my $pass = "password";

print get_token($url,$user,$pass);


sub get_token {
  my $url = shift;
  my $user = shift;
  my $pass = shift;

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


curl -X POST   http://gitlabce/api/v3/session/   -H 'cache-control: no-cache'   -H 'content-type: application/x-www-form-urlencoded'   -H 'postman-token: f702296d-6e45-fed8-3424-ecfb06fadc80'   -d 'login=root&password=password'
