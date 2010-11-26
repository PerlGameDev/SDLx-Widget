use Module::Build;
# See perldoc Module::Build for details of how this works

Module::Build->new(
    module_name    => 'SDLx::Widget',
    license        => 'perl',
    build_requires => {
        'SDL'        => '2.523',
        'Test::More' => 0.88,
    },
    requires => {
        'SDL'        => '2.523',
        'Clipboard'  => '0',
    },
    dist_abstract => 'Common game widgets using SDL',
    dist_author   => 'Dustin Mays, garu, Zpmorgan, kthakore, FROGGS',
	dist_version  => '0.04',
    meta_merge => {
        resources => {
            bugtracker => 'http://sdlperl.ath.cx/projects/SDLPerl/',
            repository => 'http://github.com/PerlGameDev/SDLx-Widget'
        }
    },
)->create_build_script;
