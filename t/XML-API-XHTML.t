#!/usr/bin/perl

use strict;
use warnings;
use Test::More tests => 20;
use Test::Exception;

BEGIN {
    use_ok('XML::API::XHTML');
}

# check that we have a constructor
can_ok("XML::API::XHTML", 'new');

# giving doctype with new
throws_ok {
    XML::API::XHTML->new(doctype => 'lksdf', encoding => 'UTF-8');
} qr/^Must not specify doctype/;

# new called without 'encoding' parameter and no $XML::API::ENCODING
my $x;
eval {
    no warnings;
    $x = XML::API::XHTML->new();
};
#like($@, qr/Missing 'encoding' parameter/, 'lskdlkskdjlf');

# new called with only $XML::API::ENCODING set
$XML::API::ENCODING = 'UTF-8';
#$x = XML::API::XHTML->new();

$x = XML::API::XHTML->new(encoding => 'UTF-8');
isa_ok($x, 'XML::API');
isa_ok($x, 'XML::API::XHTML');

# test the interface

can_ok($x, '_debug');
can_ok($x, '_encoding');
can_ok($x, '_add');
can_ok($x, '_parse');
can_ok($x, '_current');
can_ok($x, '_set_id');
can_ok($x, '_goto');
can_ok($x, '_attrs');
can_ok($x, '_cdata');
can_ok($x, '_javascript');
can_ok($x, '_as_string');
can_ok($x, '_fast_string');
can_ok($x, '_print');

$x->_comment('COMMENT');

$x->html_open;
$x->_comment('this is another comment inside the html tag');
$x->_encoding('latin1');
$x->head_open;
$x->_javascript(<<"EOT");
    function blah() {
        var e = element.something.somewhere;
        e.style = 'a string here';
        return;
    }
EOT
$x->head_close;

$x->body_open;
$x->_set_id('body');
$x->div('junk with ordered keys?', {key2 => 'val2', key1 => 'val1'});
$x->_goto('body');
$x->li_open();
$x->a({href => '#'}, 'link');
$x->_add('|');
$x->li_close();
$x->div(-class => 'classname', -id => 'idname', 'and the content');

my $j = XML::API->new(doctype => 'xhtml');
$j->p_open;
$j->_add('external object');
$j->_comment('with comment');
$j->_parse('<p>some paragraph <a href="p.html">inlinelink</a> and end</p>');
$x->_add($j);
ok(2);

# Check what happens for empty elements / objects
my $k = XML::API->new(doctype => 'xhtml');
$k->p_open('external object (but began with empty element)');
$x->_add($k);
$k->_comment(' comment');
$k->em('with emphasis');
$k->_comment('second comment');
$k->p_close;
$k->_comment('COMMENT for external object (but began with empty element)');
ok(3);
print $x;
#print STDERR "\nDocument looks like: ",length($x->_as_string),"\n";
#print STDERR $x->_as_string;
#print STDERR "\nFAST looks like: ",length($x->_fast_string),"\n";
#print STDERR $x->_fast_string;


