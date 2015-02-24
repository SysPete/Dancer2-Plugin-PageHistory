use Test::Roo;
use Class::Load qw(try_load_class);

my @session_engines = qw(
    Cookie
    Simple
    DBIC
    KiokuDB
    Memcached
    MongoDB
    PSGI
    Storable
    YAML
);

has session_engine => (
    is       => 'ro',
    required => 1,
);

test page => sub {
    my $self = shift;

    ok(1);

};

foreach my $engine ( @session_engines ) {

    my $session_class = "Dancer::Session::$engine";
    unless ( try_load_class($session_class) ) {
        diag "$session_class missing so not testing this session engine";
        next;
    }
    run_me("Testing $session_class", { session_engine => $engine });
}

done_testing;
