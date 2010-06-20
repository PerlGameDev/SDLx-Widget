use strict;
use SDL;
use SDL::Video;
use SDL::Color;
use SDL::Rect;
use SDL::Surface;
use SDL::GFX::Rotozoom;

use SDLx::Widget::Sprite;



SDL::init(SDL_INIT_VIDEO);

my $disp = SDL::Video::set_video_mode( 300, 300, 32, SDL_ANYFORMAT);

my $sprite = SDLx::Widget::Sprite->new();

 $sprite->load('data/chest.png');
 $sprite->x(10);
 $sprite->y(10);

 my $angle = 0;
 while ($angle++ < 20) {
     $sprite->rotation($angle);
     $sprite->alpha_key(SDL::Color->new(0xfc, 0x00, 0xff))->alpha(0xcc);

     $sprite->draw($disp);

     SDL::Video::update_rect($disp, 0, 0, 300,300);

     SDL::delay( 100 );

     $sprite->alpha(0.20);
     $sprite->draw_xy( $disp, 60, 60);

     SDL::Video::update_rect($disp, 0, 0, 300,300);
 }
 SDL::delay( 2000 );

