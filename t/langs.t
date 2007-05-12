#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 7;
use Test::Exception;
use XML::API;

my $x = XML::API->new(doctype => 'xhtml');

$x->html_open;
$x->_set_lang('en');

ok($x->_langs == 1, 'first lang accepted');

$x->_set_lang('de');

ok($x->_langs == 2, 'second lang accepted');

$x->head('test head');
my $str = $x->_as_string;

ok($str =~ /html.*xml:lang="en"/, 'html is en');
ok($str =~ /head.*xml:lang="de"/, 'head is de');


#
# Test languages on a generic XML document
#
$x = XML::API->new();
$x->one_open;
$x->_set_lang('en');
$x->two('a test two element');

ok($x->_langs == 1, 'lang accepted for generic xml');
$str = $x->_as_string;

ok($str !~ /one.*xml:lang="en"/, 'root node lang is not set');
ok($str =~ /two.*xml:lang="en"/, 'two did get the language');
