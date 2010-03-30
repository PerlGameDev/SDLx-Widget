=head1 NAME
    
SDLx::Widget::Drawable - abstract base class for drawable things

=head1 DESCRIPTION
    
This module is an abstract base class for drawable things (sprites, animations, etc). It is not meant to be used directly. Subclass it instead.
    
=head1 METHODS
    
This module is not used directly. Instead, the following documentation describes the intended purposes of the methods.

=over 12
    
=item C<new>

Return a new drawable object
    
=item C<draw>

Draw the object
    
=item C<rect>

Accessor. Set or return the drawable's rect. For an image-type object, the rect is the area of the image to copy to the screen. For an entity-type object, the rect is the (x, y) coordinates, width, and height of the object.
    
=item C<x>

Accessor. Returns the x value of the object. See L<rect> for context.
    
=item C<y>

Accessor. Returns the y value of the object. See L<rect> for context.
        
=item C<width>

Accessor. Returns the width of the object. See L<rect> for context.
    
=item C<height>

Accessor. Returns the height of the object. See L<rect> for context.

=back

=head1 AUTHOR

Dustin Mays <dork.fish.wat@gmail.com>

=head1 SEE ALSO
    
L<SDL>

=cut
package SDLx::Widget::Drawable;

sub new {
    die "Dying: SDLx::Widget::Drawable is an abstract base class, it is not meant to be instantiated. Subclass it instead.";
}

sub draw {
    my $mypkg = caller;
    warn "Use of undefined abstract method SDLx::Widget::Drawable->draw() by package $mypkg";
}

sub rect {
    my $mypkg = caller;
    warn "Use of undefined abstract method SDLx::Widget::Drawable->rect() by package $mypkg";
}

sub width {
    my $mypkg = caller;
    warn "Use of undefined abstract method SDLx::Widget::Drawable->width() by package $mypkg";
}

sub height {
    my $mypkg = caller;
    warn "Use of undefined abstract method SDLx::Widget::Drawable->height() by package $mypkg";
}

sub x {
    my $mypkg = caller;
    warn "Use of undefined abstract method SDLx::Widget::Drawable->x() by package $mypkg";
}

sub y {
    my $mypkg = caller;
    warn "Use of undefined abstract method SDLx::Widget::Drawable->y() by package $mypkg";
}

1;