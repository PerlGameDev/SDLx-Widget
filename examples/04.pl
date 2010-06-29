use strict;
use SDL;
use SDL::Video;
use SDL::Color;
use SDL::Rect;
use SDL::Surface;
use SDL::GFX::Rotozoom;
use lib '../lib';
use SDLx::Sprite;



SDL::init(SDL_INIT_VIDEO);

my $disp = SDL::Video::set_video_mode( 300, 300, 32, SDL_ANYFORMAT);

my $pixel   = SDL::Video::map_RGB( $disp->format, 0, 0, 0 );
SDL::Video::fill_rect( $disp, SDL::Rect->new( 0, 0, $disp->w, $disp->h ), $pixel );


my $sprite = SDLx::Sprite->new();

 $sprite->load('data/chest.png');
 $sprite->x(10);
 $sprite->y(10);
 
 $sprite->alpha_key(SDL::Color->new(0xfc, 0x00, 0xff));
 $sprite->alpha(0.8);

 my $angle = 0;
 while ($angle++ < 360) {
   SDL::Video::fill_rect( $disp, SDL::Rect->new( 0, 0, $disp->w, $disp->h ), $pixel );
     
     $sprite->rotation($angle);
#     
     $sprite->draw($disp);

     SDL::Video::update_rect($disp, 0, 0, 300,300);

     SDL::delay( 2 );
 }
 SDL::delay( 2000 );
