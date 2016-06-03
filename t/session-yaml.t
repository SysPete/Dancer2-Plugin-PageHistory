use strict;
use warnings;

use Test::Fatal;
use Test::More;
use lib 't/lib';

BEGIN {
    eval 'use Dancer2::Session::YAML';
    plan skip_all => "Dancer2::Session::YAML required to run these tests" if $@;
}

use Tests;

Tests::run_tests( { session => 'YAML' } );

done_testing;
