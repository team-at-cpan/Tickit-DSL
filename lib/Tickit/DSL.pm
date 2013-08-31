package Tickit::DSL;
# ABSTRACT: shortcuts for writing Tickit apps
use strict;
use warnings;
use parent qw(Exporter);

our $VERSION = '0.001_001';

=head1 NAME

Tickit::DSL - domain-specific language for Tickit terminal apps

=head1 SYNOPSIS

 use Tickit::DSL;
 vbox {
  hbox { static 'left' } expand => 1;
  hbox { static 'right' } expand => 1;
 }

=head1 DESCRIPTION

Provides a simplified interface for writing Tickit applications. This is
mainly intended for prototyping:

# EXAMPLE: examples/two-pane.pl

=cut

use Tickit::Widget::Border;
use Tickit::Widget::Box;
use Tickit::Widget::Button;
use Tickit::Widget::CheckButton;
use Tickit::Widget::Entry;
use Tickit::Widget::Frame;
use Tickit::Widget::GridBox;
use Tickit::Widget::HBox;
use Tickit::Widget::HSplit;
use Tickit::Widget::Menu;
use Tickit::Widget::MenuBar;
use Tickit::Widget::Menu::Item;
use Tickit::Widget::Placegrid;
use Tickit::Widget::Progressbar;
use Tickit::Widget::RadioButton;
use Tickit::Widget::Scroller;
use Tickit::Widget::Scroller::Item::Text;
use Tickit::Widget::ScrollBox;
use Tickit::Widget::SegmentDisplay;
use Tickit::Widget::SparkLine;
use Tickit::Widget::Spinner;
use Tickit::Widget::Static;
use Tickit::Widget::Statusbar;
use Tickit::Widget::Tabbed;
use Tickit::Widget::Table;
use Tickit::Widget::Table::Paged;
use Tickit::Widget::Tree;
use Tickit::Widget::VBox;
use Tickit::Widget::VSplit;

use List::UtilsBy qw(extract_by);

our $MODE;
our $PARENT;
our @PENDING_CHILD;
our $TICKIT;
our $LOOP;
our @WIDGET_ARGS;
our $GRID_COL;
our $GRID_ROW;

our @EXPORT = our @EXPORT_OK = qw(
	tickit later loop
	widget customwidget
	add_widgets
	gridbox gridrow
	vbox hbox
	vsplit hsplit
	static entry
	scroller scroller_text
	tabbed
	tree
	table
	placeholder
	statusbar
	menubar submenu menuitem menuspacer
);

sub import {
	my $class = shift;
	my ($mode) = extract_by { /^:a?sync$/ } @_;
	if($MODE && $mode && $mode ne $MODE) {
		die "Cannot mix sync/async - we are already $MODE and were requested to switch to $mode";
	} elsif($mode) {
		$MODE = $mode;
	}
	$MODE ||= ':sync';
	if($MODE eq ':sync') {
		require Tickit;
	} elsif($MODE eq ':async') {
		require IO::Async::Loop;
		require Tickit::Async;
	} else {
		die "Unknown mode: $MODE";
	}
    $class->export_to_level(1, $class, @_);
}
=head1 FUNCTIONS

All of these are exported unless otherwise noted.

=cut

sub loop {
	die "No loop available when running as $MODE" unless $MODE eq ':async';
	$LOOP = shift if @_;
	$LOOP ||= IO::Async::Loop->new
}

sub tickit {
	$TICKIT = shift if @_;
	return $TICKIT if $TICKIT;

	if($MODE eq ':async') {
		$TICKIT = Tickit::Async->new;
		loop->add($TICKIT);
	} else {
		$TICKIT ||= Tickit->new;
	}
	$TICKIT
}

sub later(&) {
	my $code = shift;
	tickit->later($code)
}

sub add_widgets(&@) {
	my $code = shift;
	my %args = @_;
	local $PARENT = delete $args{under} or die 'expected add_widgets { ... } under => $some_widget;';
	local @WIDGET_ARGS = %args;
	$code->($PARENT);
}

sub vbox(&@) {
	my ($code, %args) = @_;
	my $w = Tickit::Widget::VBox->new;
	{
		local $PARENT = $w;
		$code->($w);
	}
	apply_widget($w);
}

sub vsplit(&@) {
	my ($code, %args) = @_;
	my $w = do {
		local $PARENT = 'Tickit::Widget::VSplit';
		local @PENDING_CHILD;
		$code->();
		Tickit::Widget::VSplit->new(
			left_child  => $PENDING_CHILD[0],
			right_child => $PENDING_CHILD[1],
		);
	};
	apply_widget($w);
}

sub gridbox(&@) {
	my ($code, %args) = @_;
	my $w = Tickit::Widget::GridBox->new;
	{
		local $PARENT = $w;
		local $GRID_COL = 0;
		local $GRID_ROW = 0;
		$code->($w);
	}
	apply_widget($w);
}

sub gridrow(&@) {
	my ($code, %args) = @_;
	die "Grid rows must be in a gridbox" unless $PARENT->isa('Tickit::Widget::GridBox');
	apply_widget($code->($PARENT));
	$GRID_COL = 0;
	++$GRID_ROW;
}

sub hbox(&@) {
	my ($code, %args) = @_;
	my $w = Tickit::Widget::HBox->new;
	{
		local $PARENT = $w;
		$code->($w);
	}
	apply_widget($w);
}

sub hsplit(&@) {
	my ($code, %args) = @_;
	my $w = do {
		local $PARENT = 'Tickit::Widget::HSplit';
		local @PENDING_CHILD;
		$code->();
		Tickit::Widget::HSplit->new(
			top_child    => $PENDING_CHILD[0],
			bottom_child => $PENDING_CHILD[1],
		);
	};
	apply_widget($w);
}

