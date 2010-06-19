use strict;
use Test::More;
use SDL;
use SDL::Video;
use SDL::Color;
use SDLx::Widget::Sprite;

my $videodriver       = $ENV{SDL_VIDEODRIVER};
$ENV{SDL_VIDEODRIVER} = 'dummy' unless $ENV{SDL_RELEASE_TESTING};

SDL::init(SDL_INIT_VIDEO);

my $disp = SDL::Video::set_video_mode( 300, 300, 32, SDL_ANYFORMAT);

my $sprite = SDLx::Widget::Sprite->new();

isa_ok ( $sprite, 'SDLx::Widget::Sprite');

isa_ok ( $sprite->load('data/hero.png'), 'SDLx::Widget::Sprite', '[load] works');

isa_ok ( $sprite->alpha_key(SDL::Color->new(0xfc, 0x00, 0xff)), 'SDLx::Widget::Sprite', '[alpha] works');


TODO:
{
	local $TODO = 'This stuff needs to be implemented';
	fail (' Implement Alpha ');
}

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

