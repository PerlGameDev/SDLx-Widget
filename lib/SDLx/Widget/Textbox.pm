#!/usr/bin/perl

package SDLx::Widget::Textbox;

use SDL;
use SDLx::App;
use SDLx::Controller::Interface;
use Data::Dumper;
use SDL::Event;
use SDL::Events;
use SDL::TTF;
use Encode;

sub new {
    my $class          = shift;
    my %params         = @_;
    my $self           = \%params;
    $self->{value}     = '';
    $self->{focus}     = 0;
    $self->{cursor}    = 0;
    $self->{textbox}   = SDLx::Controller::Interface->new( x=> 0, y => 0, v_x => 1, v_y=> 0 );
    $self->{textbox}->set_acceleration( sub { return ( 0, 0, 0 ); } );
    $self->{textbox_render} = sub {
        my ($state, $_self) = @_;
        $_self->{app}->draw_rect( [$_self->{x}, $_self->{y}, $_self->{w}, $_self->{h}], [255,255,255,255] );
        if($_self->{name} && !length($_self->{value}) && !$_self->{focus}) {
            $_self->{app}->draw_gfx_text( [$_self->{x} + 3, $_self->{y} + 7], 0xAAAAAAFF, $_self->{name} );
        }
        elsif($_self->{password}) {
            $_self->{app}->draw_gfx_text( [$_self->{x} + 3, $_self->{y} + 7], 0x000000FF, '*' x length($_self->{value}) );
        }
        else {
            $_self->{app}->draw_gfx_text( [$_self->{x} + 3, $_self->{y} + 7], 0x000000FF, $_self->{value} );
        }
        if($_self->{focus} && ($state->x / 3) & 1) {
            my $x = $_self->{x} + 2 + $_self->{cursor} * 8;
            $_self->{app}->draw_line( [$x, $_self->{y} + 2], [$x, $_self->{y} + $_self->{h} - 4], 0x000000FF, 0 );
        }
        $_self->{app}->update;
    };

    $self           = bless $self, $class;
    $self->{app}->add_event_handler( sub{$self->event_handler(@_)} );
    SDL::Events::enable_unicode(1);

    return $self;
}


sub show {
    my $self = shift;
    $self->{textbox}->attach( $self->{app}, $self->{textbox_render}, $self );
}

sub event_handler {
    my ($self, $event, $app) = @_;
    
    if(SDL_MOUSEMOTION == $event->type) {
        if($self->{x} <= $event->motion_x && $event->motion_x < $self->{x} + $self->{w}
        && $self->{y} <= $event->motion_y && $event->motion_y < $self->{y} + $self->{h}) {
            warn "on_mousemotion";
        }
    }
    elsif(SDL_MOUSEBUTTONDOWN == $event->type) {
        if($self->{x} <= $event->button_x && $event->button_x < $self->{x} + $self->{w}
        && $self->{y} <= $event->button_y && $event->button_y < $self->{y} + $self->{h}) {
            warn "on_mousedown";
            if(SDL_BUTTON_LEFT == $event->button_button && !$self->{focus}) {
                warn "on_focus";
                $self->{focus} = 1;
            }
        }
    }
    elsif(SDL_MOUSEBUTTONUP == $event->type) {
        if($self->{x} <= $event->button_x && $event->button_x < $self->{x} + $self->{w}
        && $self->{y} <= $event->button_y && $event->button_y < $self->{y} + $self->{h}) {
            warn "on_mouseup";
        }
        else {
            if(SDL_BUTTON_LEFT == $event->button_button && $self->{focus}) {
                warn "on_blur";
                $self->{focus} = 0;
            }
        }
    }
    elsif(SDL_KEYDOWN == $event->type) {
        if($self->{focus}) {
            my $key = SDL::Events::get_key_name($event->key_sym);
            warn "on_keydown: $key";
            if($key eq 'left') {
                $self->{cursor}-- if $self->{cursor} > 0;
                warn "moving left";
            }
            elsif($key eq 'right') {
                $self->{cursor}++ if $self->{cursor} < length($self->{value});
                warn "moving right";
            }
            elsif($key eq 'delete') {
                if($self->{cursor} < length($self->{value})) {
                    $self->{value} = substr($self->{value}, 0, $self->{cursor})
                                   . substr($self->{value}, $self->{cursor} + 1);
                }
            }
            elsif($key eq 'backspace') {
                if($self->{cursor} > 0) {
                    $self->{value} = substr($self->{value}, 0, length($self->{value}) - 1);
                    $self->{cursor}--;
                }
            }
            elsif($event->key_unicode && length($key) == 1) {
                $self->{value} = substr($self->{value}, 0, $self->{cursor})
                               . chr($event->key_unicode)
                               . substr($self->{value}, $self->{cursor});
                $self->{cursor}++;
            }
        }
    }
    elsif(SDL_KEYUP == $event->type) {
        if($self->{focus}) {
            warn "on_keyup";
        }
    }
}

1;
