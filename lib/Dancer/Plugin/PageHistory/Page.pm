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
);

=head2 title

Page title.

=cut

has title => (
    is        => 'ro',
    isa       => Str,
    predicate => 1,
);

=head1 METHODS

=head2 predicates

The following predicate methods are defined:

=over

=item * has_attributes

=item * has_title

=back

=head2 uri

Returns the string URI for L</path> and L</query>.

=cut

sub uri {
    my $self = shift;
    my $uri = URI->new( $self->path );
    $uri->query_form($self->query);
    return $uri->as_string;
}

=head2 STORABLE_freeze

Convert to non-obj for Storable serialisation.

=cut

sub STORABLE_freeze {
    my ($self, $cloning) = @_;
    return if $cloning;
    return (undef, $self->to_hashref);
}

=head2 STORABLE_thaw

Thaw from Storable.

=cut

sub STORABLE_thaw {
    my ($self, $cloning, undef, $data) = @_;
    return if $cloning;
    %{$self} = %$data;
}

=head2 TO_JSON

Convert to non-obj for JSON serialisation.

=cut

sub TO_JSON {
    return shift->to_hashref;
}

=head2 to_hashref

Convert to hash reference for use by other serializer methods.

=cut

sub to_hashref {
    my $self = shift;
    my %ret = ( path => $self->path );

    $ret{attributes} = $self->attributes if $self->has_attributes;
    $ret{query}      = $self->query;
    $ret{title}      = $self->title      if $self->has_title;
    return \%ret;
}

1;
