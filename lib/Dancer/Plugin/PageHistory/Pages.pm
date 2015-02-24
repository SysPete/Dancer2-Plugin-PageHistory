package Dancer::Plugin::PageHistory::Pages;

=head1 NAME

Dancer::Plugin::PageHistory::Pages - Pages store for Dancer::Plugin::PageHistory

=cut

use Moo;
use Scalar::Util qw(blessed);
use Sub::Quote qw(quote_sub);
use Types::Standard qw(ArrayRef HashRef InstanceOf Int);
use namespace::clean;

=head1 ATTRIBUTES

=head2 max_items

The maximum number of each history C<type> stored in L</pages>.

=cut

has max_items => (
    is      => 'ro',
    isa     => Int,
    default => 10,
);

=head2 pages

A hash reference of arrays of hash references.

Primary key is the history C<type> such as C<all> or C<product>. For each 
C<type> an array reference of pages is stored with newest pages added at 
the start of the list.

=cut

has pages => (
    is => 'rw',
    isa =>
      HashRef [ ArrayRef [ InstanceOf ['Dancer::Plugin::PageHistory::Page'] ] ],
    coerce => \&_coerce_pages,
);

sub _coerce_pages {
    while ( my ( $type, $pages ) = each %{ $_[0] } ) {
      PAGE: foreach my $page (@$pages) {
            if ( !blessed($page) && ref($page) eq 'HASH' && $page->{__page__} )
            {
                $page =
                  Dancer::Plugin::PageHistory::Page->new( $page->{__page__} );
            }
        }
    }
    return $_[0];
}

=head2 current_page

Returns the first page from L</pages> of type C<all>.  Returns undef if
L</pages> has no C<type> named C<all>.

=cut

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

=head2 previous_page

Returns the second page from L</pages> of type C<all>. Returns undef if
L</pages> has no C<type> named C<all>.

=cut

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

=head2 methods

An array reference of extra method names that should be added to the class.
For example if one of these method names is 'product' then the following
shortcut method will be added:

    sub product {
        return shift->pages->{"product"};
    }

=cut

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
            quote_sub "Dancer::Plugin::PageHistory::Pages::$method",
              q{ return shift->pages->{$method}; },
              { '$method' => \$method };
        }
    }
}

=head1 METHODS

=head2 add( %args )

If C<$args{type}> is not defined then we die.

In addition to C<type> other arguments should be those passed to C<new> in
L<Dancer::Plugin::PageHistory::Page>.

=cut

sub add {
    my ( $self, %args ) = @_;
    my $type = delete $args{type};

    die "type must be defined for Dancer::Plugin::PageHistory->add"
      unless $type;
    die "path must be defined for Dancer::Plugin::PageHistory->add"
      unless $args{path};

    my $page = Dancer::Plugin::PageHistory::Page->new( %args );

    if (   !$self->pages->{$type}
        || !$self->pages->{$type}->[0]
        || $self->pages->{$type}->[0]->uri ne $page->uri )
    {

        # not same uri as newest items on this list so add it

        unshift( @{ $self->pages->{$type} }, $page );

        # trim to max_items if necessary
        pop @{ $self->pages->{$type} }
          if @{ $self->pages->{$type} } > $self->max_items;
    }
}

=head2 types

Return all of the page types currently stored in history.

In array context returns an array of type names (keys of L</pages>)
and in scalar context returns the same as an array reference.

=cut

sub types {
    my $self = shift;
    wantarray ? keys $self->pages : [ keys $self->pages ];
}

1;
