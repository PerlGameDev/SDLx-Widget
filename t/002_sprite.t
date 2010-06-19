use strict;
use Test::More;
use SDL::Color;
use SDLx::Widget::Sprite;

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
