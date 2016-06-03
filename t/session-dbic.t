use strict;
use warnings;

use Test::Fatal;
use Test::More;
use lib 't/lib';

BEGIN {
    $ENV{DANCER_ENVIRONMENT} = 'dbic';

    eval 'use DBIx::Class';
    plan skip_all => "DBIx::Class required to run these tests" if $@;

    eval 'use DBD::SQLite';
    plan skip_all => "DBD::SQLite required to run these tests" if $@;

    eval 'use DBICx::Sugar';
    plan skip_all => "DBICx::Sugar required to run these tests" if $@;
}

BEGIN {
    use DBICx::Sugar qw(schema);

    DBICx::Sugar::config(
        {
            default => {
                dsn          => "dbi:SQLite:dbname=:memory:",
                schema_class => "TestApp::Schema"
            }
        }
    );

    is exception { schema->deploy }, undef, "Deploy DBIC schema lives";
}

use Tests;
Tests::run_tests();

done_testing;
