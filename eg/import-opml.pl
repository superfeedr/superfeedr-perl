#!/usr/bin/perl
use strict;
use AnyEvent::Superfeedr;
use XML::OPML::LibXML;

my($opml, $jid, $pass) = @ARGV;
$opml && $jid && $pass or die "Usage: $0 OPML JID password";

my $parser = XML::OPML::LibXML->new;
my $doc = $parser->parse_file($opml);

my @feeds;
$doc->walkdown(sub { push @feeds, $_[0]->xml_url if defined $_[0]->xml_url });

my $superfeedr = AnyEvent::Superfeedr->new(
    debug => $ENV{ANYEVENT_SUPERFEEDR_DEBUG},
    jid => $jid,
    password => $pass,
);

$superfeedr->connect;
    on_connect => sub {
        $superfeedr->subscribe(@feeds, sub { warn "Subscribed to $_[0]\n" });
    },

AnyEvent->condvar->recv;

