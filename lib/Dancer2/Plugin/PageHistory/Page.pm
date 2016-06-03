package Dancer2::Plugin::PageHistory::Page;

=head1 NAME

Dancer2::Plugin::PageHistory::Page - Page object for Dancer2::Plugin::PageHistory

=cut

use Moo;
use Dancer2::Core::Types qw(Str HashRef);
use namespace::clean;

=head1 ATTRIBUTES

=head2 attributes

Extra attributes as a hash reference, e.g.: SKU for a product page.

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

=head2 query_string

The original query string

=cut

has query_string => (
    is        => 'ro',
    isa       => Str,
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
    my $uri = $self->path;
    $uri .= '?' . $self->query_string if $self->query_string;
    return "$uri";
}

1;
