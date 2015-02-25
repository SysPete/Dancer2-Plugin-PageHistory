use strict;
use warnings;
use Test::More import => ['!pass'];
use Class::Load qw(try_load_class);

my @session_engines = (
#    'Cookie',
    'Simple',
    'DBIC',
    'KiokuDB',
    'Memcached',
    'MongoDB',
    'PSGI',
    'Storable',
    'YAML',
);

{
    use Dancer;
    use Dancer::Plugin::PageHistory;

    set show_errors => 1;
    set logger => 'console';
    set log => 'debug';

    get '/**' => sub {
        my @path = splat;
        return history;
    };
}

sub run_tests {
    my $engine = shift;
    diag "Testing with $engine";

    if ( $engine eq 'Cookie' ) {
        set session_cookie_key => 'notagood secret';
        set session => 'cookie';
    }
    elsif ( $engine eq 'Simple' ) {
        set session => 'Simple';
    }
    else {
        diag "skipping $engine - needs setup config";
        return;
    }

    set plugins => {
        PageHistory => {
            add_all_pages => 1,
            ignore_ajax => 1,
        }
    };

    use Dancer::Test;

    #use Data::Dumper::Concise;
    #print STDERR Dumper(session);

    my $response = dancer_response GET => '/one';
    $response = dancer_response GET => '/two';
    $response = dancer_response GET => '/three';

    use Data::Dumper::Concise;
    print STDERR "content: " . Dumper($response->content);

    ok(1);
}

foreach my $engine ( @session_engines ) {

    my $session_class = "Dancer::Session::$engine";
    unless ( try_load_class($session_class) ) {
        if ( $ENV{RELEASE_TESTING} ) {
            fail "$session_class missing";
        }
        else {
            diag "$session_class missing so not testing this session engine";
        }
        next;
    }
    run_tests( $engine );
    last;#######
}

done_testing;
