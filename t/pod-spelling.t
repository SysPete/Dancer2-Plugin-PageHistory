use strict;
use warnings;
use Test::More;

unless ( $ENV{RELEASE_TESTING} ) {
    plan( skip_all => "Author tests not required for installation" );
}

use Test::Spelling;
add_stopwords(<DATA>);
all_pod_files_spelling_ok();

__END__
ajax
DBIC
Mottram
PRs
SKU
SysPete
TODO
