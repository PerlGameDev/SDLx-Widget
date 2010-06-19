package SDLx::Widget::Sprite;
use strict;
use warnings;

use SDL;
use SDL::Video;
use SDL::Image;
use SDL::Rect;
use SDL::Surface;
use Carp ();

sub new {
	my ($class, %options) = @_;
	my $self = bless {}, ref $class || $class;

	# create our two initial rects
	$self->rect( exists $options{rect} ? $options{rect}
		: SDL::Rect->new(0,0,0,0)
	);
	$self->clip( exists $options{clip} ? $options{clip}
		: SDL::Rect->new(0,0,0,0)
	);

	# short-circuit
	return $self unless %options;

	Carp::croak 'rect cannot be instantiated together with x or y'
	if exists $options{rect} and (exists $options{x} or exists $options{y});

	Carp::croak 'image and surface cannot be instantiated together'
	if exists $options{image} and exists $options{surface};

	# note: ordering here is somewhat important. If you change anything,
	# please rerun the test suite to make sure everything still works :)
	$self->load($options{image})          if exists $options{image};
	$self->surface($options{surface})     if exists $options{surface};
	$self->x($options{x})                 if exists $options{x};
	$self->y($options{y})                 if exists $options{y};
#    $self->rotation($options{rotation})   if exists $options{rotation};
	$self->alpha_key($options{alpha_key}) if exists $options{alpha_key};
#    $self->alpha($options{alpha})         if exists $options{alpha};

	return $self;
}


sub load {
	my ($self, $filename) = @_;

	require SDL::Image;
	my $surface = SDL::Image::load( $filename )
		or Carp::croak SDL::get_error;

	$self->surface( $surface );
	return $self;
}


sub surface {
	my ($self, $surface) = @_;

	# short-circuit
	return $self->{surface} unless $surface;

	Carp::croak 'surface accepts only SDL::Surface objects'
	unless $surface->isa('SDL::Surface');

	my $old_surface = $self->{surface};
	$self->{surface} = $surface;

	# update our source and destination rects
	$self->rect->w( $surface->w );
	$self->rect->h( $surface->h );
	$self->clip->w( $surface->w );
	$self->clip->h( $surface->h );

	return $old_surface;
}


sub rect {
	my ($self, $rect) = @_;

	# short-circuit
	return $self->{rect} unless $rect;

	Carp::croak 'rect accepts only SDL::Rect objects'
	unless $rect->isa('SDL::Rect');

	return $self->{rect} = $rect;
}


sub clip {
	my ($self, $clip) = @_;

	# short-circuit
	return $self->{clip} unless $clip;

	Carp::croak 'clip accepts only SDL::Rect objects'
	unless $clip->isa('SDL::Rect');

	return $self->{clip} = $clip;
}


sub w {
	my $self = shift;

	return 0 unless my $surface = $self->surface;
	return $surface->w
}

sub h {
	my $self = shift;
	return 0 unless my $surface = $self->surface;
	return $surface->h
}

sub x {
	my ($self, $x) = @_;

	if ($x) {
		$self->rect->x($x);
	}

	return $self->rect->x;
}

sub y {
	my ($self, $y) = @_;

	if ($y) {
		$self->rect->y($y);
	}

	return $self->rect->y;
}

sub draw {
	my ($self, $surface) = @_;

	Carp::croak 'destination must be a SDL::Surface'
	unless ref $surface and $surface->isa('SDL::Surface');


	SDL::Video::blit_surface( $self->surface,
		$self->clip,
		$surface,
		$self->rect
	);
	return $self;
}

sub alpha_key {
	my ($self, $color) = @_;

	Carp::croak 'color must be a SDL::Color'
	unless ref $color and $color->isa('SDL::Color');

	Carp::croak 'SDL::Video::set_video_mode must be called first'
	unless ref SDL::Video::get_video_surface();

	my $surf = $self->surface();

	$self->{surface} =  SDL::Video::display_format($surf);

	SDL::Video::set_color_key($self->surface, SDL_SRCCOLORKEY, $color);


	return $self;
}

