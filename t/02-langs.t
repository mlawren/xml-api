use strict;
use warnings;
use Test::More tests => 6;
use Test::Exception;
use XML::API;

my $x = XML::API->new(doctype => 'xhtml');

$x->html_open(undef);
$x->_set_lang('en');

ok($x->_langs == 1, 'first lang recorded');
is($x,'<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xml:lang="en" xmlns="http://www.w3.org/1999/xhtml"></html>','html ok');

$x->_set_lang('de');
$x->head('test head');
ok($x->_langs == 2, 'second lang accepted');

is($x,'<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xml:lang="en" xmlns="http://www.w3.org/1999/xhtml">
  <head xml:lang="de">test head</head>
</html>','html ok');


#
# Test languages on a generic XML document
#
$x = XML::API->new();
$x->one_open;
$x->_set_lang('en');
$x->two('a test two element');

ok($x->_langs == 1, 'lang accepted for generic xml');
is($x,'<?xml version="1.0" encoding="UTF-8" ?>
<one>
  <two xml:lang="en">a test two element</two>
</one>','generic xml ok');



