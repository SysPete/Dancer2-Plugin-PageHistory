use strict;
use warnings;

use Test::Fatal;
use Test::More;
use lib 't/lib';

BEGIN {
    $ENV{DANCER_ENVIRONMENT} = 'redis';

    eval 'use Dancer2::Session::Redis';
    plan skip_all => "Dancer2::Session::Redis required to run these tests" if $@;
}

use Tests;

Tests::run_tests();

done_testing;
