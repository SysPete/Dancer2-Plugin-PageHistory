use strict;
use warnings;

use Test::Fatal;
use Test::More;
use lib 't/lib';

BEGIN {
    eval 'use Dancer2::Session::JSON';
    plan skip_all => "Dancer2::Session::JSON required to run these tests" if $@;
}

use Tests;

Tests::run_tests( { session => 'JSON' } );

done_testing;
