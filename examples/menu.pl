use strict;
use warnings;
use Carp 'croak';
use SDL;
use SDL::Events;
use SDL::Video;
use SDL::Surface;

use lib 'lib';
use SDLx::Controller;
use SDLx::Widget::Menu;

croak 'Cannot init  ' . SDL::get_error() if SDL::init(SDL_INIT_VIDEO) == -1;

# Create our display window
my $display
    = SDL::Video::set_video_mode( 800, 600, 32,
    SDL_HWSURFACE | SDL_DOUBLEBUF | SDL_HWACCEL )
    or croak 'Cannot create display: ' . SDL::get_error();

my $game = SDLx::Controller->new( eoq => 1 );
my $menu = SDLx::Widget::Menu->new( topleft => [ 0, 400 ], mouse => 1 );
$menu->items(
    'New Game'  => sub { },
    'Load Game' => sub { },
    'Options'   => sub { },
    'Quit' => sub { $menu->{exit} = 1; },    #return the of this in event loop
);

$game->add_event_handler(
    sub {
        $menu->event_hook( $_[0] );
        $game->stop if $menu->{exit};
    }
);

$game->add_show_handler(
    sub {
        $menu->render($display);
        SDL::Video::flip($display);
    }
);

$game->run;
