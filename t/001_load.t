# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'SDLx::Widget' ); }

my $object = SDLx::Widget->new ();
isa_ok ($object, 'SDLx::Widget');


