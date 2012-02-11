#!/usr/bin/perl -w
#
# Check to see if a resource is programmatically available when a client-side SSL certificate is required.
use LWP::UserAgent;
use Data::Dumper qw(Dumper);

my $user = 'YOUR_USER_EMAIL';
my $pass = 'YOUR_USER_PASS';
my $url = 'https://YOUR_RESOURCE/';

$ENV{HTTPS_PKCS12_FILE} = '/path/to/YOUR_CERTIFICATE.p12';
$ENV{HTTPS_PKCS12_PASSWORD} = 'YOUR_CERTIFICATE_PASS';

my $ua = LWP::UserAgent->new;
#$ua->credentials("YOUR_RESOURCE:443",$user, $pass);
#my $res = $ua->get('https://YOUR_RESOURCE/');
my $req = HTTP::Request->new(GET => $url);
$req->authorization_basic($user,$pass);
my $res = $ua->request($req);

if ($res->is_success) {
	print $res->decoded_content;
} else {
	die $res->status_line;
}
#print $res->content, "\n";
#print Dumper($res);

__END__
