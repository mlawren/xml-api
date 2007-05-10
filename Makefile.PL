# Load the Module::Install bundled in ./inc/
use inc::Module::Install;
    
# Define metadata
name            'XML-API';
all_from        'lib/XML/API.pm';
    
# Specific dependencies
requires        'Tree::Simple'      => '0.17';
requires        'XML::Parser::Expat' => 0; 
build_requires  'Test::More'        => '0.42';
#recommends      'Your::OtherModule' => '0.01';
    
#no_index        'directory'         => 'demos';
    
#install_script  'bin/myscript';
    
auto_install;
WriteAll;
