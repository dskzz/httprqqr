#!/usr/bin/perl
use strict;
#use Data::Validate::URI qw(is_uri);
use HTTP::Request;
use LWP::Simple;
use URI;

#my $ua = LWP::UserAgent->new();
my $req = HTTP::Request->new(  );
my @headers = qw/Accept-Charset
Accept-Encoding
Authorization
Expect
From
If-Match
If-Modified-Since
If-None-Match
If-Range
If-Unmodified-Since
Max-Forwards
Proxy-Authorization
Range
Referer
TE/;

print "[?] GET/POST/HEAD/TRACE or G/P/H/T >";
my $type = <STDIN>;
my $clean_type = undef;

$clean_type = 'GET' if ( $type =~ /^G/i );
$clean_type = 'POST' if ( $type =~ /^P/i );
$clean_type = 'HEAD' if ( $type =~ /^H/i );
$clean_type = 'TRACE' if ( $type =~ /^T/i );

if ( !$clean_type )
{
	$clean_type = 'GET';
	print "[+] Type defaulted to GET\n";
}

$req->method( $clean_type );

print "[?] URL or default to scanme.org >";
my $url = <STDIN>;
$url =~ s/[\n\r\l\f]//g;
$url = 'http://www.scanme.org' unless $url;
$url = 'http://'.$url unless $url =~ /^http:\/\//;

my $URI = URI->new( $url );
my $host = $URI->host;
my $port = $URI->port;
$port = '80' unless $port;


print "[?] Cookie or enter for none >";
my $cookie=<STDIN>;
$cookie =~ s/[\n\r\l\f]//g;
$req->header( 'Cookie' => $cookie ) if length( $cookie ) >1;

print "[?] Agent of Press enter for random >";
my $agent = <STDIN>;
$agent =~ s/[\n\r\l\f]//g;
print "\n";
$agent =`user_agent_faker.py` unless length( $agent) >1;
$agent =~ s/[\n\r\l\f]//g;
$req->header( 'User-Agent'=> $agent ) if $cookie;


my $i = 0;
my @val_stack;
if ( $clean_type eq 'POST' )
{

	print 	"[?] Enter Param=Value press enter; When finished press enter".
		"[?] Enter only D to delete last entry >\n";
	
	while (1)
	{
		$i++;	
		print "Param=Val # $i > ";
		my $val = <STDIN>;
		if ( $val =~ /^\n$/ )
		{
			print "[+] Done\n";
			last;
		}
		elsif ( $val =~ /^D\b/i )
		{
			print "[-] Deleting last.\n";
			$i--;
			pop @val_stack;
		}
		elsif ( $val =~ /.+=.+/ )
		{
			$val =~ s/[\n\l\f\r]//g;
			push @val_stack, $val;
			print "[+] $val accepted.\n";
		}
		else
		{
			print "[!] Something went wrong.\n";
			$i--;
		}	
				
	if (@val_stack && $#val_stack > 0)
	{
		my $k=0;
		foreach my $vs (@val_stack)		
		{
			$k++;
			print " [+] $k - $vs\n";
		}
	} 
	}
	
	print "[+] Done \n"; 
}


my @headers_stack;
while (1)
{
	print "[?] Additional headers? Pres N or Enter to skip; D to delete last >";
	my $more = <STDIN>;
	if ( $more !~ /^n/i && $more !~ /^d/i && $more !~ /^\n/i )
	{
		my $j = 0;
		foreach my $h (@headers)
		{
			$j++;
			print "   $j -> $h\n";
		}
		print "[?] Enter a number Or Q >";
		my $head_id = <STDIN>;
		last if $head_id =~ /^q/;
		print "[!] Please enter a number!\n" if $head_id !~ /^\d/;
		print "[!] Too high!\n" if $head_id > $j;
		print "[!] Too Low!\n" if $head_id < 1;

		if( $head_id > 0 && $head_id <= $j )
		{
			my $index = $head_id - 1;
			print "[?] Please enter a value for ".$headers[$index]." >";
			my $value = <STDIN>;
			$value =~ s/[\n\r\l\f]//g;
			push @headers_stack, $headers[$index].': '.$value;
			
			print "[+] Current Headers:\n";
			foreach my $hs (@headers_stack)
			{
				print " [+] $hs\n";
			}
			print "\n";
			print "[?] Done Y? >";
			my $d = <STDIN>;
			last if $d =~ /y/i;
		}
	}
	elsif ($more =~ /^d/i)
	{
		pop @headers_stack if (@headers_stack);
	}
	else
	{ last; }
}


print "[+] Composing!\n";

my $vals_combined = undef;
my $vals_len = undef;
if (@val_stack)
{
	$vals_combined = join( '&', @val_stack );
	$vals_len = length( $vals_combined );
}

my $more_headers = undef;
if (@headers_stack)
	{	$more_headers = join "\n", @headers_stack; 	}


my $header = 	"$clean_type $url HTTP/1.1\n";
$header .=	"User Agent: $agent\n";
$header	.=	"Host: $host\n";
$header .= 	"Accept-Language: en-us\n";
$header .=	"Connection: Keep-Alive\n";
$header .= 	"Cookie: $cookie\n" 	if $cookie;
$header .=	"$more_headers\n" 		if $more_headers;
$header .= 	"Content-Type: application/x-www-form-urlencoded\n" if $vals_combined;
$header .=	"Content-Length: $vals_len\n" if $vals_len;
$header .=	"\n$vals_combined" if $vals_combined;

print "[+] Here's your REQUEST!\n";
print "-------------------------------------------------\n";
print $header."\n\n";
print "-------------------------------------------------\n";

print "[+] Do you want to nc this over somewhere?\nY to nc or anything else to quit>";
my $nc_yes = <STDIN>;
if ($nc_yes =~ /^y/i )
{
	my $string;
	for (0..7) { $string .= chr( int(rand(25) + 65) ); }

	`touch /tmp/$string`;
	open OUT, ">/tmp/$string/";
	print OUT $header;
	close OUT;
	my $cmd = "nc $host $port -vv </tmp/$string";
	print `$cmd`;
}







