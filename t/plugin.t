use strict;
use warnings;
use Test::More import => ['!pass'];
use Test::Exception;
use Class::Load qw(try_load_class);
use File::Spec;
use File::Temp;
use Dancer qw(:tests);

use lib File::Spec->catdir( 't', 'TestApp', 'lib' );
use TestApp;

BEGIN {
    $ENV{DANCER_APPDIR} =
      File::Spec->rel2abs( File::Spec->catdir( 't', 'TestApp' ) );
}

my $release = $ENV{RELEASE_TESTING};

use Data::Dumper::Concise;

#set logger => 'console';
#set log => 'debug';

# not yet supported: KiokuDB Memcached MongoDB PSGI
my @session_engines = (
    qw/
      Cookie DBIC Simple Storable YAML
      /
);

sub fail_or_diag {
    my $msg = shift;
    if ( $release ) {
        fail $msg;
    }
    else {
        diag $msg;
    }
}

sub run_tests {
    my $engine = shift;
    note "Testing with $engine";

    my ( $history, $resp );

    if ( $engine eq 'Cookie' ) {
        set session_cookie_key => 'notagood secret';
        set session            => 'cookie';
    }
    elsif ( $engine eq 'DBIC' ) {
        unless ( try_load_class('Dancer::Plugin::DBIC') ) {
            &fail_or_diag("Dancer::Plugin::DBIC needed for this test");
            return;
        }
        unless ( try_load_class('DBD::SQLite') ) {
            &fail_or_diag("Dancer::Plugin::DBIC needed for this test");
        }
        use Dancer::Plugin::DBIC;
        use TestApp::Schema;
        schema->deploy;
        set session => 'DBIC';
        set session_options => { schema => schema };
    }
    elsif ( $engine eq 'MongoDB' ) {
        my $conn;
        eval { $conn = MongoDB::Connection->new; };
        if ($@) {
            &fail_or_diag("MongoDB needs to be running for this test.");
            return;
        }
        set mongodb_session_db => 'test_dancer_plugin_pagehistory';
        set mongodb_auto_reconnect => 0;
        set session => 'MongoDB';
        my $engine;
        lives_ok( sub { $engine = Dancer::Session::MongoDB->create },
            "create mongodb" );
    }
    elsif ( $engine eq 'Simple' ) {
        set session => 'Simple';
    }
    elsif ( $engine eq 'Storable' ) {
        set session => 'Storable';
    }
    elsif ( $engine eq 'YAML' ) {
        set session => 'YAML';
    }

    use Dancer::Test;

    # var page_history is available here due to the nastiness of Dancer::Test
    # so to make sure the code is behaving we need to undef it before we
    # make a request

    var page_history => undef;
    $resp = dancer_response GET => '/one';
    response_status_is $resp => 200, 'GET /one status is ok';

    isa_ok( session, "Dancer::Session::$engine" );

    $history = $resp->content;
    cmp_ok( @{ $history->default }, '==', 1, "1 page type default" );
    cmp_ok( $history->current_page->uri, "eq", "/one", "current_page OK" );
    ok( !defined $history->previous_page, "previous_page undef" );

    var page_history => undef;
    $resp = dancer_response GET => '/two';
    response_status_is $resp => 200, 'GET /two status is ok';

    $history = $resp->content;
    cmp_ok( @{ $history->default }, '==', 2, "2 pages type default" );
    cmp_ok( $history->current_page->uri, "eq", "/two", "current_page OK" );
    cmp_ok( $history->previous_page->uri, "eq", "/one", "previous_page OK" );

    var page_history => undef;
    $resp = dancer_response GET => '/three?q=we';
    response_status_is $resp => 200, 'GET /three?q=we status is ok';

    $history = $resp->content;
    cmp_ok( @{ $history->default }, '==', 3, "3 pages type default" );
    cmp_ok( $history->current_page->uri,
        "eq", "/three?q=we", "current_page OK" );
    cmp_ok( $history->previous_page->uri, "eq", "/two", "previous_page OK" );

    if ( $engine eq 'Cookie' ) {
        # ugly hack
        set session_cookie_key => 'anewsecret';
    }
    lives_ok( sub { session->destroy }, "destroy session" );

    var page_history => undef;
    $resp = dancer_response GET => '/one';
    response_status_is $resp => 200, 'GET /one status is ok';

    $history = $resp->content;
    cmp_ok( @{ $history->default }, '==', 1, "1 page type default" );
    cmp_ok( $history->current_page->uri, "eq", "/one", "current_page OK" );
    ok( !defined $history->previous_page, "previous_page undef" );

}

foreach my $engine (@session_engines) {

    my $session_class = "Dancer::Session::$engine";
    unless ( try_load_class($session_class) ) {
        if ( $release ) {
            fail "$session_class missing";
        }
        else {
            diag "$session_class missing so not testing this session engine";
        }
        next;
    }
    run_tests($engine);
}

done_testing;
