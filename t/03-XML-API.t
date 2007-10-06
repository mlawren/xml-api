use strict;
use warnings;
use Test::More tests => 10;
use Test::Exception;

BEGIN {
    use_ok('XML::API');
}

# test the interface

can_ok('XML::API', qw/
    _encoding
    _debug
    _add
    _parse
    _current
    _set_id
    _goto
    _attrs
    _set_lang
    _langs
    _cdata
    _javascript
    _as_string
    _fast_string
/);


# giving invalid doctype with new
throws_ok {
    XML::API->new(doctype => 'notexist');
} qr/^Could not load module 'XML::API::NOTEXIST'/;


# make a root for our tree
my $x = XML::API->new;
isa_ok($x, 'XML::API');

$x->e_open();
is($x, '<?xml version="1.0" encoding="UTF-8" ?>
<e />', 'e content');

$x->c('content');
is($x, '<?xml version="1.0" encoding="UTF-8" ?>
<e>
  <c>content</c>
</e>', 'e c content');

my $n = XML::API->new;
$n->n_open(-attr => 1);
$n->n2_open;
$n->_add('content');
$n->n3;

is($n, '<?xml version="1.0" encoding="UTF-8" ?>
<n attr="1">
  <n2>content
    <n3 />
  </n2>
</n>', 'n content');

$x->_add($n);

is($x, '<?xml version="1.0" encoding="UTF-8" ?>
<e>
  <c>content</c>
  <n attr="1">
    <n2>content
      <n3 />
    </n2>
  </n>
</e>', 'e c n content');

$x->p_open;
$x->_add('<raw />');
$x->_raw('<raw />');

is($x, '<?xml version="1.0" encoding="UTF-8" ?>
<e>
  <c>content</c>
  <n attr="1">
    <n2>content
      <n3 />
    </n2>
  </n>
  <p>&lt;raw /&gt;<raw /></p>
</e>', 'e c n p escaped and raw content');

$n->_cdata('my < CDATA');
#warn $n;
#warn $x;

is($x, '<?xml version="1.0" encoding="UTF-8" ?>
<e>
  <c>content</c>
  <n attr="1">
    <n2>content
      <n3 />
      <![CDATA[my < CDATA]]>
    </n2>
  </n>
  <p>&lt;raw /&gt;<raw /></p>
</e>', 'e c n p escaped and raw content');

exit;
use Data::Dumper;
$Data::Dumper::Indent = 1;
#die Dumper($x);

$x->_parse('<div><p>text</p></div>');
$x->_comment('COMMENT');

$x->html_open();
$x->_set_lang('en');
$x->_comment('this is another comment inside the html tag');
$x->_encoding('latin1');
$x->_debug(1);
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
$x->div(-class => 'classname', -id => 'idname', 'and the content with &');

my $j = XML::API->new();
$j->_set_lang('de', 'ltr');
$j->p_open;
$j->_add('external object');
$j->_add(' Added a second scalar - should produce one object');
#use Data::Dumper;
#$Data::Dumper::Indent = 2;
#die Dumper($j);
$j->_comment('with comment');
$j->_parse('<p>A *parsed* paragraph <a href="p.html">inlinelink</a> and end</p>');
print STDERR "\n", $j->_as_string;

$x->div($j);
$x->_add($j);
ok(2);

# Check what happens for empty elements / objects
my $k = XML::API->new(doctype => 'xhtml');
$k->p_open('-xml:lang' => 'de',
   'external object (but began with empty element)');
$x->_add($k);
$k->_comment(' comment');
$k->em('with emphasis');
$k->_comment('second comment');
$k->p_close;
$k->_comment('COMMENT for external object (but began with empty element)');
ok(3);

ok(scalar($x->_langs) == 2, 'language check');
print join(',',$x->_langs);
print $x;
print STDERR "\nDocument looks like: ",length($x->_as_string),"\n";
print STDERR $x->_as_string;
#print STDERR "\nFAST looks like: ",length($x->_fast_string),"\n";
#print STDERR $x->_fast_string;


