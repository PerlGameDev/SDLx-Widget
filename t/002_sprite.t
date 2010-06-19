use strict;
use Test::More;
use SDLx::Widget::Sprite;

my $sprite = SDLx::Widget::Sprite->new();

isa_ok ( $sprite, 'SDLx::Widget::Sprite');

TODO:
{
	local $TODO = 'This stuff needs to be implemented';
	fail (' Implement Alpha ');
}

done_testing;
