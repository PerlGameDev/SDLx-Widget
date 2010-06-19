use strict;
use Test::More;
use SDLx::Widget::Sprite;

my $sprite = SDLx::Widget::Sprite->new();

isa_ok ( $sprite, 'SDLx::Widget::Sprite');

isa_ok ( $sprite->load('data/hero.png'), 'SDLx::Widget::Sprite', '[load] works');

TODO:
{
	local $TODO = 'This stuff needs to be implemented';
	fail (' Implement Alpha ');
}

done_testing;
