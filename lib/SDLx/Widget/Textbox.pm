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
    my $class         = shift;
    my %params        = @_;
    my $self          = \%params;
       $self->{value} = '';
       $self          = bless $self, $class;
       $self->{app}->add_event_handler( sub{$self->event_handler(@_)} );
       SDL::Events::enable_unicode(1);
    return $self;
}

my $textbox = SDLx::Controller::Interface->new( x=> 0, y => 0, v_x => 1, v_y=> 0 );
$textbox->set_acceleration ( 
    sub {
        my ($time, $current_state) = @_; 
        return ( 0, 0, 0 );
    }
);
my $focus  = 0;
my $cursor = 0;

my $textbox_render = sub {
    my ($state, $self) = @_;
    $self->{app}->draw_rect( [$self->{x}, $self->{y}, $self->{w}, $self->{h}], [255,255,255,255] );
    $self->{app}->draw_gfx_text( [$self->{x} + 3, $self->{y} + 7], 0x000000FF, $self->{value} );
    if(($state->x / 3) & 1) {
        my $x = $self->{x} + 2 + $cursor * 8;
        $self->{app}->draw_line( [$x, $self->{y} + 2], [$x, $self->{y} + $self->{h} - 4], 0x000000FF, 0 );
    }
    $self->{app}->update;
};

sub show {
    my $self = shift;
    $textbox->attach( $self->{app}, $textbox_render, $self );
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
            if(SDL_BUTTON_LEFT == $event->button_button && !$focus) {
                warn "on_focus";
                $focus = 1;
            }
        }
    }
    elsif(SDL_MOUSEBUTTONUP == $event->type) {
        if($self->{x} <= $event->button_x && $event->button_x < $self->{x} + $self->{w}
        && $self->{y} <= $event->button_y && $event->button_y < $self->{y} + $self->{h}) {
            warn "on_mouseup";
        }
        else {
            if(SDL_BUTTON_LEFT == $event->button_button && $focus) {
                warn "on_blur";
                $focus = 0;
            }
        }
    }
    elsif(SDL_KEYDOWN == $event->type) {
        if($focus) {
            my $key = SDL::Events::get_key_name($event->key_sym);
            warn "on_keydown: $key";
            if($key eq 'left') {
                $cursor-- if $cursor > 0;
                warn "moving left";
            }
            elsif($key eq 'right') {
                $cursor++ if $cursor < length($self->{value});
                warn "moving right";
            }
            elsif($key eq 'delete') {
                if($cursor < length($self->{value})) {
                    $self->{value} = substr($self->{value}, 0, $cursor)
                                   . substr($self->{value}, $cursor + 1);
                }
            }
            elsif($key eq 'backspace') {
                if($cursor > 0) {
                    $self->{value} = substr($self->{value}, 0, length($self->{value}) - 1);
                    $cursor--;
                }
            }
            elsif($event->key_unicode) {
                $self->{value} .= chr($event->key_unicode);
                $cursor++;
            }
        }
    }
    elsif(SDL_KEYUP == $event->type) {
        if($focus) {
            warn "on_keyup";
        }
    }
}

1;
