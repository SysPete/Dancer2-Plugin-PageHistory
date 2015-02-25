package Dancer::Plugin::PageHistory::Page;

=head1 NAME

Dancer::Plugin::PageHistory::Page - Page object for Dancer::Plugin::PageHistory

=cut

use Moo;
use Types::Standard qw(Str HashRef);
use URI;
use namespace::clean;

=head1 ATTRBIUTES

=head2 attributes

Extra attributes as a hash refence, e.g.: SKU for a product page.

=cut

has attributes => (
    is        => 'ro',
    isa       => HashRef,
    predicate => 1,
);

=head2 path

Absolute path of the page. This is the only required attribute.

=cut

has path => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

=head2 query

Query parameters as a hash reference.

=cut

has query => (
    is        => 'ro',
    isa       => HashRef,
    predicate => 1,
);

=head2 title

Page title.

=cut

has title => (
    is        => 'ro',
    isa       => Str,
    predicate => 1,
);

=head2 uri

This does not need to be supplied to C<new> since it is constructed lazily
from L</path> and L</query>.

B<WARNING:> This attribute is not saved back to the session.

=cut

has uri => (
    is => 'lazy',
);

sub _build_uri {
    my $self = shift;
    my $uri = URI->new( $self->path );
    $uri->query_form($self->query);
    return $uri;
}

=head1 METHODS

=head2 predicates

The following predicates are defined:

=over

=item * has_attributes

=item * has_title

=item * has_query

=back

=head2 STORABLE_freeze

Convert to non-obj for Storable serialisation.

=cut

sub STORABLE_freeze {
    my ($self, $cloning) = @_;
    return if $cloning;
    return $self->TO_JSON;
}

=head2 TO_JSON

Convert to non-obj for JSON serialisation.

=cut

sub TO_JSON {
    my $self = shift;
    my %ret = ( path => $self->path );

    $ret{attributes} = $self->attributes if $self->has_attributes;
    $ret{query}      = $self->query      if $self->has_query;
    $ret{title}      = $self->title      if $self->has_title;

    return { __page__ => \%ret };
}

1;
