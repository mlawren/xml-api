use strict;
use warnings;
use Test::More 'no_plan';

BEGIN {
    use_ok('XML::API');
}

my $x = XML::API->new;
$x->html_open(-class => 'pretty-style');
isa_ok $x->_attrs, 'HASH';
is $x->_attrs->{class}, "pretty-style";

$x->div_open;
$x->_attrs({id => 'main-content'});
is keys(%{ $x->_attrs }), 1;
is $x->_attrs->{id}, 'main-content';
$x->div_close;

isa_ok $x->root_attrs, 'HASH';
isa_ok $x->root_attrs->{contents}, 'ARRAY';
isa_ok $x->root_attrs->{attrs}, 'HASH';
isa_ok $x->root_attrs->{parent}, 'XML::API::Element';

$x->div_open;
$x->_attrs({id => 'inner-content', class => 'nice-content'});
is keys(%{ $x->_attrs }), 2;
is $x->_attrs->{id}, 'inner-content';
is $x->_attrs->{class}, 'nice-content';
$x->div_close;