1;
__END__
=head1 NAME

SDLx::Widget::Sprite - interact with images quick and easily in SDL

=head1 SYNOPSIS

    use SDLx::Widget::Sprite;

    my $sprite = SDLx::Widget::Sprite->new;

    # loads image file into a SDL::Surface and
    # automatically sets a SDL::Rect inside with
    # that image's dimensions.
    $sprite->load('hero.png');

    # set sprite image transparency
    $sprite->alpha_key( $color );
    $sprite->alpha(0.5);

    # you can set and check the sprite position anytime
    say $sprite->x;   # rect->x shortcut accessor
    $sprite->y(30);   # rect->y shortcut accessor

    # read-only surface dimensions
    $sprite->w;   # width
    $sprite->h;   # height

    # you can also fetch the full rect
    # (think destination coordinates for ->draw)
    my $rect = $sprite->rect;

    # you can get the surface object too if you need it
    my $surface = $sprite->surface;

    # rotation() NOT YET IMPLEMENTED
    # if your SDL has gfx, rotation is also straightforward:
    $sprite->rotation( $rads );

    # add() / remove() NOT YET IMPLEMENTED
    # you can also attach other sprites to it
    $sprite->add( armor => $other_sprite );
    $sprite->remove('armor');

    # blits $sprite (and attached sprites) into $screen,
    # in the (x,y) coordinates of the sprite
    $sprite->draw($screen);

    # if you need to clip the original image/surface
    # before drawing it
    $sprite->clip->x(10);
    $sprite->clip->y(3);
    $sprite->clip->w(5);
    $sprite->clip->h(5);

    # ...or all at once:
    $sprite->clip($x,$y,$w,$h);

    # spawning can include almost all of the above:
    my $sprite = SDLx::Widget::Sprite->new(
		      image   => 'hero.png',   # or surface => SDL::Surface
		      rect    => SDL::Rect,    # or x => $x, y => $y
		      clip    => SDL::Rect,
		      alpha_key => SDL::Color, # or [$r, $g, $b]
		      alpha     => 1,
		      rotation  => 3.14, # rads
		 );


=head1 DESCRIPTION

SDLx::Widget::Sprite is a SDL::Surface on steroids! It let's you quickly
load, setup and interact with images in your SDL application, abstracting
all the drudge code and letting you concentrate on your app's logic instead.

This module automatically creates and holds SDL::Rect objects for the source
and destination surfaces, and provides several surface manipulation options
like alpha blending and rotation.

=head1 WARNING! VOLATILE CODE AHEAD

This is a new module and the API is subject to change without notice.
If you care, please join the discussion on the #sdl IRC channel in
I<irc.perl.org>. All thoughts on further improving the API are welcome.

You have been warned :)

=head1 METHODS

=head2 new

=head2 new( %options )

Creates a new SDLx::Widget::Sprite object. No option is mandatory.
Available options are:

=over 4

=item * image => $filename

Uses $filename as source image for the Sprite's surface. See suported
formats in L<< SDL::Image >>. This option B<cannot> be used together
with the 'surface' option (see below).

=item * surface => SDL::Surface

Uses the provided L<< SDL::Surface >> object as source surface for this
sprite, instead of creating one automatically. This option B<cannot> be
used together with the 'image' option (see above).

=item * clip => SDL::Rect

Uses the provided L<< SDL::Rect >> object as clipping rect for the source
surface. This means the object will only blit that particular area from
the surface.

=item * rect => SDL::Rect

Uses the provided L<< SDL::Rect >> object as destination coordinates to
whatever surface you call draw() on. You B<cannot> use this option together
with 'x' and 'y' (see below)

=item * x => $x

Uses $x as the x-axis (left-to-right, 0 being leftmost) positioning of
the Sprite into the destination you call draw() upon. This option B<cannot>
be used together with 'rect' (see above).

=item * y => $y

