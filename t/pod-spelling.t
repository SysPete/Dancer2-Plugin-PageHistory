use strict;
use warnings;
use Test::More;

unless ( $ENV{RELEASE_TESTING} ) {
    plan( skip_all => "Author tests not required for installation" );
}

eval "use Test::Spelling";
plan skip_all => "Test::Spelling required" if $@;
add_stopwords(<DATA>);
all_pod_files_spelling_ok();

__END__
ajax
CGISession
DBIC
eserte
GH
logout
Mottram
PRs
Redis
Rezić
SKU
Slaven
SysPete
TODO
