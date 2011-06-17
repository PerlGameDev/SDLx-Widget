package SDLx::Widget::Menu;
use SDL;
use SDL::Audio;
use SDL::Video;
use SDLx::Text;
use SDL::Color;
use SDL::Rect;
use SDL::Event;
use SDL::Events;
use Carp ();
use Mouse;

# TODO: add default values
has 'font'         => ( is => 'ro', isa => 'Str' );
has 'font_color'   => ( is => 'ro', isa => 'ArrayRef', 
                        default => sub { [ 255, 255, 255] }
                      );

has 'topleft' => ( is => 'ro', isa => 'ArrayRef', default => sub { [0,0] } );

has 'select_color' => ( is => 'ro', isa => 'ArrayRef', 
                        default => sub { [ 255, 0, 0 ] }
                      );

has 'font_size'    => ( is => 'ro', isa => 'Int', default => 24 );
has 'current'      => ( is => 'rw', isa => 'Int', default => 0 );

# TODO implement those
has 'mouse'        => ( is => 'ro', isa => 'Bool');
has 'change_sound' => ( is => 'ro', isa => 'Str' );
has 'select_sound' => ( is => 'ro', isa => 'Str' );

# private
has 'has_audio' => ( is => 'rw', isa => 'Bool', default => 0,
                     writer => '_has_audio' );

# internal
has '_items' => (is => 'rw', isa => 'ArrayRef', default => sub {[]} );
has '_font'  => (is => 'rw', isa => 'SDLx::Text' );
has '_change_sound' => (is => 'rw', isa => 'SDL::Mixer::MixChunk' );
has '_select_sound' => (is => 'rw', isa => 'SDL::Mixer::MixChunk' );

sub BUILD {
    my $self = shift;

    $self->_build_font;
    $self->_build_sound;
}

sub _build_font {
    my $self = shift;

    my $font = SDLx::Text->new( size => $self->font_size );
    $font->font( $self->font ) if $self->font;

    $self->_font( $font );
}

sub _build_sound {
    my $self = shift;

    if ($self->select_sound or $self->change_sound ) {
        require SDL::Mixer;
        require SDL::Mixer::Music;
        require SDL::Mixer::Channels;
        require SDL::Mixer::Samples;
        require SDL::Mixer::MixChunk;

        # initializes sound if it's not already
        my ($status) = @{ SDL::Mixer::query_spec() };
        if ($status != 1) {
            SDL::Mixer::open_audio( 44100, AUDIO_S16, 2, 4096 );
            ($status) = @{ SDL::Mixer::query_spec() };
        }

        # load sounds if audio is (or could be) initialized
        if ( $status == 1 ) {
            $self->_has_audio(1);
            if ($self->select_sound) {
                my $sound = SDL::Mixer::Samples::load_WAV($self->select_sound);
                $self->_select_sound( $sound );
            }
            if ($self->change_sound) {
                my $sound = SDL::Mixer::Samples::load_WAV($self->change_sound);
                $self->_change_sound( $sound );
            }
        }
    }
}

# this is the method used to indicate
# all menu items and their callbacks
sub items {
    my ($self, @items) = @_;

    while( my ($name, $val) = splice @items, 0, 2 ) {
        push @{$self->_items}, { name => $name, trigger => $val };
    }

    return $self;
}

sub event_hook {
    my ($self, $event) = @_;
    # TODO: add mouse hooks
    if ( $event->type == SDL_KEYDOWN ) {
        my $key = $event->key_sym;

        if ($key == SDLK_DOWN) {
            $self->current( ($self->current + 1) % @{$self->_items} );
            $self->_play($self->_change_sound);
        }
        elsif ($key == SDLK_UP) {
            $self->current( ($self->current - 1) % @{$self->_items} );
            $self->_play($self->_change_sound);
        }
        elsif ($key == SDLK_RETURN or $key == SDLK_KP_ENTER ) {
            $self->_play($self->_select_sound);
            return $self->_items->[$self->current]->{trigger}->();
        }
    }

    return 1;
}

