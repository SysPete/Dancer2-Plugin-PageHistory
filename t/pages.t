use Test::More;
use Test::Exception;
use Dancer::Plugin::PageHistory::Page;
use Dancer::Plugin::PageHistory::Pages;
use JSON;

my ( $data, $page, $pages );

lives_ok( sub { $pages = Dancer::Plugin::PageHistory::Pages->new },
    "Pages->new with no args" );

isa_ok( $pages, "Dancer::Plugin::PageHistory::Pages", "pages class" )
  or diag explain $pages;

can_ok( $pages, qw(max_items pages current_page previous_page methods add) );

done_testing;
