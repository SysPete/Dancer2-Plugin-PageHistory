use Test::More;
use Test::Exception;
use Dancer::Plugin::PageHistory::Page;
use Dancer::Plugin::PageHistory::PageSet;
use JSON;

my ( $data, $page, $pages );

lives_ok( sub { $pages = Dancer::Plugin::PageHistory::PageSet->new },
    "PageSet->new with no args" );

isa_ok( $pages, "Dancer::Plugin::PageHistory::PageSet", "pages class" )
  or diag explain $pages;

can_ok( $pages, qw(max_items pages current_page previous_page methods add) );

lives_ok( sub { $page = $pages->current_page }, "get current_page" );

$data = {
    all => [
        {
            '__page__' => {
                'attributes' => { 'foo' => 'bar' },
                'path'       => '/some/path',
                'query' => { 'a' => 123, 'b' => 456 },
                'title' => 'Some page'
            }
        },
        {
            '__page__' =>
              { 'path' => '/another/path', 'title' => 'Another page' }
        },
    ],
    bananas => [
        {
            '__page__' =>
              { 'path' => '/another/path', 'title' => 'Another page' }
        },
    ],
};

lives_ok(
    sub {
        $pages = Dancer::Plugin::PageHistory::PageSet->new(
            max_items => 3,
            methods   => [ 'all', 'bananas' ],
            pages     => $data
        );
    },
    "PageSet->new with args"
);

can_ok( $pages, qw(all bananas) );

is_deeply( [ sort $pages->types ], [qw/all bananas/], "check pages types" );

my $count = 0;
foreach my $type ( $pages->types ) {
    foreach my $page ( @{ $pages->pages->{$type} } ) {
        isa_ok(
            $page,
            "Dancer::Plugin::PageHistory::Page",
            "$type " . $page->path
        ) && $count++
    }
}
cmp_ok( $count, "==", 3, "found 3 pages" );

cmp_ok( @{$pages->bananas}, '==', 1, "one page of bananas via method" );

cmp_ok( $pages->bananas->[0]->path, "eq", "/another/path", "path is good" );

done_testing;
