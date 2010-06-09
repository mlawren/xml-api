# Load the Module::Install bundled in ./inc/
use inc::Module::Install;
    
name            'XML-API';
license         'GPL';
all_from        'lib/XML/API.pm';
requires        'XML::SAX'            => 0; 
requires        'XML::LibXML::SAX'    => 0; 
requires        'Scalar::Util'        => 0; 
build_requires  'Test::More'          => '0.42';
build_requires  'Test::Exception'     => 0;
build_requires  'Test::Memory::Cycle' => 0;
build_requires  'File::Slurp'         => 0;

no_index package => 'XML::API::Element';
no_index package => 'XML::API::SAXHandler';

resources
    bugtracker => 'http://rt.cpan.org/NoAuth/ReportBug.html?Queue=XML-API',
    repository => 'git://github.com/mlawren/xml-api.git';
    
WriteAll;
