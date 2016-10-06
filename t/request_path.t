use strict;
use warnings;
use utf8;

BEGIN {
    $ENV{DANCER_CONFDIR} = 't';
}

use Test::More;
use HTTP::Cookies;
use HTTP::Request::Common;
use JSON qw//;
use Plack::Builder;
use Plack::Test;

{
    package TestApp;
    use Dancer2;
    use Dancer2::Plugin::PageHistory;

    set session => 'Simple';

    get '/**' => sub {
        content_type('application/json');
        return to_json( session('page_history') );
    };
}

subtest '... app mounted at /' => sub {
    my $app = TestApp->to_app;

    ok ref($app) eq 'CODE', "Got an app";
    my $test = Plack::Test->create($app);

    my $req = GET "http://localhost/my/path?foo=הלו";
    my $res = $test->request($req);
    ok( $res->is_success, "get /my/path OK" );

    # הלו gets url encoded to %D7%94%D7%9C%D7%95
    is_deeply JSON::from_json( $res->content ),
      {
        default => [
            {
                path         => '/my/path',
                query_string => 'foo=%D7%94%D7%9C%D7%95',
                request_path => '/my/path'
            }
        ]
      },
      "Check PageHistory is OK";
};

subtest '... app mounted at /' => sub {
    my $app = builder {
        mount '/bar/' => TestApp->to_app;
    };

    ok ref($app) eq 'CODE', "Got an app";
    my $test = Plack::Test->create($app);

    my $req = GET "http://localhost/bar/my/path?foo=הלו";
    my $res = $test->request($req);
    ok( $res->is_success, "get /bar/my/path OK" );

    is_deeply JSON::from_json( $res->content ),
      {
        default => [
            {
                path         => '/my/path',
                query_string => 'foo=%D7%94%D7%9C%D7%95',
                request_path => '/bar/my/path'
            }
        ]
      },
      "Check PageHistory is OK";
};

done_testing;
