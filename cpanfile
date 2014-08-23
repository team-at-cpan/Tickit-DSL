requires 'parent', 0;
requires 'Exporter', 0;
requires 'List::UtilsBy', 0;

requires 'Tickit', '>= 0.46';
requires 'Tickit::Console', '>= 0.06';
requires 'Tickit::Widgets', '>= 0.12';
requires 'Tickit::Widget::Breadcrumb', '>= 0.001';
requires 'Tickit::Widget::Decoration', '>= 0.001';
requires 'Tickit::Widget::FileViewer', '>= 0.002';
requires 'Tickit::Widget::FloatBox', '>= 0.02';
requires 'Tickit::Widget::Layout::Desktop', '>= 0.003';
requires 'Tickit::Widget::Layout::Relative', '>= 0.003';
requires 'Tickit::Widget::Menu', '>= 0.05';
requires 'Tickit::Widget::Progressbar', '>= 0.002';
requires 'Tickit::Widget::Scroller', '>= 0.12';
requires 'Tickit::Widget::ScrollBox', '>= 0.01';
requires 'Tickit::Widget::SegmentDisplay', '>= 0.01';
requires 'Tickit::Widget::SparkLine', '>= 0.001';
requires 'Tickit::Widget::Statusbar', '>= 0.003';
requires 'Tickit::Widget::Tabbed', '>= 0.010';
requires 'Tickit::Widget::Table', '>= 0.202';
requires 'Tickit::Widget::Tree', '>= 0.103';

on 'test' => sub {
	requires 'Test::More', '>= 0.98';
};

