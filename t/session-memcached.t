use strict;
use warnings;

use Test::Fatal;
use Test::More;
use lib 't/lib';

BEGIN {
    $ENV{DANCER_ENVIRONMENT} = 'memcached';

    eval 'use Dancer2::Session::Memcached 0.003';
    plan skip_all => "Dancer2::Session::Memcached >= 0.003 required to run these tests" if $@;
}

diag "Dancer2::Session::Memcached $Dancer2::Session::Memcached::VERSION";

use Tests;

Tests::run_tests();

done_testing;