sub scroller(&@) {
	my ($code, %args) = @_;
	my $w = Tickit::Widget::Scroller->new;
	{
		local $PARENT = $w;
		$code->($w);
	}
	apply_widget($w);
}

sub scroller_text {
	my $w = Tickit::Widget::Scroller::Item::Text->new(shift // '');
	apply_widget($w);
}

sub tabbed(&@) {
	my ($code, %args) = @_;
	my $w = Tickit::Widget::Tabbed->new;
	{
		local $PARENT = $w;
		$code->($w);
	}
	apply_widget($w);
}

sub statusbar(&@) {
	my ($code, %args) = @_;
	my $w = Tickit::Widget::Statusbar->new;
	{
		local $PARENT = $w;
		$code->($w);
	}
	apply_widget($w);
}

sub widget(&@) {
	my ($code, @args) = @_;
	my %args = @args;
	local $PARENT = delete($args{parent}) || $PARENT;
	{
		local @WIDGET_ARGS = @args;
		$code->($PARENT);
	}
}

sub customwidget(&@) {
	my ($code, @args) = @_;
	my %args = @args;
	local $PARENT = delete($args{parent}) || $PARENT;
	my $w = $code->($PARENT);
	{
		local @WIDGET_ARGS = %args;
		apply_widget($w);
	}
}

sub static {
	my %args = (text => @_);
	$args{text} //= '';
	my $w = Tickit::Widget::Static->new(
		%args
	);
	apply_widget($w);
}

sub entry(&@) {
	my %args = (on_enter => @_);
	my $w = Tickit::Widget::Entry->new(
		%args
	);
	apply_widget($w);
}

sub tree(&@) {
	my %args = (on_enter => @_);
	my $w = Tickit::Widget::Tree->new(
		%args
	);
	apply_widget($w);
}

sub placeholder() {
	apply_widget(Tickit::Widget::Placegrid->new);
}

sub menubar(&@) {
	my ($code, %args) = @_;
	my $w = Tickit::Widget::MenuBar->new;
	{
		local $PARENT = $w;
		$code->($w);
	}
	apply_widget($w);
}

sub submenu {
	my ($text, $code) = splice @_, 0, 2;
	my $w = Tickit::Widget::Menu->new(name => $text);
	{
		local $PARENT = $w;
		$code->($w);
	}
	apply_widget($w);
}

sub menuspacer() {
	my $w = Tickit::Widget::Menu->separator;
#	local @WIDGET_ARGS = (expand => 1);
	apply_widget($w);
}

sub menuitem {
	my ($text, $code) = splice @_, 0, 2;
	my $w = Tickit::Widget::Menu::Item->new(
		name        => $text,
		on_activate => $code,
	);
	apply_widget($w);
}

sub apply_widget {
	my $w = shift;
	if($PARENT) {
		if($PARENT->isa('Tickit::Widget::Scroller')) {
			$PARENT->push($w);
		} elsif($PARENT->isa('Tickit::Widget::Menu')) {
			$PARENT->push_item($w, @WIDGET_ARGS);
		} elsif($PARENT->isa('Tickit::Widget::MenuBar')) {
			$PARENT->push_item($w, @WIDGET_ARGS);
		} elsif($PARENT->isa('Tickit::Widget::HSplit')) {
			push @PENDING_CHILD, $w;
		} elsif($PARENT->isa('Tickit::Widget::VSplit')) {
			push @PENDING_CHILD, $w;
		} elsif($PARENT->isa('Tickit::Widget::Tabbed')) {
			$PARENT->add_tab($w, @WIDGET_ARGS);
		} elsif($PARENT->isa('Tickit::Widget::GridBox')) {
			$PARENT->add($GRID_ROW, $GRID_COL++, $w, @WIDGET_ARGS);
		} else {
			$PARENT->add($w, @WIDGET_ARGS);
		}
	} else {
		tickit->set_root_widget($w);
	}
	$w
}

1;

__END__

=head1 SEE ALSO

=over 4

=item * L<Tickit::Widget::Border>

=item * L<Tickit::Widget::Box>

=item * L<Tickit::Widget::Button>

=item * L<Tickit::Widget::CheckButton>

=item * L<Tickit::Widget::Entry>

=item * L<Tickit::Widget::Frame>

=item * L<Tickit::Widget::GridBox>

=item * L<Tickit::Widget::HBox>

=item * L<Tickit::Widget::HSplit>

=item * L<Tickit::Widget::Menu>

=item * L<Tickit::Widget::Placegrid>

=item * L<Tickit::Widget::Progressbar>

=item * L<Tickit::Widget::RadioButton>

=item * L<Tickit::Widget::Scroller>

=item * L<Tickit::Widget::Scroller::Item::Text>

=item * L<Tickit::Widget::ScrollBox>

=item * L<Tickit::Widget::SegmentDisplay>

=item * L<Tickit::Widget::SparkLine>

=item * L<Tickit::Widget::Static>

=item * L<Tickit::Widget::Statusbar>

=item * L<Tickit::Widget::Tabbed>

=item * L<Tickit::Widget::Table>

=item * L<Tickit::Widget::Tree>

=item * L<Tickit::Widget::VBox>

=item * L<Tickit::Widget::VSplit>

=back

=head1 AUTHOR

Tom Molesworth <cpan@entitymodel.com>

=head1 LICENSE

Copyright Tom Molesworth 2012-2013. Licensed under the same terms as Perl itself.