sub _play {
    my ($self, $sound) = @_;
    return unless $self->has_audio;

    my $channel = SDL::Mixer::Channels::play_channel(-1, $sound, 0 );
    if ( $channel ) {
        SDL::Mixer::Channels::volume( $channel, 10 );
    }
}


# NOTE: the update() call is here just as an example.
# SDLx::* calls should likely implement those whenever
# they need updating in each delta t.
sub update {}


sub render {
    my ($self, $screen) = @_;

    # TODO: parametrize line spacing (height)
    # and other constants used here
    my ($top, $left) = @{$self->topleft};
    my $font = $self->_font;

    foreach my $item ( @{$self->_items} ) {
#        print STDERR 'it: ' . $item->{name} . ', s: '. $self->_items->[$self->current]->{name} . ', c: ' . $self->current . $/;
        my $color = $item->{name} eq $self->_items->[$self->current]->{name}
                  ? $self->select_color : $self->font_color
                  ;

        $font->color( $color );
        $font->write_xy( $screen, $left, $top, $item->{'name'} );
        $top += 50;
    }
}

1;
__END__
=head1 NAME

SDLx::Widget::Menu - create menus for your SDL apps easily

=head1 SYNOPSIS

Create a simple SDL menu for your game/app:

    my $menu = SDLx::Widget::Menu->new->items(
                   'New Game' => \&play,
                   'Options'  => \&settings,
                   'Quit'     => \&quit,
               );


Or customize it at will:

    my $menu = SDLx::Widget::Menu->new(
                   topleft      => [100, 120],
                   font         => 'game/data/menu_font.ttf',
                   font_size    => 20,
                   font_color   => [255, 0, 0], # RGB (in this case, 'red')
                   select_color => [0, 255, 0],
                   change_sound => 'game/data/menu_select.ogg',
               )->items(
                   'New Game' => \&play,
                   'Options'  => \&settings,
                   'Quit'     => \&quit,
               );

After that, all you have to do is make sure your menu object's hooks are
called at the right time in your game loop:

    # in the event loop
    $menu->event_hook( $event );  # $event is a SDL::Event

    # in the rendering loop
    $menu->render( $screen );     # $screen is a SDL::Surface


=head1 DESCRIPTION

Main menus are a very common thing in games. They let the player choose
between a new game, loading games, setting up controls, among lots of other
stuff. This menu widget is meant to aid developers create menus quickly and easily, so they can concentrate in their game's logic rather than on such a
repetitive task. Simple menus, easy. Complex menus, possible!


=head1 WARNING! VOLATILE CODE AHEAD

This is a new module and the API is subject to change without notice.
If you care, please join the discussion on the #sdl IRC channel in
I<irc.perl.org>. All thoughts on further improving the API are welcome.

You have been warned :)

=head1 METHODS

=head2 new

=head2 new( %options )

Creates a new SDLx::Widget::Menu object. No option is mandatory.
Available options are:

=over 4

=item * topleft => [ $top, $left ]

Determines topmost and leftmost positions for the menu.

=item * font => $filename

File name of the font used to render menu text.

=item * font_size => $size

Size of the font used to render menu text.

=item * font_color => [ $red, $green, $blue ]

RGB value to set the font color.

=item * select_color => [ $red, $green, $blue ]

RGB value for the font color of the select item

=item * change_sound => $filename

File name of the sound to play when the selected item changes

=back

=head2 items( 'Item 1' => \&sub1, 'Item 2' => \&sub2, ... )

Creates menu items, setting up callbacks for each item.

=head1 BUGS AND LIMITATIONS

=over 4

=item * Mouse doesn't work (yet)

=item * Doesn't let you setup other keys to change current selection (yet)

=item * Doesn't let you handle menu changes yourself (yet)

=back

=head1 AUTHORS

Breno G. de Oliveira, C<< <garu at cpan.org> >>

Kartik thakore C<< <kthakore at cpan.org> >>


=head1 SEE ALSO

L<< SDL >>, L<< SDLx::App >>, L<< SDLx::Controller >>

