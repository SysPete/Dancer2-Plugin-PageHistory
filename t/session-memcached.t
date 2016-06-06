use strict;
use warnings;

use Test::Fatal;
use Test::More;
use lib 't/lib';

BEGIN {
    $ENV{DANCER_ENVIRONMENT} = 'memcached';

    eval 'use Dancer2::Session::Memcached';
    plan skip_all => "Dancer2::Session::Memcached required to run these tests" if $@;
}

use Tests;

Tests::run_tests();

done_testing;
