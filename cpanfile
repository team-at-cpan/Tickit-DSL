requires 'parent', 0;
requires 'Exporter', 0;
requires 'List::UtilsBy', 0;

requires 'Tickit', '>= 0.50';
requires 'Tickit::Widgets', '>= 0.19';
requires 'Tickit::Widget::Breadcrumb', '>= 0.003';
requires 'Tickit::Widget::Decoration', '>= 0.004';
requires 'Tickit::Widget::FileViewer', '>= 0.004';
requires 'Tickit::Widget::FloatBox', '>= 0.02';
requires 'Tickit::Widget::Layout::Desktop', '>= 0.009';
requires 'Tickit::Widget::Layout::Relative', '>= 0.005';
requires 'Tickit::Widget::LogAny', '>= 0.004';
requires 'Tickit::Widget::Menu', '>= 0.08';
requires 'Tickit::Widget::Progressbar', '>= 0.101';
requires 'Tickit::Widget::Scroller', '>= 0.18';
requires 'Tickit::Widget::ScrollBox', '>= 0.03';
requires 'Tickit::Widget::SegmentDisplay', '>= 0.02';
requires 'Tickit::Widget::SparkLine', '>= 0.104';
requires 'Tickit::Widget::Statusbar', '>= 0.004';
requires 'Tickit::Widget::Tabbed', '>= 0.017';
requires 'Tickit::Widget::Table', '>= 0.214';
requires 'Tickit::Widget::Tree', '>= 0.113';

recommends 'Tickit::Async', 0;
recommends 'Tickit::Console', '>= 0.06';

on 'test' => sub {
	requires 'Test::More', '>= 0.98';
};

