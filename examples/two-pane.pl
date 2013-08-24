#!/usr/bin/env perl 
use strict;
use warnings;
use Tickit::DSL;

vbox {
 # Single line menu at the top of the screen
 menubar {
  submenu File => sub {
   menuitem Open  => sub { warn 'open' };
  };
  submenu Edit => sub {
   menuitem Copy  => sub { warn 'copy' };
   menuitem Cut   => sub { warn 'cut' };
   menuitem Paste => sub { warn 'paste' };
  };
  menuspacer;
  submenu Help => sub {
   menuitem About => sub { warn 'about' };
  };
 };
 # A 2-panel layout covers most of the rest of the display
 widget {
  # Left and right panes:
  hbox {
   # A tree on the left, 1/4 total width
   widget {
    tree { };
   } expand => 1;
   # and a tab widget on the right, 3/4 total width
   widget {
    tabbed { };
   } expand => 3;
  } expand => 1;
 } expand => 1;
 # At the bottom of the screen we show the status bar
 statusbar { } show => [qw(clock cpu memory debug)];
};
tickit->run;

