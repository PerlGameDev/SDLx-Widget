=head1 NAME

SDLx::Widget::Sprite - a drawable image

=head1 SYNOPSIS

    use SDL;
    use SDL::Image;
    use SDL::Rect;
    use SDLx::Widget::Sprite;
    
    ...
    
    my $surface = SDL::Image::load('myimage.png');
    my $clip_rect = SDL::Rect->new(0,0,32,32);
    my $sprite = SDLx::Widget::Sprite->new($surface, $clip_rect);
    
    my $pos = SDL::Rect->new(67, 89, 32, 32);
    
    $sprite->x;                    # returns x value of sprite
    
    $sprite->x(64);                # set x clipping location of sprite
    
    $sprite->draw($screen, $pos)   # draw the sprite to a surface,
                                   # in this case $screen, at the
                                   # screen coordinates indicated by
                                   # $pos
    
=head1 DESCRIPTION

SDLx::Widget::Sprite is essentially an SDL::Surface with an added draw() method,
and accessor methods that allow you to define the clipping regions of the Sprite
without having to create an SDL::Rect every time you want to change the clipping
region.

=head1 METHODS

=over 12

=item C<x>

Accessor. Sets the left-most value of the clipping region

=item C<y>

Accessor. Sets the top-most value of the clipping region

=item C<w>

Accessor. Sets the width of the clipping region

=item C<h>

Accessor. Sets the height of the clipping region

=item C<draw>

Takes two arguments, an SDL::Surface and an SDL::Rect. Draws the Sprite on the SDL::Surface at the location designated by the SDL::Rect.

=back

=head1 AUTHOR

Dustin Mays <dork.fish.wat@gmail.com>

=head1 SEE ALSO

SDL::Surface, SDL_Perl

=cut

package SDLx::Widget::Sprite;

use SDL;
use SDL::Surface;
use SDL::Rect;
use SDL::Video;

our @ISA = qw(SDLx::Widget::Drawable);

sub new {
    my $self = {};
    my $class = shift;
    
    $self->{surface} = \shift;
    $self->{rect} = \shift;

    bless $self, $class;
    return $self;
}

sub w {
    my $self = shift;
    if (@_ == 1 ) {
        $self->{rect}->w = shift;
    }
    elsif ( @_ > 1 ) {
        die "SDLx::Widget::Sprite->w() only accepts one argument.";
    }
    return $self->{rect}->w;
}

sub h {
    my $self = shift;
    if ( @_ == 1 ) {
        $self->{rect}->h = shift;
    }
    elsif ( @_ > 1 ) {
        die "SDLx::Widget::Sprite->h() only accepts one argument.";
    }
    return $self->{rect}->h;
}

sub x {
    my $self = shift;
    if ( @_ == 1 ) {
        $self->{rect}->x = shift;
    }
    elsif ( @_ > 1 ) {
        die "SDLx::Widget::Sprite->x() only accepts one argument.";
    }
    return $self->{rect}->x;
}

sub y {
    my $self = shift;
    if ( @_ == 1 ) {
        $self->{rect}->y = shift;
    }
    elsif ( @_ > 1 ) {
        die "SDLx::Widget::Sprite->y() only accepts one argument.";
    }
    return $self->{rect}->y;
}

sub draw {
    my $self = shift;
    if (@_ == 2) {
        my ($dest_surf, $dest_rect) = @_;
        SDL::Video::blit_surface($self->{surface}, $self->{rect}, $dest_surf, $dest_rect);   
    }
    else {
        die "SDLx::Widget::Sprite->draw() only accepts two arguments."
    }
}

1;