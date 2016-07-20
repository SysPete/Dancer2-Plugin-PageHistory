use strict;
use warnings;

use Test::Fatal;
use Test::More;
use lib 't/lib';

BEGIN {
    eval 'use Dancer2::Session::CGISession';
    plan skip_all => "Dancer2::Session::CGISession required to run these tests" if $@;
}

use Tests;

diag "Dancer2::Session::CGISession $Dancer2::Session::CGISession::VERSION";

Tests::run_tests( { session => 'CGISession' } );

done_testing;
