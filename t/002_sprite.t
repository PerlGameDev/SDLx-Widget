use strict;
use warnings;
use Test::More;
use SDL;
use SDL::Video;
use SDL::Color;

BEGIN { 
	use_ok( 'SDLx::Sprite' )
		or BAIL_OUT 'failed to load Sprite class - bailing'
}

can_ok('SDLx::Sprite', qw( new rect clip load surface x y
                                   w h draw alpha_key)
      );

TODO: {
    local $TODO = 'methods not implemented yet';

    can_ok( 'SDLx::Sprite', qw( rotation ) );
};


my $videodriver       = $ENV{SDL_VIDEODRIVER};
$ENV{SDL_VIDEODRIVER} = 'dummy' unless $ENV{SDL_RELEASE_TESTING};

SDL::init(SDL_INIT_VIDEO);

my $disp = SDL::Video::set_video_mode( 300, 300, 32, SDL_ANYFORMAT);

my $sprite = SDLx::Sprite->new;

# test initial values
ok($sprite, 'object defined');
isa_ok ( $sprite, 'SDLx::Sprite');

my $rect = $sprite->rect;
ok($rect, 'rect defined upon raw initialization');
isa_ok($rect, 'SDL::Rect', 'spawned rect isa SDL::Rect');
is($rect->x, 0, 'rect->x init');
is($rect->y, 0, 'rect->y init');
is($rect->w, 0, 'rect->w init');
is($rect->h, 0, 'rect->h init');

my ($x, $y) = ($sprite->x, $sprite->y);
is($x, 0, 'no x defined upon raw initialization');
is($y, 0, 'no y defined upon raw initialization');

my ($w, $h) = ($sprite->w, $sprite->h);
is($w, 0, 'no w defined upon raw initialization');
is($h, 0, 'no h defined upon raw initialization');


isa_ok ( $sprite->load('data/hero.png'), 'SDLx::Sprite', '[load] works');

isa_ok ( $sprite->alpha_key(SDL::Color->new(0xfc, 0x00, 0xff)), 'SDLx::Sprite', '[alpha] works');

isa_ok ( $sprite->alpha(0xcc), 'SDLx::Sprite', '[alpha] integer works ');

isa_ok ( $sprite->alpha(0.3), 'SDLx::Sprite', '[alpha]  percentage works');



done_testing;

#reset the old video driver
if($videodriver)
{
	$ENV{SDL_VIDEODRIVER} = $videodriver;
}
else
{
	delete $ENV{SDL_VIDEODRIVER};
}

