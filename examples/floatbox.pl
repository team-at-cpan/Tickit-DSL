#!/usr/bin/env perl
use strict;
use warnings;
use Tickit::DSL;

vbox {
	floatbox {
		vbox {
			static 'top line';
			frame {
				$::BT = button {
					float {
						vbox {
							static 'lol hi';
							hbox {
								static 'left';
								static 'right';
							} 'parent:expand' => 1;
						} 'parent:expand' => 1;
					} top => 1, left => 1, bottom => 5, right => 30;
				} 'OK', 'parent:expand' => 1;
			} 'parent:expand' => 1;
			static 'last line';
		} 'parent:expand' => 1;
	}
};
later {
	my $w = $::BT;
	while($w && $w->parent) {
		warn "Widget $w => parent " . $w->parent . ", root is " . tickit->{root_widget};
		$w = $w->parent;
	}
	exit;
} if 0;
tickit->run;
