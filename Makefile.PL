# Load the Module::Install bundled in ./inc/
use inc::Module::Install;
    
name            'XML-API';
license         'GPL';
all_from        'lib/XML/API.pm';
requires        'XML::Parser::Expat' => 0; 
build_requires  'Test::More'        => '0.42';
    
auto_install;

WriteAll;
