# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 4;

BEGIN {
    use_ok( 'SDLx::Widget' );
    use_ok( 'SDLx::Widget::Menu' );
    use_ok( 'SDLx::Widget::Textbox');
    use_ok( 'SDLx::Widget::Button');

}




