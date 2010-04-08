use Module::Build;
# See perldoc Module::Build for details of how this works

Module::Build->new
    ( module_name     => 'SDLx::Widget',
      license         => 'perl',
      build_reguires  => {
	      SDL => '2.4'
      }
      author	      => 'Dustin Mays <dork.fish.wat@gmail.com>'
    )->create_build_script;
