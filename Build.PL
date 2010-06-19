use Module::Build;
# See perldoc Module::Build for details of how this works

Module::Build->new
    ( module_name     => 'SDLx::Widget',
      license         => 'perl',
      build_requires  => {
	      'SDL'        => '2.4',
          'Test::More' => 0.88,
      },
      dist_abstract 	      => 'Common game widgets using SDL',
      dist_author	      => 'Dustin Mays, garu, Zpmorgan, kthakore',
	meta_merge => {
		resources  => {
			bugtracker => 'http://sdlperl.ath.cx/projects/SDLPerl/',
			repository => 'http://github.com/kthakore/SDLx-Widgets'
		}
	},

    )->create_build_script;