Uses $y as the y-axis (top-to-bottom, 0 being topmost) positioning of
the Sprite into the destination you call draw() upon. This option B<cannot>
be used together with 'rect' (see above).

=item * rotation => $rads

NOT YET IMPLEMENTED

Uses $rads as the angle to rotate the surface to, in radians
(0..2*PI, remember? :). This option is only available if your compiled SDL
library has support for GFX (see L<< Alien::SDL >> for details).

=item * alpha_key => SDL::Color

=item * alpha_key => [ $r, $g, $b ]

NOT YET IMPLEMENTED

Uses the provided L<< SDL::Color >> object (or an array reference with red,
green and blue values) as the color to be turned into transparent
(see 'alpha' below).

=item * alpha => $percentage

NOT YET IMPLEMENTED

Uses $percentage as how much transparency to add to the surface. If you use
this, it is mandatory that you also provide the alpha_key (see above).

=back

=head2 load( $filename )

Loads the given image file into the object's internal surface. A new surface
is B<always> created, so whatever you had on the previous surface will be
lost. Croaks on errors such as no support built for the image or a file
reading error (the error message is SDL::get_error and should give more
details).

Returns the own Sprite object, to allow method chaining.

=head2 surface()

=head2 surface( SDL::Surface )

Returns the object's internal surface, or undef if there is none.

If you pass a SDL::Surface to it, it will overwrite the original surface
with it, while returning the B<old> (previous) surface. Note that, as such,
it will return C<undef> if you use it without having previously loaded
either an image or a previous surface. It will croak if you pass anything
that's not an SDL::Surface object (or SDL::Surface subclassed objects).

=head2 rect()

=head2 rect( SDL::Rect )

Returns the destination L<< SDL::Rect >> object used when you call draw().

If you haven't explicitly set it, it will be a SDL::Rect with the same
dimensions as the object's internal surface. If no surface was set yet,
it will be an empty SDL::Rect (dimensions 0,0,0,0).

If you pass it a L<< SDL::Rect >> object, it will set rect() to that object
before returning, but it will B<overwrite> any width and height values, as
those are read only and set to the size of the underlying surface.

If you want to clip the source surface, set clip() instead.

=head2 clip()

=head2 clip( SDL::Rect )

Returns the source L<< SDL::Rect >> object used when you call draw().

You can use this method to choose only a small subset of the object's
internal surface to be used on calls to draw().

If you haven't explicitly set it, it will be a SDL::Rect with the same
dimensions as the object's internal surface. If no surface was set yet,
it will be an empty SDL::Rect (dimensions 0,0,0,0).

If you pass it a L<< SDL::Rect >> object, it will set clip() to that object
before returning.

=head2 x()

=head2 x( $int )

Gets/sets the x-axis (left-to-right, 0 being leftmost) positioning of
the Sprite into the destination you call draw() upon.

It is a shortcut to C<< $sprite->rect->x >>.


=head2 y()

=head2 y( $int )

Gets/sets the y-axis (top-to-bottom, 0 being topmost) positioning of
the Sprite into the destination you call draw() upon.

It is a shortcut to C<< $sprite->rect->y >>.


=head2 w()

Returns the Sprite surface's width. This method is read-only.

It is a shortcut to C<< $sprite->surface->w >>.


=head2 h()

Returns the Sprite surface's height. This method is read-only.

It is a shortcut to C<< $sprite->surface->h >>.


=head2 draw( SDL::Surface )

Draws the Sprite on the provided SDL::Surface object - usually the screen -
using the blit_surface SDL function, using the source rect from clip() and the
destination rect (position) from rect().

Returns the own Sprite object, to allow method chaining.

=head1 AUTHORS

Dustin Mays, C<< <dork.fish.wat@gmail.com> >>

Breno G. de Oliveira, C<< <garu at cpan.org> >>

Kartik thakore C<< <kthakore at cpan.org> >>

=head1 SEE ALSO

L<< SDL::Surface >>, L<< SDL >>

