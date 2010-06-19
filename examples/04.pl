use strict;
use SDL;
use SDL::Video;
use SDL::Color;
use SDLx::Widget::Sprite;
use SDL::Surface;



SDL::init(SDL_INIT_VIDEO);

my $disp = SDL::Video::set_video_mode( 300, 300, 32, SDL_ANYFORMAT);

my $sprite = SDLx::Widget::Sprite->new();

 $sprite, 'SDLx::Widget::Sprite';

 $sprite->load('data/hero.png');

 $sprite->alpha_key(SDL::Color->new(0xfc, 0x00, 0xff));

 $sprite->x(10);
 $sprite->y(10);
 $sprite->draw($disp);



 SDL::Video::flip($disp);

sleep( 2 );
