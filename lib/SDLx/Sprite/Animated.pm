#Animation notes

#An animation is a series of frames that are played in order, and which have a play time
#and can set at which index to loop the animation from, if it is undesirable to loop from the beginning.
#An animation contains at least one named cycle of frames. These cycles allow for animations to be in different states,
#such as walking in a certain direction.

package SDLx::Widget::Animation;

use SDL;
use SDL::Surface;
use SDL::Rect;
use SDLx::Widget::Sprite;

our @ISA=('SDLx::Widget::Drawable');

sub new {
    my $self = {};
    my $class = shift;
    
    my $speed = shift;
    my $loop_index = shift;
    
    my %cycles = shift;
    
    bless $self, $class;
}

sub play {
    
}

sub pause {
    
}

sub stop {
    
}

sub backward {
    
}

sub forward {
    
}

sub draw {
    
}

sub loop_index {
    
}

sub speed {
    
}

sub current_cycle {
    
}

sub current_frame {
    
}

1;