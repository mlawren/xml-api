use strict;
use warnings;
use Test::More tests => 12;
use Test::Exception;

BEGIN {
    use_ok('XML::API');
}

# test the interface

can_ok('XML::API', qw/
    _encoding
    _debug
    _add
    _ast
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


$x->_parse('<div class="divclass"><p>text</p></div>');

is($x, '<?xml version="1.0" encoding="UTF-8" ?>
<e>
  <c>content</c>
  <n attr="1">
    <n2>content
      <n3 />
      <![CDATA[my < CDATA]]>
    </n2>
  </n>
  <p>&lt;raw /&gt;<raw />
    <div class="divclass">
      <p>text</p>
    </div>
  </p>
</e>', 'e c n p escaped and raw content with parsed data');


my $a = XML::API->new;
$a->_ast(
    p => [
        label => 'Body',
        textarea => [
            -rows  => 10,
            -cols  => 50,
            -name  => 'body',
            'the body',
        ],
    ],
);

is($a, '<?xml version="1.0" encoding="UTF-8" ?>
<p>
  <label>Body</label>
  <textarea cols="50" name="body" rows="10">the body</textarea>
</p>', 'Abstract syntax tree input');
