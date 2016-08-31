#!/usr/bin/perl
use strict;
#use Data::Validate::URI qw(is_uri);
use HTTP::Request;
use LWP::Simple;
use URI;
use Getopt::Long;

my $verbose = '';
my $nc_use = '';
my $type = 'GET';
my $url = 'http://www.scanme.org';
my $user_agent = `user_agent_faker.py`;
my $cookie = '';
my $params = '';
my $save_loc = '';
my $nc_body_response='';
my ($AcceptEncoding, $Authorization, $Expect, $From, $MaxForwards, $ProxyAuthorization, $Range, $Referer,$TE) = '';
my $post_override ='';
my $port_force = '';

my $HOST; 
my $PORT;
my $PATH;

my $show_help;

GetOptions(
'verbose'=>\$verbose,
'nc' =>\$nc_use,
'ncbody'=>\$nc_body_response,
'type=s' =>\$type,
'url=s' =>\$url,
'host=s' =>\$url,
'cookie=s' =>\$cookie,
'agent=s'=>\$user_agent,
'param=s'=>\$params,
'help'=>\$show_help,
'out=s'=>\$save_loc,
'post'=>\$post_override,
'port=i'=>\$port_force
);

$type = 'POST' if $post_override eq 1;

my $THRESHOLD = 0;
sub o
{
	my $str = shift;
	my $pre = shift;
	my $priority = shift;
	$pre = '+' unless $pre;
	$priority = 0 unless $priority;
	print "[$pre] $str\n" if $priority >= $THRESHOLD;
}	
my @x = (split( /\//, $0 ));
my $file = pop( @x  );

$type= figure_out_request( $type );
$url= clean_url( $url );
$user_agent = strip($user_agent);

$PORT = $port_force if ($port_force =~ /^\d{1,}$/);

o("Running $file with $type $url");
o("Verbosity on ") if $verbose;
o("User Agent: $user_agent ") if $user_agent && $verbose;
o("Cookie: $cookie") if $cookie && $verbose;
o("Host Port Path: $HOST $PORT $PATH") if $user_agent && $verbose;
	

help($file, "NO HOST") if !$url;
help($file ) if $show_help;


my $vals_len = undef;
$vals_len = length($params) if $params;

$PATH = '/' unless $PATH;
$PATH = '' if $type eq 'HEAD';

my $header = 	"$type $PATH HTTP/1.1\n";
$header .=	"User Agent: $user_agent\n";
$header	.=	"Host: $HOST\n";
$header .= 	"Accept-Language: en-us\n";
$header .=	"Connection: Keep-Alive\n";
$header .= 	"Cookie: $cookie\n" 	if $cookie;
$header .= 	"Content-Type: application/x-www-form-urlencoded\n" if $params;
$header .=	"Content-Length: $vals_len\n" if $vals_len;
$header .=	"\n$params" if $params;
$header .=	"\n\n";

o("Header Created:") if $verbose;
my $nc_res = undef;
if ( $nc_use )
{
	print "\n$header" if ($verbose);
	my $string;
	for (0..7) { $string .= chr( int(rand(25) + 65) ); }

	open OUT, ">$string" or die "Failed to open $string";
	print OUT $header or die "Could not write to $string";
	close OUT;

	my $cmd = "nc $HOST $PORT -vv <$string";
	o($cmd) if $verbose;
	$nc_res = `$cmd`;
	`rm $string`;

	my $nc_head_only = $nc_res;
	$nc_head_only =~ /(.*?)\n\n/s;
	$nc_head_only = $1;
	
	o("nc response:") if $verbose;	
	print $nc_head_only if $verbose &&  $nc_body_response eq '';
	print $nc_res if $verbose && $nc_body_response ne '' ;
}
else
{
	print "\n$header";
}

if( $save_loc ne '' )
{
	open OUT, ">$save_loc";
	print OUT $header;
	print OUT "---------------------------------------\n$nc_res" if $nc_res;
	close OUT;
	o("Saved to $save_loc") if $verbose;

}

sub strip
{
	my $x=	shift;
	$x =~ s/[\n\r\l\f]//g;
	return $x;
}

sub clean_url
{
	my $url_lcl = shift;
	$url_lcl =~ s/[\n\r\l\f]//g;
	$url_lcl = 'http://'.$url_lcl unless $url_lcl =~ /^http:\/\//;

	my $URI = URI->new( $url_lcl );
	$HOST = $URI->host;
	$PORT = $URI->port;
	$PORT = '80' unless $PORT;
	$PATH = $URI->path;
	return $url_lcl;
}

sub figure_out_request
{
	my $req = shift;
	return 'POST' if $req =~ /^p/i;
	return 'GET' if $req =~ /^g/i;
	return 'HEAD' if $req =~ /^h/i;
	return 'TRACE' if $req =~ /^t/i;
}

sub help
{
	my $filename = shift;
	my $error = shift;

	o($error, '!', 5) if $error ;
	print "\t$filename\n".
		"\t\t-url   \t\t[full url] \n".
		"\t\t-port  \t\t[port numb, can send with url too but this clobbers] \n".
		"\t\t-type  \t\t[G/P/T/H; default GET]  OR pass -post \n".
		"\t\t-cookie\t\t[whatever]\n".
		"\t\t-agent \t\t[User agent; this defaults to random]\n".
		"\t\t-param\t\t[param=val&param2=val2&etc Not checked! Poison if you want...]\n".
		"\t\t-nc   \tThis automatically sends the header to nc host port\n".
		"\t\t-ncbody\tThis shows entire response from sending to nc\n".
		"\t\t-verbose\tShow all the stuff\n".
		"\t\t-out\tSave the header to a file\n".
		"";
	exit(0);

}
