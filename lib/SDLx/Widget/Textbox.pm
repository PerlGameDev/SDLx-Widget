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

my $textbox = SDLx::Controller::Interface->new( x=> 0, y => 0, v_x => 0, v_y=> 0 );
$textbox->set_acceleration ( 
      sub {
         my ($time, $current_state) = @_; 

         return ( 0.1, 0, 0 );
      }
  );
my $textbox_render = sub {
    my ($state, $self) = @_;
    $self->{app}->draw_rect( [$self->{x}, $self->{y}, $self->{w}, $self->{h}], [255,255,255,255] );
    $self->{app}->draw_gfx_text( [$self->{x} + 3, $self->{y} + 7], 0x000000FF, $self->{value} );
    $self->{app}->update;
};

sub show {
    my $self = shift;
    $textbox->attach( $self->{app}, $textbox_render, $self );
}

my $focus = 0;
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
            warn "on_keydown";
            if($event->key_unicode) {
                $self->{value} .= chr($event->key_unicode);
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
