use Test::Roo;
use Test::Exception;
use Dancer qw(:tests !after);
use Dancer::Plugin::PageHistory::Page;

test page => sub {
    my $self = shift;

    my ( $page );

    throws_ok( sub { $page = Dancer::Plugin::PageHistory::Page->new },
        qr/Missing required arguments: path/, "Page->new with no args" );
    
    throws_ok(
        sub { $page = Dancer::Plugin::PageHistory::Page->new( path => {} ) },
        qr/did not pass type constraint/,
        "Page->new bad type for path"
    );
    
    throws_ok(
        sub {
            $page = Dancer::Plugin::PageHistory::Page->new(
                path  => '/',
                query => ''
            );
        },
        qr/did not pass type constraint/,
        "Page->new bad query"
    );
    
    throws_ok(
        sub {
            $page = Dancer::Plugin::PageHistory::Page->new(
                path  => '/',
                attributes => ''
            );
        },
        qr/did not pass type constraint/,
        "Page->new bad attributes"
    );
    
    throws_ok(
        sub {
            $page = Dancer::Plugin::PageHistory::Page->new(
                path  => '/',
                title => {}
            );
        },
        qr/did not pass type constraint/,
        "Page->new bad title"
    );
    
};

run_me;

done_testing;
