use strict;
use warnings;
use Test::More tests => 34;
use Test::Exception;
use Test::Memory::Cycle;
use File::Slurp;

BEGIN {
    use_ok('XML::API');
}

# test the interface

can_ok('XML::API', qw/
    _encoding
    _debug
    _open
    _add
    _raw
    _close
    _element
    _ast
    _parse
    _parse_chunk
    _current
    _set_id
    _goto
    _attrs
    _set_lang
    _langs
    _css
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

$x->_open('e');
is($x, '<?xml version="1.0" encoding="UTF-8" ?>
<e />', 'e open');

$x->_close('e');
is($x, '<?xml version="1.0" encoding="UTF-8" ?>
<e />', 'e close');

$x = XML::API->new;
$x->_open('e',-type => 'mytype','mycontent');
is($x, '<?xml version="1.0" encoding="UTF-8" ?>
<e type="mytype">mycontent</e>', 'e open content');

$x->_add(' more content');
$x->_element('f', 'f content');

$x->_close('e');
is($x, '<?xml version="1.0" encoding="UTF-8" ?>
<e type="mytype">mycontent more content
  <f>f content</f>
</e>', 'e content');

$x = XML::API->new;
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


$x->_parse_chunk('<div class="divclass"><p>text</p></div>');

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
    <div class="divclass">
      <p>text</p>
    </div>
  </p>
</e>', 'e c n p escaped and raw content with parsed data');

$x->style_open(-type => 'text/css');
$x->_css('margin: 0;');
$x->style_close();

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
    <div class="divclass">
      <p>text</p>
    </div>
    <style type="text/css">/*<![CDATA[*/ margin: 0; /*]]>*/</style>
  </p>
</e>', 'e c n p escaped and raw content with parsed data');

is($x->_fast_string, '<?xml version="1.0" encoding="UTF-8" ?><e><c>content</c><n attr="1"><n2>content<n3></n3><![CDATA[my < CDATA]]></n2></n><p>&lt;raw /&gt;<raw /><div class="divclass"><p>text</p></div><div class="divclass"><p>text</p></div><style type="text/css">/*<![CDATA[*/ margin: 0; /*]]>*/</style></p></e>'
, 'e c n p escaped and raw content with parsed data FAST');


my $tfile = '_test.xml';
unlink($tfile);
ok(! -f $tfile, 'output file does not exist');
$x->_as_string($tfile);
ok(-f $tfile, 'output file created');

my $text = read_file($tfile, binmode => ':utf8');
is($x, $text, 'output file content matches');


unlink($tfile);
$x->_fast_string($tfile);
ok(-f $tfile, 'fast output file created');

$text = read_file($tfile, binmode => ':utf8');
is($x->_fast_string, $text, 'fast output file content matches');

END {unlink $tfile};


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


memory_cycle_ok($x, 'memory cycle');

my $ns = XML::API->new;
$ns->_ns('soapenv');
$ns->Envelope_open();
$ns->ns1__Body_open('my body');
$ns->Body_close();
$ns->_ns(undef);
$ns->password('-xsi:type' => 'xsd:string');
$ns->Envelope_close();


#
# Adding XML objects to themselves.
#

is($ns,'<?xml version="1.0" encoding="UTF-8" ?>
<soapenv:Envelope>
  <ns1:Body>my body</ns1:Body>
  <password xsi:type="xsd:string" />
</soapenv:Envelope>', 'NameSpace support');

$ns->_set_lang('en');

my $noelements = XML::API->new();
$ns->_add($noelements);

memory_cycle_ok($noelements, 'memory cycle');
memory_cycle_ok($ns, 'memory cycle');

is($ns,'<?xml version="1.0" encoding="UTF-8" ?>
<soapenv:Envelope>
  <ns1:Body>my body</ns1:Body>
  <password xsi:type="xsd:string" />
</soapenv:Envelope>
', 'No elements');

is($noelements->_lang, 'en', 'language up the tree');

$noelements->think('deep');
is($noelements,'<?xml version="1.0" encoding="UTF-8" ?>
<think>deep</think>', 'no elements with element');

memory_cycle_ok($noelements, 'memory cycle');
memory_cycle_ok($ns, 'memory cycle');

is($ns,'<?xml version="1.0" encoding="UTF-8" ?>
<soapenv:Envelope>
  <ns1:Body>my body</ns1:Body>
  <password xsi:type="xsd:string" />
</soapenv:Envelope>
<think>deep</think>', 'ns plus think');


