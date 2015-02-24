package # Hide from PAUSE
  Dancer::Plugin::PageHistory::History;

use Moo;

use MooX::Types::MooseLike::Base qw(ArrayRef HashRef Int);
use Sub::Quote qw(quote_sub);

has max_items => (
    is      => 'ro',
    isa     => Int,
    default => 10,
);

has pages => (
    is  => 'rw',
    isa => HashRef [ ArrayRef [HashRef] ],
);

has current_page => (
    is => 'lazy',
    isa => HashRef,
);

sub _build_current_page {
    my $self = shift;
    if ( defined $self->pages->{all} ) {
        return $self->pages->{all}->[0];
    }
    return undef;
}

has previous_page => (
    is  => 'lazy',
    isa => HashRef,
);

sub _build_previous_page {
    my $self = shift;
    if ( defined $self->pages->{all} ) {
        return $self->pages->{all}->[1];
    }
    return undef;
}

has methods => (
    is      => 'ro',
    isa     => ArrayRef,
    default => sub { [] },
    trigger => 1,
);

sub _trigger_methods {
    my ( $self, $methods ) = @_;
    foreach my $method ( @$methods ) {
        unless ( $self->can( $method )) {
            quote_sub "Angler::History::$method",
              q{ return shift->pages->{$method}; },
              { '$method' => \$method };
        }
    }
}

sub add {
    my ( $self, %args ) = @_;
    my $type = delete $args{type};

    die "type must be defined for Dancer::History->add" unless $type;
    die "uri must be defined for Dancer::History->add"  unless $args{uri};

    if (   !$self->pages->{$type}
        || !$self->pages->{$type}->[0]
        || $self->pages->{$type}->[0]->{uri} ne $args{uri} )
    {

        # not same uri as newest items on this list so add it

        unshift( @{ $self->pages->{$type} }, \%args );

        # trim to max_items if necessary
        pop @{ $self->pages->{$type} }
          if @{ $self->pages->{$type} } > $self->max_items;
    }
}
package Dancer::Plugin::PageHistory;

use Dancer ':syntax';
use Dancer::Plugin;


register_plugin;
1;
