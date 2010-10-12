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
use Clipboard;

sub new {
    my $class          = shift;
    my %params         = @_;
    my $self           = \%params;
    $self->{value}     = '';
    $self->{focus}     = 0;
    $self->{cursor}    = 0;
    $self->{mousedown} = 0;
    $self->{textbox}   = SDLx::Controller::Interface->new( x=> 0, y => 0, v_x => 1, v_y=> 0 );
    $self->{textbox}->set_acceleration( sub { return ( 0, 0, 0 ); } );
    $self->{textbox_render} = sub {
        my ($state, $_self) = @_;
        $_self->{app}->draw_rect( [$_self->{x}, $_self->{y}, $_self->{w}, $_self->{h}], [255,255,255,255] );
        
        # calculation the text-highlight-box on mouse movement
        if($self->{mousedown} && $_self->{value}) {
            my ($mask, $mouse_x)      = @{ SDL::Events::get_mouse_state( ) };
            my $text_end              = $_self->{x} + 2 + length($_self->{value}) * 8;
            $mouse_x                  = $_self->{x} + $_self->{w} if $mouse_x > $_self->{x} + $_self->{w};
            $mouse_x                  = $_self->{x}               if $mouse_x < $_self->{x};
            $mouse_x                  = $text_end                 if $mouse_x > $text_end;
            $_self->{mousedown}       = $text_end                 if $_self->{mousedown} > $text_end;
            $_self->{selection_start} = int(($_self->{mousedown} - 2 - $_self->{x}) / 8 + 0.5);
            $_self->{selection_stop}  = int(($mouse_x            - 2 - $_self->{x}) / 8 + 0.5);
        }
        
        # drawing the text-highlight-box
        if(defined $_self->{selection_start} && defined $_self->{selection_stop} && $_self->{selection_start} != $_self->{selection_stop}) {
            ($_self->{selection_start}, $_self->{selection_stop}) = sort {$a <=> $b} ($_self->{selection_start}, $_self->{selection_stop});
            my $width = ($_self->{selection_stop} - $_self->{selection_start}) * 8;
            my $left  = $_self->{selection_start} * 8 + 2 + $_self->{x};
            $_self->{app}->draw_rect( [$left, $_self->{y} + 2, $width, $_self->{h} - 4], [128,128,255,255] );
        }
        
        # drawing the name of the textbox in grey letters
        if($_self->{name} && !length($_self->{value}) && !$_self->{focus}) {
            $_self->{app}->draw_gfx_text( [$_self->{x} + 3, $_self->{y} + 7], 0xAAAAAAFF, $_self->{name} );
        }
        # drawing asterisk for password fields
        elsif($_self->{password}) {
            $_self->{app}->draw_gfx_text( [$_self->{x} + 3, $_self->{y} + 7], 0x000000FF, '*' x length($_self->{value}) );
        }
        # drawing the value
        else {
            $_self->{app}->draw_gfx_text( [$_self->{x} + 3, $_self->{y} + 7], 0x000000FF, $_self->{value} );
        }
        
        # drawing the blinking cursor
        if($_self->{focus} && ($state->x / 3) & 1
        && (!defined $_self->{selection_start} || !defined $_self->{selection_stop} || $_self->{selection_start} == $_self->{selection_stop})) {
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
        if($self->{focus} && $self->{mousedown}) {
            warn "on_drag";
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
            $self->{mousedown} = $event->button_x;
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
                $self->{selection_start} = undef;
                $self->{selection_stop}  = undef;
                $self->{focus}           = 0;
            }
        }
        $self->{mousedown} = 0;
    }
    elsif(SDL_KEYDOWN == $event->type) {
        if($self->{focus}) {
            my $key = SDL::Events::get_key_name($event->key_sym);
            my $mod = SDL::Events::get_mod_state();

            warn 'on_keydown' . $key;
            
            $key = ' ' if $key eq 'space';
            
            if($mod & KMOD_CTRL) {
                warn 'on_shiftdown';
                if($key eq 'v') {
                    $self->{value}   = substr($self->{value}, 0, $self->{cursor})
                                     . Clipboard->paste
                                     . substr($self->{value}, $self->{cursor});
                    $self->{cursor} += length(Clipboard->paste);
                }
                elsif(defined $self->{selection_start} && defined $self->{selection_stop}) {
                    ($_self->{selection_start}, $_self->{selection_stop}) = sort {$a <=> $b} ($_self->{selection_start}, $_self->{selection_stop});
                    if($key eq 'c') {
                        Clipboard->copy(substr($self->{value}, $self->{selection_start}, $self->{selection_stop} - $self->{selection_start}));
                    }
                    elsif($key eq 'x') {
                        Clipboard->copy(substr($self->{value}, $self->{selection_start}, $self->{selection_stop} - $self->{selection_start}));
                        $self->{value} = substr($self->{value}, 0, $self->{selection_start})
                                       . substr($self->{value}, $self->{selection_stop});
                        $self->{selection_start} = undef;
                        $self->{selection_stop}  = undef;
                    }
                }
            }
            elsif($key =~ /\bshift$/) {
                warn 'on_shiftdown';
                $self->{shiftdown} = $self->{cursor};
            }
            elsif($key eq 'left') {
                $self->{cursor}-- if $self->{cursor} > 0;
                if(defined $self->{shiftdown}) {
                    $self->{selection_start} = $self->{cursor};
                    $self->{selection_stop}  = $self->{shiftdown};
                }
                else {
                    $self->{selection_start} = undef;
                    $self->{selection_stop}  = undef;
                }
            }
            elsif($key eq 'right') {
                $self->{cursor}++ if $self->{cursor} < length($self->{value});
                if(defined $self->{shiftdown}) {
                    $self->{selection_start} = $self->{shiftdown};
                    $self->{selection_stop}  = $self->{cursor};
                }
                else {
                    $self->{selection_start} = undef;
                    $self->{selection_stop}  = undef;
                }
            }
            elsif($key eq 'home') {
                $self->{cursor}          = 0;
                $self->{selection_start} = undef;
                $self->{selection_stop}  = undef;
            }
            elsif($key eq 'end') {
                $self->{cursor}          = length($self->{value});
                $self->{selection_start} = undef;
                $self->{selection_stop}  = undef;
            }
            elsif($key eq 'delete') {
                if(defined $self->{selection_start} && defined $self->{selection_stop} && $self->{selection_start} != $self->{selection_stop}) {
                    $self->{value} = substr($self->{value}, 0, $self->{selection_start})
                                   . substr($self->{value}, $self->{selection_stop});
                    $self->{cursor} = $self->{selection_start};
                    $self->{selection_start} = undef;
                    $self->{selection_stop}  = undef;
                }
                elsif($self->{cursor} < length($self->{value})) {
                    $self->{value} = substr($self->{value}, 0, $self->{cursor})
                                   . substr($self->{value}, $self->{cursor} + 1);
                }
            }
            elsif($key eq 'backspace') {
                if(defined $self->{selection_start} && defined $self->{selection_stop} && $self->{selection_start} != $self->{selection_stop}) {
                    $self->{value} = substr($self->{value}, 0, $self->{selection_start})
                                   . substr($self->{value}, $self->{selection_stop});
                    $self->{cursor} = $self->{selection_start};
                    $self->{selection_start} = undef;
                    $self->{selection_stop}  = undef;
                }
                elsif($self->{cursor} > 0) {
                    $self->{value} = substr($self->{value}, 0, $self->{cursor} - 1)
                                   . substr($self->{value}, $self->{cursor});
                    $self->{cursor}--;
                }
            }
            elsif($event->key_unicode && length($key) == 1) {
                if(defined $self->{selection_start} && defined $self->{selection_stop} && $self->{selection_start} != $self->{selection_stop}) {
                    $self->{value} = substr($self->{value}, 0, $self->{selection_start})
                                   . chr($event->key_unicode)
                                   . substr($self->{value}, $self->{selection_stop});
                    $self->{cursor} = $self->{selection_start} + 1;
                    $self->{selection_start} = undef;
                    $self->{selection_stop}  = undef;
                }
                else {
                    $self->{value} = substr($self->{value}, 0, $self->{cursor})
                                   . chr($event->key_unicode)
                                   . substr($self->{value}, $self->{cursor});
                    $self->{cursor}++;
                }
            }
        }
    }
    elsif(SDL_KEYUP == $event->type) {
        if($self->{focus}) {
            my $key = SDL::Events::get_key_name($event->key_sym);
            warn "on_keyup";
            if($key =~ /\bshift$/) {
                $self->{shiftdown}  = undef;
            }
        }
    }
}

sub DESTROY {
    my $self = shift;
}

1;
