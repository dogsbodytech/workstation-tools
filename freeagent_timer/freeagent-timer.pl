#!/usr/bin/perl
#
# This file is managed by Dogsbody Technology Ltd.
#   https://www.dogsbody.com/
#
# Description:  A script to stop all freeagent timers and start a new one. 
#
# Usage:  $0 <Timer text>
#
# To do:
# - Automatically update the timer date
# - Use config file for settings
# - Move script into git repo
# - Make getting/setting the userid easier 

$curl = "/usr/bin/curl";
$api_endpoint="https://api.freeagent.com";
$app_id="VARAPPID";
$app_secret="VARSECRETID";
$oauth2_refresh_token="VARREFRESHTOKEN";
$myfreeagentid="VARMYFAID";
$defaulttask="VARDEFAULTTASK";
$defaultproject="VARDEFAULTPROJECT";


use XML::LibXML;
# Get an Access token so we can do our queries
# We can't use XML::LibXML here as we get JSON back
$output = `$curl $api_endpoint/v2/token_endpoint -s -S -X POST -d "client_secret=$app_secret&grant_type=refresh_token&refresh_token=$oauth2_refresh_token&client_id=$app_id"`;
@output = split(/,/,$output);
foreach $line (@output)
  {
  my ($key,$pair) = split(/:/,$line);
  if ($key =~ /access_token/)
    {
    $token = $pair;
    $token =~ s/"//g;
    }
  }

# Get list of users
# We shouldn't need to paginate as we should always have under 100 users
#$output = `$curl "$api_endpoint/v2/users?per_page=100" -s -S -X GET -H "Authorization: Bearer $token" -H "Accept: application/xml"`;
#$parser = XML::LibXML->new();
#$xml = $parser->parse_string($output);
#foreach $item ($xml->findnodes('/freeagent/users/user'))
#  {
#  my $url = $item->findnodes('./url');
#  $url = $url->to_literal;
#  my $firstname = $item->findnodes('./first-name');
#  $firstname = $firstname->to_literal;
#  my $lastname = $item->findnodes('./last-name');
#  $lastname = $lastname->to_literal;
#  #$url2name{$url} = "$firstname $lastname";
#  #push(@users,$url);
#  print "Found User: $url - $firstname $lastname\n";
#  }

# Get list of running timers for the user
# We shouldn't need to paginate as we should always have under 100 timers
$output = `$curl "$api_endpoint/v2/timeslips?user=https://api.freeagent.com/v2/users/$myfreeagentid&view=running&per_page=100" -s -S -X GET -H "Authorization: Bearer $token" -H "Accept: application/xml"`;
$parser = XML::LibXML->new();
$xml = $parser->parse_string($output);
foreach $item ($xml->findnodes('/freeagent/timeslips/timeslip'))
  {
  my $url = $item->findnodes('./url');
  $url = $url->to_literal;
  print "Stopping Timer: $url\n";
  $output = `$curl "$url/timer" -s -S -X DELETE -H "Authorization: Bearer $token" -H "Accept: application/xml"`;
  #print "$output\n";
  }

print "Creating new Timeslip\n";

use POSIX qw(strftime);
my $fadate = strftime "%Y-%m-%d", localtime;

$famessage = "No message supplied";

$famessage = "@ARGV"
if exists $ARGV[0];

$command=qq({ "timeslip": { "task":"https://api.freeagent.com/v2/tasks/$defaulttask", "user":"https://api.freeagent.com/v2/users/$myfreeagentid", "project":"https://api.freeagent.com/v2/projects/$defaultproject", "dated_on":"$fadate", "hours":"0.0167", "comment":"$famessage" }});

$output = `$curl "$api_endpoint/v2/timeslips" -s -S -X POST -d '$command' -H "Authorization: Bearer $token" -H "Content-Type: application/json" -H "Accept: application/xml"`;

#print "$output\n";
$parser = XML::LibXML->new();
$xml = $parser->parse_string($output);
foreach $item ($xml->findnodes('/freeagent/timeslip'))
  {
  my $url = $item->findnodes('./url');
  $url = $url->to_literal;
  print "Starting Timer: $url\n";
  $output = `$curl "$url/timer" -s -S -X POST -H "Authorization: Bearer $token" -H "Accept: application/xml"`;
  #print "$output\n";
  }


