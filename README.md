# httprqqr
#### The HTTP Wrecker - http request crafter ####
This perl program depends on the nifty little python program fake-useragent:
>pip install fake-useragent

It's found here: 
  
  https://github.com/hellysmile/fake-useragent


I couldn't find a good one of these on the old intertubes so I decided I might as well make my own.  

This has 2 perl files - 

  skz-http_req_craft_cmd.pl  
  skz-http_req_craft.pl

### The interactive version ###

skz-http_req_craft.pl allows the creation of advanced packets through a query/response system.  
What's super cool is that this not only creates the packet but also lets you nc the packet somewhere and view the response.  
Try doing that curl!

Here's a sample run:

  [?] GET/POST/HEAD/TRACE or G/P/H/T >G
  [?] URL or default to scanme.org >
  [?] Cookie or enter for none >
  [?] Agent of Press enter for random >
  [?] Additional headers? Pres N or Enter to skip; D to delete last >Y
    1 -> Accept-Charset
     2 -> Accept-Encoding
     3 -> Authorization
     4 -> Expect
     5 -> From
     6 -> If-Match
     7 -> If-Modified-Since
     8 -> If-None-Match
     9 -> If-Range
     10 -> If-Unmodified-Since
     11 -> Max-Forwards
     12 -> Proxy-Authorization
     13 -> Range
     14 -> Referer
     15 -> TE
  [?] Enter a number Or Q >1
  [?] Please enter a value for Accept-Charset >utf-8
  [+] Current Headers:
  [+] Accept-Charset: utf-8
  
  [?] Done Y? >y
  [+] Composing!
  [+] Here's your REQUEST!
  -------------------------------------------------
  GET http://www.scanme.org HTTP/1.1
  User Agent: 
  Host: www.scanme.org
  Accept-Language: en-us
  Connection: Keep-Alive
  Accept-Charset: utf-8
  
  
  -------------------------------------------------
NOTE - it depends on the python user_agent_faker.py tool; need to work with that maybe make an inline python command 

#### Command line version ####
HTTP requests are handy things to throw around the shell.  So in some cases, an interactive program just wont cut it. 
So here is a version that will work on the command line.  It's a little less advanced; it wont take the more complex HTTP methods
but it does the job well enough.  Can go in and add those later I guess. 

TODO -  load the actual packet header from an existing if you want.  

> skz-http_req_craft_cmd.pl 

  [+] Running skz-http_req_craft_cmd.pl with GET http://www.scanme.org
  
  GET / HTTP/1.1
  User Agent: Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2226.0 Safari/537.36
  Host: www.scanme.org
  Accept-Language: en-us
  Connection: Keep-Alive

Let's run it and ask for some guidance:

> ./skz-http_req_craft_cmd.pl --help
  [+] Running skz-http_req_craft_cmd.pl with GET http://www.scanme.org
	  skz-http_req_craft_cmd.pl
  		-url   		[full url] 
  		-port  		[port numb, can send with url too but this clobbers] 
  		-type  		[G/P/T/H; default GET]  OR pass -post 
  		-cookie		[whatever]
  		-agent 		[User agent; this defaults to random]
  		-param		[param=val&param2=val2&etc Not checked! Poison if you want...]
  		-nc   	  This automatically sends the header to nc host port
  		-ncbody	  This shows entire response from sending to nc
  		-verbose	Show all the stuff
  		-out	    Save the header to a file

Hope this helps out somewhere!


